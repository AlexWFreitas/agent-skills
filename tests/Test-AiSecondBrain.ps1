$initializeScript = Join-Path $repositoryRoot 'skills\ai-second-brain\scripts\Initialize-SecondBrain.ps1'
$captureScript = Join-Path $repositoryRoot 'skills\ai-second-brain\scripts\Add-SecondBrainCapture.ps1'
$completeScreenshotScript = Join-Path $repositoryRoot 'skills\ai-second-brain\scripts\Complete-SecondBrainScreenshot.ps1'
$completeVideoScript = Join-Path $repositoryRoot 'skills\ai-second-brain\scripts\Complete-SecondBrainVideo.ps1'
$processVideoScript = Join-Path $repositoryRoot 'skills\ai-second-brain\scripts\Process-SecondBrainVideo.ps1'
$backfillVisualLibraryScript = Join-Path $repositoryRoot 'skills\ai-second-brain\scripts\Backfill-SecondBrainVisualLibrary.ps1'
$buildSearchIndexScript = Join-Path $repositoryRoot 'skills\ai-second-brain\scripts\Build-SecondBrainSearchIndex.ps1'
$ensureSearchIndexScript = Join-Path $repositoryRoot 'skills\ai-second-brain\scripts\Ensure-SecondBrainSearchIndex.ps1'
$searchIndexScript = Join-Path $repositoryRoot 'skills\ai-second-brain\scripts\Search-SecondBrainIndex.ps1'
$searchEnginePath = Join-Path $repositoryRoot 'skills\ai-second-brain\scripts\second_brain_fts.py'
$processingEventScript = Join-Path $repositoryRoot 'skills\ai-second-brain\scripts\Add-SecondBrainProcessingEvent.ps1'
$relationScript = Join-Path $repositoryRoot 'skills\ai-second-brain\scripts\Add-SecondBrainRelation.ps1'
$contextAuditScript = Join-Path $repositoryRoot 'skills\ai-second-brain\scripts\Test-SecondBrainContext.ps1'
$reconciliationLockScript = Join-Path $repositoryRoot 'skills\ai-second-brain\scripts\Manage-SecondBrainReconciliationLock.ps1'
$migrationScript = Join-Path $repositoryRoot 'skills\ai-second-brain\scripts\Migrate-SecondBrainHumanLayout.ps1'
$skillPath = Join-Path $repositoryRoot 'skills\ai-second-brain\SKILL.md'
$validationScenariosPath = Join-Path $repositoryRoot 'skills\ai-second-brain\references\validation-scenarios.md'
$localSearchReferencePath = Join-Path $repositoryRoot 'skills\ai-second-brain\references\local-search-index.md'
$stateTrackingReferencePath = Join-Path $repositoryRoot 'skills\ai-second-brain\references\state-tracking.md'

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
        -ActivityTemplate 'game-playthrough' `
        -SearchMode off
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
        (Join-Path $context '_evidence\relations.jsonl'),
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
    Assert-True ($allText.Contains('Search mode: `off`')) `
        'Initializer did not persist the fixture search-mode override.'
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
        -ActivityTemplate 'game-playthrough' `
        -SearchMode off
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
    $result = & $initializeScript `
        -VaultPath $vault `
        -CollectionName 'Test Subject' `
        -CollectionSlug 'test-subject'
    Assert-Equal 'existing-compatible' $result.State 'Compatible re-entry was not detected.'
    Assert-Equal 'off' $result.ConfiguredSearchMode 'Compatible re-entry ignored persisted search preferences.'
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

    Assert-True ($skill.Contains('Update one canonical guide home')) `
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

Invoke-Test 'second brain visual-library backfill catalogs existing media without changing evidence' {
    $vault = New-SecondBrainFixture 'second-brain-visual-library-backfill'
    $context = Join-Path $vault 'collections\test-subject\contexts\main'
    $imagePath = Join-Path $script:TemporaryRoot 'backfill-image.png'
    $videoPath = Join-Path $script:TemporaryRoot 'backfill-video.mp4'
    [IO.File]::WriteAllBytes($imagePath, [byte[]](0x89, 0x50, 0x4e, 0x47))
    [IO.File]::WriteAllBytes($videoPath, [byte[]](0x00, 0x00, 0x00, 0x18))

    $screenshot = & $captureScript `
        -VaultPath $vault `
        -InputType screenshot `
        -Content 'I found a Soft Earth tile near water.' `
        -UserCaption 'Image #1' `
        -AttachmentPath $imagePath
    $video = & $captureScript `
        -VaultPath $vault `
        -InputType video `
        -Content 'A short character dialogue clip.' `
        -UserCaption 'Character dialogue' `
        -AttachmentPath $videoPath
    $pending = & $captureScript `
        -VaultPath $vault `
        -InputType screenshot `
        -Content 'A composer-only map screenshot.' `
        -UserCaption 'Map marker still pending'

    $legacyCaptureId = 'CAP-20260701-120000-legacy'
    $legacyDateRoot = Join-Path $context '_evidence\captures\2026-07-01'
    [void](New-Item -ItemType Directory -Path $legacyDateRoot)
    $legacyAttachment = Join-Path $context "attachments\$legacyCaptureId.png"
    [IO.File]::WriteAllBytes($legacyAttachment, [byte[]](0x89, 0x50, 0x4e, 0x47, 0x0d))
    Set-Content -LiteralPath (Join-Path $legacyDateRoot "$legacyCaptureId.md") -Encoding UTF8 -Value @"
---
capture_id: $legacyCaptureId
captured_at: 2026-07-01T12:00:00-03:00
input_type: screenshot
session_id: legacy-session
attachment: collections/test-subject/contexts/main/attachments/$legacyCaptureId.png
attachment_state: ready
initial_processing_state: pending
---

# Original input

Legacy screenshot with a descriptive note.

# User caption

Legacy object example
"@

    $interpretationPath = Join-Path $context "_evidence\interpretations\$($screenshot.CaptureId).md"
    Set-Content -LiteralPath $interpretationPath -Encoding UTF8 -Value @'
# Direct observations

- The screenshot shows a brown Soft Earth patch beside blue water.

# AI inferences

- None.

# Unresolved

- None.
'@

    $captureHash = (Get-FileHash -LiteralPath $screenshot.CapturePath -Algorithm SHA256).Hash
    $attachmentHash = (Get-FileHash -LiteralPath $screenshot.AttachmentPath -Algorithm SHA256).Hash
    $preview = & $backfillVisualLibraryScript `
        -VaultPath $vault `
        -IncludePendingMedia `
        -WhatIf
    Assert-Equal 'preview' $preview.State 'Visual-library preview did not report preview state.'
    Assert-Equal 4 $preview.MediaCaptures 'Visual-library preview lost eligible or legacy media captures.'
    Assert-False (Test-Path -LiteralPath (Join-Path $context 'library')) `
        'Visual-library preview wrote to the fixture.'

    $result = & $backfillVisualLibraryScript `
        -VaultPath $vault `
        -IncludePendingMedia `
        -Confirm:$false
    Assert-Equal 'backfilled' $result.State 'Visual-library backfill did not report success.'
    Assert-Equal 4 $result.DescriptorCreates 'Visual-library backfill did not create every descriptor.'
    Assert-Equal 1 $result.PreviouslyInterpreted 'Visual-library backfill lost interpretation state.'
    Assert-Equal 3 $result.PendingVisualReview 'Visual-library backfill did not preserve pending visual review.'
    Assert-Equal 1 $result.PendingAttachment 'Visual-library backfill did not preserve pending attachment state.'

    $descriptorRoot = Join-Path $context 'library\captures'
    $descriptors = @(Get-ChildItem -LiteralPath $descriptorRoot -File -Filter '*.md')
    Assert-Equal 4 $descriptors.Count 'Visual-library descriptor count is incorrect.'
    $softEarthDescriptor = @($descriptors | Where-Object { $_.Name -match 'soft-earth' })
    Assert-Equal 1 $softEarthDescriptor.Count 'Interpretation did not produce a semantic Soft Earth filename.'
    $softEarthText = Get-Content -LiteralPath $softEarthDescriptor[0].FullName -Raw
    Assert-True ($softEarthText.Contains('![The screenshot shows a brown Soft Earth patch beside blue water.](../../attachments/')) `
        'Screenshot descriptor does not embed its immutable media.'
    Assert-True ($softEarthText.Contains('[Interpretation](../../_evidence/interpretations/')) `
        'Screenshot descriptor does not link its prior interpretation.'

    $pendingDescriptor = Get-ChildItem -LiteralPath $descriptorRoot -File -Filter "*--$($pending.CaptureId).md"
    $pendingText = Get-Content -LiteralPath $pendingDescriptor.FullName -Raw
    Assert-True ($pendingText.Contains('No durable local media is available yet (`pending-save-first`).')) `
        'Pending descriptor falsely claims a durable preview.'

    Assert-Equal $captureHash (Get-FileHash -LiteralPath $screenshot.CapturePath -Algorithm SHA256).Hash `
        'Visual-library backfill changed immutable capture evidence.'
    Assert-Equal $attachmentHash (Get-FileHash -LiteralPath $screenshot.AttachmentPath -Algorithm SHA256).Hash `
        'Visual-library backfill changed immutable attachment evidence.'
    Assert-True (Test-Path -LiteralPath $result.IndexPath -PathType Leaf) 'Visual-library index was not created.'
    Assert-Equal 1 @(Get-ChildItem -LiteralPath $descriptorRoot -File -Filter "*--$legacyCaptureId.md").Count `
        'Visual-library backfill rejected a preserved legacy capture ID.'

    $reentry = & $backfillVisualLibraryScript `
        -VaultPath $vault `
        -IncludePendingMedia `
        -Confirm:$false
    Assert-Equal 4 $reentry.DescriptorSkips 'Backfill re-entry did not preserve existing descriptors.'
    Assert-Equal 0 $reentry.DescriptorCreates 'Backfill re-entry created duplicate descriptors.'

    $curatedText = [IO.File]::ReadAllText($softEarthDescriptor[0].FullName, [Text.Encoding]::UTF8)
    $curatedText = $curatedText.Replace('reference_ids: []', 'reference_ids: ["ref-soft-earth"]')
    $curatedText = $curatedText.Replace(
        'None assigned during mechanical backfill.',
        '[ref-soft-earth](../references/soft-earth.md) — `depicts`.'
    )
    [IO.File]::WriteAllText($softEarthDescriptor[0].FullName, $curatedText)
    $updated = & $backfillVisualLibraryScript `
        -VaultPath $vault `
        -IncludePendingMedia `
        -UpdateExisting `
        -Confirm:$false
    Assert-Equal 4 $updated.DescriptorUpdates 'Update-existing did not refresh every existing descriptor.'
    $updatedCuratedText = [IO.File]::ReadAllText($softEarthDescriptor[0].FullName, [Text.Encoding]::UTF8)
    Assert-True ($updatedCuratedText.Contains('reference_ids: ["ref-soft-earth"]')) `
        'Update-existing erased curated stable reference IDs.'
    Assert-True ($updatedCuratedText.Contains('[ref-soft-earth](../references/soft-earth.md) — `depicts`.')) `
        'Update-existing erased curated visual-reference links.'
}

Invoke-Test 'second brain FTS5 wrappers keep the index disposable and context bounded' {
    $vault = New-SecondBrainFixture 'second-brain-fts5-wrapper'
    $context = Join-Path $vault 'collections\test-subject\contexts\main'
    $guidePath = Join-Path $context 'guide\mechanics.md'
    Set-Content -LiteralPath $guidePath -Encoding UTF8 -Value @'
# Mechanics

## Soft Earth

A dotted brown soil plot is used for planting Gasha Seeds.
'@
    $capture = & $captureScript -VaultPath $vault -InputType text -Content 'A source capture that must remain unchanged.'
    $captureHash = (Get-FileHash -LiteralPath $capture.CapturePath -Algorithm SHA256).Hash

    $fakePython = Join-Path $script:TemporaryRoot 'fake-second-brain-python.ps1'
    Set-Content -LiteralPath $fakePython -Encoding UTF8 -Value @'
param([Parameter(ValueFromRemainingArguments = $true)][string[]]$ToolArguments)

function Get-ToolArgument {
    param([string]$Name)
    $index = [Array]::IndexOf($ToolArguments, $Name)
    if ($index -lt 0 -or $index + 1 -ge $ToolArguments.Count) { return $null }
    return $ToolArguments[$index + 1]
}

$command = $ToolArguments[1]
$indexPath = Get-ToolArgument '--index'
if ($command -eq 'build') {
    $parent = Split-Path -Parent $indexPath
    if (-not (Test-Path -LiteralPath $parent)) { [void](New-Item -ItemType Directory -Path $parent) }
    [IO.File]::WriteAllBytes($indexPath, [byte[]](1, 2, 3, 4))
    [ordered]@{
        state = 'built'
        index_path = $indexPath
        collection = (Get-ToolArgument '--collection')
        context = (Get-ToolArgument '--context')
        files = 7
        sections = 13
        include_evidence = (-not ($ToolArguments -contains '--exclude-evidence'))
        include_external = ($ToolArguments -contains '--include-external')
        tree_fingerprint = 'fixture-fingerprint'
        sqlite_version = 'fixture-sqlite'
        semantic_enabled = ($ToolArguments -contains '--semantic')
        embedding_provider = if ($ToolArguments -contains '--semantic') { Get-ToolArgument '--embedding-provider' } else { $null }
        embedding_model = if ($ToolArguments -contains '--semantic') { Get-ToolArgument '--embedding-model' } else { $null }
        embedding_endpoint = if ($ToolArguments -contains '--semantic') { Get-ToolArgument '--embedding-endpoint' } else { $null }
        embedding_dimension = if ($ToolArguments -contains '--semantic') { 4 } else { 0 }
        semantic_sections = if ($ToolArguments -contains '--semantic') { 13 } else { 0 }
    } | ConvertTo-Json -Compress
    return
}
if ($command -eq 'query') {
    $vault = Get-ToolArgument '--vault'
    $collection = Get-ToolArgument '--collection'
    $context = Get-ToolArgument '--context'
    $source = Join-Path $vault "collections\$collection\contexts\$context\guide\mechanics.md"
    [ordered]@{
        state = 'searched'
        index_path = $indexPath
        index_generated_at = '2026-08-26T12:00:00-03:00'
        index_stale = $false
        query = (Get-ToolArgument '--query')
        effective_query = '"soft" AND "earth"'
        fallback_used = $false
        semantic_requested = ($ToolArguments -contains '--semantic')
        semantic_used = ($ToolArguments -contains '--semantic')
        semantic_error = $null
        embedding_model = if ($ToolArguments -contains '--semantic') { 'fixture-embedding-model' } else { $null }
        results = @(
            [ordered]@{
                rank = 1
                score = -0.75
                lexical_rank = 1
                semantic_rank = if ($ToolArguments -contains '--semantic') { 1 } else { $null }
                semantic_similarity = if ($ToolArguments -contains '--semantic') { 0.95 } else { $null }
                hybrid_score = if ($ToolArguments -contains '--semantic') { 0.032786885 } else { $null }
                retrieval_modes = if ($ToolArguments -contains '--semantic') { @('lexical', 'semantic') } else { @('lexical') }
                relative_path = 'guide/mechanics.md'
                absolute_path = $source
                source_tier = 'human'
                kind = 'guide'
                capture_id = ''
                title = 'Mechanics'
                heading = 'Mechanics > Soft Earth'
                snippet = 'A dotted brown [soil plot] is used for planting Gasha Seeds.'
                source_exists = $true
                source_stale = $false
            }
        )
    } | ConvertTo-Json -Depth 6 -Compress
    return
}
throw "Unexpected fake Python command '$command'."
'@

    $automaticVault = Join-Path $script:TemporaryRoot 'second-brain-auto-search-init'
    [void](New-Item -ItemType Directory -Path $automaticVault -Force)
    [IO.File]::WriteAllText(
        (Join-Path $automaticVault '.gitignore'),
        "preserve-this-rule`r`n",
        (New-Object Text.UTF8Encoding($false))
    )
    $automatic = & $initializeScript `
        -VaultPath $automaticVault `
        -CollectionName 'Automatic Search' `
        -CollectionSlug 'automatic-search' `
        -SearchMode auto `
        -EmbeddingModel 'fixture-embedding-model' `
        -EmbeddingEndpoint 'http://127.0.0.1:1' `
        -EmbeddingProbeTimeoutSeconds 1 `
        -PythonPath $fakePython
    Assert-Equal 'initialized' $automatic.State 'Automatic-search initialization did not preserve vault success.'
    Assert-Equal 'ready' $automatic.SearchIndexState 'Automatic-search initialization did not build a local index.'
    Assert-Equal 'lexical' $automatic.EffectiveSearchMode 'Unavailable Ollama did not degrade initialization to lexical FTS5.'
    Assert-True (Test-Path -LiteralPath $automatic.SearchIndexPath -PathType Leaf) `
        'Automatic-search initialization did not create the context index.'
    $automaticState = Get-Content -LiteralPath (Join-Path $automaticVault 'collections\automatic-search\contexts\main\_evidence\state.md') -Raw
    Assert-True ($automaticState.Contains('Search mode: `auto`')) 'Initializer did not persist automatic search mode.'
    Assert-True ($automaticState.Contains('Embedding model: `fixture-embedding-model`')) `
        'Initializer did not persist the configured embedding model.'
    Assert-True ($automaticState.Contains('Embedding endpoint: `http://127.0.0.1:1`')) `
        'Initializer did not persist the configured loopback embedding endpoint.'
    $ignoreContent = [IO.File]::ReadAllText((Join-Path $automaticVault '.gitignore'))
    Assert-True ($ignoreContent.StartsWith("preserve-this-rule`r`n")) `
        'Automatic setup rewrote pre-existing .gitignore bytes.'
    Assert-Equal 1 @([regex]::Matches($ignoreContent, '(?m)^/\.index/\r?$')).Count `
        'Automatic setup did not add exactly one generated-index ignore rule.'
    $automaticIndexHash = (Get-FileHash -LiteralPath $automatic.SearchIndexPath -Algorithm SHA256).Hash
    [void](& $captureScript -VaultPath $automaticVault -InputType text -Content 'Fast intake must not update the index.')
    Assert-Equal $automaticIndexHash (Get-FileHash -LiteralPath $automatic.SearchIndexPath -Algorithm SHA256).Hash `
        'Fast capture rebuilt or rewrote the automatic search index.'
    Remove-Item -LiteralPath $automatic.SearchIndexPath -Force
    $recreated = & $searchIndexScript `
        -VaultPath $automaticVault `
        -Query 'Soft Earth' `
        -SearchMode lexical `
        -PythonPath $fakePython
    Assert-True $recreated.AutoRefreshed 'Retrieval did not recreate a missing automatic index.'
    Assert-False $recreated.IndexStale 'Retrieval returned a stale result after recreating a missing index.'

    $noPythonVault = Join-Path $script:TemporaryRoot 'second-brain-auto-search-no-python'
    $missingPython = & $initializeScript `
        -VaultPath $noPythonVault `
        -CollectionName 'No Python' `
        -CollectionSlug 'no-python' `
        -SearchMode auto `
        -PythonPath (Join-Path $script:TemporaryRoot 'missing-python.exe') `
        -WarningAction SilentlyContinue
    Assert-Equal 'initialized' $missingPython.State `
        'Unavailable optional search runtime invalidated vault initialization.'
    Assert-Equal 'unavailable' $missingPython.SearchIndexState `
        'Unavailable optional search runtime was not reported.'
    Assert-True (Test-Path -LiteralPath (Join-Path $noPythonVault 'second-brain.md') -PathType Leaf) `
        'Unavailable optional search runtime removed the authoritative vault.'

    $unicodeVault = New-SecondBrainFixture 'second-brain-auto-search-unicode-ignore'
    $unicodeIgnorePath = Join-Path $unicodeVault '.gitignore'
    [IO.File]::WriteAllText(
        $unicodeIgnorePath,
        "preserve-unicode-rule`r`n",
        (New-Object Text.UnicodeEncoding($false, $true))
    )
    [void](& $ensureSearchIndexScript `
        -VaultPath $unicodeVault `
        -SearchMode lexical `
        -PythonPath $fakePython `
        -ForceRebuild)
    $unicodeBytes = [IO.File]::ReadAllBytes($unicodeIgnorePath)
    Assert-True ($unicodeBytes[0] -eq 0xFF -and $unicodeBytes[1] -eq 0xFE) `
        'Automatic setup changed the existing .gitignore encoding.'
    $unicodeIgnore = [IO.File]::ReadAllText($unicodeIgnorePath)
    Assert-True ($unicodeIgnore.Contains("preserve-unicode-rule`r`n/.index/")) `
        'Automatic setup did not append a readable ignore rule in the existing encoding.'

    $preview = & $buildSearchIndexScript `
        -VaultPath $vault `
        -PythonPath $fakePython `
        -WhatIf
    Assert-Equal 'preview' $preview.State 'FTS5 build preview did not report preview state.'
    Assert-True ($preview.IndexPath -match '[\\/]\.index[\\/]ai-second-brain[\\/]test-subject--main\.sqlite$') `
        'FTS5 default path is not context-specific under the vault index root.'
    Assert-False (Test-Path -LiteralPath $preview.IndexPath) 'FTS5 preview created an index file.'

    $built = & $buildSearchIndexScript `
        -VaultPath $vault `
        -PythonPath $fakePython `
        -Confirm:$false
    Assert-Equal 'built' $built.State 'FTS5 wrapper did not report a completed build.'
    Assert-Equal 7 $built.Files 'FTS5 wrapper lost the indexed file count.'
    Assert-Equal 13 $built.Sections 'FTS5 wrapper lost the indexed section count.'
    Assert-True $built.IncludeEvidence 'FTS5 default unexpectedly excluded textual evidence.'
    Assert-False $built.IncludeExternal 'FTS5 default unexpectedly included outside knowledge.'
    Assert-True (Test-Path -LiteralPath $built.IndexPath -PathType Leaf) 'FTS5 wrapper did not create the disposable index.'
    Assert-Equal $captureHash (Get-FileHash -LiteralPath $capture.CapturePath -Algorithm SHA256).Hash `
        'FTS5 build changed authoritative capture evidence.'

    $searched = & $searchIndexScript `
        -VaultPath $vault `
        -Query 'What is Soft Earth?' `
        -PythonPath $fakePython
    Assert-Equal 'searched' $searched.State 'FTS5 wrapper did not report a search result.'
    Assert-False $searched.IndexStale 'Fresh fixture index was reported stale.'
    Assert-Equal 1 @($searched.Results).Count 'FTS5 wrapper lost ranked results.'
    Assert-Equal $guidePath $searched.Results[0].Path 'FTS5 result did not resolve to the active context source.'
    Assert-Equal 'Mechanics > Soft Earth' $searched.Results[0].Heading 'FTS5 result lost heading provenance.'
    Assert-True ($searched.Results[0].Snippet -match '\[soil plot\]') 'FTS5 result lost its ranked snippet.'

    $semanticBuilt = & $buildSearchIndexScript `
        -VaultPath $vault `
        -PythonPath $fakePython `
        -Semantic `
        -EmbeddingModel 'fixture-embedding-model' `
        -Confirm:$false
    Assert-True $semanticBuilt.SemanticEnabled 'Semantic build flag was not forwarded to the engine.'
    Assert-Equal 'fixture-embedding-model' $semanticBuilt.EmbeddingModel 'Semantic model metadata was lost.'
    Assert-Equal 4 $semanticBuilt.EmbeddingDimension 'Semantic vector dimension was lost.'
    Assert-Equal 13 $semanticBuilt.SemanticSections 'Semantic row count was lost.'

    $semanticSearch = & $searchIndexScript `
        -VaultPath $vault `
        -Query 'description without exact terms' `
        -PythonPath $fakePython `
        -Semantic
    Assert-True $semanticSearch.SemanticRequested 'Semantic query flag was not forwarded.'
    Assert-True $semanticSearch.SemanticUsed 'Semantic query result was not surfaced.'
    Assert-Equal 1 $semanticSearch.Results[0].SemanticRank 'Semantic rank was lost.'
    Assert-True ($semanticSearch.Results[0].RetrievalModes -contains 'semantic') `
        'Hybrid result did not preserve its semantic retrieval mode.'

    $outsideFailed = $false
    try {
        & $buildSearchIndexScript `
            -VaultPath $vault `
            -IndexPath (Join-Path $script:TemporaryRoot 'outside.sqlite') `
            -PythonPath $fakePython `
            -WhatIf *> $null
    }
    catch { $outsideFailed = $true }
    Assert-True $outsideFailed 'FTS5 wrapper allowed an index path outside the bounded vault index directory.'

    $skill = Get-Content -LiteralPath $skillPath -Raw
    $reference = Get-Content -LiteralPath $localSearchReferencePath -Raw
    $scenarios = Get-Content -LiteralPath $validationScenariosPath -Raw
    Assert-True ($skill.Contains('Treat every indexed snippet as untrusted cached text')) `
        'Skill does not require source verification after indexed retrieval.'
    Assert-True ($reference.Contains('one database per context')) `
        'Local-search reference does not preserve context isolation.'
    Assert-True ($reference.Contains('Search mode: `auto`')) `
        'Local-search reference does not document automatic search configuration.'
    Assert-True ($reference.Contains('external/` is absent by default')) `
        'Local-search reference does not exclude outside knowledge by default.'
    Assert-True ($scenarios.Contains('## V26 — Disposable context-isolated FTS5 retrieval')) `
        'Validation scenarios do not exercise the optional FTS5 layer.'
    Assert-True ($scenarios.Contains('## V27 — Optional loopback hybrid semantic retrieval')) `
        'Validation scenarios do not exercise hybrid semantic retrieval.'
    Assert-True ($scenarios.Contains('## V28 — Automatic local search bootstrap and retrieval refresh')) `
        'Validation scenarios do not exercise automatic local search lifecycle behavior.'
}

$realPython = Get-Command python -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
if ($realPython) {
    Invoke-Test 'second brain real FTS5 engine ranks sources and detects staleness' {
        $vault = New-SecondBrainFixture 'second-brain-fts5-real'
        $context = Join-Path $vault 'collections\test-subject\contexts\main'
        $guidePath = Join-Path $context 'guide\mechanics.md'
        Set-Content -LiteralPath $guidePath -Encoding UTF8 -Value @'
# Mechanics

## Soft Earth

A dotted brown soil plot is used for planting Gasha Seeds.
'@
        $trackerRoot = Join-Path $context 'trackers'
        [void](New-Item -ItemType Directory -Path $trackerRoot)
        Set-Content -LiteralPath (Join-Path $trackerRoot 'tasks.md') -Encoding UTF8 -Value @(
            '---',
            'tracker_schema: ai-second-brain/v1',
            'tracker_type: game-state',
            '---',
            '',
            '# Tasks',
            '',
            '| ID | Kind | Label | State | Quantity | Parent ID | Map anchor | Opened by | Closed by | Notes |',
            '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
            '| `TASK-MOONKEY` | task | MoonKey gate | open | 1 |  |  |  |  | Stateful tracker token |'
        )
        $referenceRoot = Join-Path $context 'library\references'
        [void](New-Item -ItemType Directory -Path $referenceRoot -Force)
        Set-Content -LiteralPath (Join-Path $referenceRoot 'soft-earth.md') -Encoding UTF8 -Value @'
---
reference_id: ref-soft-earth
preferred_name: "Soft Earth"
aliases: ["planting plot", "soft soil"]
---

# Soft Earth

The plot accepts a Gasha Seed.
'@
        Set-Content -LiteralPath (Join-Path $context 'external\outside.md') -Encoding UTF8 -Value @'
# Outside note

Outside spoiler phrase.
'@
        $sibling = Join-Path $vault 'collections\test-subject\contexts\sibling'
        [void](New-Item -ItemType Directory -Path $sibling -Force)
        Set-Content -LiteralPath (Join-Path $sibling 'README.md') -Encoding UTF8 -Value @'
# Sibling

Forbidden sibling fact.
'@
        $sourceHash = (Get-FileHash -LiteralPath $guidePath -Algorithm SHA256).Hash

        $built = & $buildSearchIndexScript `
            -VaultPath $vault `
            -PythonPath $realPython.Source `
            -IncludeExternal `
            -Confirm:$false
        Assert-Equal 'built' $built.State 'Real FTS5 engine did not build an index.'
        Assert-True ($built.Files -ge 8) 'Real FTS5 engine indexed too few Markdown files.'
        Assert-True ($built.Sections -gt $built.Files) 'Real FTS5 engine did not create heading-aligned sections.'
        Assert-True (Test-Path -LiteralPath $built.IndexPath -PathType Leaf) 'Real FTS5 database is missing.'
        Assert-Equal $sourceHash (Get-FileHash -LiteralPath $guidePath -Algorithm SHA256).Hash `
            'Real FTS5 build changed an authoritative guide file.'

        $search = & $searchIndexScript `
            -VaultPath $vault `
            -Query 'soil plot planting Gasha' `
            -PythonPath $realPython.Source
        Assert-False $search.IndexStale 'Fresh real FTS5 index was reported stale.'
        Assert-True (@($search.Results).Count -gt 0) 'Real FTS5 search returned no result.'
        Assert-True (@($search.Results | Where-Object { $_.RelativePath -eq 'guide/mechanics.md' }).Count -gt 0) `
            'Real FTS5 search did not return the governing guide.'
        Assert-True (@($search.Results | Where-Object { $_.Snippet -match '\[soil\]|\[plot\]|\[planting\]' }).Count -gt 0) `
            'Real FTS5 search did not mark matching snippet terms.'

        $trackerSearch = & $searchIndexScript `
            -VaultPath $vault `
            -Query 'MoonKey gate stateful tracker token' `
            -PythonPath $realPython.Source
        Assert-True (@($trackerSearch.Results | Where-Object {
            $_.RelativePath -eq 'trackers/tasks.md' -and $_.Kind -eq 'state-tracker'
        }).Count -gt 0) 'Real FTS5 search did not classify current-state trackers.'

        $externalHidden = & $searchIndexScript `
            -VaultPath $vault `
            -Query 'outside spoiler phrase' `
            -PythonPath $realPython.Source
        Assert-Equal 0 @($externalHidden.Results).Count `
            'Normal FTS5 query leaked explicitly indexed outside knowledge.'
        $externalVisible = & $searchIndexScript `
            -VaultPath $vault `
            -Query 'outside spoiler phrase' `
            -PythonPath $realPython.Source `
            -IncludeExternal
        Assert-True (@($externalVisible.Results | Where-Object { $_.SourceTier -eq 'external' }).Count -eq 1) `
            'Scoped FTS5 query did not return explicitly included outside knowledge.'

        $siblingLeak = & $searchIndexScript `
            -VaultPath $vault `
            -Query 'forbidden sibling fact' `
            -PythonPath $realPython.Source
        Assert-Equal 0 @($siblingLeak.Results).Count 'FTS5 index leaked a sibling-context fact.'

        Add-Content -LiteralPath $guidePath -Encoding UTF8 -Value "`r`nA later source edit."
        [IO.File]::SetLastWriteTimeUtc($guidePath, [DateTime]::UtcNow.AddSeconds(2))
        $stale = & $searchIndexScript `
            -VaultPath $vault `
            -Query 'soil plot planting Gasha' `
            -PythonPath $realPython.Source `
            -NoAutoRefresh `
            -WarningAction SilentlyContinue
        Assert-True $stale.IndexStale 'Changed source did not mark the real FTS5 index stale.'
        Assert-True (@($stale.Results | Where-Object { $_.RelativePath -eq 'guide/mechanics.md' -and $_.SourceStale }).Count -gt 0) `
            'Changed returned source did not receive SourceStale=true.'

        $automaticallyRefreshed = & $searchIndexScript `
            -VaultPath $vault `
            -Query 'soil plot planting Gasha' `
            -PythonPath $realPython.Source `
            -SearchMode lexical
        Assert-True $automaticallyRefreshed.AutoRefreshAttempted `
            'Normal retrieval did not attempt to refresh the stale index.'
        Assert-True $automaticallyRefreshed.AutoRefreshed `
            'Normal retrieval did not atomically rebuild the stale index.'
        Assert-False $automaticallyRefreshed.IndexStale `
            'Automatic retrieval refresh returned the original stale result.'
        Assert-Equal 'lexical' $automaticallyRefreshed.AutoRefreshMode `
            'Explicit lexical automatic refresh changed retrieval mode.'

        $wrongContextFailed = $false
        try {
            & $searchIndexScript `
                -VaultPath $vault `
                -CollectionSlug 'test-subject' `
                -ContextSlug 'sibling' `
                -IndexPath $built.IndexPath `
                -Query 'Soft Earth' `
                -PythonPath $realPython.Source *> $null
        }
        catch { $wrongContextFailed = $_.Exception.Message -match 'different context' }
        Assert-True $wrongContextFailed 'FTS5 query accepted an index belonging to another context.'

        $rebuilt = & $buildSearchIndexScript `
            -VaultPath $vault `
            -PythonPath $realPython.Source `
            -IncludeExternal `
            -Confirm:$false
        $freshAgain = & $searchIndexScript `
            -VaultPath $vault `
            -Query 'soil plot planting Gasha' `
            -PythonPath $realPython.Source
        Assert-False $freshAgain.IndexStale 'Atomic rebuild did not refresh the real FTS5 index.'
        Assert-Equal $rebuilt.IndexPath $freshAgain.IndexPath 'Rebuild changed the context-specific index identity.'
    }
}

if ($realPython) {
    Invoke-Test 'second brain hybrid search uses loopback embeddings and lexical fallback' {
        $vault = New-SecondBrainFixture 'second-brain-hybrid-real'
        $context = Join-Path $vault 'collections\test-subject\contexts\main'
        $guidePath = Join-Path $context 'guide\time-travel.md'
        Set-Content -LiteralPath $guidePath -Encoding UTF8 -Value @'
# Time travel

## Concentric floor tile

A concentric brown floor tile transfers Link across temporal states.
'@
        Set-Content -LiteralPath (Join-Path $context 'guide\unrelated.md') -Encoding UTF8 -Value @'
# Unrelated

The village shop sells ordinary supplies.
'@
        Set-Content -LiteralPath (Join-Path $context 'external\semantic-outside.md') -Encoding UTF8 -Value @'
# Outside semantic note

A hidden portal jumps between eras but is not firsthand playthrough evidence.
'@
        $guideHash = (Get-FileHash -LiteralPath $guidePath -Algorithm SHA256).Hash

        $listener = New-Object Net.Sockets.TcpListener([Net.IPAddress]::Loopback, 0)
        $listener.Start()
        $port = ([Net.IPEndPoint]$listener.LocalEndpoint).Port
        $listener.Stop()
        $serverScript = Join-Path $script:TemporaryRoot 'mock-ollama-embed.py'
        Set-Content -LiteralPath $serverScript -Encoding UTF8 -Value @'
import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import sys

def vector(text):
    lowered = text.lower()
    if "dimension mismatch query" in lowered:
        return [1.0, 0.0, 0.0]
    if any(term in lowered for term in ("concentric", "temporal", "portal", "jumping", "eras")):
        return [1.0, 0.0, 0.0, 0.0]
    if any(term in lowered for term in ("shop", "supplies")):
        return [0.0, 1.0, 0.0, 0.0]
    return [0.0, 0.0, 0.0, 1.0]

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path != "/api/tags":
            self.send_error(404)
            return
        body = json.dumps({"models": [{"name": "fixture-embedding-model:latest"}]}).encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_POST(self):
        if self.path != "/api/embed":
            self.send_error(404)
            return
        length = int(self.headers.get("Content-Length", "0"))
        payload = json.loads(self.rfile.read(length).decode("utf-8"))
        inputs = payload.get("input", [])
        if isinstance(inputs, str):
            inputs = [inputs]
        body = json.dumps({"model": payload.get("model"), "embeddings": [vector(item) for item in inputs]}).encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format, *args):
        return

ThreadingHTTPServer(("127.0.0.1", int(sys.argv[1])), Handler).serve_forever()
'@

        $server = Start-Process `
            -FilePath $realPython.Source `
            -ArgumentList @('-B', $serverScript, [string]$port) `
            -WindowStyle Hidden `
            -PassThru
        $endpoint = "http://127.0.0.1:$port"
        $started = $false
        try {
            for ($attempt = 0; $attempt -lt 50; $attempt++) {
                $client = New-Object Net.Sockets.TcpClient
                try {
                    $client.Connect('127.0.0.1', $port)
                    $started = $true
                    break
                }
                catch { Start-Sleep -Milliseconds 100 }
                finally { $client.Dispose() }
            }
            Assert-True $started 'Local mock embedding endpoint did not start.'

            $automaticVault = Join-Path $script:TemporaryRoot 'second-brain-hybrid-auto'
            $automatic = & $initializeScript `
                -VaultPath $automaticVault `
                -CollectionName 'Hybrid Automatic' `
                -CollectionSlug 'hybrid-automatic' `
                -SearchMode auto `
                -EmbeddingModel 'fixture-embedding-model' `
                -EmbeddingEndpoint $endpoint `
                -PythonPath $realPython.Source
            Assert-Equal 'ready' $automatic.SearchIndexState `
                'Automatic initialization did not build a search index with available prerequisites.'
            Assert-Equal 'hybrid' $automatic.EffectiveSearchMode `
                'Automatic initialization did not prefer the available loopback embedding model.'
            Assert-Equal 'fixture-embedding-model' $automatic.EmbeddingModel `
                'Automatic initialization lost the selected local embedding model.'
            $automaticContext = Join-Path $automaticVault 'collections\hybrid-automatic\contexts\main'
            Set-Content -LiteralPath (Join-Path $automaticContext 'guide\time-travel.md') -Encoding UTF8 -Value @'
# Time travel

A concentric floor tile transfers the traveler between temporal states.
'@
            $automaticSearch = & $searchIndexScript `
                -VaultPath $automaticVault `
                -Query 'portal for jumping between eras' `
                -PythonPath $realPython.Source
            Assert-True $automaticSearch.AutoRefreshed `
                'First retrieval after a source change did not refresh the automatic hybrid index.'
            Assert-False $automaticSearch.IndexStale `
                'Automatic hybrid retrieval returned a stale index after refresh.'
            Assert-True $automaticSearch.SemanticRequested `
                'Automatic search mode did not request semantic retrieval by default.'
            Assert-True $automaticSearch.SemanticUsed `
                'Automatic search mode did not use the configured local embedding model.'
            Assert-True (@($automaticSearch.Results | Where-Object { $_.RelativePath -eq 'guide/time-travel.md' }).Count -gt 0) `
                'Automatic hybrid retrieval missed the newly indexed guide.'

            $built = & $buildSearchIndexScript `
                -VaultPath $vault `
                -PythonPath $realPython.Source `
                -Semantic `
                -IncludeExternal `
                -EmbeddingModel 'fixture-embedding-model' `
                -EmbeddingEndpoint $endpoint `
                -EmbeddingBatchSize 3 `
                -Confirm:$false
            Assert-True $built.SemanticEnabled 'Hybrid fixture did not build semantic vectors.'
            Assert-Equal 4 $built.EmbeddingDimension 'Hybrid fixture lost vector dimension.'
            Assert-Equal $built.Sections $built.SemanticSections 'Not every indexed section received an embedding.'
            Assert-Equal $guideHash (Get-FileHash -LiteralPath $guidePath -Algorithm SHA256).Hash `
                'Semantic build changed the authoritative guide.'

            $semanticOnly = & $searchIndexScript `
                -VaultPath $vault `
                -Query 'portal for jumping between eras' `
                -PythonPath $realPython.Source `
                -Semantic `
                -EmbeddingEndpoint $endpoint
            Assert-True $semanticOnly.SemanticUsed 'Description query did not use semantic retrieval.'
            $semanticGuide = @($semanticOnly.Results | Where-Object { $_.RelativePath -eq 'guide/time-travel.md' })
            Assert-True ($semanticGuide.Count -gt 0) 'Semantic retrieval missed the description-only matching guide.'
            Assert-True ($semanticGuide[0].RetrievalModes -contains 'semantic') 'Semantic result lost its retrieval mode.'
            Assert-True ($null -eq $semanticGuide[0].LexicalRank) 'Description-only fixture unexpectedly depended on lexical retrieval.'
            Assert-Equal 0 @($semanticOnly.Results | Where-Object { $_.SourceTier -eq 'external' }).Count `
                'Normal semantic query leaked explicitly indexed outside knowledge.'

            $semanticExternal = & $searchIndexScript `
                -VaultPath $vault `
                -Query 'portal for jumping between eras' `
                -PythonPath $realPython.Source `
                -Semantic `
                -IncludeExternal `
                -EmbeddingEndpoint $endpoint
            Assert-True (@($semanticExternal.Results | Where-Object { $_.SourceTier -eq 'external' }).Count -gt 0) `
                'Scoped semantic query did not return explicitly included outside knowledge.'

            $hybrid = & $searchIndexScript `
                -VaultPath $vault `
                -Query 'concentric brown floor tile' `
                -PythonPath $realPython.Source `
                -Semantic `
                -EmbeddingEndpoint $endpoint
            $hybridGuide = @($hybrid.Results | Where-Object { $_.RelativePath -eq 'guide/time-travel.md' })
            Assert-True ($hybridGuide.Count -gt 0) 'Hybrid query missed the governing guide.'
            Assert-True ($hybridGuide[0].RetrievalModes -contains 'lexical') 'Hybrid result lost lexical provenance.'
            Assert-True ($hybridGuide[0].RetrievalModes -contains 'semantic') 'Hybrid result lost semantic provenance.'
            Assert-True ($hybridGuide[0].HybridScore -gt 0) 'Hybrid result lost reciprocal-rank score.'

            $dimensionMismatch = & $searchIndexScript `
                -VaultPath $vault `
                -Query 'dimension mismatch query' `
                -PythonPath $realPython.Source `
                -Semantic `
                -EmbeddingEndpoint $endpoint `
                -WarningAction SilentlyContinue
            Assert-False $dimensionMismatch.SemanticUsed 'Dimension mismatch was accepted as semantic evidence.'
            Assert-True ($dimensionMismatch.SemanticError -match 'dimension') 'Dimension mismatch did not produce a visible semantic error.'

            $indexHash = (Get-FileHash -LiteralPath $built.IndexPath -Algorithm SHA256).Hash
            $remoteFailed = $false
            try {
                & $buildSearchIndexScript `
                    -VaultPath $vault `
                    -PythonPath $realPython.Source `
                    -Semantic `
                    -IncludeExternal `
                    -EmbeddingModel 'fixture-embedding-model' `
                    -EmbeddingEndpoint 'http://example.com' `
                    -Confirm:$false *> $null
            }
            catch { $remoteFailed = $_.Exception.Message -match 'loopback|127\.0\.0\.1' }
            Assert-True $remoteFailed 'Semantic build accepted a non-loopback embedding endpoint.'
            Assert-Equal $indexHash (Get-FileHash -LiteralPath $built.IndexPath -Algorithm SHA256).Hash `
                'Failed semantic rebuild replaced the prior completed index.'
        }
        finally {
            if ($server -and -not $server.HasExited) {
                Stop-Process -Id $server.Id -Force
                $server.WaitForExit()
            }
        }

        $lexicalFallback = & $searchIndexScript `
            -VaultPath $vault `
            -Query 'concentric brown floor tile' `
            -PythonPath $realPython.Source `
            -Semantic `
            -EmbeddingEndpoint $endpoint `
            -EmbeddingTimeoutSeconds 2 `
            -WarningAction SilentlyContinue
        Assert-False $lexicalFallback.SemanticUsed 'Offline endpoint did not degrade semantic retrieval.'
        Assert-True ([bool]$lexicalFallback.SemanticError) 'Offline semantic fallback did not expose its limitation.'
        Assert-True (@($lexicalFallback.Results | Where-Object { $_.RetrievalModes -contains 'lexical' }).Count -gt 0) `
            'Offline semantic endpoint blocked otherwise valid FTS5 results.'
    }
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
    Assert-True ($skill.Contains('`-CaptureId` and `-CaptureGroupId`')) `
        'Skill does not require candidate capture and group IDs on the first helper call.'
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

Invoke-Test 'second brain capture groups and relations preserve predecessor identity' {
    $vault = New-SecondBrainFixture 'second-brain-groups-relations'
    $imagePath = Join-Path $script:TemporaryRoot 'group-image.png'
    [IO.File]::WriteAllBytes($imagePath, [byte[]](0x89, 0x50, 0x4e, 0x47))
    $sourceGroup = 'GRP-20260726-180000-abcd'
    $first = & $captureScript `
        -VaultPath $vault `
        -InputType screenshot `
        -Content 'Two views of one chest.' `
        -AttachmentPath $imagePath `
        -CaptureId 'CAP-20260726-180000-a001' `
        -CaptureGroupId $sourceGroup `
        -GroupOrdinal 1 `
        -SessionId 'session-groups'
    $second = & $captureScript `
        -VaultPath $vault `
        -InputType screenshot `
        -Content 'Two views of one chest.' `
        -AttachmentPath $imagePath `
        -CaptureId 'CAP-20260726-180000-a002' `
        -CaptureGroupId $sourceGroup `
        -GroupOrdinal 2 `
        -SessionId 'session-groups'
    $resultGroup = 'GRP-20260726-180100-b001'
    $identified = & $captureScript `
        -VaultPath $vault `
        -InputType text `
        -Content 'The item from the previous message was identified.' `
        -CaptureId 'CAP-20260726-180100-b001' `
        -CaptureGroupId $resultGroup `
        -PreviousCaptureGroupId $sourceGroup `
        -SessionId 'session-groups'

    Assert-Equal $sourceGroup $first.CaptureGroupId 'First companion capture lost the shared group.'
    Assert-Equal $sourceGroup $second.CaptureGroupId 'Second companion capture lost the shared group.'
    Assert-Equal 2 $second.GroupOrdinal 'Second companion capture lost attachment order.'
    Assert-Equal $sourceGroup $identified.PreviousCaptureGroupId 'Predecessor group was not persisted.'
    $identifiedText = Get-Content -LiteralPath $identified.CapturePath -Raw
    Assert-True ($identifiedText.Contains("previous_capture_group_id: $sourceGroup")) `
        'Immutable capture did not preserve the predecessor group.'

    $relationId = 'REL-20260726-180101-c001'
    $relation = & $relationScript `
        -VaultPath $vault `
        -SourceId $identified.CaptureId `
        -RelationType resolves `
        -TargetId $sourceGroup `
        -EvidenceCaptureId $identified.CaptureId `
        -Detail 'The user explicitly referred to the immediately preceding group.' `
        -RelationId $relationId
    $retry = & $relationScript `
        -VaultPath $vault `
        -SourceId $identified.CaptureId `
        -RelationType resolves `
        -TargetId $sourceGroup `
        -EvidenceCaptureId $identified.CaptureId `
        -Detail 'The user explicitly referred to the immediately preceding group.' `
        -RelationId $relationId
    Assert-Equal 'related' $relation.State 'Relation helper did not append the relation.'
    Assert-Equal 'existing-relation' $retry.State 'Relation retry duplicated an existing relation ID.'

    $audit = & $contextAuditScript -VaultPath $vault
    Assert-True $audit.IsConsistent 'Grouped fixture did not pass the context audit.'
    Assert-Equal 2 $audit.CaptureGroupCount 'Context audit lost capture-group identity.'
    Assert-Equal 1 $audit.RelationCount 'Context audit did not count the relation ledger exactly.'
}

Invoke-Test 'second brain tracker invariants detect stale identified and harvested state' {
    $vault = New-SecondBrainFixture 'second-brain-tracker-invariants'
    $capture = & $captureScript `
        -VaultPath $vault `
        -InputType text `
        -Content 'Synthetic current-state evidence.' `
        -CaptureId 'CAP-20260726-181000-d001'
    $context = Join-Path $vault 'collections\test-subject\contexts\main'
    $trackers = Join-Path $context 'trackers'
    [void](New-Item -ItemType Directory -Path $trackers)
    $trackerPath = Join-Path $trackers 'current-state.md'
    $trackerText = @(
        '---',
        'tracker_schema: ai-second-brain/v1',
        'tracker_type: game-state',
        '---',
        '',
        '| ID | Kind | Label | State | Quantity | Parent ID | Map anchor | Opened by | Closed by | Notes |',
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
        ('| `PLANT-001` | planting | Test planting | planted | 1 |  |  | `{0}` |  | Waiting |' -f $capture.CaptureId),
        ('| `NUT-001` | harvest | Test harvest | collected | 1 | `PLANT-001` |  | `{0}` | `{0}` | Collected |' -f $capture.CaptureId),
        ('| `RING-001` | item-instance | Test Ring | unidentified | 1 |  |  | `{0}` |  | Appraised later |' -f $capture.CaptureId)
    ) -join [Environment]::NewLine
    Set-Content -LiteralPath $trackerPath -Value $trackerText -Encoding UTF8
    & $relationScript `
        -VaultPath $vault `
        -SourceId 'NUT-001' `
        -RelationType 'harvest-of' `
        -TargetId 'PLANT-001' `
        -EvidenceCaptureId $capture.CaptureId `
        -Detail 'The harvested item came from the planting.' | Out-Null
    & $relationScript `
        -VaultPath $vault `
        -SourceId 'RING-001' `
        -RelationType 'identified-as' `
        -TargetId 'RING-TYPE-ALPHA' `
        -EvidenceCaptureId $capture.CaptureId `
        -Detail 'The item was identified.' | Out-Null

    $stale = & $contextAuditScript -VaultPath $vault
    Assert-False $stale.IsConsistent 'Audit accepted stale tracker state after confirmed relations.'
    Assert-True (@($stale.Errors | Where-Object { $_ -match 'harvest-of.*still has state' }).Count -eq 1) `
        'Audit did not detect the stale planting state.'
    Assert-True (@($stale.Errors | Where-Object { $_ -match 'identified-as.*still has state' }).Count -eq 1) `
        'Audit did not detect the stale unidentified state.'

    $trackerText = $trackerText.Replace('| planted |', '| harvested |').Replace('| unidentified |', '| identified |')
    Set-Content -LiteralPath $trackerPath -Value $trackerText -Encoding UTF8
    $fixed = & $contextAuditScript -VaultPath $vault
    Assert-True $fixed.IsConsistent 'Corrected tracker states did not pass the audit.'
    Assert-Equal 3 $fixed.TrackerRecordCount 'Audit lost tracker rows.'
}

Invoke-Test 'second brain completion audit requires terminal disposition and detects false zero claims' {
    $vault = New-SecondBrainFixture 'second-brain-completion-gate'
    $capture = & $captureScript -VaultPath $vault -InputType text -Content 'Optional credits note.'
    $context = Join-Path $vault 'collections\test-subject\contexts\main'
    $statePath = Join-Path $context '_evidence\state.md'
    $state = (Get-Content -LiteralPath $statePath -Raw).Replace('Lifecycle: `active`', 'Lifecycle: `completed`')
    $state += [Environment]::NewLine + 'Latest queue: `no pending captures`'
    Set-Content -LiteralPath $statePath -Value $state -Encoding UTF8

    $blocked = & $contextAuditScript -VaultPath $vault -CompletionGate
    Assert-False $blocked.CompletionReady 'Completion gate accepted a pending capture.'
    Assert-True (@($blocked.Errors | Where-Object { $_ -match 'claims no pending captures' }).Count -eq 1) `
        'Audit did not detect the false zero-pending claim.'

    $closed = & $processingEventScript `
        -VaultPath $vault `
        -CaptureId $capture.CaptureId `
        -State scope-closed `
        -Detail 'User explicitly declined processing.'
    Assert-Equal 'scope-closed' $closed.State 'Processing helper did not accept scope-closed.'
    $ready = & $contextAuditScript -VaultPath $vault -CompletionGate
    Assert-True $ready.CompletionReady 'Terminally disposed capture did not satisfy the completion gate.'
    Assert-Equal 0 $ready.PendingCaptureCount 'Scope-closed capture remained pending.'
}

Invoke-Test 'second brain reconciliation lock enforces exact ownership' {
    $vault = New-SecondBrainFixture 'second-brain-reconciliation-lock'
    $first = & $reconciliationLockScript `
        -VaultPath $vault `
        -Action acquire `
        -OwnerId 'task-one'
    Assert-Equal 'acquired' $first.State 'First reconciliation owner did not acquire the lock.'
    $renewed = & $reconciliationLockScript `
        -VaultPath $vault `
        -Action acquire `
        -OwnerId 'task-one'
    Assert-Equal 'renewed' $renewed.State 'Existing owner could not renew the reconciliation lease.'

    $second = & $reconciliationLockScript `
        -VaultPath $vault `
        -Action acquire `
        -OwnerId 'task-two'
    Assert-Equal 'locked' $second.State 'Second reconciliation owner incorrectly acquired the lock.'
    Assert-Equal 'task-one' $second.OwnerId 'Lock view lost the current owner.'

    $wrongOwnerFailed = $false
    try {
        & $reconciliationLockScript -VaultPath $vault -Action release -OwnerId 'task-two' *> $null
    }
    catch { $wrongOwnerFailed = $true }
    Assert-True $wrongOwnerFailed 'A different owner released the reconciliation lock.'

    $released = & $reconciliationLockScript `
        -VaultPath $vault `
        -Action release `
        -OwnerId 'task-one'
    Assert-Equal 'released' $released.State 'Exact owner did not release the reconciliation lock.'
    $view = & $reconciliationLockScript -VaultPath $vault -Action view
    Assert-Equal 'unlocked' $view.State 'Released lock remained present.'
}

Invoke-Test 'second brain audit reports human-surface, rollover, duplicate, and link drift' {
    $vault = New-SecondBrainFixture 'second-brain-audit-drift'
    for ($index = 1; $index -le 6; $index++) {
        $captureId = 'CAP-20260726-19{0:0000}-a{1:000}' -f $index, $index
        & $captureScript `
            -VaultPath $vault `
            -InputType text `
            -Content "Session entry $index." `
            -CaptureId $captureId `
            -SessionId 'oversized-session' | Out-Null
    }
    $context = Join-Path $vault 'collections\test-subject\contexts\main'
    $trackers = Join-Path $context 'trackers'
    [void](New-Item -ItemType Directory -Path $trackers)
    $duplicateTracker = @(
        '---',
        'tracker_schema: ai-second-brain/v1',
        'tracker_type: game-state',
        '---',
        '',
        '| ID | Kind | Label | State | Quantity | Parent ID | Map anchor | Opened by | Closed by | Notes |',
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
        '| `TASK-001` | task | First | open | 1 |  |  |  |  | First |',
        '| `TASK-001` | task | Duplicate | open | 1 |  |  |  |  | Duplicate |'
    ) -join [Environment]::NewLine
    Set-Content -LiteralPath (Join-Path $trackers 'tasks.md') -Value $duplicateTracker -Encoding UTF8
    Add-Content -LiteralPath (Join-Path $context 'README.md') -Value "`r`n[Broken](missing-note.md)"
    $statePath = Join-Path $context '_evidence\state.md'
    Add-Content -LiteralPath $statePath -Value (("`r`nLatest checkpoint delta: history" * 200))

    $audit = & $contextAuditScript `
        -VaultPath $vault `
        -MaxSessionCaptureGroups 5 `
        -MaxStateBytes 4096
    Assert-False $audit.IsConsistent 'Audit accepted duplicate tracker IDs and a broken link.'
    Assert-True (@($audit.Errors | Where-Object { $_ -match "Tracker ID 'TASK-001' appears more than once" }).Count -eq 1) `
        'Audit did not detect a duplicate tracker ID.'
    Assert-Equal 1 $audit.BrokenLinkCount 'Audit did not detect the broken local link exactly.'
    Assert-True (@($audit.Warnings | Where-Object { $_ -match 'oversized-session.*roll over' }).Count -eq 1) `
        'Audit did not warn about proactive task rollover.'
    Assert-True (@($audit.Warnings | Where-Object { $_ -match 'State metadata is.*compact it' }).Count -eq 1) `
        'Audit did not warn about oversized state metadata.'
}

Invoke-Test 'second brain skill requires exhaustive state tracking and completion validation' {
    $skill = Get-Content -LiteralPath $skillPath -Raw
    $stateTracking = Get-Content -LiteralPath $stateTrackingReferencePath -Raw
    $scenarios = Get-Content -LiteralPath $validationScenariosPath -Raw

    Assert-True ($skill.Contains('choose one capture-group ID')) `
        'Skill does not require one durable group for an accepted message.'
    Assert-True ($skill.Contains('Never label top-ranked search results exhaustive.')) `
        'Skill does not separate exhaustive enumeration from search ranking.'
    Assert-True ($skill.Contains('`-CompletionGate`')) `
        'Skill does not require the completion audit.'
    Assert-True ($stateTracking.Contains('Identification and source attribution are separate.')) `
        'State-tracking contract does not preserve aggregate state without false attribution.'
    Assert-True ($stateTracking.Contains('When a screenshot contains a map')) `
        'State-tracking contract does not make implicit map position first-class.'
    foreach ($scenario in 29..36) {
        Assert-True ($scenarios.Contains(('## V{0:00}' -f $scenario))) `
            "Validation scenarios are missing V$scenario."
    }
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
