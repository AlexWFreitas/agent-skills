#requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$VaultPath,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^CAP-\d{8}-\d{6}-[a-f0-9]{4}$')]
    [string]$CaptureId,

    [Parameter(Mandatory = $true)]
    [ValidateSet('pending', 'interpreted', 'reconciled', 'conflicted', 'blocked', 'scope-closed')]
    [string]$State,

    [Parameter(Mandatory = $true)]
    [string]$Detail,

    [string]$CollectionSlug,

    [string]$ContextSlug
)

$ErrorActionPreference = 'Stop'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Resolve-EvidenceRoot {
    param([Parameter(Mandatory = $true)][string]$ContextRoot)

    $humanFirstRoot = Join-Path $ContextRoot '_evidence'
    $legacyRoot = Join-Path $ContextRoot 'inbox'
    $hasHumanFirst = Test-Path -LiteralPath $humanFirstRoot -PathType Container
    $hasLegacy = Test-Path -LiteralPath $legacyRoot -PathType Container
    if ($hasHumanFirst -and $hasLegacy) {
        throw "Active context has both '_evidence' and legacy 'inbox' backends. Refusing an ambiguous write."
    }
    if ($hasHumanFirst) { return $humanFirstRoot }
    if ($hasLegacy) { return $legacyRoot }
    throw "Active context has no evidence backend: $ContextRoot"
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

$contextRoot = Join-Path $vaultRoot "collections\$CollectionSlug\contexts\$ContextSlug"
$evidenceRoot = Resolve-EvidenceRoot -ContextRoot $contextRoot
$captureDate = $CaptureId.Substring(4, 8)
$dateDirectory = '{0}-{1}-{2}' -f
    $captureDate.Substring(0, 4),
    $captureDate.Substring(4, 2),
    $captureDate.Substring(6, 2)
$capturePath = Join-Path $evidenceRoot "captures\$dateDirectory\$CaptureId.md"
$ledgerPath = Join-Path $evidenceRoot 'processing-events.jsonl'
if (-not (Test-Path -LiteralPath $capturePath -PathType Leaf)) {
    throw "Capture '$CaptureId' does not exist in the selected context."
}
if (-not (Test-Path -LiteralPath $ledgerPath -PathType Leaf)) {
    throw "Processing ledger does not exist: $ledgerPath"
}

$event = [ordered]@{
    capture_id = $CaptureId
    recorded_at = (Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK')
    state = $State
    detail = $Detail
}
$line = $event | ConvertTo-Json -Compress
$stream = New-Object IO.FileStream(
    $ledgerPath,
    [IO.FileMode]::Append,
    [IO.FileAccess]::Write,
    [IO.FileShare]::Read
)
try {
    $writer = New-Object IO.StreamWriter($stream, $utf8NoBom)
    try { $writer.WriteLine($line) }
    finally { $writer.Dispose() }
}
finally {
    if ($stream) { $stream.Dispose() }
}

[pscustomobject]@{
    State = $State
    CaptureId = $CaptureId
    LedgerPath = $ledgerPath
}
