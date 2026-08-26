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

    [switch]$IncludeExternal
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

$resolved = Resolve-SearchContext `
    -RootPath $VaultPath `
    -Collection $CollectionSlug `
    -Context $ContextSlug `
    -RequestedIndexPath $IndexPath
if (-not (Test-Path -LiteralPath $resolved.IndexPath -PathType Leaf)) {
    throw "Search index does not exist: $($resolved.IndexPath). Build it first or use ordinary file search."
}
$python = Resolve-PythonExecutable -ExplicitPath $PythonPath
$engine = Join-Path $PSScriptRoot 'second_brain_fts.py'
if (-not (Test-Path -LiteralPath $engine -PathType Leaf)) {
    throw "Search engine script is missing: $engine"
}
$arguments = @(
    $engine,
    'query',
    '--vault', $resolved.VaultRoot,
    '--collection', $resolved.Collection,
    '--context', $resolved.Context,
    '--index', $resolved.IndexPath,
    '--query', $Query,
    '--limit', [string]$Limit
)
if ($RawQuery) { $arguments += '--raw-query' }
if ($IncludeExternal) { $arguments += '--include-external' }

$global:LASTEXITCODE = 0
$output = @(& $python @arguments 2>&1)
if (-not $? -or $LASTEXITCODE -ne 0) {
    throw "FTS5 search failed: $($output -join [Environment]::NewLine)"
}
try { $result = ($output -join [Environment]::NewLine) | ConvertFrom-Json }
catch { throw "FTS5 search returned invalid JSON: $($_.Exception.Message)" }

$results = @($result.results | ForEach-Object {
    [pscustomobject]@{
        Rank = [int]$_.rank
        Score = [double]$_.score
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
    Results = $results
}
