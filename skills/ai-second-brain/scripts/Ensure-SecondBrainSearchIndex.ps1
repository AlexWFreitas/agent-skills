#requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$VaultPath,

    [string]$CollectionSlug,

    [string]$ContextSlug,

    [string]$IndexPath,

    [string]$PythonPath,

    [ValidateSet('auto', 'off', 'lexical', 'hybrid')]
    [string]$SearchMode,

    [string]$EmbeddingModel,

    [string]$EmbeddingEndpoint,

    [ValidateRange(1, 30)]
    [int]$EmbeddingProbeTimeoutSeconds = 2,

    [ValidateRange(1, 128)]
    [int]$EmbeddingBatchSize = 32,

    [ValidateRange(1, 600)]
    [int]$EmbeddingTimeoutSeconds = 120,

    [ValidateRange(1000, 50000)]
    [int]$EmbeddingMaxCharacters = 8000,

    [switch]$HumanOnly,

    [switch]$IncludeExternal,

    [switch]$ForceRebuild,

    [switch]$SkipGitIgnore
)

$ErrorActionPreference = 'Stop'
$script:Utf8NoBom = New-Object Text.UTF8Encoding($false)

function Resolve-PythonExecutable {
    param([string]$ExplicitPath)

    if ($ExplicitPath) {
        if (-not [IO.Path]::IsPathRooted($ExplicitPath)) {
            throw 'PythonPath must be absolute.'
        }
        $resolved = [IO.Path]::GetFullPath($ExplicitPath)
        if (-not (Test-Path -LiteralPath $resolved -PathType Leaf)) {
            throw "Python executable does not exist: $resolved"
        }
        return $resolved
    }

    $command = Get-Command python -CommandType Application -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($command) { return $command.Source }
    return $null
}

function Resolve-SearchContext {
    param(
        [string]$RootPath,
        [string]$Collection,
        [string]$Context,
        [string]$RequestedIndexPath
    )

    if (-not [IO.Path]::IsPathRooted($RootPath)) {
        throw 'VaultPath must be absolute.'
    }
    $vaultRoot = [IO.Path]::GetFullPath($RootPath)
    $rootIndexPath = Join-Path $vaultRoot 'second-brain.md'
    if (-not (Test-Path -LiteralPath $rootIndexPath -PathType Leaf)) {
        throw "Not an initialized second-brain vault: $vaultRoot"
    }
    $rootIndex = [IO.File]::ReadAllText($rootIndexPath, [Text.Encoding]::UTF8)
    if (-not $Collection) {
        $match = [regex]::Match($rootIndex, '(?m)^Active collection:\s+`([^`]+)`\s*$')
        if (-not $match.Success) { throw 'second-brain.md does not declare one active collection.' }
        $Collection = $match.Groups[1].Value
    }
    if (-not $Context) {
        $match = [regex]::Match($rootIndex, '(?m)^Active context:\s+`([^`]+)`\s*$')
        if (-not $match.Success) { throw 'second-brain.md does not declare one active context.' }
        $Context = $match.Groups[1].Value
    }
    foreach ($slug in @($Collection, $Context)) {
        if ($slug -notmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') {
            throw "Invalid collection or context slug '$slug'."
        }
    }

    $contextRoot = [IO.Path]::GetFullPath((Join-Path $vaultRoot "collections\$Collection\contexts\$Context"))
    if (-not (Test-Path -LiteralPath $contextRoot -PathType Container)) {
        throw "Selected context does not exist: $contextRoot"
    }
    $indexRoot = [IO.Path]::GetFullPath((Join-Path $vaultRoot '.index\ai-second-brain'))
    $resolvedIndexPath = if ($RequestedIndexPath) {
        if (-not [IO.Path]::IsPathRooted($RequestedIndexPath)) {
            throw 'IndexPath must be absolute.'
        }
        [IO.Path]::GetFullPath($RequestedIndexPath)
    }
    else { Join-Path $indexRoot "$Collection--$Context.sqlite" }
    $indexPrefix = $indexRoot.TrimEnd('\') + '\'
    if (-not $resolvedIndexPath.StartsWith($indexPrefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw "IndexPath must remain inside '$indexRoot'."
    }
    if ([IO.Path]::GetExtension($resolvedIndexPath).ToLowerInvariant() -ne '.sqlite') {
        throw 'IndexPath must use the .sqlite extension.'
    }

    return [pscustomobject]@{
        VaultRoot = $vaultRoot
        Collection = $Collection
        Context = $Context
        ContextRoot = $contextRoot
        IndexPath = $resolvedIndexPath
    }
}

function Resolve-OllamaTagsUri {
    param([Parameter(Mandatory = $true)][string]$Endpoint)

    try { $uri = New-Object Uri($Endpoint, [UriKind]::Absolute) }
    catch { throw 'EmbeddingEndpoint must be an absolute HTTP URI on a loopback host.' }

    $hostName = $uri.Host.Trim([char[]]'[]').ToLowerInvariant()
    if ($uri.Scheme.ToLowerInvariant() -ne 'http' -or
        $hostName -notin @('127.0.0.1', 'localhost', '::1')) {
        throw 'EmbeddingEndpoint must use http on 127.0.0.1, localhost, or ::1.'
    }
    if ($uri.UserInfo) { throw 'EmbeddingEndpoint must not contain credentials.' }

    $path = $uri.AbsolutePath.TrimEnd('/')
    if ($path -and $path -ne '/api/embed') {
        throw 'EmbeddingEndpoint path must be empty or /api/embed.'
    }

    $builder = New-Object UriBuilder($uri)
    $builder.Path = '/api/tags'
    $builder.Query = ''
    $builder.Fragment = ''
    return $builder.Uri.AbsoluteUri
}

function Get-OllamaModelAvailability {
    param(
        [Parameter(Mandatory = $true)][string]$Endpoint,
        [Parameter(Mandatory = $true)][string]$Model,
        [Parameter(Mandatory = $true)][int]$TimeoutSeconds
    )

    $tagsUri = Resolve-OllamaTagsUri -Endpoint $Endpoint
    try {
        $response = Invoke-RestMethod `
            -Uri $tagsUri `
            -Method Get `
            -TimeoutSec $TimeoutSeconds `
            -MaximumRedirection 0 `
            -ErrorAction Stop
    }
    catch {
        return [pscustomobject]@{
            Available = $false
            Reason = "Ollama is not available at the configured loopback endpoint: $($_.Exception.Message)"
        }
    }

    $availableNames = @($response.models | ForEach-Object {
        if ($_.name) { [string]$_.name }
        elseif ($_.model) { [string]$_.model }
    })
    $acceptedNames = @($Model)
    if (-not $Model.Contains(':')) { $acceptedNames += "$Model`:latest" }
    $found = @($availableNames | Where-Object { $acceptedNames -contains $_ }).Count -gt 0
    return [pscustomobject]@{
        Available = $found
        Reason = if ($found) { $null } else { "Ollama model '$Model' is not installed." }
    }
}

function Ensure-IndexGitIgnore {
    param([Parameter(Mandatory = $true)][string]$RootPath)

    $gitIgnorePath = Join-Path $RootPath '.gitignore'
    $existingBytes = if (Test-Path -LiteralPath $gitIgnorePath -PathType Leaf) {
        [IO.File]::ReadAllBytes($gitIgnorePath)
    }
    else { [byte[]]@() }
    $existing = if ($existingBytes.Length -gt 0) {
        [IO.File]::ReadAllText($gitIgnorePath)
    }
    else { '' }

    $appendEncoding = $script:Utf8NoBom
    if ($existingBytes.Length -ge 4 -and
        $existingBytes[0] -eq 0x00 -and $existingBytes[1] -eq 0x00 -and
        $existingBytes[2] -eq 0xFE -and $existingBytes[3] -eq 0xFF) {
        $appendEncoding = New-Object Text.UTF32Encoding($true, $false)
    }
    elseif ($existingBytes.Length -ge 4 -and
        $existingBytes[0] -eq 0xFF -and $existingBytes[1] -eq 0xFE -and
        $existingBytes[2] -eq 0x00 -and $existingBytes[3] -eq 0x00) {
        $appendEncoding = New-Object Text.UTF32Encoding($false, $false)
    }
    elseif ($existingBytes.Length -ge 2 -and
        $existingBytes[0] -eq 0xFE -and $existingBytes[1] -eq 0xFF) {
        $appendEncoding = New-Object Text.UnicodeEncoding($true, $false)
    }
    elseif ($existingBytes.Length -ge 2 -and
        $existingBytes[0] -eq 0xFF -and $existingBytes[1] -eq 0xFE) {
        $appendEncoding = New-Object Text.UnicodeEncoding($false, $false)
    }

    if ($existing -match '(?m)^\s*/?\.index/?\s*$') { return $false }

    $newline = if ($existing.Contains("`r`n")) { "`r`n" } else { "`n" }
    $prefix = if (-not $existing -or $existing.EndsWith("`n") -or $existing.EndsWith("`r")) {
        ''
    }
    else { $newline }
    $addition = $prefix + '/.index/' + $newline

    if (Test-Path -LiteralPath $gitIgnorePath -PathType Leaf) {
        $stream = New-Object IO.FileStream(
            $gitIgnorePath,
            [IO.FileMode]::Append,
            [IO.FileAccess]::Write,
            [IO.FileShare]::Read
        )
        try {
            $bytes = $appendEncoding.GetBytes($addition)
            $stream.Write($bytes, 0, $bytes.Length)
        }
        finally { $stream.Dispose() }
    }
    else {
        [IO.File]::WriteAllText($gitIgnorePath, $addition, $script:Utf8NoBom)
    }
    return $true
}

function New-EnsureResult {
    param(
        [string]$State,
        [string]$Action,
        [string]$EffectiveMode,
        [string]$ResolvedIndexPath,
        [bool]$GitIgnoreUpdated,
        $BuildResult,
        [string]$Reason
    )

    return [pscustomobject]@{
        State = $State
        Action = $Action
        RequestedMode = $SearchMode
        SearchMode = $EffectiveMode
        IndexPath = $ResolvedIndexPath
        GitIgnoreUpdated = $GitIgnoreUpdated
        SemanticEnabled = if ($BuildResult) { [bool]$BuildResult.SemanticEnabled } else { $EffectiveMode -eq 'hybrid' }
        EmbeddingModel = if ($BuildResult) { $BuildResult.EmbeddingModel } elseif ($EffectiveMode -eq 'hybrid') { $EmbeddingModel } else { $null }
        Files = if ($BuildResult) { [int]$BuildResult.Files } else { 0 }
        Sections = if ($BuildResult) { [int]$BuildResult.Sections } else { 0 }
        SemanticSections = if ($BuildResult) { [int]$BuildResult.SemanticSections } else { 0 }
        Reason = $Reason
    }
}

$buildScript = Join-Path $PSScriptRoot 'Build-SecondBrainSearchIndex.ps1'
if (-not (Test-Path -LiteralPath $buildScript -PathType Leaf)) {
    throw "Search-index builder is missing: $buildScript"
}

$resolved = Resolve-SearchContext `
    -RootPath $VaultPath `
    -Collection $CollectionSlug `
    -Context $ContextSlug `
    -RequestedIndexPath $IndexPath
$resolvedIndexPath = $resolved.IndexPath

$statePath = Join-Path $resolved.ContextRoot '_evidence\state.md'
if (Test-Path -LiteralPath $statePath -PathType Leaf) {
    $state = [IO.File]::ReadAllText($statePath, [Text.Encoding]::UTF8)
    if (-not $SearchMode) {
        $match = [regex]::Match($state, '(?m)^Search mode:\s+`(auto|off|lexical|hybrid)`\s*$')
        if ($match.Success) { $SearchMode = $match.Groups[1].Value }
    }
    if (-not $EmbeddingModel) {
        $match = [regex]::Match($state, '(?m)^Embedding model:\s+`([^`]+)`\s*$')
        if ($match.Success) { $EmbeddingModel = $match.Groups[1].Value }
    }
    if (-not $EmbeddingEndpoint) {
        $match = [regex]::Match($state, '(?m)^Embedding endpoint:\s+`([^`]+)`\s*$')
        if ($match.Success) { $EmbeddingEndpoint = $match.Groups[1].Value }
    }
}
if (-not $SearchMode) { $SearchMode = 'auto' }
if (-not $EmbeddingModel) { $EmbeddingModel = 'embeddinggemma' }
if (-not $EmbeddingEndpoint) { $EmbeddingEndpoint = 'http://127.0.0.1:11434' }

if ($SearchMode -eq 'off') {
    New-EnsureResult `
        -State 'skipped' `
        -Action 'unchanged' `
        -EffectiveMode 'files' `
        -ResolvedIndexPath $resolvedIndexPath `
        -GitIgnoreUpdated $false `
        -BuildResult $null `
        -Reason 'Automatic local indexing is disabled for this context.'
    return
}

$gitIgnoreUpdated = if ($SkipGitIgnore) { $false } else {
    Ensure-IndexGitIgnore -RootPath $resolved.VaultRoot
}

$python = Resolve-PythonExecutable -ExplicitPath $PythonPath
if (-not $python) {
    New-EnsureResult `
        -State 'unavailable' `
        -Action 'unchanged' `
        -EffectiveMode 'files' `
        -ResolvedIndexPath $resolvedIndexPath `
        -GitIgnoreUpdated $gitIgnoreUpdated `
        -BuildResult $null `
        -Reason 'Python with standard-library SQLite/FTS5 is unavailable; use ordinary file search.'
    return
}

$modelAvailability = $null
if ($SearchMode -in @('auto', 'hybrid')) {
    if (-not $EmbeddingModel) {
        throw 'EmbeddingModel is required when SearchMode is auto or hybrid.'
    }
    $modelAvailability = Get-OllamaModelAvailability `
        -Endpoint $EmbeddingEndpoint `
        -Model $EmbeddingModel `
        -TimeoutSeconds $EmbeddingProbeTimeoutSeconds
}

$effectiveMode = switch ($SearchMode) {
    'lexical' { 'lexical' }
    'hybrid' { if ($modelAvailability.Available) { 'hybrid' } else { 'files' } }
    default { if ($modelAvailability.Available) { 'hybrid' } else { 'lexical' } }
}

if ($SearchMode -eq 'hybrid' -and -not $modelAvailability.Available) {
    New-EnsureResult `
        -State 'unavailable' `
        -Action 'unchanged' `
        -EffectiveMode 'files' `
        -ResolvedIndexPath $resolvedIndexPath `
        -GitIgnoreUpdated $gitIgnoreUpdated `
        -BuildResult $null `
        -Reason $modelAvailability.Reason
    return
}

if (-not $ForceRebuild -and
    (Test-Path -LiteralPath $resolvedIndexPath -PathType Leaf) -and
    $effectiveMode -eq 'lexical') {
    New-EnsureResult `
        -State 'ready' `
        -Action 'unchanged' `
        -EffectiveMode 'lexical' `
        -ResolvedIndexPath $resolvedIndexPath `
        -GitIgnoreUpdated $gitIgnoreUpdated `
        -BuildResult $null `
        -Reason $modelAvailability.Reason
    return
}

$buildParameters = @{
    VaultPath = $resolved.VaultRoot
    CollectionSlug = $resolved.Collection
    ContextSlug = $resolved.Context
    PythonPath = $python
    EmbeddingBatchSize = $EmbeddingBatchSize
    EmbeddingTimeoutSeconds = $EmbeddingTimeoutSeconds
    EmbeddingMaxCharacters = $EmbeddingMaxCharacters
}
if ($IndexPath) { $buildParameters.IndexPath = $IndexPath }
if ($HumanOnly) { $buildParameters.HumanOnly = $true }
if ($IncludeExternal) { $buildParameters.IncludeExternal = $true }

$fallbackReason = if ($effectiveMode -eq 'lexical' -and $modelAvailability) {
    $modelAvailability.Reason
}
else { $null }

if ($effectiveMode -eq 'hybrid') {
    try {
        $semanticBuild = & $buildScript @buildParameters `
            -Semantic `
            -EmbeddingModel $EmbeddingModel `
            -EmbeddingEndpoint $EmbeddingEndpoint `
            -Confirm:$false
        New-EnsureResult `
            -State 'ready' `
            -Action 'rebuilt' `
            -EffectiveMode 'hybrid' `
            -ResolvedIndexPath $resolvedIndexPath `
            -GitIgnoreUpdated $gitIgnoreUpdated `
            -BuildResult $semanticBuild `
            -Reason $null
        return
    }
    catch {
        if ($SearchMode -eq 'hybrid') {
            New-EnsureResult `
                -State 'unavailable' `
                -Action 'unchanged' `
                -EffectiveMode 'files' `
                -ResolvedIndexPath $resolvedIndexPath `
                -GitIgnoreUpdated $gitIgnoreUpdated `
                -BuildResult $null `
                -Reason "Hybrid index build failed without replacing a prior index: $($_.Exception.Message)"
            return
        }
        $fallbackReason = "Semantic indexing was unavailable, so automatic setup used lexical FTS5: $($_.Exception.Message)"
    }
}

try {
    $lexicalBuild = & $buildScript @buildParameters -Confirm:$false
    New-EnsureResult `
        -State 'ready' `
        -Action 'rebuilt' `
        -EffectiveMode 'lexical' `
        -ResolvedIndexPath $resolvedIndexPath `
        -GitIgnoreUpdated $gitIgnoreUpdated `
        -BuildResult $lexicalBuild `
        -Reason $fallbackReason
}
catch {
    New-EnsureResult `
        -State 'unavailable' `
        -Action 'unchanged' `
        -EffectiveMode 'files' `
        -ResolvedIndexPath $resolvedIndexPath `
        -GitIgnoreUpdated $gitIgnoreUpdated `
        -BuildResult $null `
        -Reason "Local FTS5 setup failed; use ordinary file search: $($_.Exception.Message)"
}
