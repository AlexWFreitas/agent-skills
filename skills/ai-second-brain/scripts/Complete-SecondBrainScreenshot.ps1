#requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$VaultPath,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^CAP-\d{8}-\d{6}-[a-f0-9]{4}$')]
    [string]$CaptureId,

    [Parameter(Mandatory = $true)]
    [string]$AttachmentPath,

    [string]$CollectionSlug,

    [string]$ContextSlug
)

$ErrorActionPreference = 'Stop'

if (-not [IO.Path]::IsPathRooted($VaultPath)) {
    throw 'VaultPath must be an absolute path.'
}
if (-not [IO.Path]::IsPathRooted($AttachmentPath)) {
    throw 'AttachmentPath must be absolute.'
}
$vaultRoot = [IO.Path]::GetFullPath($VaultPath)
$attachmentSource = [IO.Path]::GetFullPath($AttachmentPath)
if (-not (Test-Path -LiteralPath $attachmentSource -PathType Leaf)) {
    throw "Screenshot file does not exist: $attachmentSource"
}

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
$captureDate = $CaptureId.Substring(4, 8)
$dateDirectory = '{0}-{1}-{2}' -f
    $captureDate.Substring(0, 4),
    $captureDate.Substring(4, 2),
    $captureDate.Substring(6, 2)
$capturePath = Join-Path $contextRoot "inbox\captures\$dateDirectory\$CaptureId.md"
if (-not (Test-Path -LiteralPath $capturePath -PathType Leaf)) {
    throw "Capture '$CaptureId' does not exist in the selected context."
}
$captureText = Get-Content -LiteralPath $capturePath -Raw
if (-not $captureText.Contains('input_type: screenshot')) {
    throw "Capture '$CaptureId' is not a screenshot capture."
}

$extension = [IO.Path]::GetExtension($attachmentSource).ToLowerInvariant()
if ($extension -notin @('.png', '.jpg', '.jpeg', '.webp', '.gif', '.bmp')) {
    throw "Unsupported screenshot extension '$extension'."
}
$attachmentRoot = Join-Path $contextRoot 'attachments'
$existing = @(Get-ChildItem -LiteralPath $attachmentRoot -Filter "$CaptureId.*" -File)
if ($existing.Count -gt 0) {
    throw "Capture '$CaptureId' already has a durable attachment: $($existing[0].FullName)"
}

$destination = Join-Path $attachmentRoot "$CaptureId$extension"
[IO.File]::Copy($attachmentSource, $destination, $false)
try {
    $eventScript = Join-Path $PSScriptRoot 'Add-SecondBrainProcessingEvent.ps1'
    [void](& $eventScript `
        -VaultPath $vaultRoot `
        -CaptureId $CaptureId `
        -State pending `
        -Detail "screenshot attachment ready at collections/$CollectionSlug/contexts/$ContextSlug/attachments/$CaptureId$extension" `
        -CollectionSlug $CollectionSlug `
        -ContextSlug $ContextSlug)
}
catch {
    if (Test-Path -LiteralPath $destination) { Remove-Item -LiteralPath $destination -Force }
    throw
}

[pscustomobject]@{
    State = 'attachment-ready'
    CaptureId = $CaptureId
    AttachmentPath = $destination
}
