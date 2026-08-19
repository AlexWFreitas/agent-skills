#requires -Version 5.1

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory = $true)]
    [string]$VaultPath,

    [string]$CollectionSlug,

    [string]$ContextSlug,

    [ValidateSet('auto', 'markdown', 'obsidian')]
    [string]$LinkStyle = 'auto'
)

$ErrorActionPreference = 'Stop'
$script:Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Write-NewUtf8File {
    param(
        [Parameter(Mandatory = $true)][string]$LiteralPath,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Content
    )

    $stream = New-Object IO.FileStream(
        $LiteralPath,
        [IO.FileMode]::CreateNew,
        [IO.FileAccess]::Write,
        [IO.FileShare]::Read
    )
    try {
        $writer = New-Object IO.StreamWriter($stream, $script:Utf8NoBom)
        try { $writer.Write($Content) }
        finally { $writer.Dispose() }
    }
    finally {
        if ($stream) { $stream.Dispose() }
    }
}

function Assert-PathInsideContext {
    param(
        [Parameter(Mandatory = $true)][string]$ContextRoot,
        [Parameter(Mandatory = $true)][string]$CandidatePath
    )

    $contextPrefix = [IO.Path]::GetFullPath($ContextRoot).TrimEnd('\') + '\'
    $candidateFull = [IO.Path]::GetFullPath($CandidatePath)
    if (-not $candidateFull.StartsWith($contextPrefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing a migration path outside the selected context: $candidateFull"
    }
    return $candidateFull
}

function Get-FieldValue {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][string]$Label,
        [string]$DefaultValue
    )

    $pattern = '(?m)^' + [regex]::Escape($Label) + ':\s+`?([^`\r\n]+)`?\s*$'
    $match = [regex]::Match($Text, $pattern)
    if ($match.Success) { return $match.Groups[1].Value.Trim() }
    return $DefaultValue
}

function Get-ScopeValue {
    param([Parameter(Mandatory = $true)][string]$Text)

    $match = [regex]::Match($Text, '(?ms)^## Scope\s*\r?\n\s*(.+?)(?=\r?\n## |\z)')
    if ($match.Success) { return $match.Groups[1].Value.Trim() }
    return 'User-provided knowledge for this context.'
}

function Get-RelativeContextPath {
    param(
        [Parameter(Mandatory = $true)][string]$ContextRoot,
        [Parameter(Mandatory = $true)][string]$LiteralPath
    )

    $contextPrefix = [IO.Path]::GetFullPath($ContextRoot).TrimEnd('\') + '\'
    $fullPath = [IO.Path]::GetFullPath($LiteralPath)
    if (-not $fullPath.StartsWith($contextPrefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Path is outside the selected context: $fullPath"
    }
    return $fullPath.Substring($contextPrefix.Length).Replace('\', '/')
}

function New-PreservationRecord {
    param(
        [Parameter(Mandatory = $true)][string]$ContextRoot,
        [Parameter(Mandatory = $true)][string]$SourcePath,
        [Parameter(Mandatory = $true)][string]$TargetPath,
        [Parameter(Mandatory = $true)][string]$Category
    )

    $sourceItem = Get-Item -LiteralPath $SourcePath
    return [pscustomobject][ordered]@{
        category = $Category
        original_path = Get-RelativeContextPath -ContextRoot $ContextRoot -LiteralPath $SourcePath
        migrated_path = Get-RelativeContextPath -ContextRoot $ContextRoot -LiteralPath $TargetPath
        length = $sourceItem.Length
        sha256 = (Get-FileHash -LiteralPath $SourcePath -Algorithm SHA256).Hash.ToLowerInvariant()
        target_full_path = [IO.Path]::GetFullPath($TargetPath)
    }
}

if (-not [IO.Path]::IsPathRooted($VaultPath)) {
    throw 'VaultPath must be an absolute path.'
}
$vaultRoot = [IO.Path]::GetFullPath($VaultPath)
$rootIndexPath = Join-Path $vaultRoot 'second-brain.md'
if (-not (Test-Path -LiteralPath $rootIndexPath -PathType Leaf)) {
    throw "Not an initialized second-brain vault: $vaultRoot"
}

$rootIndex = Get-Content -LiteralPath $rootIndexPath -Raw
if (-not $CollectionSlug) {
    $match = [regex]::Match($rootIndex, '(?m)^Active collection:\s+`([^`]+)`\s*$')
    if (-not $match.Success) { throw 'second-brain.md does not declare one active collection.' }
    $CollectionSlug = $match.Groups[1].Value
}
if (-not $ContextSlug) {
    $match = [regex]::Match($rootIndex, '(?m)^Active context:\s+`([^`]+)`\s*$')
    if (-not $match.Success) { throw 'second-brain.md does not declare one active context.' }
    $ContextSlug = $match.Groups[1].Value
}
foreach ($slug in @($CollectionSlug, $ContextSlug)) {
    if ($slug -notmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') {
        throw "Invalid collection or context slug '$slug'."
    }
}

$contextRoot = Join-Path $vaultRoot "collections\$CollectionSlug\contexts\$ContextSlug"
if (-not (Test-Path -LiteralPath $contextRoot -PathType Container)) {
    throw "Selected context does not exist: $contextRoot"
}
$contextRoot = [IO.Path]::GetFullPath($contextRoot)
$collectionRoot = [IO.Path]::GetFullPath((Join-Path $vaultRoot "collections\$CollectionSlug"))
$resolvedLinkStyle = $LinkStyle.ToLowerInvariant()
if ($resolvedLinkStyle -eq 'auto') {
    $resolvedLinkStyle = if (Test-Path -LiteralPath (Join-Path $collectionRoot '.obsidian') -PathType Container) {
        'obsidian'
    }
    else {
        'markdown'
    }
}
$legacyInbox = Assert-PathInsideContext -ContextRoot $contextRoot -CandidatePath (Join-Path $contextRoot 'inbox')
$evidenceRoot = Assert-PathInsideContext -ContextRoot $contextRoot -CandidatePath (Join-Path $contextRoot '_evidence')

$humanTargets = @(
    (Join-Path $contextRoot 'README.md'),
    (Join-Path $contextRoot 'open-questions.md'),
    (Join-Path $contextRoot 'guide\index.md'),
    (Join-Path $contextRoot 'journal\index.md'),
    (Join-Path $evidenceRoot 'state.md'),
    (Join-Path $evidenceRoot 'processing-events.jsonl')
)
if ((Test-Path -LiteralPath $evidenceRoot -PathType Container) -and
    -not (Test-Path -LiteralPath $legacyInbox)) {
    $missingTargets = @($humanTargets | Where-Object { -not (Test-Path -LiteralPath $_) })
    if ($missingTargets.Count -eq 0) {
        [pscustomobject]@{
            State = 'existing-compatible'
            VaultPath = $vaultRoot
            Collection = $CollectionSlug
            Context = $ContextSlug
            EvidencePath = $evidenceRoot
        }
        return
    }
    throw "Human-first layout is partial; missing: $($missingTargets -join ', ')"
}
if ((Test-Path -LiteralPath $evidenceRoot) -and (Test-Path -LiteralPath $legacyInbox)) {
    throw "Both '$legacyInbox' and '$evidenceRoot' exist. Refusing an ambiguous migration."
}
if (-not (Test-Path -LiteralPath $legacyInbox -PathType Container)) {
    throw "Legacy evidence backend does not exist: $legacyInbox"
}

$legacyContextPath = Join-Path $contextRoot 'context.md'
$legacyTimelinePath = Join-Path $contextRoot 'timeline.md'
$legacyOpenItemsPath = Join-Path $contextRoot 'open-items.md'
$legacyTopicsPath = Join-Path $contextRoot 'topics'
$guidePath = Join-Path $contextRoot 'guide'
$journalPath = Join-Path $contextRoot 'journal'
$legacySynthesisPath = Join-Path $evidenceRoot 'legacy-synthesis'

foreach ($requiredPath in @(
    $legacyContextPath,
    $legacyTimelinePath,
    $legacyOpenItemsPath,
    (Join-Path $legacyInbox 'captures'),
    (Join-Path $legacyInbox 'interpretations'),
    (Join-Path $legacyInbox 'media-processing'),
    (Join-Path $legacyInbox 'processing-events.jsonl')
)) {
    if (-not (Test-Path -LiteralPath $requiredPath)) {
        throw "Legacy context is incomplete; missing '$requiredPath'."
    }
}
foreach ($conflictPath in @(
    (Join-Path $contextRoot 'README.md'),
    (Join-Path $contextRoot 'open-questions.md'),
    $guidePath,
    $journalPath
)) {
    if (Test-Path -LiteralPath $conflictPath) {
        throw "Migration target already exists: $conflictPath"
    }
}

$legacyContext = Get-Content -LiteralPath $legacyContextPath -Raw
$headingMatch = [regex]::Match($legacyContext, '(?m)^# Context:\s*(.+?)\s*$')
$fullContextTitle = if ($headingMatch.Success) { $headingMatch.Groups[1].Value.Trim() } else { $CollectionSlug }
$contextDisplay = if ($fullContextTitle -match '^(.*?)\s+-\s+(.+)$') { $Matches[2] } else { $ContextSlug }
$collectionDisplay = if ($fullContextTitle -match '^(.*?)\s+-\s+(.+)$') { $Matches[1] } else {
    (Get-Culture).TextInfo.ToTitleCase($CollectionSlug.Replace('-', ' '))
}
$activityTemplate = Get-FieldValue -Text $legacyContext -Label 'Activity template' -DefaultValue 'game-playthrough'
$lifecycle = Get-FieldValue -Text $legacyContext -Label 'Lifecycle' -DefaultValue 'active'
$epistemicMode = Get-FieldValue -Text $legacyContext -Label 'Epistemic mode' -DefaultValue 'firsthand-only'
$created = Get-FieldValue -Text $legacyContext -Label 'Created' -DefaultValue (Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK')
$lastUpdated = Get-FieldValue -Text $legacyContext -Label 'Last updated' -DefaultValue $created
$latestCheckpoint = Get-FieldValue -Text $legacyContext -Label 'Latest checkpoint' -DefaultValue 'none'
$contextScope = Get-ScopeValue -Text $legacyContext

$preservationRecords = @()
foreach ($sourceFile in Get-ChildItem -LiteralPath $legacyInbox -File -Recurse) {
    $relativeUnderInbox = $sourceFile.FullName.Substring($legacyInbox.Length).TrimStart('\')
    $targetFile = Join-Path $evidenceRoot $relativeUnderInbox
    $preservationRecords += New-PreservationRecord `
        -ContextRoot $contextRoot `
        -SourcePath $sourceFile.FullName `
        -TargetPath $targetFile `
        -Category 'evidence-backend'
}
foreach ($sourcePath in @($legacyContextPath, $legacyTimelinePath, $legacyOpenItemsPath)) {
    $targetPath = Join-Path $legacySynthesisPath (Split-Path -Leaf $sourcePath)
    $preservationRecords += New-PreservationRecord `
        -ContextRoot $contextRoot `
        -SourcePath $sourcePath `
        -TargetPath $targetPath `
        -Category 'legacy-synthesis'
}
if (Test-Path -LiteralPath $legacyTopicsPath -PathType Container) {
    foreach ($sourceFile in Get-ChildItem -LiteralPath $legacyTopicsPath -File -Recurse) {
        $relativeUnderTopics = $sourceFile.FullName.Substring($legacyTopicsPath.Length).TrimStart('\')
        $targetFile = Join-Path $guidePath $relativeUnderTopics
        $preservationRecords += New-PreservationRecord `
            -ContextRoot $contextRoot `
            -SourcePath $sourceFile.FullName `
            -TargetPath $targetFile `
            -Category 'topic-note'
    }
}
if (Test-Path -LiteralPath (Join-Path $contextRoot 'attachments') -PathType Container) {
    foreach ($sourceFile in Get-ChildItem -LiteralPath (Join-Path $contextRoot 'attachments') -File -Recurse) {
        $preservationRecords += New-PreservationRecord `
            -ContextRoot $contextRoot `
            -SourcePath $sourceFile.FullName `
            -TargetPath $sourceFile.FullName `
            -Category 'attachment-unchanged'
    }
}

if (-not $PSCmdlet.ShouldProcess(
    $contextRoot,
    "Move the legacy inbox and synthesis into _evidence and create the human-first guide/journal surface"
)) {
    [pscustomobject]@{
        State = 'migration-preview'
        VaultPath = $vaultRoot
        Collection = $CollectionSlug
        Context = $ContextSlug
        PreservedFiles = $preservationRecords.Count
    }
    return
}

$skillRoot = Split-Path -Parent $PSScriptRoot
$assetRoot = Join-Path $skillRoot 'assets\vault'
$createdFiles = @()
$createdDirectories = @()
$movedCoreFiles = @()
$movedTopics = $false
$movedInbox = $false

try {
    Move-Item -LiteralPath $legacyInbox -Destination $evidenceRoot
    $movedInbox = $true

    [void](New-Item -ItemType Directory -Path $legacySynthesisPath)
    $createdDirectories += $legacySynthesisPath
    foreach ($sourcePath in @($legacyContextPath, $legacyTimelinePath, $legacyOpenItemsPath)) {
        $targetPath = Join-Path $legacySynthesisPath (Split-Path -Leaf $sourcePath)
        Move-Item -LiteralPath $sourcePath -Destination $targetPath
        $movedCoreFiles += [pscustomobject]@{ Source = $sourcePath; Target = $targetPath }
    }

    if (Test-Path -LiteralPath $legacyTopicsPath -PathType Container) {
        Move-Item -LiteralPath $legacyTopicsPath -Destination $guidePath
        $movedTopics = $true
    }
    else {
        [void](New-Item -ItemType Directory -Path $guidePath)
        $createdDirectories += $guidePath
    }
    [void](New-Item -ItemType Directory -Path $journalPath)
    $createdDirectories += $journalPath

    $tokens = @{
        '{{COLLECTION_NAME}}' = $collectionDisplay
        '{{COLLECTION_SLUG}}' = $CollectionSlug
        '{{CONTEXT_TITLE}}' = $contextDisplay
        '{{ACTIVITY_TEMPLATE}}' = $activityTemplate
        '{{LIFECYCLE}}' = $lifecycle
        '{{EPISTEMIC_MODE}}' = $epistemicMode
        '{{LINK_STYLE}}' = $resolvedLinkStyle
        '{{GUIDE_LINK}}' = if ($resolvedLinkStyle -eq 'obsidian') {
            "[[contexts/$ContextSlug/guide/index|Guide]]"
        }
        else {
            '[Guide](guide/index.md)'
        }
        '{{JOURNAL_LINK}}' = if ($resolvedLinkStyle -eq 'obsidian') {
            "[[contexts/$ContextSlug/journal/index|Journal]]"
        }
        else {
            '[Journal](journal/index.md)'
        }
        '{{OPEN_QUESTIONS_LINK}}' = if ($resolvedLinkStyle -eq 'obsidian') {
            "[[contexts/$ContextSlug/open-questions|Open questions]]"
        }
        else {
            '[Open questions](open-questions.md)'
        }
        '{{CREATED}}' = $created
        '{{LAST_UPDATED}}' = $lastUpdated
        '{{LATEST_CHECKPOINT}}' = $latestCheckpoint
        '{{CONTEXT_SCOPE}}' = $contextScope
    }
    $templateFiles = @(
        @{ Source = (Join-Path $assetRoot 'home.md'); Target = (Join-Path $contextRoot 'README.md') },
        @{ Source = (Join-Path $assetRoot 'open-questions.md'); Target = (Join-Path $contextRoot 'open-questions.md') },
        @{ Source = (Join-Path $assetRoot 'journal\index.md'); Target = (Join-Path $journalPath 'index.md') },
        @{ Source = (Join-Path $assetRoot 'state.md'); Target = (Join-Path $evidenceRoot 'state.md') }
    )
    if (-not (Test-Path -LiteralPath (Join-Path $guidePath 'index.md'))) {
        $templateFiles += @{
            Source = (Join-Path $assetRoot 'guide\index.md')
            Target = (Join-Path $guidePath 'index.md')
        }
    }
    foreach ($file in $templateFiles) {
        $content = Get-Content -LiteralPath $file.Source -Raw
        foreach ($token in $tokens.Keys) { $content = $content.Replace($token, $tokens[$token]) }
        Write-NewUtf8File -LiteralPath $file.Target -Content $content
        $createdFiles += $file.Target
    }

    foreach ($record in $preservationRecords) {
        if (-not (Test-Path -LiteralPath $record.target_full_path -PathType Leaf)) {
            throw "Preserved file is missing after migration: $($record.migrated_path)"
        }
        $targetItem = Get-Item -LiteralPath $record.target_full_path
        $targetHash = (Get-FileHash -LiteralPath $record.target_full_path -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($targetItem.Length -ne $record.length -or $targetHash -ne $record.sha256) {
            throw "Preserved file changed during migration: $($record.migrated_path)"
        }
    }

    $manifestPath = Join-Path $evidenceRoot 'migration-manifest.json'
    $manifestRecords = @($preservationRecords | ForEach-Object {
        [pscustomobject][ordered]@{
            category = $_.category
            original_path = $_.original_path
            migrated_path = $_.migrated_path
            length = $_.length
            sha256 = $_.sha256
        }
    })
    $manifest = [ordered]@{
        migrated_at = (Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK')
        layout_version = 2
        link_style = $resolvedLinkStyle
        collection = $CollectionSlug
        context = $ContextSlug
        preserved_files = $manifestRecords
    }
    Write-NewUtf8File -LiteralPath $manifestPath -Content ($manifest | ConvertTo-Json -Depth 6)
    $createdFiles += $manifestPath

    [pscustomobject]@{
        State = 'migrated-human-layout'
        VaultPath = $vaultRoot
        Collection = $CollectionSlug
        Context = $ContextSlug
        LinkStyle = $resolvedLinkStyle
        EvidencePath = $evidenceRoot
        PreservedFiles = $preservationRecords.Count
        ManifestPath = $manifestPath
    }
}
catch {
    $migrationError = $_
    foreach ($file in @($createdFiles) | Sort-Object Length -Descending) {
        if (Test-Path -LiteralPath $file -PathType Leaf) {
            Remove-Item -LiteralPath $file -Force
        }
    }
    foreach ($move in @($movedCoreFiles) | Sort-Object { $_.Target.Length } -Descending) {
        if ((Test-Path -LiteralPath $move.Target -PathType Leaf) -and
            -not (Test-Path -LiteralPath $move.Source)) {
            Move-Item -LiteralPath $move.Target -Destination $move.Source
        }
    }
    if ($movedTopics -and (Test-Path -LiteralPath $guidePath -PathType Container) -and
        -not (Test-Path -LiteralPath $legacyTopicsPath)) {
        Move-Item -LiteralPath $guidePath -Destination $legacyTopicsPath
    }
    foreach ($directory in @($createdDirectories) | Sort-Object Length -Descending) {
        if ((Test-Path -LiteralPath $directory -PathType Container) -and
            @((Get-ChildItem -LiteralPath $directory -Force)).Count -eq 0) {
            Remove-Item -LiteralPath $directory -Force
        }
    }
    if ($movedInbox -and (Test-Path -LiteralPath $evidenceRoot -PathType Container) -and
        -not (Test-Path -LiteralPath $legacyInbox)) {
        Move-Item -LiteralPath $evidenceRoot -Destination $legacyInbox
    }
    throw "Human-layout migration failed and rollback was attempted: $($migrationError.Exception.Message)"
}
