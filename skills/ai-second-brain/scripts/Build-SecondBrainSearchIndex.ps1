#requires -Version 5.1

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
param(
    [Parameter(Mandatory = $true)]
    [string]$VaultPath,

    [string]$CollectionSlug,

    [string]$ContextSlug,

    [string]$IndexPath,

    [string]$PythonPath,

    [switch]$HumanOnly,

    [switch]$IncludeExternal,

    [Alias('Hybrid')]
    [switch]$Semantic,

    [ValidateSet('ollama')]
    [string]$EmbeddingProvider = 'ollama',

    [string]$EmbeddingModel,

    [string]$EmbeddingEndpoint = 'http://127.0.0.1:11434',

    [ValidateRange(1, 128)]
    [int]$EmbeddingBatchSize = 32,

    [ValidateRange(1, 600)]
    [int]$EmbeddingTimeoutSeconds = 120,

    [ValidateRange(1000, 50000)]
    [int]$EmbeddingMaxCharacters = 8000
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
    if ([IO.Path]::GetExtension($resolvedIndexPath).ToLowerInvariant() -ne '.sqlite') {
        throw 'IndexPath must use the .sqlite extension.'
    }
    return [pscustomobject]@{
        VaultRoot = $vaultRoot
        Collection = $Collection
        Context = $Context
        ContextRoot = [IO.Path]::GetFullPath($contextRoot)
        IndexPath = $resolvedIndexPath
    }
}

$resolved = Resolve-SearchContext `
    -RootPath $VaultPath `
    -Collection $CollectionSlug `
    -Context $ContextSlug `
    -RequestedIndexPath $IndexPath

if ($Semantic -and -not $EmbeddingModel) {
    throw 'EmbeddingModel is required with -Semantic.'
}
if (-not $Semantic -and $PSBoundParameters.ContainsKey('EmbeddingModel')) {
    throw 'EmbeddingModel is valid only with -Semantic.'
}

if (-not $PSCmdlet.ShouldProcess(
    $resolved.IndexPath,
    "Rebuild the disposable FTS5 index for $($resolved.Collection)/$($resolved.Context)"
)) {
    [pscustomobject]@{
        State = 'preview'
        IndexPath = $resolved.IndexPath
        Collection = $resolved.Collection
        Context = $resolved.Context
        IncludeEvidence = (-not $HumanOnly)
        IncludeExternal = [bool]$IncludeExternal
        SemanticEnabled = [bool]$Semantic
        EmbeddingProvider = if ($Semantic) { $EmbeddingProvider } else { $null }
        EmbeddingModel = if ($Semantic) { $EmbeddingModel } else { $null }
        EmbeddingEndpoint = if ($Semantic) { $EmbeddingEndpoint } else { $null }
    }
    return
}

$python = Resolve-PythonExecutable -ExplicitPath $PythonPath
$engine = Join-Path $PSScriptRoot 'second_brain_fts.py'
if (-not (Test-Path -LiteralPath $engine -PathType Leaf)) {
    throw "Search engine script is missing: $engine"
}
$arguments = @(
    $engine,
    'build',
    '--vault', $resolved.VaultRoot,
    '--collection', $resolved.Collection,
    '--context', $resolved.Context,
    '--index', $resolved.IndexPath
)
if ($HumanOnly) { $arguments += '--exclude-evidence' }
if ($IncludeExternal) { $arguments += '--include-external' }
if ($Semantic) {
    $arguments += @(
        '--semantic',
        '--embedding-provider', $EmbeddingProvider,
        '--embedding-model', $EmbeddingModel,
        '--embedding-endpoint', $EmbeddingEndpoint,
        '--embedding-batch-size', [string]$EmbeddingBatchSize,
        '--embedding-timeout-seconds', [string]$EmbeddingTimeoutSeconds,
        '--embedding-max-characters', [string]$EmbeddingMaxCharacters
    )
}

$global:LASTEXITCODE = 0
$output = @(& $python @arguments 2>&1)
if (-not $? -or $LASTEXITCODE -ne 0) {
    throw "FTS5 index build failed: $($output -join [Environment]::NewLine)"
}
try { $result = ($output -join [Environment]::NewLine) | ConvertFrom-Json }
catch { throw "FTS5 index builder returned invalid JSON: $($_.Exception.Message)" }

[pscustomobject]@{
    State = $result.state
    IndexPath = $result.index_path
    Collection = $result.collection
    Context = $result.context
    Files = [int]$result.files
    Sections = [int]$result.sections
    IncludeEvidence = [bool]$result.include_evidence
    IncludeExternal = [bool]$result.include_external
    TreeFingerprint = $result.tree_fingerprint
    SQLiteVersion = $result.sqlite_version
    SemanticEnabled = [bool]$result.semantic_enabled
    EmbeddingProvider = $result.embedding_provider
    EmbeddingModel = $result.embedding_model
    EmbeddingEndpoint = $result.embedding_endpoint
    EmbeddingDimension = [int]$result.embedding_dimension
    SemanticSections = [int]$result.semantic_sections
}
