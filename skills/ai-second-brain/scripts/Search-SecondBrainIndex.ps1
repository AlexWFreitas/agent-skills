#requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$VaultPath,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Query,

    [string]$CollectionSlug,

    [string]$ContextSlug,

    [string]$IndexPath,

    [string]$PythonPath,

    [ValidateRange(1, 50)]
    [int]$Limit = 10,

    [switch]$RawQuery,

    [switch]$IncludeExternal,

    [Alias('Hybrid')]
    [switch]$Semantic,

    [switch]$LexicalOnly,

    [ValidateSet('auto', 'off', 'lexical', 'hybrid')]
    [string]$SearchMode,

    [string]$EmbeddingModel,

    [string]$EmbeddingEndpoint,

    [ValidateRange(1, 30)]
    [int]$EmbeddingProbeTimeoutSeconds = 2,

    [ValidateRange(1, 600)]
    [int]$EmbeddingTimeoutSeconds = 120,

    [switch]$NoAutoRefresh
)

$ErrorActionPreference = 'Stop'

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
    if (-not $command) {
        throw 'The optional FTS5 index requires Python with standard-library SQLite. Use ordinary file search when Python is unavailable.'
    }
    return $command.Source
}

function Resolve-SearchContext {
    param(
        [string]$RootPath,
        [string]$Collection,
        [string]$Context,
        [string]$RequestedIndexPath
    )

    if (-not [IO.Path]::IsPathRooted($RootPath)) { throw 'VaultPath must be absolute.' }
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
    $contextRoot = Join-Path $vaultRoot "collections\$Collection\contexts\$Context"
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
    else {
        Join-Path $indexRoot "$Collection--$Context.sqlite"
    }
    $indexPrefix = $indexRoot.TrimEnd('\') + '\'
    if (-not $resolvedIndexPath.StartsWith($indexPrefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw "IndexPath must remain inside '$indexRoot'."
    }
    return [pscustomobject]@{
        VaultRoot = $vaultRoot
        Collection = $Collection
        Context = $Context
        ContextRoot = [IO.Path]::GetFullPath($contextRoot)
        IndexPath = $resolvedIndexPath
    }
}

function Get-SearchPreferences {
    param(
        [Parameter(Mandatory = $true)][string]$ContextRoot,
        [string]$ExplicitMode,
        [string]$ExplicitModel,
        [string]$ExplicitEndpoint
    )

    $configuredMode = $ExplicitMode
    $configuredModel = $ExplicitModel
    $configuredEndpoint = $ExplicitEndpoint
    $statePath = Join-Path $ContextRoot '_evidence\state.md'
    if (Test-Path -LiteralPath $statePath -PathType Leaf) {
        $state = [IO.File]::ReadAllText($statePath, [Text.Encoding]::UTF8)
        if (-not $configuredMode) {
            $match = [regex]::Match($state, '(?m)^Search mode:\s+`(auto|off|lexical|hybrid)`\s*$')
            if ($match.Success) { $configuredMode = $match.Groups[1].Value }
        }
        if (-not $configuredModel) {
            $match = [regex]::Match($state, '(?m)^Embedding model:\s+`([^`]+)`\s*$')
            if ($match.Success) { $configuredModel = $match.Groups[1].Value }
        }
        if (-not $configuredEndpoint) {
            $match = [regex]::Match($state, '(?m)^Embedding endpoint:\s+`([^`]+)`\s*$')
            if ($match.Success) { $configuredEndpoint = $match.Groups[1].Value }
        }
    }
    if (-not $configuredMode) { $configuredMode = 'auto' }
    if (-not $configuredModel) { $configuredModel = 'embeddinggemma' }
    if (-not $configuredEndpoint) { $configuredEndpoint = 'http://127.0.0.1:11434' }

    return [pscustomobject]@{
        SearchMode = $configuredMode
        EmbeddingModel = $configuredModel
        EmbeddingEndpoint = $configuredEndpoint
    }
}

function Invoke-IndexQuery {
    param(
        [Parameter(Mandatory = $true)][string]$Python,
        [Parameter(Mandatory = $true)][string]$Engine,
        [Parameter(Mandatory = $true)]$ResolvedContext,
        [Parameter(Mandatory = $true)][bool]$UseSemantic
    )

    $arguments = @(
        $Engine,
        'query',
        '--vault', $ResolvedContext.VaultRoot,
        '--collection', $ResolvedContext.Collection,
        '--context', $ResolvedContext.Context,
        '--index', $ResolvedContext.IndexPath,
        '--query', $Query,
        '--limit', [string]$Limit
    )
    if ($RawQuery) { $arguments += '--raw-query' }
    if ($IncludeExternal) { $arguments += '--include-external' }
    if ($UseSemantic) {
        $arguments += @('--semantic', '--embedding-timeout-seconds', [string]$EmbeddingTimeoutSeconds)
        $arguments += @('--embedding-endpoint', $preferences.EmbeddingEndpoint)
    }

    $global:LASTEXITCODE = 0
    $output = @(& $Python @arguments 2>&1)
    if (-not $? -or $LASTEXITCODE -ne 0) {
        throw "FTS5 search failed: $($output -join [Environment]::NewLine)"
    }
    try { return (($output -join [Environment]::NewLine) | ConvertFrom-Json) }
    catch { throw "FTS5 search returned invalid JSON: $($_.Exception.Message)" }
}

$resolved = Resolve-SearchContext `
    -RootPath $VaultPath `
    -Collection $CollectionSlug `
    -Context $ContextSlug `
    -RequestedIndexPath $IndexPath
$preferences = Get-SearchPreferences `
    -ContextRoot $resolved.ContextRoot `
    -ExplicitMode $SearchMode `
    -ExplicitModel $EmbeddingModel `
    -ExplicitEndpoint $EmbeddingEndpoint
if ($Semantic -and $LexicalOnly) {
    throw 'Semantic and LexicalOnly are mutually exclusive.'
}
$useSemantic = [bool]$Semantic -or
    (-not $LexicalOnly -and $preferences.SearchMode -in @('auto', 'hybrid'))

$ensureScript = Join-Path $PSScriptRoot 'Ensure-SecondBrainSearchIndex.ps1'
$automaticAttempted = $false
$automaticRefreshed = $false
$ensureResult = $null

function Invoke-AutomaticEnsure {
    param([switch]$Force)

    if ($NoAutoRefresh -or $preferences.SearchMode -eq 'off') { return $null }
    if (-not (Test-Path -LiteralPath $ensureScript -PathType Leaf)) {
        throw "Automatic search-index helper is missing: $ensureScript"
    }
    $parameters = @{
        VaultPath = $resolved.VaultRoot
        CollectionSlug = $resolved.Collection
        ContextSlug = $resolved.Context
        IndexPath = $resolved.IndexPath
        SearchMode = $preferences.SearchMode
        EmbeddingModel = $preferences.EmbeddingModel
        EmbeddingProbeTimeoutSeconds = $EmbeddingProbeTimeoutSeconds
        EmbeddingTimeoutSeconds = $EmbeddingTimeoutSeconds
    }
    if ($PythonPath) { $parameters.PythonPath = $PythonPath }
    $parameters.EmbeddingEndpoint = $preferences.EmbeddingEndpoint
    if ($IncludeExternal) { $parameters.IncludeExternal = $true }
    if ($Force) { $parameters.ForceRebuild = $true }
    return (& $ensureScript @parameters)
}

if (-not (Test-Path -LiteralPath $resolved.IndexPath -PathType Leaf)) {
    if (-not $NoAutoRefresh -and $preferences.SearchMode -ne 'off') {
        $automaticAttempted = $true
        $ensureResult = Invoke-AutomaticEnsure -Force
        $automaticRefreshed = $ensureResult.State -eq 'ready' -and $ensureResult.Action -eq 'rebuilt'
    }
    if (-not (Test-Path -LiteralPath $resolved.IndexPath -PathType Leaf)) {
        $reason = if ($ensureResult -and $ensureResult.Reason) { " Automatic setup: $($ensureResult.Reason)" } else { '' }
        throw "Search index does not exist: $($resolved.IndexPath). Use ordinary file search.$reason"
    }
}

$python = Resolve-PythonExecutable -ExplicitPath $PythonPath
$engine = Join-Path $PSScriptRoot 'second_brain_fts.py'
if (-not (Test-Path -LiteralPath $engine -PathType Leaf)) {
    throw "Search engine script is missing: $engine"
}
$result = Invoke-IndexQuery `
    -Python $python `
    -Engine $engine `
    -ResolvedContext $resolved `
    -UseSemantic $useSemantic

if ([bool]$result.index_stale -and
    -not $automaticAttempted -and
    -not $NoAutoRefresh -and
    $preferences.SearchMode -ne 'off') {
    $automaticAttempted = $true
    $ensureResult = Invoke-AutomaticEnsure -Force
    if ($ensureResult.State -eq 'ready' -and $ensureResult.Action -eq 'rebuilt') {
        $automaticRefreshed = $true
        $result = Invoke-IndexQuery `
            -Python $python `
            -Engine $engine `
            -ResolvedContext $resolved `
            -UseSemantic $useSemantic
    }
}

if ($useSemantic -and
    -not [bool]$result.semantic_used -and
    [string]$result.semantic_error -match 'no semantic embeddings' -and
    -not $automaticAttempted -and
    -not $NoAutoRefresh -and
    $preferences.SearchMode -in @('auto', 'hybrid')) {
    $automaticAttempted = $true
    $ensureResult = Invoke-AutomaticEnsure
    if ($ensureResult.State -eq 'ready' -and
        $ensureResult.Action -eq 'rebuilt' -and
        $ensureResult.SearchMode -eq 'hybrid') {
        $automaticRefreshed = $true
        $result = Invoke-IndexQuery `
            -Python $python `
            -Engine $engine `
            -ResolvedContext $resolved `
            -UseSemantic $true
    }
}

$results = @($result.results | ForEach-Object {
    [pscustomobject]@{
        Rank = [int]$_.rank
        Score = if ($null -ne $_.score) { [double]$_.score } else { $null }
        LexicalRank = if ($null -ne $_.lexical_rank) { [int]$_.lexical_rank } else { $null }
        SemanticRank = if ($null -ne $_.semantic_rank) { [int]$_.semantic_rank } else { $null }
        SemanticSimilarity = if ($null -ne $_.semantic_similarity) { [double]$_.semantic_similarity } else { $null }
        HybridScore = if ($null -ne $_.hybrid_score) { [double]$_.hybrid_score } else { $null }
        RetrievalModes = @($_.retrieval_modes)
        Path = $_.absolute_path
        RelativePath = $_.relative_path
        SourceTier = $_.source_tier
        Kind = $_.kind
        CaptureId = $_.capture_id
        Title = $_.title
        Heading = $_.heading
        Snippet = $_.snippet
        SourceExists = [bool]$_.source_exists
        SourceStale = [bool]$_.source_stale
    }
})
if ([bool]$result.index_stale) {
    Write-Warning 'The FTS5 index is stale. Rebuild it before relying on completeness; verify every returned source directly.'
}
if ($useSemantic -and -not [bool]$result.semantic_used) {
    Write-Warning "Semantic retrieval was unavailable and the query fell back to FTS5: $($result.semantic_error)"
}
if (@($results | Where-Object { $_.SourceStale -or -not $_.SourceExists }).Count -gt 0) {
    Write-Warning 'One or more returned sources changed or disappeared after indexing. Do not rely on their cached snippets.'
}

[pscustomobject]@{
    State = $result.state
    Query = $result.query
    EffectiveQuery = $result.effective_query
    FallbackUsed = [bool]$result.fallback_used
    IndexPath = $result.index_path
    IndexGeneratedAt = $result.index_generated_at
    IndexStale = [bool]$result.index_stale
    SemanticRequested = [bool]$result.semantic_requested
    SemanticUsed = [bool]$result.semantic_used
    SemanticError = $result.semantic_error
    EmbeddingModel = $result.embedding_model
    ConfiguredSearchMode = $preferences.SearchMode
    AutoRefreshAttempted = $automaticAttempted
    AutoRefreshed = $automaticRefreshed
    AutoRefreshMode = if ($ensureResult) { $ensureResult.SearchMode } else { $null }
    AutoRefreshReason = if ($ensureResult) { $ensureResult.Reason } else { $null }
    Results = $results
}
