#requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$VaultPath,

    [Parameter(Mandatory = $true)]
    [ValidateSet('acquire', 'view', 'release')]
    [string]$Action,

    [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9._-]{0,127}$')]
    [string]$OwnerId,

    [ValidateRange(5, 1440)]
    [int]$LeaseMinutes = 120,

    [switch]$TakeOverStale,

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
        throw "Active context has both '_evidence' and legacy 'inbox' backends. Refusing an ambiguous lock."
    }
    if ($hasHumanFirst) { return $humanFirstRoot }
    if ($hasLegacy) { return $legacyRoot }
    throw "Active context has no evidence backend: $ContextRoot"
}

function Read-LockRecord {
    param([Parameter(Mandatory = $true)][string]$LiteralPath)

    if (-not (Test-Path -LiteralPath $LiteralPath -PathType Leaf)) { return $null }
    try { return Get-Content -LiteralPath $LiteralPath -Raw | ConvertFrom-Json -ErrorAction Stop }
    catch { throw "Reconciliation lock is unreadable: $($_.Exception.Message)" }
}

function New-LockRecord {
    param(
        [Parameter(Mandatory = $true)][string]$LiteralPath,
        [Parameter(Mandatory = $true)][string]$Owner,
        [Parameter(Mandatory = $true)][int]$Minutes
    )

    $now = [DateTimeOffset]::Now
    $record = [ordered]@{
        owner_id = $Owner
        acquired_at = $now.ToString('o')
        expires_at = $now.AddMinutes($Minutes).ToString('o')
        process_id = $PID
    }
    $stream = New-Object IO.FileStream(
        $LiteralPath,
        [IO.FileMode]::CreateNew,
        [IO.FileAccess]::Write,
        [IO.FileShare]::Read
    )
    try {
        $writer = New-Object IO.StreamWriter($stream, $script:Utf8NoBom)
        try { $writer.Write(($record | ConvertTo-Json -Compress)) }
        finally { $writer.Dispose() }
    }
    finally {
        if ($stream) { $stream.Dispose() }
    }
    return [pscustomobject]$record
}

function Get-LockView {
    param($Record)

    if (-not $Record) {
        return [pscustomobject]@{
            State = 'unlocked'
            OwnerId = $null
            AcquiredAt = $null
            ExpiresAt = $null
            IsStale = $false
            LockPath = $lockPath
        }
    }
    try { $expiresAt = [DateTimeOffset]::Parse([string]$Record.expires_at) }
    catch { throw 'Reconciliation lock has an invalid expires_at value.' }
    return [pscustomobject]@{
        State = 'locked'
        OwnerId = [string]$Record.owner_id
        AcquiredAt = [string]$Record.acquired_at
        ExpiresAt = [string]$Record.expires_at
        IsStale = ($expiresAt -le [DateTimeOffset]::Now)
        LockPath = $lockPath
    }
}

if (-not [IO.Path]::IsPathRooted($VaultPath)) {
    throw 'VaultPath must be an absolute path.'
}
if ($Action -in @('acquire', 'release') -and -not $OwnerId) {
    throw 'OwnerId is required for acquire and release.'
}
if ($TakeOverStale -and $Action -ne 'acquire') {
    throw 'TakeOverStale is valid only with Action acquire.'
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
$lockPath = Join-Path $evidenceRoot 'reconciliation.lock.json'
$existing = Read-LockRecord -LiteralPath $lockPath

if ($Action -eq 'view') {
    Get-LockView -Record $existing
    return
}

if ($Action -eq 'release') {
    if (-not $existing) {
        [pscustomobject]@{
            State = 'already-unlocked'
            OwnerId = $OwnerId
            LockPath = $lockPath
        }
        return
    }
    if ([string]$existing.owner_id -ne $OwnerId) {
        throw "Reconciliation lock belongs to '$($existing.owner_id)', not '$OwnerId'."
    }
    Remove-Item -LiteralPath $lockPath -Force
    [pscustomobject]@{
        State = 'released'
        OwnerId = $OwnerId
        LockPath = $lockPath
    }
    return
}

if ($existing) {
    $view = Get-LockView -Record $existing
    if ($view.OwnerId -eq $OwnerId) {
        Remove-Item -LiteralPath $lockPath -Force
        $renewed = New-LockRecord -LiteralPath $lockPath -Owner $OwnerId -Minutes $LeaseMinutes
        [pscustomobject]@{
            State = 'renewed'
            OwnerId = [string]$renewed.owner_id
            AcquiredAt = [string]$renewed.acquired_at
            ExpiresAt = [string]$renewed.expires_at
            IsStale = $false
            LockPath = $lockPath
        }
        return
    }
    if (-not ($view.IsStale -and $TakeOverStale)) {
        $view
        return
    }
    Remove-Item -LiteralPath $lockPath -Force
}

try {
    $created = New-LockRecord -LiteralPath $lockPath -Owner $OwnerId -Minutes $LeaseMinutes
}
catch {
    if (Test-Path -LiteralPath $lockPath -PathType Leaf) {
        Get-LockView -Record (Read-LockRecord -LiteralPath $lockPath)
        return
    }
    throw
}
[pscustomobject]@{
    State = 'acquired'
    OwnerId = [string]$created.owner_id
    AcquiredAt = [string]$created.acquired_at
    ExpiresAt = [string]$created.expires_at
    IsStale = $false
    LockPath = $lockPath
}
