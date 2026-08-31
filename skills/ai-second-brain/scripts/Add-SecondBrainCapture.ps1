#requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$VaultPath,

    [Parameter(Mandatory = $true)]
    [ValidateSet('text', 'voice', 'screenshot', 'video')]
    [string]$InputType,

    [Parameter(Mandatory = $true)]
    [AllowEmptyString()]
    [string]$Content,

    [string]$UserCaption,

    [string]$Title,

    [string[]]$Keywords,

    [string]$AttachmentPath,

    [string]$SessionId,

    [string]$CollectionSlug,

    [string]$ContextSlug,

    [string]$CaptureId,

    [string]$CaptureGroupId,

    [string]$PreviousCaptureGroupId,

    [ValidateRange(1, 1000)]
    [int]$GroupOrdinal = 1
)

$ErrorActionPreference = 'Stop'
$script:Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Write-NewUtf8File {
    param(
        [Parameter(Mandatory = $true)][string]$LiteralPath,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$FileContent
    )

    $stream = New-Object IO.FileStream(
        $LiteralPath,
        [IO.FileMode]::CreateNew,
        [IO.FileAccess]::Write,
        [IO.FileShare]::Read
    )
    try {
        $writer = New-Object IO.StreamWriter($stream, $script:Utf8NoBom)
        try { $writer.Write($FileContent) }
        finally { $writer.Dispose() }
    }
    finally {
        if ($stream) { $stream.Dispose() }
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

function ConvertTo-SafeSlug {
    param([string]$Value)

    if (-not $Value) { return $null }
    $normalized = $Value.Normalize([Text.NormalizationForm]::FormD)
    $builder = New-Object Text.StringBuilder
    foreach ($character in $normalized.ToCharArray()) {
        $category = [Globalization.CharUnicodeInfo]::GetUnicodeCategory($character)
        if ($category -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$builder.Append($character)
        }
    }

    $slug = $builder.ToString().Normalize([Text.NormalizationForm]::FormC).ToLowerInvariant()
    $slug = [regex]::Replace($slug, '[^a-z0-9]+', '-').Trim('-')
    if ($slug.Length -gt 64) { $slug = $slug.Substring(0, 64).Trim('-') }
    if (-not $slug) { return $null }
    return $slug
}

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
foreach ($slug in @($CollectionSlug, $ContextSlug)) {
    if ($slug -notmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') {
        throw "Invalid collection or context slug '$slug'."
    }
}
if (-not $SessionId) { $SessionId = 'session-' + (Get-Date -Format 'yyyyMMdd') }
if ($SessionId -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]*$') {
    throw 'SessionId must contain only letters, digits, period, underscore, or hyphen.'
}
if ($InputType -notin @('screenshot', 'video') -and $AttachmentPath) {
    throw 'AttachmentPath is valid only for screenshot or video input.'
}
if ($Title) {
    $Title = $Title.Trim()
    if ($Title -match '[\r\n]') { throw 'Title must be a single line.' }
    if ($Title.Length -gt 160) { throw 'Title must be 160 characters or fewer.' }
    if (-not $Title) { $Title = $null }
}
$normalizedKeywords = @()
foreach ($keyword in @($Keywords)) {
    if (-not $keyword) { continue }
    $normalizedKeyword = $keyword.Trim()
    if (-not $normalizedKeyword) { continue }
    if ($normalizedKeyword -match '[\r\n]') { throw 'Each keyword must be a single line.' }
    if ($normalizedKeyword.Length -gt 80) { throw 'Each keyword must be 80 characters or fewer.' }
    if ($normalizedKeyword -notin $normalizedKeywords) { $normalizedKeywords += $normalizedKeyword }
}
if ($normalizedKeywords.Count -gt 20) { throw 'At most 20 keywords are allowed.' }

$contextRoot = Join-Path $vaultRoot "collections\$CollectionSlug\contexts\$ContextSlug"
$evidenceRoot = Resolve-EvidenceRoot -ContextRoot $contextRoot
$captureRoot = Join-Path $evidenceRoot 'captures'
$attachmentRoot = Join-Path $contextRoot 'attachments'
$ledgerPath = Join-Path $evidenceRoot 'processing-events.jsonl'
foreach ($requiredPath in @($captureRoot, $attachmentRoot, $ledgerPath)) {
    if (-not (Test-Path -LiteralPath $requiredPath)) {
        throw "Active context is incomplete; missing '$requiredPath'."
    }
}

$capturedAt = Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK'
if ($CaptureId) {
    if ($CaptureId -notmatch '^CAP-\d{8}-\d{6}-[a-f0-9]{4}$') {
        throw 'CaptureId must match CAP-YYYYMMDD-HHMMSS-ffff.'
    }
}
else {
    $CaptureId = 'CAP-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' +
        ([guid]::NewGuid().ToString('N').Substring(0, 4))
}
if ($CaptureGroupId) {
    if ($CaptureGroupId -notmatch '^GRP-\d{8}-\d{6}-[a-f0-9]{4}$') {
        throw 'CaptureGroupId must match GRP-YYYYMMDD-HHMMSS-ffff.'
    }
}
else {
    $CaptureGroupId = 'GRP' + $CaptureId.Substring(3)
}
if ($PreviousCaptureGroupId -and
    $PreviousCaptureGroupId -notmatch '^GRP-\d{8}-\d{6}-[a-f0-9]{4}$') {
    throw 'PreviousCaptureGroupId must match GRP-YYYYMMDD-HHMMSS-ffff.'
}
if ($PreviousCaptureGroupId -eq $CaptureGroupId) {
    throw 'PreviousCaptureGroupId cannot equal CaptureGroupId.'
}

$captureDate = $CaptureId.Substring(4, 8)
$captureDateDirectory = '{0}-{1}-{2}' -f
    $captureDate.Substring(0, 4),
    $captureDate.Substring(4, 2),
    $captureDate.Substring(6, 2)
$dailyRoot = Join-Path $captureRoot $captureDateDirectory
if (-not (Test-Path -LiteralPath $dailyRoot)) {
    [void](New-Item -ItemType Directory -Path $dailyRoot)
}
$capturePath = Join-Path $dailyRoot "$CaptureId.md"

if (Test-Path -LiteralPath $capturePath -PathType Leaf) {
    [pscustomobject]@{
        State = 'existing-capture'
        CaptureId = $CaptureId
        CaptureGroupId = $CaptureGroupId
        CapturePath = $capturePath
        AttachmentState = 'unchanged'
    }
    return
}

$attachmentRelative = 'none'
$attachmentState = 'none'
$copiedAttachment = $null
$attachmentStem = $CaptureId
$titleSlug = ConvertTo-SafeSlug -Value $Title
if ($titleSlug) { $attachmentStem = "$CaptureId--$titleSlug" }

if ($InputType -in @('screenshot', 'video')) {
    if ($AttachmentPath) {
        if (-not [IO.Path]::IsPathRooted($AttachmentPath)) {
            throw 'AttachmentPath must be absolute.'
        }
        $attachmentSource = [IO.Path]::GetFullPath($AttachmentPath)
        if (-not (Test-Path -LiteralPath $attachmentSource -PathType Leaf)) {
            throw "Media file does not exist: $attachmentSource"
        }
        $extension = [IO.Path]::GetExtension($attachmentSource).ToLowerInvariant()
        $allowedExtensions = if ($InputType -eq 'screenshot') {
            @('.png', '.jpg', '.jpeg', '.webp', '.gif', '.bmp')
        }
        else {
            @('.mp4', '.mov', '.mkv', '.webm', '.avi', '.m4v')
        }
        if ($extension -notin $allowedExtensions) {
            throw "Unsupported $InputType extension '$extension'."
        }
        $copiedAttachment = Join-Path $attachmentRoot "$attachmentStem$extension"
        [IO.File]::Copy($attachmentSource, $copiedAttachment, $false)
        $attachmentRelative = "collections/$CollectionSlug/contexts/$ContextSlug/attachments/$attachmentStem$extension"
        $attachmentState = 'ready'
    }
    else {
        $attachmentState = 'pending-save-first'
    }
}

if (-not $UserCaption) { $UserCaption = 'None' }
$displayTitleJson = if ($Title) { ConvertTo-Json -InputObject $Title -Compress } else { 'null' }
$keywordsJson = ConvertTo-Json -InputObject @($normalizedKeywords) -Compress
$previousCaptureGroupValue = if ($PreviousCaptureGroupId) { $PreviousCaptureGroupId } else { 'null' }
$newline = [Environment]::NewLine
$captureContent = @(
    '---',
    "capture_id: $CaptureId",
    "captured_at: $capturedAt",
    "input_type: $InputType",
    "session_id: $SessionId",
    "capture_group_id: $CaptureGroupId",
    "group_ordinal: $GroupOrdinal",
    "previous_capture_group_id: $previousCaptureGroupValue",
    "display_title: $displayTitleJson",
    "keywords: $keywordsJson",
    "attachment: $attachmentRelative",
    "attachment_state: $attachmentState",
    'initial_processing_state: pending',
    '---',
    '',
    '# Original input',
    '',
    $Content,
    '',
    '# User caption',
    '',
    $UserCaption,
    ''
) -join $newline

try {
    Write-NewUtf8File -LiteralPath $capturePath -FileContent $captureContent
}
catch {
    if ($copiedAttachment -and (Test-Path -LiteralPath $copiedAttachment)) {
        Remove-Item -LiteralPath $copiedAttachment -Force
    }
    throw
}

try {
    $event = [ordered]@{
        capture_id = $CaptureId
        recorded_at = (Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK')
        state = 'pending'
        detail = if ($attachmentState -eq 'pending-save-first') {
            "$InputType evidence awaits a user-saved local file"
        }
        else {
            'awaiting assimilation'
        }
    }
    Add-Utf8Line -LiteralPath $ledgerPath -Line ($event | ConvertTo-Json -Compress)
}
catch {
    throw "Capture '$CaptureId' is durable at '$capturePath' but the processing event failed: $($_.Exception.Message)"
}

[pscustomobject]@{
    State = 'captured'
    CaptureId = $CaptureId
    CaptureGroupId = $CaptureGroupId
    PreviousCaptureGroupId = $PreviousCaptureGroupId
    GroupOrdinal = $GroupOrdinal
    CapturePath = $capturePath
    AttachmentState = $attachmentState
    AttachmentPath = $copiedAttachment
    DisplayTitle = $Title
    Keywords = @($normalizedKeywords)
}
