#requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$VaultPath,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^CAP-\d{8}-\d{6}-[a-f0-9]{4}$')]
    [string]$CaptureId,

    [string]$CollectionSlug,

    [string]$ContextSlug,

    [string]$FfmpegPath,

    [string]$FfprobePath,

    [string]$WhisperPath,

    [string]$WhisperModelPath,

    [ValidateRange(0.25, 60)]
    [double]$FrameIntervalSeconds = 1,

    [ValidateRange(1, 10000)]
    [int]$MaxFrames = 1200,

    [ValidatePattern('^(auto|[a-z]{2,3})$')]
    [string]$Language = 'auto'
)

$ErrorActionPreference = 'Stop'
$script:Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Resolve-Executable {
    param(
        [string]$ExplicitPath,
        [string]$CommandName,
        [string]$Purpose,
        [string[]]$CandidatePaths = @(),
        [string]$SearchDescription = 'PATH'
    )

    if ($ExplicitPath) {
        if (-not [IO.Path]::IsPathRooted($ExplicitPath)) {
            throw "$Purpose path must be absolute."
        }
        $resolved = [IO.Path]::GetFullPath($ExplicitPath)
        if (-not (Test-Path -LiteralPath $resolved -PathType Leaf)) {
            throw "$Purpose executable does not exist: $resolved"
        }
        return $resolved
    }

    foreach ($candidatePath in @($CandidatePaths)) {
        if (-not $candidatePath -or -not [IO.Path]::IsPathRooted($candidatePath)) { continue }
        $resolvedCandidate = [IO.Path]::GetFullPath($candidatePath)
        if (Test-Path -LiteralPath $resolvedCandidate -PathType Leaf) {
            return $resolvedCandidate
        }
    }

    $command = Get-Command $CommandName -CommandType Application -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if (-not $command) {
        throw "$Purpose is required but '$CommandName' was not found after checking $SearchDescription."
    }
    return $command.Source
}

function Resolve-RequiredFile {
    param(
        [string]$ExplicitPath,
        [string]$Purpose,
        [string[]]$CandidatePaths = @(),
        [string]$SearchDescription
    )

    if ($ExplicitPath) {
        if (-not [IO.Path]::IsPathRooted($ExplicitPath)) {
            throw "$Purpose path must be absolute."
        }
        $resolved = [IO.Path]::GetFullPath($ExplicitPath)
        if (-not (Test-Path -LiteralPath $resolved -PathType Leaf)) {
            throw "$Purpose does not exist: $resolved"
        }
        return $resolved
    }

    foreach ($candidatePath in @($CandidatePaths)) {
        if (-not $candidatePath -or -not [IO.Path]::IsPathRooted($candidatePath)) { continue }
        $resolvedCandidate = [IO.Path]::GetFullPath($candidatePath)
        if (Test-Path -LiteralPath $resolvedCandidate -PathType Leaf) {
            return $resolvedCandidate
        }
    }

    throw "$Purpose is required but no readable file was found after checking $SearchDescription."
}

function Get-RecordedRuntimePath {
    param([string]$RecordPath, [string]$Label)

    if (-not (Test-Path -LiteralPath $RecordPath -PathType Leaf)) { return $null }
    $record = Get-Content -LiteralPath $RecordPath -Raw
    $pattern = '(?im)^\s*-\s*' + [regex]::Escape($Label) + ':\s*`([^`]+)`'
    $match = [regex]::Match($record, $pattern)
    if (-not $match.Success) { return $null }

    $candidatePath = $match.Groups[1].Value.Trim()
    if (-not [IO.Path]::IsPathRooted($candidatePath)) { return $null }
    return [IO.Path]::GetFullPath($candidatePath)
}

function Get-StableWhisperRoot {
    $userProfilePath = [Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile)
    if (-not $userProfilePath) { return $null }
    return Join-Path $userProfilePath '.codex\local-tools\whisper.cpp'
}

function Find-StableWhisperExecutable {
    param([string]$WhisperRoot)

    if (-not $WhisperRoot -or -not (Test-Path -LiteralPath $WhisperRoot -PathType Container)) {
        return $null
    }
    $candidate = Get-ChildItem -LiteralPath $WhisperRoot -Recurse -Filter 'whisper-cli.exe' -File `
        -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '[\\/]_download[\\/]' } |
        Sort-Object @{ Expression = { $_.LastWriteTimeUtc }; Descending = $true }, FullName |
        Select-Object -First 1
    if ($candidate) { return $candidate.FullName }
    return $null
}

function Find-StableWhisperModel {
    param([string]$WhisperRoot)

    if (-not $WhisperRoot) { return $null }
    $modelRoot = Join-Path $WhisperRoot 'models'
    foreach ($modelName in @('ggml-small.bin', 'ggml-base.bin', 'ggml-medium.bin', 'ggml-tiny.bin')) {
        $candidatePath = Join-Path $modelRoot $modelName
        if (Test-Path -LiteralPath $candidatePath -PathType Leaf) {
            return [IO.Path]::GetFullPath($candidatePath)
        }
    }
    return $null
}

function Write-Utf8File {
    param([string]$LiteralPath, [AllowEmptyString()][string]$Content)
    [IO.File]::WriteAllText($LiteralPath, $Content, $script:Utf8NoBom)
}

function Invoke-CheckedTool {
    param([string]$LiteralPath, [string[]]$Arguments, [string]$Purpose)

    $global:LASTEXITCODE = 0
    & $LiteralPath @Arguments
    if (-not $? -or $LASTEXITCODE -ne 0) {
        throw "$Purpose failed with exit code $LASTEXITCODE."
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
if (-not $captureText.Contains('input_type: video')) {
    throw "Capture '$CaptureId' is not a video capture."
}

$attachmentRoot = Join-Path $contextRoot 'attachments'
$attachments = @(Get-ChildItem -LiteralPath $attachmentRoot -Filter "$CaptureId.*" -File |
    Where-Object { $_.Extension.ToLowerInvariant() -in @('.mp4', '.mov', '.mkv', '.webm', '.avi', '.m4v') })
if ($attachments.Count -ne 1) {
    throw "Capture '$CaptureId' must have exactly one durable video attachment before processing."
}
$videoPath = $attachments[0].FullName

$ffmpeg = Resolve-Executable -ExplicitPath $FfmpegPath -CommandName 'ffmpeg' -Purpose 'FFmpeg'
$ffprobe = Resolve-Executable -ExplicitPath $FfprobePath -CommandName 'ffprobe' -Purpose 'FFprobe'

$global:LASTEXITCODE = 0
$probeLines = @(& $ffprobe -v error -show_format -show_streams -of json $videoPath)
if (-not $? -or $LASTEXITCODE -ne 0) {
    throw "FFprobe failed with exit code $LASTEXITCODE."
}
$probeText = $probeLines -join [Environment]::NewLine
try { $probe = $probeText | ConvertFrom-Json }
catch { throw "FFprobe did not return valid JSON: $($_.Exception.Message)" }

$videoStreams = @($probe.streams | Where-Object { $_.codec_type -eq 'video' })
$audioStreams = @($probe.streams | Where-Object { $_.codec_type -eq 'audio' })
if ($videoStreams.Count -eq 0) { throw "Attachment '$videoPath' contains no video stream." }

$duration = 0.0
if ($probe.format.duration) {
    [void][double]::TryParse(
        [string]$probe.format.duration,
        [Globalization.NumberStyles]::Float,
        [Globalization.CultureInfo]::InvariantCulture,
        [ref]$duration
    )
}
$effectiveInterval = $FrameIntervalSeconds
if ($duration -gt 0 -and [Math]::Ceiling($duration / $effectiveInterval) -gt $MaxFrames) {
    $effectiveInterval = $duration / $MaxFrames
}

$whisper = $null
$model = $null
if ($audioStreams.Count -gt 0) {
    $mediaRoot = Join-Path $contextRoot 'inbox\media-processing'
    $runtimeRecordPath = Join-Path $mediaRoot 'processing-runtime.md'
    $stableWhisperRoot = Get-StableWhisperRoot
    $recordedWhisperPath = Get-RecordedRuntimePath `
        -RecordPath $runtimeRecordPath `
        -Label 'Extracted executable'
    $recordedModelPath = Get-RecordedRuntimePath `
        -RecordPath $runtimeRecordPath `
        -Label 'Model path'
    $stableWhisperPath = Find-StableWhisperExecutable -WhisperRoot $stableWhisperRoot
    $stableModelPath = Find-StableWhisperModel -WhisperRoot $stableWhisperRoot
    $runtimeSearchDescription = "the active vault runtime record, the stable Codex local-tools directory, and PATH"
    $modelSearchDescription = "the active vault runtime record and the stable Codex local-tools directory"

    $whisper = Resolve-Executable `
        -ExplicitPath $WhisperPath `
        -CommandName 'whisper-cli' `
        -Purpose 'whisper.cpp' `
        -CandidatePaths @($recordedWhisperPath, $stableWhisperPath) `
        -SearchDescription $runtimeSearchDescription
    $model = Resolve-RequiredFile `
        -ExplicitPath $WhisperModelPath `
        -Purpose 'Whisper model' `
        -CandidatePaths @($recordedModelPath, $stableModelPath) `
        -SearchDescription $modelSearchDescription
}

$mediaRoot = Join-Path $contextRoot 'inbox\media-processing'
if (-not (Test-Path -LiteralPath $mediaRoot)) {
    [void](New-Item -ItemType Directory -Path $mediaRoot)
}
$targetRoot = Join-Path $mediaRoot $CaptureId
if (Test-Path -LiteralPath $targetRoot) {
    [pscustomobject]@{
        State = 'existing-processing'
        CaptureId = $CaptureId
        ProcessingPath = $targetRoot
    }
    return
}

$temporaryRoot = Join-Path $mediaRoot ('.' + $CaptureId + '-' + [guid]::NewGuid().ToString('N'))
$mediaRootFull = [IO.Path]::GetFullPath($mediaRoot).TrimEnd('\') + '\'
$temporaryFull = [IO.Path]::GetFullPath($temporaryRoot)
if (-not $temporaryFull.StartsWith($mediaRootFull, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Refusing to use a temporary directory outside the active media-processing directory.'
}

try {
    [void](New-Item -ItemType Directory -Path $temporaryRoot)
    $framesRoot = Join-Path $temporaryRoot 'frames'
    [void](New-Item -ItemType Directory -Path $framesRoot)
    Write-Utf8File -LiteralPath (Join-Path $temporaryRoot 'ffprobe.json') -Content $probeText

    $intervalText = $effectiveInterval.ToString('0.###', [Globalization.CultureInfo]::InvariantCulture)
    $framePattern = Join-Path $framesRoot 'frame-%06d.jpg'
    Invoke-CheckedTool -LiteralPath $ffmpeg -Purpose 'Video frame extraction' -Arguments @(
        '-hide_banner', '-loglevel', 'error', '-y', '-i', $videoPath,
        '-map', '0:v:0', '-vf', "fps=1/$intervalText", '-q:v', '2', $framePattern
    )

    $frameFiles = @(Get-ChildItem -LiteralPath $framesRoot -Filter 'frame-*.jpg' -File | Sort-Object Name)
    if ($frameFiles.Count -eq 0) { throw 'Video processing produced no reviewable frames.' }
    $frameEntries = @()
    for ($index = 0; $index -lt $frameFiles.Count; $index++) {
        $frameEntries += [pscustomobject][ordered]@{
            index = $index + 1
            timestamp_seconds = [Math]::Round($index * $effectiveInterval, 3)
            path = "frames/$($frameFiles[$index].Name)"
        }
    }
    Write-Utf8File -LiteralPath (Join-Path $temporaryRoot 'frames.json') -Content (
        ConvertTo-Json -InputObject $frameEntries -Depth 4
    )

    $transcriptionState = 'no-audio'
    if ($audioStreams.Count -gt 0) {
        $audioPath = Join-Path $temporaryRoot 'audio.wav'
        Invoke-CheckedTool -LiteralPath $ffmpeg -Purpose 'Video audio extraction' -Arguments @(
            '-hide_banner', '-loglevel', 'error', '-y', '-i', $videoPath,
            '-map', '0:a:0', '-vn', '-ar', '16000', '-ac', '1', '-c:a', 'pcm_s16le', $audioPath
        )
        $transcriptPrefix = Join-Path $temporaryRoot 'audio-transcript'
        Invoke-CheckedTool -LiteralPath $whisper -Purpose 'Offline speech transcription' -Arguments @(
            '-m', $model, '-f', $audioPath, '-l', $Language,
            '-oj', '-osrt', '-of', $transcriptPrefix, '-np'
        )
        foreach ($requiredTranscript in @("$transcriptPrefix.json", "$transcriptPrefix.srt")) {
            if (-not (Test-Path -LiteralPath $requiredTranscript -PathType Leaf)) {
                throw "Offline transcription did not create '$requiredTranscript'."
            }
        }
        $transcriptionState = 'machine-transcript-ready'
    }

    $manifest = [ordered]@{
        capture_id = $CaptureId
        generated_at = (Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK')
        source_attachment = "../../../attachments/$($attachments[0].Name)"
        duration_seconds = [Math]::Round($duration, 3)
        frame_interval_seconds = [Math]::Round($effectiveInterval, 3)
        frame_count = $frameFiles.Count
        visual_coverage = 'sampled-frames'
        audio_stream_count = $audioStreams.Count
        transcription_state = $transcriptionState
        language = if ($audioStreams.Count -gt 0) { $Language } else { 'none' }
    }
    Write-Utf8File -LiteralPath (Join-Path $temporaryRoot 'manifest.json') -Content (
        $manifest | ConvertTo-Json -Depth 4
    )

    [IO.Directory]::Move($temporaryRoot, $targetRoot)
}
catch {
    if (Test-Path -LiteralPath $temporaryRoot) {
        Remove-Item -LiteralPath $temporaryRoot -Recurse -Force
    }
    throw
}

$eventScript = Join-Path $PSScriptRoot 'Add-SecondBrainProcessingEvent.ps1'
$eventDetail = if ($audioStreams.Count -gt 0) {
    "video frames and offline audio transcript prepared at collections/$CollectionSlug/contexts/$ContextSlug/inbox/media-processing/$CaptureId"
}
else {
    "video frames prepared; source has no audio stream; derivatives at collections/$CollectionSlug/contexts/$ContextSlug/inbox/media-processing/$CaptureId"
}
[void](& $eventScript `
    -VaultPath $vaultRoot `
    -CaptureId $CaptureId `
    -State pending `
    -Detail $eventDetail `
    -CollectionSlug $CollectionSlug `
    -ContextSlug $ContextSlug)

[pscustomobject]@{
    State = 'media-ready'
    CaptureId = $CaptureId
    ProcessingPath = $targetRoot
    FrameCount = $frameFiles.Count
    AudioStreamCount = $audioStreams.Count
    TranscriptionState = $transcriptionState
}
