$initializeScript = Join-Path $repositoryRoot 'skills\ai-second-brain\scripts\Initialize-SecondBrain.ps1'
$captureScript = Join-Path $repositoryRoot 'skills\ai-second-brain\scripts\Add-SecondBrainCapture.ps1'
$completeScreenshotScript = Join-Path $repositoryRoot 'skills\ai-second-brain\scripts\Complete-SecondBrainScreenshot.ps1'
$completeVideoScript = Join-Path $repositoryRoot 'skills\ai-second-brain\scripts\Complete-SecondBrainVideo.ps1'
$processVideoScript = Join-Path $repositoryRoot 'skills\ai-second-brain\scripts\Process-SecondBrainVideo.ps1'
$processingEventScript = Join-Path $repositoryRoot 'skills\ai-second-brain\scripts\Add-SecondBrainProcessingEvent.ps1'
$skillPath = Join-Path $repositoryRoot 'skills\ai-second-brain\SKILL.md'
$validationScenariosPath = Join-Path $repositoryRoot 'skills\ai-second-brain\references\validation-scenarios.md'

function New-SecondBrainFixture {
    param([string]$Name)

    $vault = Join-Path $script:TemporaryRoot $Name
    $result = & $initializeScript `
        -VaultPath $vault `
        -CollectionName 'Test Subject' `
        -CollectionSlug 'test-subject' `
        -VaultTitle 'Test Brain' `
        -ContextTitle 'Main Test' `
        -ContextScope 'Only supplied test evidence.' `
        -ActivityTemplate 'game-playthrough'
    Assert-Equal 'initialized' $result.State 'Fixture initialization did not report success.'
    return $vault
}

Invoke-Test 'second brain initializer creates the portable context contract' {
    $vault = New-SecondBrainFixture 'second-brain-init'
    $context = Join-Path $vault 'collections\test-subject\contexts\main'

    foreach ($path in @(
        (Join-Path $vault 'AGENTS.md'),
        (Join-Path $vault 'second-brain.md'),
        (Join-Path $context 'context.md'),
        (Join-Path $context 'timeline.md'),
        (Join-Path $context 'open-items.md'),
        (Join-Path $context 'inbox\captures'),
        (Join-Path $context 'inbox\interpretations'),
        (Join-Path $context 'inbox\media-processing'),
        (Join-Path $context 'inbox\processing-events.jsonl'),
        (Join-Path $context 'topics'),
        (Join-Path $context 'attachments'),
        (Join-Path $context 'external')
    )) {
        Assert-True (Test-Path -LiteralPath $path) "Expected initialized path '$path'."
    }

    $allText = (Get-Content -Raw (Join-Path $vault 'second-brain.md')) +
        (Get-Content -Raw (Join-Path $context 'context.md'))
    Assert-False ($allText -match '\{\{[A-Z_]+\}\}') 'Initializer left an unresolved template token.'
    Assert-True ($allText -match 'test-subject') 'Initializer did not write the collection slug.'
}

Invoke-Test 'second brain initializer is compatible on exact re-entry and refuses collisions' {
    $vault = New-SecondBrainFixture 'second-brain-reentry'
    $indexPath = Join-Path $vault 'second-brain.md'
    $before = Get-Content -Raw $indexPath
    $result = & $initializeScript -VaultPath $vault -CollectionName 'Test Subject' -CollectionSlug 'test-subject'
    Assert-Equal 'existing-compatible' $result.State 'Compatible re-entry was not detected.'
    Assert-Equal $before (Get-Content -Raw $indexPath) 'Compatible re-entry rewrote the root index.'

    $collisionVault = Join-Path $script:TemporaryRoot 'second-brain-collision'
    [void](New-Item -ItemType Directory -Path $collisionVault)
    Set-Content -LiteralPath (Join-Path $collisionVault 'AGENTS.md') -Value 'unrelated instructions'
    $threw = $false
    try {
        & $initializeScript -VaultPath $collisionVault -CollectionName 'Collision' *> $null
    }
    catch { $threw = $true }
    Assert-True $threw 'Initializer did not refuse an incompatible target.'
    Assert-Equal 'unrelated instructions' ((Get-Content -Raw (Join-Path $collisionVault 'AGENTS.md')).Trim()) 'Collision file changed.'
}

Invoke-Test 'second brain text and voice captures are immutable transcript evidence' {
    $vault = New-SecondBrainFixture 'second-brain-text-voice'
    $textResult = & $captureScript -VaultPath $vault -InputType text -Content 'I found a sealed red door.'
    $voiceResult = & $captureScript -VaultPath $vault -InputType voice -Content 'Corrected spoken note.'

    Assert-Equal 'captured' $textResult.State 'Text capture failed.'
    Assert-Equal 'captured' $voiceResult.State 'Voice capture failed.'
    Assert-True ($textResult.CaptureId -ne $voiceResult.CaptureId) 'Capture IDs were not unique.'

    $textEvidence = Get-Content -Raw $textResult.CapturePath
    $voiceEvidence = Get-Content -Raw $voiceResult.CapturePath
    Assert-True ($textEvidence.Contains('I found a sealed red door.')) 'Text evidence was not preserved.'
    Assert-True ($voiceEvidence.Contains('input_type: voice')) 'Voice input type was not preserved.'
    Assert-True ($voiceEvidence.Contains('Corrected spoken note.')) 'Corrected transcript was not preserved.'
    Assert-False ($voiceEvidence -match '\.(wav|mp3|m4a)') 'Voice evidence unexpectedly references raw audio.'

    $ledger = Get-Content (Join-Path $vault 'collections\test-subject\contexts\main\inbox\processing-events.jsonl')
    Assert-Equal 2 @($ledger).Count 'Each capture did not append exactly one processing event.'
}

Invoke-Test 'second brain screenshot capture copies local evidence or remains visibly pending' {
    $vault = New-SecondBrainFixture 'second-brain-screenshot'
    $imagePath = Join-Path $script:TemporaryRoot 'test-image.png'
    [IO.File]::WriteAllBytes($imagePath, [byte[]](0x89, 0x50, 0x4e, 0x47))

    $ready = & $captureScript `
        -VaultPath $vault `
        -InputType screenshot `
        -Content 'Map screen after opening the gate.' `
        -UserCaption 'The red marker is mine.' `
        -AttachmentPath $imagePath
    Assert-Equal 'ready' $ready.AttachmentState 'Local screenshot did not become ready.'
    Assert-True (Test-Path -LiteralPath $ready.AttachmentPath -PathType Leaf) 'Screenshot attachment was not copied.'
    Assert-True ((Split-Path -Leaf $ready.AttachmentPath).StartsWith($ready.CaptureId)) 'Attachment filename does not use capture ID.'

    $pending = & $captureScript `
        -VaultPath $vault `
        -InputType screenshot `
        -Content 'Screenshot attached only in the composer.' `
        -UserCaption 'Needs save-first fallback.'
    Assert-Equal 'pending-save-first' $pending.AttachmentState 'Missing local screenshot did not remain pending.'
    $pendingEvidence = Get-Content -Raw $pending.CapturePath
    Assert-True ($pendingEvidence.Contains('attachment_state: pending-save-first')) 'Pending state is not durable.'

    $completed = & $completeScreenshotScript `
        -VaultPath $vault `
        -CaptureId $pending.CaptureId `
        -AttachmentPath $imagePath
    Assert-Equal 'attachment-ready' $completed.State 'Save-first screenshot was not completed.'
    Assert-True (Test-Path -LiteralPath $completed.AttachmentPath -PathType Leaf) 'Completed screenshot was not copied.'

    $ledger = Get-Content (Join-Path $vault 'collections\test-subject\contexts\main\inbox\processing-events.jsonl')
    $completionEvents = @($ledger | Where-Object { $_ -match [regex]::Escape($pending.CaptureId) })
    Assert-Equal 2 $completionEvents.Count 'Pending screenshot did not retain capture and completion events.'
}

Invoke-Test 'second brain video capture preserves media and supports save-first completion' {
    $vault = New-SecondBrainFixture 'second-brain-video-capture'
    $videoPath = Join-Path $script:TemporaryRoot 'test-video.mp4'
    [IO.File]::WriteAllBytes($videoPath, [byte[]](0x00, 0x00, 0x00, 0x18))

    $ready = & $captureScript `
        -VaultPath $vault `
        -InputType video `
        -Content 'A short clip with dialogue.' `
        -UserCaption 'Interpret the visible and audible channels.' `
        -AttachmentPath $videoPath
    Assert-Equal 'ready' $ready.AttachmentState 'Local video did not become ready.'
    Assert-True (Test-Path -LiteralPath $ready.AttachmentPath -PathType Leaf) 'Video attachment was not copied.'
    Assert-True ((Get-Content -Raw $ready.CapturePath).Contains('input_type: video')) 'Video input type was not preserved.'

    $pending = & $captureScript `
        -VaultPath $vault `
        -InputType video `
        -Content 'Composer-only video.'
    Assert-Equal 'pending-save-first' $pending.AttachmentState 'Missing local video did not remain pending.'

    $completed = & $completeVideoScript `
        -VaultPath $vault `
        -CaptureId $pending.CaptureId `
        -AttachmentPath $videoPath
    Assert-Equal 'attachment-ready' $completed.State 'Save-first video was not completed.'
    Assert-True (Test-Path -LiteralPath $completed.AttachmentPath -PathType Leaf) 'Completed video was not copied.'
}

Invoke-Test 'second brain video processing prepares frames and an offline speech transcript' {
    $vault = New-SecondBrainFixture 'second-brain-video-processing'
    $videoPath = Join-Path $script:TemporaryRoot 'processable-video.mp4'
    [IO.File]::WriteAllBytes($videoPath, [byte[]](0x00, 0x00, 0x00, 0x18))
    $capture = & $captureScript `
        -VaultPath $vault `
        -InputType video `
        -Content 'Synthetic video evidence.' `
        -AttachmentPath $videoPath

    $toolRoot = Join-Path $script:TemporaryRoot 'fake-media-tools'
    [void](New-Item -ItemType Directory -Path $toolRoot)
    $ffprobe = Join-Path $toolRoot 'ffprobe.ps1'
    $ffmpeg = Join-Path $toolRoot 'ffmpeg.ps1'
    $whisper = Join-Path $toolRoot 'whisper-cli.ps1'
    $model = Join-Path $toolRoot 'ggml-base.bin'

    Set-Content -LiteralPath $ffprobe -Encoding UTF8 -Value @'
param([Parameter(ValueFromRemainingArguments = $true)][string[]]$ToolArguments)
'{"streams":[{"codec_type":"video","codec_name":"h264"},{"codec_type":"audio","codec_name":"aac"}],"format":{"duration":"2.000"}}'
'@
    Set-Content -LiteralPath $ffmpeg -Encoding UTF8 -Value @'
param([Parameter(ValueFromRemainingArguments = $true)][string[]]$ToolArguments)
$destination = $ToolArguments[$ToolArguments.Count - 1]
if ($destination -like '*%06d*') {
    [IO.File]::WriteAllBytes($destination.Replace('%06d', '000001'), [byte[]](1, 2, 3))
    [IO.File]::WriteAllBytes($destination.Replace('%06d', '000002'), [byte[]](4, 5, 6))
}
else {
    [IO.File]::WriteAllBytes($destination, [byte[]](7, 8, 9))
}
'@
    Set-Content -LiteralPath $whisper -Encoding UTF8 -Value @'
param([Parameter(ValueFromRemainingArguments = $true)][string[]]$ToolArguments)
$outputIndex = [Array]::IndexOf($ToolArguments, '-of')
if ($outputIndex -lt 0) { throw 'Missing -of.' }
$prefix = $ToolArguments[$outputIndex + 1]
[IO.File]::WriteAllText("$prefix.json", '{"transcription":[{"timestamps":{"from":"00:00:00,000","to":"00:00:01,000"},"text":"spoken words"}]}')
[IO.File]::WriteAllText("$prefix.srt", "1`r`n00:00:00,000 --> 00:00:01,000`r`nspoken words`r`n")
'@
    [IO.File]::WriteAllBytes($model, [byte[]](10, 11, 12))
    $runtimeRecord = Join-Path $vault 'collections\test-subject\contexts\main\inbox\media-processing\processing-runtime.md'
    Set-Content -LiteralPath $runtimeRecord -Encoding UTF8 -Value @"
# Local video-processing runtime

- Install/use authorization: ``granted``
- Extracted executable: ``$whisper``
- Model path: ``$model``
"@

    $missingTranscriberFailed = $false
    try {
        & $processVideoScript `
            -VaultPath $vault `
            -CaptureId $capture.CaptureId `
            -FfmpegPath $ffmpeg `
            -FfprobePath $ffprobe `
            -WhisperPath (Join-Path $toolRoot 'missing-whisper.exe') `
            -WhisperModelPath $model *> $null
    }
    catch { $missingTranscriberFailed = $true }
    Assert-True $missingTranscriberFailed 'Video with audio did not block when offline transcription was unavailable.'

    $result = & $processVideoScript `
        -VaultPath $vault `
        -CaptureId $capture.CaptureId `
        -FfmpegPath $ffmpeg `
        -FfprobePath $ffprobe

    Assert-Equal 'media-ready' $result.State 'Video processing did not report ready media.'
    Assert-Equal 2 $result.FrameCount 'Prepared frame count was not reported.'
    Assert-Equal 'machine-transcript-ready' $result.TranscriptionState 'Audio was not transcribed offline.'
    foreach ($name in @('manifest.json', 'ffprobe.json', 'frames.json', 'audio.wav', 'audio-transcript.json', 'audio-transcript.srt')) {
        Assert-True (Test-Path -LiteralPath (Join-Path $result.ProcessingPath $name) -PathType Leaf) "Missing video derivative '$name'."
    }
    $manifest = Get-Content -Raw (Join-Path $result.ProcessingPath 'manifest.json') | ConvertFrom-Json
    Assert-Equal 'sampled-frames' $manifest.visual_coverage 'Manifest did not disclose sampled visual coverage.'
    Assert-Equal 1 $manifest.audio_stream_count 'Manifest lost stream metadata.'
    Assert-True ($manifest.source_attachment -match '^\.\./\.\./\.\./attachments/') 'Manifest source path does not reach the immutable attachment.'
    Assert-True (Test-Path -LiteralPath $capture.AttachmentPath -PathType Leaf) 'Processing changed the immutable attachment.'
}

Invoke-Test 'second brain video defaults to same-turn interpretation and durable Whisper reuse' {
    $skill = Get-Content -Raw $skillPath
    $scenarios = Get-Content -Raw $validationScenariosPath

    Assert-True ($skill.Contains('treat an attached video as a request to capture, process,')) `
        'Skill does not default an attached video to capture, processing, and interpretation.'
    Assert-True ($skill.Contains('Do not ask an')) `
        'Skill does not prohibit an extra intent question for an uncaptioned video.'
    Assert-True ($skill.Contains('continue interpretation in the same assistant turn')) `
        'Skill does not continue already-authorized dependency recovery in the same turn.'
    Assert-True ($skill.Contains('the helper reuses the active vault runtime record')) `
        'Skill does not route Whisper reuse through durable or stable discovery.'
    Assert-True ($scenarios.Contains('## V20 — Durable Whisper reuse outside PATH')) `
        'Validation scenarios do not exercise durable Whisper reuse outside PATH.'
}

Invoke-Test 'second brain capture retry with an existing capture id does not duplicate evidence' {
    $vault = New-SecondBrainFixture 'second-brain-retry'
    $captureId = 'CAP-20260726-170000-abcd'
    $first = & $captureScript -VaultPath $vault -InputType text -Content 'Retry-safe input.' -CaptureId $captureId
    $second = & $captureScript -VaultPath $vault -InputType text -Content 'Retry-safe input.' -CaptureId $captureId
    Assert-Equal 'captured' $first.State 'First explicit-ID capture failed.'
    Assert-Equal 'existing-capture' $second.State 'Retry did not detect existing capture.'

    $captureFiles = Get-ChildItem -LiteralPath (Join-Path $vault 'collections\test-subject\contexts\main\inbox\captures') -Recurse -File
    Assert-Equal 1 @($captureFiles).Count 'Retry created duplicate capture evidence.'
    $ledger = Get-Content (Join-Path $vault 'collections\test-subject\contexts\main\inbox\processing-events.jsonl')
    Assert-Equal 1 @($ledger).Count 'Retry duplicated the processing event.'
}

Invoke-Test 'second brain skill bounds compaction recovery and task rollover' {
    $skill = Get-Content -Raw $skillPath
    $scenarios = Get-Content -Raw $validationScenariosPath

    Assert-True ($skill.Contains('Before the first helper call, choose one candidate capture ID')) `
        'Skill does not preallocate a capture ID before persistence.'
    Assert-True ($skill.Contains('pass that ID through `-CaptureId`')) `
        'Skill does not require the candidate ID on the first helper call.'
    Assert-True ($skill.Contains('retry the exact capture at most once with that ID')) `
        'Skill does not bound uncertain-result capture retries.'
    Assert-True ($skill.Contains('Treat the first context compaction in a task as a rollover signal')) `
        'Skill does not roll over a task after context compaction.'
    Assert-True ($skill.Contains('If a second context compaction occurs')) `
        'Skill does not stop a repeated compaction loop.'
    Assert-True ($skill.Contains('Do not fork the saturated task')) `
        'Skill does not prevent rollover by history-preserving fork.'
    Assert-True ($skill.Contains('Lost working context is not a tool error.')) `
        'Skill does not distinguish compaction loss from a verified tool failure.'
    Assert-True ($scenarios.Contains('## V19 — Context-compaction rollover')) `
        'Validation scenarios do not exercise context-compaction rollover.'
}

Invoke-Test 'second brain processing events append without rewriting capture evidence' {
    $vault = New-SecondBrainFixture 'second-brain-processing'
    $capture = & $captureScript -VaultPath $vault -InputType text -Content 'Event source.'
    $before = Get-Content -Raw $capture.CapturePath
    $event = & $processingEventScript `
        -VaultPath $vault `
        -CaptureId $capture.CaptureId `
        -State interpreted `
        -Detail 'direct observation and inference recorded'
    Assert-Equal 'interpreted' $event.State 'Processing event was not appended.'
    Assert-Equal $before (Get-Content -Raw $capture.CapturePath) 'Processing event rewrote immutable evidence.'

    $ledger = Get-Content (Join-Path $vault 'collections\test-subject\contexts\main\inbox\processing-events.jsonl')
    Assert-Equal 2 @($ledger).Count 'Processing history did not remain append-only.'
}

Invoke-Test 'second brain helpers resolve resources independently of current directory' {
    $unrelated = Join-Path $script:TemporaryRoot 'unrelated-cwd'
    [void](New-Item -ItemType Directory -Path $unrelated)
    Push-Location $unrelated
    try {
        $vault = New-SecondBrainFixture 'second-brain-unrelated-cwd'
        $result = & $captureScript -VaultPath $vault -InputType text -Content 'Called elsewhere.'
        Assert-Equal 'captured' $result.State 'Capture failed from unrelated current directory.'
    }
    finally { Pop-Location }
}
