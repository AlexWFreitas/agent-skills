$initializeScript = Join-Path $repositoryRoot 'skills\ai-second-brain\scripts\Initialize-SecondBrain.ps1'
$captureScript = Join-Path $repositoryRoot 'skills\ai-second-brain\scripts\Add-SecondBrainCapture.ps1'
$completeScreenshotScript = Join-Path $repositoryRoot 'skills\ai-second-brain\scripts\Complete-SecondBrainScreenshot.ps1'
$completeVideoScript = Join-Path $repositoryRoot 'skills\ai-second-brain\scripts\Complete-SecondBrainVideo.ps1'
$processVideoScript = Join-Path $repositoryRoot 'skills\ai-second-brain\scripts\Process-SecondBrainVideo.ps1'
$processingEventScript = Join-Path $repositoryRoot 'skills\ai-second-brain\scripts\Add-SecondBrainProcessingEvent.ps1'
$migrationScript = Join-Path $repositoryRoot 'skills\ai-second-brain\scripts\Migrate-SecondBrainHumanLayout.ps1'
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
        (Join-Path $context 'README.md'),
        (Join-Path $context 'guide\index.md'),
        (Join-Path $context 'journal\index.md'),
        (Join-Path $context 'open-questions.md'),
        (Join-Path $context '_evidence\state.md'),
        (Join-Path $context '_evidence\captures'),
        (Join-Path $context '_evidence\interpretations'),
        (Join-Path $context '_evidence\media-processing'),
        (Join-Path $context '_evidence\processing-events.jsonl'),
        (Join-Path $context 'attachments'),
        (Join-Path $context 'external')
    )) {
        Assert-True (Test-Path -LiteralPath $path) "Expected initialized path '$path'."
    }

    $allText = (Get-Content -Raw (Join-Path $vault 'second-brain.md')) +
        (Get-Content -Raw (Join-Path $context 'README.md')) +
        (Get-Content -Raw (Join-Path $context '_evidence\state.md'))
    Assert-False ($allText -match '\{\{[A-Z_]+\}\}') 'Initializer left an unresolved template token.'
    Assert-True ($allText -match 'test-subject') 'Initializer did not write the collection slug.'
    Assert-True ($allText -match 'Raw\s+captures.*_evidence' -or $allText -match '_evidence.*backend') `
        'Initializer did not explain the human/evidence boundary.'
    Assert-True ($allText.Contains('Link style: `markdown`')) `
        'Client-neutral initialization did not select portable Markdown links.'
    Assert-True ($allText.Contains('[Guide](guide/index.md)')) `
        'Client-neutral initialization did not create a relative Markdown guide link.'
}

Invoke-Test 'second brain initializer uses native links for an Obsidian collection' {
    $vault = Join-Path $script:TemporaryRoot 'second-brain-obsidian-init'
    $collection = Join-Path $vault 'collections\test-subject'
    [void](New-Item -ItemType Directory -Path (Join-Path $collection '.obsidian') -Force)

    $result = & $initializeScript `
        -VaultPath $vault `
        -CollectionName 'Test Subject' `
        -CollectionSlug 'test-subject' `
        -ActivityTemplate 'game-playthrough'
    Assert-Equal 'obsidian' $result.LinkStyle 'Initializer did not auto-detect the Obsidian collection.'

    $context = Join-Path $collection 'contexts\main'
    $homeContent = Get-Content -LiteralPath (Join-Path $context 'README.md') -Raw
    $state = Get-Content -LiteralPath (Join-Path $context '_evidence\state.md') -Raw
    Assert-True ($homeContent.Contains('[[contexts/main/guide/index|Guide]]')) `
        'Obsidian home did not use a native vault-relative guide link.'
    Assert-True ($homeContent.Contains('[[contexts/main/open-questions|Open questions]]')) `
        'Obsidian home did not use a native vault-relative open-questions link.'
    Assert-False ($homeContent.Contains('[Guide](guide/index.md)')) `
        'Obsidian home mixed portable Markdown and native internal links.'
    Assert-True ($state.Contains('Link style: `obsidian`')) `
        'Obsidian link style was not persisted in machine state.'
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

    $ledger = Get-Content (Join-Path $vault 'collections\test-subject\contexts\main\_evidence\processing-events.jsonl')
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
        -Title 'Red gate map marker' `
        -Keywords @('map', 'red gate') `
        -AttachmentPath $imagePath
    Assert-Equal 'ready' $ready.AttachmentState 'Local screenshot did not become ready.'
    Assert-True (Test-Path -LiteralPath $ready.AttachmentPath -PathType Leaf) 'Screenshot attachment was not copied.'
    Assert-True ((Split-Path -Leaf $ready.AttachmentPath).StartsWith($ready.CaptureId)) 'Attachment filename does not use capture ID.'
    Assert-True ((Split-Path -Leaf $ready.AttachmentPath).Contains('--red-gate-map-marker.')) `
        'User-grounded media title did not produce a semantic attachment suffix.'
    $readyEvidence = Get-Content -Raw $ready.CapturePath
    Assert-True ($readyEvidence.Contains('display_title: "Red gate map marker"')) `
        'Capture did not preserve the human-readable display title.'
    Assert-True ($readyEvidence.Contains('"red gate"')) 'Capture did not preserve searchable keywords.'

    $pending = & $captureScript `
        -VaultPath $vault `
        -InputType screenshot `
        -Content 'Screenshot attached only in the composer.' `
        -UserCaption 'Needs save-first fallback.' `
        -Title 'Pending puzzle screen'
    Assert-Equal 'pending-save-first' $pending.AttachmentState 'Missing local screenshot did not remain pending.'
    $pendingEvidence = Get-Content -Raw $pending.CapturePath
    Assert-True ($pendingEvidence.Contains('attachment_state: pending-save-first')) 'Pending state is not durable.'

    $completed = & $completeScreenshotScript `
        -VaultPath $vault `
        -CaptureId $pending.CaptureId `
        -AttachmentPath $imagePath
    Assert-Equal 'attachment-ready' $completed.State 'Save-first screenshot was not completed.'
    Assert-True (Test-Path -LiteralPath $completed.AttachmentPath -PathType Leaf) 'Completed screenshot was not copied.'
    Assert-True ((Split-Path -Leaf $completed.AttachmentPath).Contains('--pending-puzzle-screen.')) `
        'Save-first completion did not reuse the durable semantic title.'

    $ledger = Get-Content (Join-Path $vault 'collections\test-subject\contexts\main\_evidence\processing-events.jsonl')
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
        -Title 'Dimitri dialogue' `
        -AttachmentPath $videoPath
    Assert-Equal 'ready' $ready.AttachmentState 'Local video did not become ready.'
    Assert-True (Test-Path -LiteralPath $ready.AttachmentPath -PathType Leaf) 'Video attachment was not copied.'
    Assert-True ((Get-Content -Raw $ready.CapturePath).Contains('input_type: video')) 'Video input type was not preserved.'

    $pending = & $captureScript `
        -VaultPath $vault `
        -InputType video `
        -Content 'Composer-only video.' `
        -Title 'Pending character clip'
    Assert-Equal 'pending-save-first' $pending.AttachmentState 'Missing local video did not remain pending.'

    $completed = & $completeVideoScript `
        -VaultPath $vault `
        -CaptureId $pending.CaptureId `
        -AttachmentPath $videoPath
    Assert-Equal 'attachment-ready' $completed.State 'Save-first video was not completed.'
    Assert-True (Test-Path -LiteralPath $completed.AttachmentPath -PathType Leaf) 'Completed video was not copied.'
    Assert-True ((Split-Path -Leaf $completed.AttachmentPath).Contains('--pending-character-clip.')) `
        'Save-first video completion did not reuse the durable semantic title.'
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
'{"streams":[{"codec_type":"video","codec_name":"h264","avg_frame_rate":"30/1","r_frame_rate":"30/1"},{"codec_type":"audio","codec_name":"aac"}],"format":{"duration":"2.000"}}'
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
    $runtimeRecord = Join-Path $vault 'collections\test-subject\contexts\main\_evidence\media-processing\processing-runtime.md'
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
    Assert-Equal 30 ([double]$manifest.source_frame_rate_fps) 'Manifest did not preserve the source frame rate.'
    Assert-Equal 8 ([double]$manifest.effective_frame_sample_fps) `
        'Short-video automatic sampling did not improve beyond one frame per second.'
    Assert-Equal 'adaptive-overview' $manifest.sampling_strategy 'Manifest lost the automatic sampling strategy.'
    Assert-Equal 1 $manifest.audio_stream_count 'Manifest lost stream metadata.'
    Assert-True ($manifest.source_attachment -match '^\.\./\.\./\.\./attachments/') 'Manifest source path does not reach the immutable attachment.'
    Assert-True (Test-Path -LiteralPath $capture.AttachmentPath -PathType Leaf) 'Processing changed the immutable attachment.'

    $sourceHash = (Get-FileHash -LiteralPath $capture.AttachmentPath -Algorithm SHA256).Hash
    $mismatchFailed = $false
    try {
        & $processVideoScript `
            -VaultPath $vault `
            -CaptureId $capture.CaptureId `
            -FfmpegPath $ffmpeg `
            -FfprobePath $ffprobe `
            -FrameSampleFps 30 *> $null
    }
    catch { $mismatchFailed = $_.Exception.Message -match 'Pass -Reprocess' }
    Assert-True $mismatchFailed 'A denser request silently reused lower-rate existing derivatives.'

    $reprocessed = & $processVideoScript `
        -VaultPath $vault `
        -CaptureId $capture.CaptureId `
        -FfmpegPath $ffmpeg `
        -FfprobePath $ffprobe `
        -FrameSampleFps 30 `
        -Reprocess
    Assert-Equal 'media-ready' $reprocessed.State 'Explicit denser reprocessing did not complete.'
    Assert-Equal 30 ([double]$reprocessed.EffectiveFrameSampleFps) 'Explicit 30 fps sampling was not honored.'
    $denseManifest = Get-Content -Raw (Join-Path $reprocessed.ProcessingPath 'manifest.json') | ConvertFrom-Json
    Assert-Equal 30 ([double]$denseManifest.requested_frame_sample_fps) 'Manifest lost the explicit requested rate.'
    Assert-Equal 30 ([double]$denseManifest.effective_frame_sample_fps) 'Manifest silently reduced the explicit rate.'
    Assert-Equal $sourceHash (Get-FileHash -LiteralPath $capture.AttachmentPath -Algorithm SHA256).Hash `
        'Reprocessing changed the immutable source video.'

    $explicitCapFailed = $false
    try {
        & $processVideoScript `
            -VaultPath $vault `
            -CaptureId $capture.CaptureId `
            -FfmpegPath $ffmpeg `
            -FfprobePath $ffprobe `
            -FrameSampleFps 30 `
            -MaxFrames 10 `
            -Reprocess *> $null
    }
    catch { $explicitCapFailed = $_.Exception.Message -match 'about 60 frames' }
    Assert-True $explicitCapFailed 'An explicit incompatible frame cap silently reduced visual coverage.'
}

Invoke-Test 'second brain separates fast video intake from requested assimilation and reuses Whisper' {
    $skill = Get-Content -Raw $skillPath
    $scenarios = Get-Content -Raw $validationScenariosPath

    Assert-True ($skill.Contains('Do not force every log entry through LLM interpretation')) `
        'Skill does not separate fast durable intake from LLM assimilation.'
    Assert-True ($skill.Contains('An attached video logged as an entry follows fast intake.')) `
        'Skill does not route logged video through fast intake.'
    Assert-True ($skill.Contains('do not ask an uncaptioned sender an')) `
        'Skill does not prohibit an extra intent question for an uncaptioned logged video.'
    Assert-True ($skill.Contains('prepare, interpret, and answer in the same assistant turn')) `
        'Skill does not interpret a video in the same turn when the user requests it.'
    Assert-True ($skill.Contains('continue interpretation in the same assistant turn')) `
        'Skill does not continue already-authorized dependency recovery in the same turn.'
    Assert-True ($skill.Contains('the helper reuses the active vault runtime record')) `
        'Skill does not route Whisper reuse through durable or stable discovery.'
    Assert-True ($scenarios.Contains('## V20 — Durable Whisper reuse outside PATH')) `
        'Validation scenarios do not exercise durable Whisper reuse outside PATH.'
    Assert-True ($scenarios.Contains('## V23 — Explicit video rate and reproducible reprocessing')) `
        'Validation scenarios do not exercise explicit video sampling and reprocessing.'
}

Invoke-Test 'second brain skill requires a human-first notebook over the evidence backend' {
    $skill = Get-Content -Raw $skillPath
    $scenarios = Get-Content -Raw $validationScenariosPath

    Assert-True ($skill.Contains('Choose one canonical guide note for each durable subject.')) `
        'Skill does not require one canonical human home per subject.'
    Assert-True ($skill.Contains('human-labeled, clickable evidence links')) `
        'Skill does not require readable section-level provenance.'
    Assert-True ($skill -match 'Unknown\s+trivia\s+is\s+not\s+automatically\s+a\s+task') `
        'Skill still promotes every unknown detail into an active question.'
    Assert-True ($skill.Contains('Search `README.md`, `guide/`, `journal/`, and an existing `library/` first.')) `
        'Skill does not route ordinary retrieval through the human surface.'
    Assert-True ($skill.Contains('use vault-relative `[[path|label]]` wikilinks')) `
        'Skill does not require native links for Obsidian collections.'
    Assert-True ($skill.Contains('Do not hide it or')) `
        'Skill hides the evidence backend without explicit user direction.'
    Assert-True ($scenarios.Contains('## V21 — Human-first layout and legacy migration')) `
        'Validation scenarios do not exercise human-first migration and retrieval.'
    Assert-True ($skill.Contains('library/captures/<descriptive-slug>--<capture-id>.md')) `
        'Skill does not create human-searchable semantic media descriptors.'
    Assert-True ($skill.Contains('library/references/<reference-slug>.md')) `
        'Skill does not maintain reusable visual reference pages.'
    Assert-True ($skill.Contains('show at least one relevant screenshot or representative')) `
        'Skill does not render relevant visual evidence during retrieval.'
    Assert-True ($scenarios.Contains('## V22 — Rapid intake and bounded assimilation')) `
        'Validation scenarios do not exercise fast intake and bounded assimilation.'
    Assert-True ($scenarios.Contains('## V24 — Semantic media and recurring visual references')) `
        'Validation scenarios do not exercise semantic media and recurring visual references.'
}

Invoke-Test 'second brain capture retry with an existing capture id does not duplicate evidence' {
    $vault = New-SecondBrainFixture 'second-brain-retry'
    $captureId = 'CAP-20260726-170000-abcd'
    $first = & $captureScript -VaultPath $vault -InputType text -Content 'Retry-safe input.' -CaptureId $captureId
    $second = & $captureScript -VaultPath $vault -InputType text -Content 'Retry-safe input.' -CaptureId $captureId
    Assert-Equal 'captured' $first.State 'First explicit-ID capture failed.'
    Assert-Equal 'existing-capture' $second.State 'Retry did not detect existing capture.'

    $captureFiles = Get-ChildItem -LiteralPath (Join-Path $vault 'collections\test-subject\contexts\main\_evidence\captures') -Recurse -File
    Assert-Equal 1 @($captureFiles).Count 'Retry created duplicate capture evidence.'
    $ledger = Get-Content (Join-Path $vault 'collections\test-subject\contexts\main\_evidence\processing-events.jsonl')
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

    $ledger = Get-Content (Join-Path $vault 'collections\test-subject\contexts\main\_evidence\processing-events.jsonl')
    Assert-Equal 2 @($ledger).Count 'Processing history did not remain append-only.'
}

Invoke-Test 'second brain migration separates the backend and preserves every legacy byte' {
    $vault = New-SecondBrainFixture 'second-brain-human-layout-migration'
    $context = Join-Path $vault 'collections\test-subject\contexts\main'
    $evidence = Join-Path $context '_evidence'
    $legacyInbox = Join-Path $context 'inbox'

    Move-Item -LiteralPath $evidence -Destination $legacyInbox
    Remove-Item -LiteralPath (Join-Path $legacyInbox 'state.md') -Force
    Remove-Item -LiteralPath (Join-Path $context 'README.md') -Force
    Remove-Item -LiteralPath (Join-Path $context 'open-questions.md') -Force
    Remove-Item -LiteralPath (Join-Path $context 'journal\index.md') -Force
    Remove-Item -LiteralPath (Join-Path $context 'journal') -Force
    Remove-Item -LiteralPath (Join-Path $context 'guide\index.md') -Force
    Move-Item -LiteralPath (Join-Path $context 'guide') -Destination (Join-Path $context 'topics')

    Set-Content -LiteralPath (Join-Path $context 'context.md') -Encoding UTF8 -Value @'
# Context: Test Subject - Main Test

Collection: `test-subject`
Context: `main`
Activity template: `game-playthrough`
Lifecycle: `active`
Epistemic mode: `firsthand-only`
Created: `2026-08-16T10:00:00-03:00`
Last updated: `2026-08-16T11:00:00-03:00`
Latest checkpoint: `legacy checkpoint`

## Scope

Only supplied test evidence.

## Current state

- A legacy fact.
'@
    Set-Content -LiteralPath (Join-Path $context 'timeline.md') -Encoding UTF8 -Value "# Timeline`r`n`r`n- A legacy event."
    Set-Content -LiteralPath (Join-Path $context 'open-items.md') -Encoding UTF8 -Value "# Open Items`r`n`r`n- A legacy question."
    Set-Content -LiteralPath (Join-Path $context 'topics\mechanics.md') -Encoding UTF8 -Value "# Mechanics`r`n`r`nA useful legacy topic."
    $rootIndexPath = Join-Path $vault 'second-brain.md'
    $rootIndex = (Get-Content -LiteralPath $rootIndexPath -Raw).Replace('Schema version: `2`', 'Schema version: `1`')
    [IO.File]::WriteAllText($rootIndexPath, $rootIndex)
    [void](New-Item -ItemType Directory -Path (Join-Path $vault 'collections\test-subject\.obsidian'))

    $imagePath = Join-Path $script:TemporaryRoot 'migration-image.png'
    [IO.File]::WriteAllBytes($imagePath, [byte[]](0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a))
    $capture = & $captureScript `
        -VaultPath $vault `
        -InputType screenshot `
        -Content 'Legacy screenshot evidence.' `
        -AttachmentPath $imagePath
    $captureHash = (Get-FileHash -LiteralPath $capture.CapturePath -Algorithm SHA256).Hash
    $attachmentHash = (Get-FileHash -LiteralPath $capture.AttachmentPath -Algorithm SHA256).Hash

    $result = & $migrationScript -VaultPath $vault -Confirm:$false
    Assert-Equal 'migrated-human-layout' $result.State 'Legacy migration did not report success.'
    Assert-Equal 'obsidian' $result.LinkStyle 'Migration did not auto-detect the Obsidian collection.'
    foreach ($path in @(
        (Join-Path $context 'README.md'),
        (Join-Path $context 'guide\index.md'),
        (Join-Path $context 'guide\mechanics.md'),
        (Join-Path $context 'journal\index.md'),
        (Join-Path $context 'open-questions.md'),
        (Join-Path $context '_evidence\state.md'),
        (Join-Path $context '_evidence\legacy-synthesis\context.md'),
        (Join-Path $context '_evidence\legacy-synthesis\timeline.md'),
        (Join-Path $context '_evidence\legacy-synthesis\open-items.md'),
        (Join-Path $context '_evidence\migration-manifest.json')
    )) {
        Assert-True (Test-Path -LiteralPath $path -PathType Leaf) "Migration did not create or preserve '$path'."
    }
    foreach ($legacyPath in @(
        (Join-Path $context 'inbox'),
        (Join-Path $context 'context.md'),
        (Join-Path $context 'timeline.md'),
        (Join-Path $context 'open-items.md'),
        (Join-Path $context 'topics')
    )) {
        Assert-False (Test-Path -LiteralPath $legacyPath) "Legacy path remained mixed into the human surface: '$legacyPath'."
    }

    $migratedCapturePath = Join-Path $context "_evidence\captures\$($capture.CaptureId.Substring(4,4))-$($capture.CaptureId.Substring(8,2))-$($capture.CaptureId.Substring(10,2))\$($capture.CaptureId).md"
    Assert-Equal $captureHash (Get-FileHash -LiteralPath $migratedCapturePath -Algorithm SHA256).Hash `
        'Migration changed immutable capture bytes.'
    Assert-Equal $attachmentHash (Get-FileHash -LiteralPath $capture.AttachmentPath -Algorithm SHA256).Hash `
        'Migration changed immutable attachment bytes.'

    $manifest = Get-Content -LiteralPath $result.ManifestPath -Raw | ConvertFrom-Json
    Assert-True (@($manifest.preserved_files).Count -ge 5) 'Migration manifest did not account for preserved files.'
    Assert-True (@($manifest.preserved_files | Where-Object { $_.category -eq 'attachment-unchanged' }).Count -eq 1) `
        'Migration manifest did not account for the unchanged attachment.'
    $migratedHome = Get-Content -LiteralPath (Join-Path $context 'README.md') -Raw
    Assert-True ($migratedHome.Contains('[[contexts/main/guide/index|Guide]]')) `
        'Migrated Obsidian home did not use native wikilinks.'

    $afterMigration = & $captureScript -VaultPath $vault -InputType text -Content 'Captured after migration.'
    Assert-True ($afterMigration.CapturePath -match '[\\/]_evidence[\\/]captures[\\/]') `
        'Capture helper did not select the migrated evidence backend.'
    $reentry = & $migrationScript -VaultPath $vault -Confirm:$false
    Assert-Equal 'existing-compatible' $reentry.State 'Migration was not idempotent on exact re-entry.'
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
