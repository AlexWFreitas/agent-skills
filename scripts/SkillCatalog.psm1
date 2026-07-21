#requires -Version 5.1

Set-StrictMode -Version 2.0
$script:NamePattern = '^[a-z0-9]+(?:-[a-z0-9]+)*$'
$script:TopLevelFields = @('name', 'description', 'license', 'compatibility', 'metadata', 'allowed-tools')

function Get-NormalizedPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    [System.IO.Path]::GetFullPath($Path).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
}

function Test-SamePath {
    param([string]$Left, [string]$Right)
    [string]::Equals((Get-NormalizedPath $Left), (Get-NormalizedPath $Right), [System.StringComparison]::OrdinalIgnoreCase)
}

function Test-StrictChildPath {
    param([string]$Parent, [string]$Child)
    $parentPath = (Get-NormalizedPath $Parent) + [System.IO.Path]::DirectorySeparatorChar
    $childPath = Get-NormalizedPath $Child
    $childPath.StartsWith($parentPath, [System.StringComparison]::OrdinalIgnoreCase)
}

function Test-PathsOverlap {
    param([string]$Left, [string]$Right)
    (Test-SamePath $Left $Right) -or (Test-StrictChildPath $Left $Right) -or (Test-StrictChildPath $Right $Left)
}

function Assert-NoReparseAncestor {
    param([Parameter(Mandatory = $true)][string]$Path)
    $candidate = Get-NormalizedPath $Path
    while (-not [string]::IsNullOrWhiteSpace($candidate)) {
        if (Test-Path -LiteralPath $candidate) {
            $item = Get-Item -LiteralPath $candidate -Force -ErrorAction Stop
            if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
                throw "Destination path traverses a reparse point: $candidate"
            }
        }
        $parent = Split-Path -Parent $candidate
        if ([string]::IsNullOrWhiteSpace($parent) -or (Test-SamePath $parent $candidate)) { break }
        $candidate = $parent
    }
}

function Get-SafeTreeItems {
    param([Parameter(Mandatory = $true)][string]$Root)
    $rootPath = Get-NormalizedPath $Root
    $pending = New-Object System.Collections.ArrayList
    [void]$pending.Add((Get-Item -LiteralPath $rootPath -Force -ErrorAction Stop))
    $items = New-Object System.Collections.ArrayList
    while ($pending.Count -gt 0) {
        $item = $pending[$pending.Count - 1]
        $pending.RemoveAt($pending.Count - 1)
        if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw "Reparse point is not allowed: $($item.FullName)"
        }
        [void]$items.Add($item)
        if ($item.PSIsContainer) {
            foreach ($child in @(Get-ChildItem -LiteralPath $item.FullName -Force -ErrorAction Stop)) {
                [void]$pending.Add($child)
            }
        }
    }
    @($items)
}

function ConvertFrom-SimpleScalar {
    param([string]$Value, [string]$Location)
    $text = $Value.Trim()
    if ($text.Length -eq 0) { throw "$Location must have a scalar value." }
    if ($text -match '^[>|{\[&*!]' -or $text -match '(^|\s)[&*!][A-Za-z0-9_-]+') { throw "$Location uses unsupported advanced YAML syntax." }
    if ($text[0] -eq "'") {
        if ($text.Length -lt 2 -or $text[$text.Length - 1] -ne "'") { throw "$Location has malformed single quotes." }
        return $text.Substring(1, $text.Length - 2).Replace("''", "'")
    }
    if ($text[0] -eq '"') {
        if ($text.Length -lt 2 -or $text[$text.Length - 1] -ne '"') { throw "$Location has malformed double quotes." }
        try { return [System.Text.RegularExpressions.Regex]::Unescape($text.Substring(1, $text.Length - 2)) }
        catch { throw "$Location has an invalid quoted scalar: $($_.Exception.Message)" }
    }
    if ($text -match '(^|\s)#' -or $text -match ':\s') {
        throw "$Location must quote values containing comments or ': '."
    }
    $text
}

function Read-SkillFrontmatter {
    param([Parameter(Mandatory = $true)][string]$SkillFile)
    $lines = @(Get-Content -LiteralPath $SkillFile -ErrorAction Stop)
    if ($lines.Count -lt 3 -or $lines[0].Trim() -ne '---') { throw 'SKILL.md must begin with YAML frontmatter delimited by ---.' }
    $closing = -1
    for ($i = 1; $i -lt $lines.Count; $i++) {
        if ($lines[$i].Trim() -eq '---') { $closing = $i; break }
    }
    if ($closing -lt 0) { throw 'SKILL.md frontmatter has no closing --- delimiter.' }
    $values = @{}
    $metadata = @{}
    $inMetadata = $false
    for ($i = 1; $i -lt $closing; $i++) {
        $line = $lines[$i]
        $location = "frontmatter line $($i + 1)"
        if ($line.Contains("`t")) { throw "$location contains a tab; use spaces." }
        if ($line.Trim().Length -eq 0 -or $line.TrimStart().StartsWith('#')) { continue }
        if ($line -match '^  ([A-Za-z0-9_.-]+):\s*(.*)$') {
            if (-not $inMetadata) { throw "$location is indented outside metadata." }
            $key = $matches[1]
            if ($metadata.ContainsKey($key)) { throw "$location duplicates metadata key '$key'." }
            $metadata[$key] = ConvertFrom-SimpleScalar $matches[2] "$location metadata.$key"
            continue
        }
        if ($line -match '^\s') { throw "$location must be top-level or a two-space metadata entry." }
        if ($line -notmatch '^([A-Za-z0-9-]+):\s*(.*)$') { throw "$location is not a supported key/value field." }
        $key = $matches[1]
        $rawValue = $matches[2]
        if ($script:TopLevelFields -notcontains $key) { throw "$location uses unknown top-level field '$key'." }
        if ($values.ContainsKey($key)) { throw "$location duplicates top-level field '$key'." }
        if ($key -eq 'metadata') {
            if ($rawValue.Trim().Length -ne 0) { throw "$location metadata must be an indented string map." }
            $values[$key] = $metadata
            $inMetadata = $true
        }
        else {
            $values[$key] = ConvertFrom-SimpleScalar $rawValue "$location $key"
            $inMetadata = $false
        }
    }
    [pscustomobject]@{ Values = $values; Body = @($lines[($closing + 1)..($lines.Count - 1)]); LineCount = $lines.Count }
}

function Add-LocalReferenceDiagnostics {
    param([string]$SkillRoot, [string]$Text, [System.Collections.ArrayList]$Errors)
    $matches = [regex]::Matches($Text, '\[[^\]]*\]\(([^)]+)\)|`((?:scripts|references|assets)[\\/][^`]+)`')
    foreach ($match in $matches) {
        $reference = if ($match.Groups[1].Success) { $match.Groups[1].Value } else { $match.Groups[2].Value }
        $reference = ($reference -split '#', 2)[0]
        if ([string]::IsNullOrWhiteSpace($reference) -or $reference -match '^[a-zA-Z][a-zA-Z0-9+.-]*:') { continue }
        try {
            $resolved = Get-NormalizedPath (Join-Path $SkillRoot ([uri]::UnescapeDataString($reference)))
            if (-not (Test-StrictChildPath $SkillRoot $resolved) -or -not (Test-Path -LiteralPath $resolved)) {
                [void]$Errors.Add("Broken or escaping local reference: $reference")
            }
        }
        catch { [void]$Errors.Add("Invalid local reference '$reference': $($_.Exception.Message)") }
    }
}

function Test-OpenAiMetadata {
    param([string]$SkillRoot, [System.Collections.ArrayList]$Errors, [System.Collections.ArrayList]$Warnings)
    $path = Join-Path $SkillRoot 'agents\openai.yaml'
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        [void]$Warnings.Add('Optional Codex metadata agents/openai.yaml is absent.')
        return
    }
    $allowedSections = @('interface', 'policy')
    $allowedFields = @{
        interface = @('display_name', 'short_description', 'default_prompt', 'icon_small', 'icon_large', 'brand_color')
        policy = @('allow_implicit_invocation')
    }
    $currentSection = $null
    $lineNumber = 0
    foreach ($line in @(Get-Content -LiteralPath $path)) {
        $lineNumber++
        if ($line.Contains("`t")) { [void]$Errors.Add("agents/openai.yaml line $lineNumber contains a tab."); continue }
        if ($line.Trim().Length -eq 0 -or $line.TrimStart().StartsWith('#')) { continue }
        if ($line -match '^([A-Za-z0-9_-]+):\s*$') {
            $currentSection = $matches[1]
            if ($allowedSections -notcontains $currentSection) { [void]$Warnings.Add("Unrecognized Codex metadata section '$currentSection'.") }
            continue
        }
        if ($line -notmatch '^  ([A-Za-z0-9_-]+):\s*(.+)$') {
            [void]$Errors.Add("agents/openai.yaml line $lineNumber is outside the supported two-level scalar profile.")
            continue
        }
        $field = $matches[1]
        $rawValue = $matches[2]
        if (-not $currentSection) { [void]$Errors.Add("agents/openai.yaml field '$field' has no parent section."); continue }
        if ($allowedFields.ContainsKey($currentSection) -and $allowedFields[$currentSection] -notcontains $field) {
            [void]$Warnings.Add("Unrecognized Codex metadata field '$currentSection.$field'.")
        }
        try { $value = ConvertFrom-SimpleScalar $rawValue "agents/openai.yaml line $lineNumber" }
        catch { [void]$Errors.Add($_.Exception.Message); continue }
        if ($currentSection -eq 'policy' -and $field -eq 'allow_implicit_invocation' -and $value -notin @('true', 'false')) {
            [void]$Errors.Add('agents/openai.yaml policy.allow_implicit_invocation must be true or false.')
        }
        if ($currentSection -eq 'interface' -and $field -in @('icon_small', 'icon_large')) {
            $assetPath = Get-NormalizedPath (Join-Path $SkillRoot $value)
            if (-not (Test-StrictChildPath $SkillRoot $assetPath) -or -not (Test-Path -LiteralPath $assetPath -PathType Leaf)) {
                [void]$Errors.Add("agents/openai.yaml references missing or escaping asset '$value'.")
            }
        }
    }
}

function Test-SkillDirectory {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$Path)
    $errors = New-Object System.Collections.ArrayList
    $warnings = New-Object System.Collections.ArrayList
    $root = Get-NormalizedPath $Path
    $name = Split-Path -Leaf $root
    try { [void](Get-SafeTreeItems $root) } catch { [void]$errors.Add($_.Exception.Message) }
    $skillFile = Join-Path $root 'SKILL.md'
    if (-not (Test-Path -LiteralPath $skillFile -PathType Leaf)) {
        [void]$errors.Add('Required SKILL.md is missing.')
    }
    else {
        try {
            $frontmatter = Read-SkillFrontmatter $skillFile
            $values = $frontmatter.Values
            foreach ($required in @('name', 'description')) {
                if (-not $values.ContainsKey($required)) { [void]$errors.Add("Required frontmatter field '$required' is missing.") }
            }
            if ($values.ContainsKey('name')) {
                if ($values.name.Length -gt 64 -or $values.name -notmatch $script:NamePattern) { [void]$errors.Add("Skill name '$($values.name)' is invalid.") }
                elseif ($values.name -cne $name) { [void]$errors.Add("Skill name '$($values.name)' must match directory '$name'.") }
            }
            if ($values.ContainsKey('description') -and ($values.description.Length -lt 1 -or $values.description.Length -gt 1024)) { [void]$errors.Add('Description must be 1 to 1024 characters.') }
            if ($values.ContainsKey('compatibility') -and $values.compatibility.Length -gt 500) { [void]$errors.Add('Compatibility must be at most 500 characters.') }
            if ((@($frontmatter.Body) -join "`n").Trim().Length -eq 0) { [void]$errors.Add('SKILL.md body must not be empty.') }
            if ($frontmatter.LineCount -gt 500) { [void]$warnings.Add("SKILL.md has $($frontmatter.LineCount) lines; consider moving detail into references/.") }
            Add-LocalReferenceDiagnostics $root (Get-Content -Raw -LiteralPath $skillFile) $errors
        }
        catch { [void]$errors.Add($_.Exception.Message) }
    }
    foreach ($repositoryFile in @('README.md', 'CHANGELOG.md', 'CONTRIBUTING.md')) {
        if (Test-Path -LiteralPath (Join-Path $root $repositoryFile)) { [void]$warnings.Add("$repositoryFile is unusual inside a skill; keep repository guidance at the root when possible.") }
    }
    Test-OpenAiMetadata $root $errors $warnings
    [pscustomobject]@{ Name = $name; Path = $root; IsValid = ($errors.Count -eq 0); Errors = @($errors); Warnings = @($warnings) }
}

function Get-CatalogSkillNames {
    param([Parameter(Mandatory = $true)][string]$CatalogRoot)
    if (-not (Test-Path -LiteralPath $CatalogRoot -PathType Container)) { throw "Catalog not found: $CatalogRoot" }
    @(Get-ChildItem -LiteralPath $CatalogRoot -Directory -Force | Sort-Object Name | ForEach-Object { $_.Name })
}

function Test-RepositoryLayout {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$RepositoryRoot)
    $errors = New-Object System.Collections.ArrayList
    $warnings = New-Object System.Collections.ArrayList
    $root = Get-NormalizedPath $RepositoryRoot
    foreach ($required in @('README.md', 'AGENTS.md', '.gitignore', 'Refresh-CodexSkills.ps1', 'scripts\Install-Skills.ps1', 'scripts\Test-Repository.ps1', 'skills')) {
        if (-not (Test-Path -LiteralPath (Join-Path $root $required))) { [void]$errors.Add("Required repository path is missing: $required") }
    }
    if (Test-Path -LiteralPath (Join-Path $root '.agents\skills')) { [void]$errors.Add('The canonical catalog must not be mirrored into repository .agents/skills.') }
    $catalog = Join-Path $root 'skills'
    if (Test-Path -LiteralPath $catalog -PathType Container) {
        foreach ($file in @(Get-ChildItem -LiteralPath $catalog -File -Force)) { [void]$errors.Add("Only skill directories are allowed directly under skills/: $($file.Name)") }
        foreach ($skillName in @(Get-CatalogSkillNames $catalog)) {
            $result = Test-SkillDirectory (Join-Path $catalog $skillName)
            foreach ($errorText in $result.Errors) { [void]$errors.Add("${skillName}: $errorText") }
            foreach ($warningText in $result.Warnings) { [void]$warnings.Add("${skillName}: $warningText") }
        }
    }
    [pscustomobject]@{ IsValid = ($errors.Count -eq 0); Errors = @($errors); Warnings = @($warnings) }
}

function Get-TreeManifest {
    param([string]$Root)
    $rootPath = Get-NormalizedPath $Root
    $entries = New-Object System.Collections.ArrayList
    foreach ($item in @(Get-SafeTreeItems $rootPath)) {
        if (Test-SamePath $item.FullName $rootPath) { continue }
        $relative = $item.FullName.Substring($rootPath.Length + 1).Replace('\', '/')
        if ($item.PSIsContainer) { [void]$entries.Add("D|$relative") }
        else { [void]$entries.Add("F|$relative|$((Get-FileHash -LiteralPath $item.FullName -Algorithm SHA256).Hash)") }
    }
    @($entries | Sort-Object)
}

function Compare-SkillTrees {
    param([string]$Left, [string]$Right)
    $leftManifest = @(Get-TreeManifest $Left)
    $rightManifest = @(Get-TreeManifest $Right)
    if ($leftManifest.Count -ne $rightManifest.Count) { return $false }
    for ($i = 0; $i -lt $leftManifest.Count; $i++) { if ($leftManifest[$i] -cne $rightManifest[$i]) { return $false } }
    $true
}

function Remove-OwnedTree {
    param([string]$DestinationRoot, [string]$Path, [string[]]$AllowedNames, [switch]$Temporary)
    $leaf = Split-Path -Leaf (Get-NormalizedPath $Path)
    if (-not (Test-StrictChildPath $DestinationRoot $Path)) { throw "Refusing cleanup outside destination root: $Path" }
    if ($Temporary) {
        if ($leaf -notmatch '^\.__agent-skills-(?:stage|backup)-[0-9a-f]+$') { throw "Refusing cleanup of unowned temporary path: $Path" }
    }
    elseif ($AllowedNames -notcontains $leaf) { throw "Refusing cleanup of unselected skill path: $Path" }
    if (Test-Path -LiteralPath $Path) { Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction Stop }
}

function Invoke-SkillRefreshTransaction {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$CatalogRoot,
        [Parameter(Mandatory = $true)][string]$DestinationRoot,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][string[]]$Names,
        [scriptblock]$FailureInjector
    )
    $catalog = Get-NormalizedPath $CatalogRoot
    $destination = Get-NormalizedPath $DestinationRoot
    $selected = @($Names | Select-Object -Unique)
    $changed = New-Object System.Collections.ArrayList
    $warnings = New-Object System.Collections.ArrayList
    $records = @{}
    $stageRoot = Join-Path $destination ('.__agent-skills-stage-' + [guid]::NewGuid().ToString('N'))
    $backupRoot = Join-Path $destination ('.__agent-skills-backup-' + [guid]::NewGuid().ToString('N'))
    $swapStarted = $false
    $currentName = '<selection>'
    $phase = 'preflight'
    try {
        if ($selected.Count -eq 0) { throw 'No skills were selected.' }
        if (Test-PathsOverlap $catalog $destination) { throw "Destination overlaps canonical catalog: $destination" }
        Assert-NoReparseAncestor $destination
        foreach ($name in $selected) {
            $currentName = $name
            if ($name -notmatch $script:NamePattern -or $name.Length -gt 64) { throw "Invalid skill name '$name'." }
            $source = Join-Path $catalog $name
            if (-not (Test-Path -LiteralPath $source -PathType Container)) { throw "Catalog skill not found: $name" }
            $target = Join-Path $destination $name
            if (-not (Test-StrictChildPath $destination $target) -or (Split-Path -Leaf $target) -cne $name) { throw "Resolved target is not the exact selected child: $target" }
            $result = Test-SkillDirectory $source
            if (-not $result.IsValid) { throw "Source validation failed: $($result.Errors -join '; ')" }
            foreach ($warningText in $result.Warnings) { [void]$warnings.Add("${name}: $warningText") }
            if (Test-Path -LiteralPath $target) {
                $targetItem = Get-Item -LiteralPath $target -Force
                if (-not $targetItem.PSIsContainer) { throw "Destination target exists and is not a directory: $target" }
                if (($targetItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) { throw "Destination target is a reparse point: $target" }
            }
            $records[$name] = [pscustomobject]@{ Source = $source; Target = $target; Stage = (Join-Path $stageRoot $name); Backup = (Join-Path $backupRoot $name); Existed = (Test-Path -LiteralPath $target); BackedUp = $false; Installed = $false }
        }
        $phase = 'staging'
        [void](New-Item -ItemType Directory -Path $stageRoot -Force)
        [void](New-Item -ItemType Directory -Path $backupRoot -Force)
        foreach ($name in $selected) {
            $currentName = $name
            if ($FailureInjector) { & $FailureInjector 'BeforeStage' $name }
            Copy-Item -LiteralPath $records[$name].Source -Destination $records[$name].Stage -Recurse -Force -ErrorAction Stop
            $stagedResult = Test-SkillDirectory $records[$name].Stage
            if (-not $stagedResult.IsValid) { throw "Staged validation failed: $($stagedResult.Errors -join '; ')" }
            if (-not (Compare-SkillTrees $records[$name].Source $records[$name].Stage)) { throw 'Staged copy differs from source.' }
        }
        $phase = 'swap'
        $swapStarted = $true
        foreach ($name in $selected) {
            $currentName = $name
            $record = $records[$name]
            if ($FailureInjector) { & $FailureInjector 'BeforeBackup' $name }
            if ($record.Existed) { Move-Item -LiteralPath $record.Target -Destination $record.Backup -ErrorAction Stop; $record.BackedUp = $true }
            if ($FailureInjector) { & $FailureInjector 'AfterBackup' $name }
            Move-Item -LiteralPath $record.Stage -Destination $record.Target -ErrorAction Stop
            $record.Installed = $true
            [void]$changed.Add($name)
            if ($FailureInjector) { & $FailureInjector 'AfterSwap' $name }
        }
        Remove-OwnedTree $destination $stageRoot $selected -Temporary
        Remove-OwnedTree $destination $backupRoot $selected -Temporary
        return [pscustomobject]@{ Success = $true; Failure = $null; RollbackStatus = 'NOT REQUIRED'; Changed = @($changed); Warnings = @($warnings); BackupPath = $null }
    }
    catch {
        $failure = "Skill '$currentName' failed during ${phase}: $($_.Exception.Message)"
        $rollbackStatus = if ($swapStarted) { 'SUCCEEDED' } else { 'NOT REQUIRED' }
        if ($swapStarted) {
            try {
                for ($rollbackIndex = $selected.Count - 1; $rollbackIndex -ge 0; $rollbackIndex--) {
                    $name = $selected[$rollbackIndex]
                    if (-not $records.ContainsKey($name)) { continue }
                    $record = $records[$name]
                    if ($record.Installed -and (Test-Path -LiteralPath $record.Target)) { Remove-OwnedTree $destination $record.Target $selected }
                    if ($record.BackedUp -and (Test-Path -LiteralPath $record.Backup)) { Move-Item -LiteralPath $record.Backup -Destination $record.Target -ErrorAction Stop }
                }
                if (Test-Path -LiteralPath $stageRoot) { Remove-OwnedTree $destination $stageRoot $selected -Temporary }
                if (Test-Path -LiteralPath $backupRoot) { Remove-OwnedTree $destination $backupRoot $selected -Temporary }
            }
            catch { $rollbackStatus = 'FAILED'; $failure += " Rollback cause: $($_.Exception.Message)" }
        }
        else {
            foreach ($tempPath in @($stageRoot, $backupRoot)) {
                try { if (Test-Path -LiteralPath $tempPath) { Remove-OwnedTree $destination $tempPath $selected -Temporary } } catch { }
            }
        }
        return [pscustomobject]@{ Success = $false; Failure = $failure; RollbackStatus = $rollbackStatus; Changed = @($changed); Warnings = @($warnings); BackupPath = $(if ($rollbackStatus -eq 'FAILED') { $backupRoot } else { $null }) }
    }
}

Export-ModuleMember -Function Get-NormalizedPath, Test-SamePath, Test-StrictChildPath, Test-PathsOverlap, Test-SkillDirectory, Get-CatalogSkillNames, Test-RepositoryLayout, Compare-SkillTrees, Invoke-SkillRefreshTransaction
