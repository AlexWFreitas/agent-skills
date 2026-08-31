#requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$VaultPath,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[A-Za-z][A-Za-z0-9._:-]{0,127}$')]
    [string]$SourceId,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-z0-9]+(?:-[a-z0-9]+)*$')]
    [string]$RelationType,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[A-Za-z][A-Za-z0-9._:-]{0,127}$')]
    [string]$TargetId,

    [Parameter(Mandatory = $true)]
    [ValidateScript({ $_ -match '^CAP-\d{8}-\d{6}-[a-f0-9]{4}$' })]
    [string[]]$EvidenceCaptureId,

    [ValidateSet('active', 'candidate', 'superseded', 'rejected')]
    [string]$Status = 'active',

    [Parameter(Mandatory = $true)]
    [ValidateLength(1, 2000)]
    [string]$Detail,

    [ValidatePattern('^REL-\d{8}-\d{6}-[a-f0-9]{4}$')]
    [string]$RelationId,

    [ValidatePattern('^REL-\d{8}-\d{6}-[a-f0-9]{4}$')]
    [string]$SupersedesRelationId,

    [string]$CollectionSlug,

    [string]$ContextSlug
)

$ErrorActionPreference = 'Stop'
$script:Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

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

function Resolve-CapturePath {
    param(
        [Parameter(Mandatory = $true)][string]$EvidenceRoot,
        [Parameter(Mandatory = $true)][string]$CaptureId
    )

    $captureDate = $CaptureId.Substring(4, 8)
    $dateDirectory = '{0}-{1}-{2}' -f
        $captureDate.Substring(0, 4),
        $captureDate.Substring(4, 2),
        $captureDate.Substring(6, 2)
    return Join-Path $EvidenceRoot "captures\$dateDirectory\$CaptureId.md"
}

function Ensure-EmptyFile {
    param([Parameter(Mandatory = $true)][string]$LiteralPath)

    if (Test-Path -LiteralPath $LiteralPath -PathType Leaf) { return }
    try {
        $stream = New-Object IO.FileStream(
            $LiteralPath,
            [IO.FileMode]::CreateNew,
            [IO.FileAccess]::Write,
            [IO.FileShare]::Read
        )
        $stream.Dispose()
    }
    catch {
        if (-not (Test-Path -LiteralPath $LiteralPath -PathType Leaf)) { throw }
    }
}

function Add-Utf8Line {
    param(
        [Parameter(Mandatory = $true)][string]$LiteralPath,
        [Parameter(Mandatory = $true)][string]$Line
    )

    $stream = New-Object IO.FileStream(
        $LiteralPath,
        [IO.FileMode]::Append,
        [IO.FileAccess]::Write,
        [IO.FileShare]::Read
    )
    try {
        $writer = New-Object IO.StreamWriter($stream, $script:Utf8NoBom)
        try { $writer.WriteLine($Line) }
        finally { $writer.Dispose() }
    }
    finally {
        if ($stream) { $stream.Dispose() }
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
$evidenceRoot = Resolve-EvidenceRoot -ContextRoot $contextRoot
$relationsPath = Join-Path $evidenceRoot 'relations.jsonl'

$normalizedEvidence = @()
foreach ($captureId in @($EvidenceCaptureId)) {
    if ($captureId -notin $normalizedEvidence) { $normalizedEvidence += $captureId }
}
if ($normalizedEvidence.Count -gt 20) {
    throw 'At most 20 EvidenceCaptureId values are allowed.'
}
foreach ($captureId in $normalizedEvidence) {
    $capturePath = Resolve-CapturePath -EvidenceRoot $evidenceRoot -CaptureId $captureId
    if (-not (Test-Path -LiteralPath $capturePath -PathType Leaf)) {
        throw "Evidence capture '$captureId' does not exist in the selected context."
    }
}

if (-not $RelationId) {
    $RelationId = 'REL-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' +
        ([guid]::NewGuid().ToString('N').Substring(0, 4))
}

Ensure-EmptyFile -LiteralPath $relationsPath
$existingRelationIds = @{}
foreach ($line in @(Get-Content -LiteralPath $relationsPath)) {
    if (-not $line.Trim()) { continue }
    try { $relation = $line | ConvertFrom-Json -ErrorAction Stop }
    catch { throw "Relations ledger contains invalid JSON: $($_.Exception.Message)" }
    if ($relation.relation_id) { $existingRelationIds[[string]$relation.relation_id] = $true }
}
if ($existingRelationIds.ContainsKey($RelationId)) {
    [pscustomobject]@{
        State = 'existing-relation'
        RelationId = $RelationId
        RelationsPath = $relationsPath
    }
    return
}
if ($SupersedesRelationId -and -not $existingRelationIds.ContainsKey($SupersedesRelationId)) {
    throw "Superseded relation '$SupersedesRelationId' does not exist in the selected context."
}

$event = [ordered]@{
    relation_id = $RelationId
    recorded_at = (Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK')
    source_id = $SourceId
    relation = $RelationType
    target_id = $TargetId
    status = $Status
    evidence_capture_ids = @($normalizedEvidence)
    supersedes_relation_id = if ($SupersedesRelationId) { $SupersedesRelationId } else { $null }
    detail = $Detail
}
Add-Utf8Line -LiteralPath $relationsPath -Line ($event | ConvertTo-Json -Compress)

[pscustomobject]@{
    State = 'related'
    RelationId = $RelationId
    SourceId = $SourceId
    RelationType = $RelationType
    TargetId = $TargetId
    Status = $Status
    RelationsPath = $relationsPath
}
