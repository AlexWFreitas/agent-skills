#requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$VaultPath,

    [string]$CollectionSlug,

    [string]$ContextSlug,

    [switch]$CompletionGate,

    [switch]$RequireCompletionReady,

    [ValidateRange(4096, 1048576)]
    [int]$MaxStateBytes = 24576,

    [ValidateRange(40, 5000)]
    [int]$MaxHomeLines = 160,

    [ValidateRange(100, 10000)]
    [int]$MaxJournalLines = 1000,

    [ValidateRange(5, 1000)]
    [int]$MaxSessionCaptureGroups = 40
)

$ErrorActionPreference = 'Stop'
$errors = New-Object Collections.Generic.List[string]
$warnings = New-Object Collections.Generic.List[string]

function Add-AuditError {
    param([Parameter(Mandatory = $true)][string]$Message)
    if (-not $errors.Contains($Message)) { [void]$errors.Add($Message) }
}

function Add-AuditWarning {
    param([Parameter(Mandatory = $true)][string]$Message)
    if (-not $warnings.Contains($Message)) { [void]$warnings.Add($Message) }
}

function Resolve-EvidenceRoot {
    param([Parameter(Mandatory = $true)][string]$ContextRoot)

    $humanFirstRoot = Join-Path $ContextRoot '_evidence'
    $legacyRoot = Join-Path $ContextRoot 'inbox'
    $hasHumanFirst = Test-Path -LiteralPath $humanFirstRoot -PathType Container
    $hasLegacy = Test-Path -LiteralPath $legacyRoot -PathType Container
    if ($hasHumanFirst -and $hasLegacy) {
        throw "Active context has both '_evidence' and legacy 'inbox' backends."
    }
    if ($hasHumanFirst) { return $humanFirstRoot }
    if ($hasLegacy) { return $legacyRoot }
    throw "Active context has no evidence backend: $ContextRoot"
}

function Get-FrontmatterValue {
    param(
        [Parameter(Mandatory = $true)][string]$Markdown,
        [Parameter(Mandatory = $true)][string]$Name
    )

    $match = [regex]::Match($Markdown, '(?m)^' + [regex]::Escape($Name) + ':\s*(.*?)\s*$')
    if (-not $match.Success) { return $null }
    $value = $match.Groups[1].Value.Trim()
    if (($value.StartsWith('"') -and $value.EndsWith('"')) -or
        ($value.StartsWith("'") -and $value.EndsWith("'")) -or
        ($value.StartsWith('`') -and $value.EndsWith('`'))) {
        if ($value.Length -ge 2) { $value = $value.Substring(1, $value.Length - 2) }
    }
    return $value
}

function Get-LineCount {
    param([Parameter(Mandatory = $true)][string]$LiteralPath)
    $count = 0
    foreach ($line in [IO.File]::ReadLines($LiteralPath)) { $count++ }
    return $count
}

function Convert-TrackerCell {
    param([string]$Value)
    if ($null -eq $Value) { return '' }
    $text = $Value.Trim()
    if ($text.StartsWith('`') -and $text.EndsWith('`') -and $text.Length -ge 2) {
        $text = $text.Substring(1, $text.Length - 2)
    }
    if ($text -in @('-', '--', '---', '—', 'none', 'None', 'null')) { return '' }
    return $text.Trim()
}

function Get-TrackerRecords {
    param([Parameter(Mandatory = $true)][string]$TrackersRoot)

    $records = @()
    if (-not (Test-Path -LiteralPath $TrackersRoot -PathType Container)) { return $records }
    foreach ($file in @(Get-ChildItem -LiteralPath $TrackersRoot -Recurse -File -Filter '*.md')) {
        $raw = Get-Content -LiteralPath $file.FullName -Raw
        if ((Get-FrontmatterValue -Markdown $raw -Name 'tracker_schema') -ne 'ai-second-brain/v1') {
            Add-AuditWarning "Tracker '$($file.FullName)' does not declare tracker_schema ai-second-brain/v1."
            continue
        }
        $lines = Get-Content -LiteralPath $file.FullName
        $headers = $null
        for ($lineIndex = 0; $lineIndex -lt $lines.Count; $lineIndex++) {
            $line = $lines[$lineIndex]
            if ($line -notmatch '^\s*\|') { continue }
            $cells = @($line.Trim().Trim('|').Split('|') | ForEach-Object { $_.Trim() })
            if (-not $headers) {
                $headers = @($cells | ForEach-Object { $_.ToLowerInvariant() })
                $required = @('id', 'kind', 'label', 'state', 'quantity', 'parent id', 'map anchor', 'opened by', 'closed by', 'notes')
                foreach ($name in $required) {
                    if ($name -notin $headers) {
                        Add-AuditError "Tracker '$($file.FullName)' is missing required column '$name'."
                    }
                }
                continue
            }
            if ($cells.Count -gt 0 -and $cells[0] -match '^:?-{3,}:?$') { continue }
            if ($cells.Count -ne $headers.Count) {
                Add-AuditError "Tracker row $($lineIndex + 1) in '$($file.FullName)' has $($cells.Count) cells; expected $($headers.Count)."
                continue
            }
            $values = @{}
            for ($column = 0; $column -lt $headers.Count; $column++) {
                $values[$headers[$column]] = Convert-TrackerCell $cells[$column]
            }
            if (-not $values['id']) { continue }
            $records += [pscustomobject]@{
                Id = $values['id']
                Kind = $values['kind']
                Label = $values['label']
                State = $values['state']
                Quantity = $values['quantity']
                ParentId = $values['parent id']
                MapAnchor = $values['map anchor']
                OpenedBy = $values['opened by']
                ClosedBy = $values['closed by']
                Notes = $values['notes']
                Path = $file.FullName
                Line = $lineIndex + 1
            }
        }
    }
    return @($records)
}

function Get-HumanMarkdownFiles {
    param([Parameter(Mandatory = $true)][string]$ContextRoot)

    $files = @()
    foreach ($name in @('README.md', 'open-questions.md')) {
        $path = Join-Path $ContextRoot $name
        if (Test-Path -LiteralPath $path -PathType Leaf) { $files += Get-Item -LiteralPath $path }
    }
    foreach ($directoryName in @('guide', 'journal', 'trackers', 'library')) {
        $directory = Join-Path $ContextRoot $directoryName
        if (Test-Path -LiteralPath $directory -PathType Container) {
            $files += @(Get-ChildItem -LiteralPath $directory -Recurse -File -Filter '*.md')
        }
    }
    return @($files)
}

function Get-BrokenLinks {
    param(
        [Parameter(Mandatory = $true)][object[]]$Files,
        [Parameter(Mandatory = $true)][string]$CollectionRoot
    )

    $broken = @()
    foreach ($file in $Files) {
        $raw = Get-Content -LiteralPath $file.FullName -Raw
        foreach ($match in [regex]::Matches($raw, '!?\[[^\]]*\]\(([^)]+)\)')) {
            $target = $match.Groups[1].Value.Trim()
            if ($target -match '^(https?:|mailto:|data:)' -or $target.StartsWith('#')) { continue }
            if ($target.StartsWith('<') -and $target.EndsWith('>')) {
                $target = $target.Substring(1, $target.Length - 2)
            }
            $target = ($target -split '#', 2)[0]
            if (-not $target) { continue }
            try { $target = [uri]::UnescapeDataString($target) } catch {}
            try {
                if ([IO.Path]::IsPathRooted($target)) { $resolved = [IO.Path]::GetFullPath($target) }
                else { $resolved = [IO.Path]::GetFullPath((Join-Path $file.DirectoryName $target)) }
            }
            catch {
                $broken += [pscustomobject]@{ Source = $file.FullName; Target = $target; Resolved = $null }
                continue
            }
            if (-not (Test-Path -LiteralPath $resolved)) {
                $broken += [pscustomobject]@{ Source = $file.FullName; Target = $target; Resolved = $resolved }
            }
        }
        foreach ($match in [regex]::Matches($raw, '!?\[\[([^\]|#]+)')) {
            $target = $match.Groups[1].Value.Trim()
            if (-not $target) { continue }
            $resolved = [IO.Path]::GetFullPath((Join-Path $CollectionRoot ($target.Replace('/', '\'))))
            if (Test-Path -LiteralPath $resolved) { continue }
            if (-not [IO.Path]::HasExtension($resolved) -and
                (Test-Path -LiteralPath ($resolved + '.md') -PathType Leaf)) { continue }
            $broken += [pscustomobject]@{ Source = $file.FullName; Target = $target; Resolved = $resolved }
        }
    }
    return @($broken)
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

$collectionRoot = Join-Path $vaultRoot "collections\$CollectionSlug"
$contextRoot = Join-Path $collectionRoot "contexts\$ContextSlug"
if (-not (Test-Path -LiteralPath $contextRoot -PathType Container)) {
    throw "Selected context does not exist: $contextRoot"
}
$evidenceRoot = Resolve-EvidenceRoot -ContextRoot $contextRoot
$captureRoot = Join-Path $evidenceRoot 'captures'
$ledgerPath = Join-Path $evidenceRoot 'processing-events.jsonl'
$relationsPath = Join-Path $evidenceRoot 'relations.jsonl'
$statePath = Join-Path $evidenceRoot 'state.md'

$captureRecords = @()
$captureById = @{}
$groupIds = @{}
$groupOrdinals = @{}
$sessionGroups = @{}
foreach ($file in @(Get-ChildItem -LiteralPath $captureRoot -Recurse -File -Filter '*.md')) {
    $raw = Get-Content -LiteralPath $file.FullName -Raw
    $captureId = Get-FrontmatterValue -Markdown $raw -Name 'capture_id'
    if (-not $captureId) { $captureId = $file.BaseName }
    if ($captureById.ContainsKey($captureId)) {
        Add-AuditError "Duplicate capture ID '$captureId' at '$($file.FullName)'."
        continue
    }
    $groupId = Get-FrontmatterValue -Markdown $raw -Name 'capture_group_id'
    $groupOrdinalValue = Get-FrontmatterValue -Markdown $raw -Name 'group_ordinal'
    $groupOrdinal = 0
    if ($groupOrdinalValue) {
        if (-not [int]::TryParse($groupOrdinalValue, [ref]$groupOrdinal) -or $groupOrdinal -lt 1) {
            Add-AuditError "Capture '$captureId' has invalid group_ordinal '$groupOrdinalValue'."
        }
    }
    $previousGroupId = Get-FrontmatterValue -Markdown $raw -Name 'previous_capture_group_id'
    if ($previousGroupId -eq 'null') { $previousGroupId = $null }
    $record = [pscustomobject]@{
        CaptureId = $captureId
        InputType = Get-FrontmatterValue -Markdown $raw -Name 'input_type'
        AttachmentState = Get-FrontmatterValue -Markdown $raw -Name 'attachment_state'
        SessionId = Get-FrontmatterValue -Markdown $raw -Name 'session_id'
        CaptureGroupId = $groupId
        GroupOrdinal = $groupOrdinal
        PreviousCaptureGroupId = $previousGroupId
        Path = $file.FullName
    }
    $captureRecords += $record
    $captureById[$captureId] = $record
    if ($groupId) {
        $groupIds[$groupId] = $true
        $ordinalKey = "$groupId|$groupOrdinal"
        if ($groupOrdinal -gt 0 -and $groupOrdinals.ContainsKey($ordinalKey)) {
            Add-AuditError "Capture group '$groupId' repeats ordinal $groupOrdinal."
        }
        elseif ($groupOrdinal -gt 0) { $groupOrdinals[$ordinalKey] = $captureId }
        if ($record.SessionId) {
            if (-not $sessionGroups.ContainsKey($record.SessionId)) { $sessionGroups[$record.SessionId] = @{} }
            $sessionGroups[$record.SessionId][$groupId] = $true
        }
    }
}
foreach ($record in $captureRecords) {
    if ($record.PreviousCaptureGroupId -and -not $groupIds.ContainsKey($record.PreviousCaptureGroupId)) {
        Add-AuditWarning "Capture '$($record.CaptureId)' references missing previous group '$($record.PreviousCaptureGroupId)'."
    }
}
foreach ($sessionId in $sessionGroups.Keys) {
    $groupCount = $sessionGroups[$sessionId].Count
    if ($groupCount -gt $MaxSessionCaptureGroups) {
        Add-AuditWarning "Session '$sessionId' has $groupCount capture groups; roll over before further assimilation."
    }
}

$latestEvents = @{}
$eventCount = 0
$allowedProcessingStates = @('pending', 'interpreted', 'reconciled', 'conflicted', 'blocked', 'scope-closed')
$legacyProcessingStates = @('processed')
if (-not (Test-Path -LiteralPath $ledgerPath -PathType Leaf)) {
    Add-AuditError "Processing ledger is missing: $ledgerPath"
}
else {
    $lineNumber = 0
    foreach ($line in @(Get-Content -LiteralPath $ledgerPath)) {
        $lineNumber++
        if (-not $line.Trim()) { continue }
        try { $event = $line | ConvertFrom-Json -ErrorAction Stop }
        catch {
            Add-AuditError "Invalid processing-event JSON at line $lineNumber."
            continue
        }
        $eventCount++
        if (-not $event.capture_id -or -not $event.state) {
            Add-AuditError "Processing event at line $lineNumber lacks capture_id or state."
            continue
        }
        if ([string]$event.state -in $legacyProcessingStates) {
            Add-AuditWarning "Capture '$($event.capture_id)' uses legacy processing state '$($event.state)'; append a current supported state when it is next reconciled."
        }
        elseif ([string]$event.state -notin $allowedProcessingStates) {
            Add-AuditError "Capture '$($event.capture_id)' has unsupported processing state '$($event.state)'."
        }
        $latestEvents[[string]$event.capture_id] = $event
    }
}
foreach ($captureId in $captureById.Keys) {
    if (-not $latestEvents.ContainsKey($captureId)) {
        Add-AuditError "Capture '$captureId' has no processing event."
    }
}
foreach ($captureId in $latestEvents.Keys) {
    if (-not $captureById.ContainsKey($captureId)) {
        Add-AuditError "Processing ledger references missing capture '$captureId'."
    }
}

$latestStateCounts = @{}
foreach ($event in $latestEvents.Values) {
    $state = [string]$event.state
    if (-not $latestStateCounts.ContainsKey($state)) { $latestStateCounts[$state] = 0 }
    $latestStateCounts[$state]++
}
$pendingCaptureIds = @($latestEvents.Keys | Where-Object { [string]$latestEvents[$_].state -eq 'pending' } | Sort-Object)
$pendingAttachmentIds = @($captureRecords | Where-Object { $_.AttachmentState -eq 'pending-save-first' } | ForEach-Object CaptureId | Sort-Object)

$interpretationIds = @{}
$interpretationRoot = Join-Path $evidenceRoot 'interpretations'
if (Test-Path -LiteralPath $interpretationRoot -PathType Container) {
    foreach ($file in @(Get-ChildItem -LiteralPath $interpretationRoot -File -Filter '*.md')) {
        $raw = Get-Content -LiteralPath $file.FullName -Raw
        $captureId = Get-FrontmatterValue -Markdown $raw -Name 'capture_id'
        if (-not $captureId) { $captureId = $file.BaseName }
        $interpretationIds[$captureId] = $true
    }
}
$descriptorIds = @{}
$descriptorRoot = Join-Path $contextRoot 'library\captures'
if (Test-Path -LiteralPath $descriptorRoot -PathType Container) {
    foreach ($file in @(Get-ChildItem -LiteralPath $descriptorRoot -File -Filter '*.md')) {
        $raw = Get-Content -LiteralPath $file.FullName -Raw
        $captureId = Get-FrontmatterValue -Markdown $raw -Name 'capture_id'
        if ($captureId) { $descriptorIds[$captureId] = $true }
    }
}
$mediaRecords = @($captureRecords | Where-Object { $_.InputType -in @('screenshot', 'video') })
$mediaWithoutInterpretation = @($mediaRecords | Where-Object { -not $interpretationIds.ContainsKey($_.CaptureId) } | ForEach-Object CaptureId | Sort-Object)
$mediaWithoutDescriptor = @()
if (Test-Path -LiteralPath $descriptorRoot -PathType Container) {
    $mediaWithoutDescriptor = @($mediaRecords | Where-Object { -not $descriptorIds.ContainsKey($_.CaptureId) } | ForEach-Object CaptureId | Sort-Object)
}
foreach ($record in $mediaRecords) {
    if (-not $latestEvents.ContainsKey($record.CaptureId)) { continue }
    $latestState = [string]$latestEvents[$record.CaptureId].state
    if ($latestState -in @('interpreted', 'reconciled') -and
        -not $interpretationIds.ContainsKey($record.CaptureId)) {
        Add-AuditError "Media capture '$($record.CaptureId)' is $latestState but has no interpretation."
    }
    if ($latestState -in @('interpreted', 'reconciled') -and
        (Test-Path -LiteralPath $descriptorRoot -PathType Container) -and
        -not $descriptorIds.ContainsKey($record.CaptureId)) {
        Add-AuditError "Media capture '$($record.CaptureId)' is $latestState but has no semantic descriptor."
    }
}

$trackerRecords = @(Get-TrackerRecords -TrackersRoot (Join-Path $contextRoot 'trackers'))
$trackerById = @{}
foreach ($record in $trackerRecords) {
    if ($record.Id -notmatch '^[A-Za-z][A-Za-z0-9._:-]{0,127}$') {
        Add-AuditError "Tracker ID '$($record.Id)' at '$($record.Path):$($record.Line)' is invalid."
        continue
    }
    if ($trackerById.ContainsKey($record.Id)) {
        Add-AuditError "Tracker ID '$($record.Id)' appears more than once."
    }
    else { $trackerById[$record.Id] = $record }
    foreach ($evidenceId in @($record.OpenedBy, $record.ClosedBy)) {
        if (-not $evidenceId) { continue }
        foreach ($captureMatch in [regex]::Matches($evidenceId, 'CAP-\d{8}-\d{6}-[a-f0-9]{4}')) {
            if (-not $captureById.ContainsKey($captureMatch.Value)) {
                Add-AuditError "Tracker '$($record.Id)' references missing evidence '$($captureMatch.Value)'."
            }
        }
    }
}
foreach ($record in $trackerRecords) {
    if ($record.ParentId -and -not $trackerById.ContainsKey($record.ParentId)) {
        Add-AuditWarning "Tracker '$($record.Id)' references unknown parent '$($record.ParentId)'."
    }
    if ($record.MapAnchor -and -not $trackerById.ContainsKey($record.MapAnchor)) {
        Add-AuditWarning "Tracker '$($record.Id)' references unknown map anchor '$($record.MapAnchor)'."
    }
}

$relationRecords = @()
$relationById = @{}
if (Test-Path -LiteralPath $relationsPath -PathType Leaf) {
    $lineNumber = 0
    foreach ($line in @(Get-Content -LiteralPath $relationsPath)) {
        $lineNumber++
        if (-not $line.Trim()) { continue }
        try { $relation = $line | ConvertFrom-Json -ErrorAction Stop }
        catch {
            Add-AuditError "Invalid relation JSON at line $lineNumber."
            continue
        }
        if (-not $relation.relation_id -or -not $relation.source_id -or
            -not $relation.relation -or -not $relation.target_id) {
            Add-AuditError "Relation at line $lineNumber lacks required identity fields."
            continue
        }
        $relationId = [string]$relation.relation_id
        if ($relationById.ContainsKey($relationId)) {
            Add-AuditError "Relation ID '$relationId' appears more than once."
            continue
        }
        $relationById[$relationId] = $relation
        $relationRecords += $relation
        foreach ($evidenceId in @($relation.evidence_capture_ids)) {
            if (-not $captureById.ContainsKey([string]$evidenceId)) {
                Add-AuditError "Relation '$relationId' references missing evidence '$evidenceId'."
            }
        }
    }
}
$supersededRelationIds = @{}
foreach ($relation in $relationRecords) {
    if ($relation.supersedes_relation_id) {
        $supersededId = [string]$relation.supersedes_relation_id
        if (-not $relationById.ContainsKey($supersededId)) {
            Add-AuditError "Relation '$($relation.relation_id)' supersedes missing relation '$supersededId'."
        }
        else { $supersededRelationIds[$supersededId] = $true }
    }
}
$activeRelationKeys = @{}
foreach ($relation in $relationRecords) {
    $relationId = [string]$relation.relation_id
    if ([string]$relation.status -ne 'active' -or $supersededRelationIds.ContainsKey($relationId)) { continue }
    $sourceId = [string]$relation.source_id
    $targetId = [string]$relation.target_id
    foreach ($endpointId in @($sourceId, $targetId)) {
        if ($endpointId -match '^CAP-' -and -not $captureById.ContainsKey($endpointId)) {
            Add-AuditError "Relation '$relationId' references missing capture endpoint '$endpointId'."
        }
        elseif ($endpointId -match '^GRP-' -and -not $groupIds.ContainsKey($endpointId)) {
            Add-AuditError "Relation '$relationId' references missing capture-group endpoint '$endpointId'."
        }
        elseif ($endpointId -match '^MAP-' -and -not $trackerById.ContainsKey($endpointId)) {
            Add-AuditError "Relation '$relationId' references missing map-anchor tracker '$endpointId'."
        }
    }
    $relationKey = "$sourceId|$($relation.relation)|$targetId"
    if ($activeRelationKeys.ContainsKey($relationKey)) {
        Add-AuditError "Active relation '$relationKey' appears more than once."
    }
    else { $activeRelationKeys[$relationKey] = $relationId }
    if ([string]$relation.relation -eq 'harvest-of' -and $trackerById.ContainsKey($targetId)) {
        if ([string]$trackerById[$targetId].State -match '(?i)planted|harvest-pending') {
            Add-AuditError "Planting '$targetId' has an active harvest-of relation but still has state '$($trackerById[$targetId].State)'."
        }
    }
    if ([string]$relation.relation -eq 'identified-as' -and $trackerById.ContainsKey($sourceId)) {
        if ([string]$trackerById[$sourceId].State -match '(?i)unidentified|pending-appraisal') {
            Add-AuditError "Item '$sourceId' has an active identified-as relation but still has state '$($trackerById[$sourceId].State)'."
        }
    }
}

$humanFiles = @(Get-HumanMarkdownFiles -ContextRoot $contextRoot)
$brokenLinks = @(Get-BrokenLinks -Files $humanFiles -CollectionRoot $collectionRoot)
foreach ($broken in $brokenLinks) {
    Add-AuditError "Broken local link '$($broken.Target)' in '$($broken.Source)'."
}

$stateText = ''
$lifecycle = 'unknown'
if (Test-Path -LiteralPath $statePath -PathType Leaf) {
    $stateText = Get-Content -LiteralPath $statePath -Raw
    $stateLifecycle = Get-FrontmatterValue -Markdown $stateText -Name 'Lifecycle'
    if ($stateLifecycle) { $lifecycle = $stateLifecycle }
    $stateBytes = (Get-Item -LiteralPath $statePath).Length
    if ($stateBytes -gt $MaxStateBytes) {
        Add-AuditWarning "State metadata is $stateBytes bytes; compact it below $MaxStateBytes bytes and move history to the ledger or journal."
    }
    $checkpointDeltaCount = @([regex]::Matches($stateText, '(?m)^Latest checkpoint delta')).Count
    if ($checkpointDeltaCount -gt 1) {
        Add-AuditWarning "State metadata contains $checkpointDeltaCount historical checkpoint-delta fields."
    }
}
else { Add-AuditError "Context state is missing: $statePath" }

$homePath = Join-Path $contextRoot 'README.md'
if (Test-Path -LiteralPath $homePath -PathType Leaf) {
    $homeLines = Get-LineCount -LiteralPath $homePath
    if ($homeLines -gt $MaxHomeLines) {
        Add-AuditWarning "README.md has $homeLines lines; keep the landing page below $MaxHomeLines lines."
    }
}
foreach ($journalFile in @(Get-ChildItem -LiteralPath (Join-Path $contextRoot 'journal') -File -Filter '*.md' -ErrorAction SilentlyContinue)) {
    $journalLines = Get-LineCount -LiteralPath $journalFile.FullName
    if ($journalLines -gt $MaxJournalLines) {
        Add-AuditWarning "Journal '$($journalFile.Name)' has $journalLines lines; split future chapters before $MaxJournalLines lines."
    }
}

if ($pendingCaptureIds.Count -gt 0 -and
    $stateText -match '(?i)(no|zero)\s+pending\s+(captures?|notes?)|capture queue[^\r\n]*0\s+pending') {
    Add-AuditError "State metadata claims no pending captures, but the latest ledger has $($pendingCaptureIds.Count)."
}
if ($mediaWithoutInterpretation.Count -gt 0 -and
    $stateText -match '(?i)no\s+pending\s+visual|all[^\r\n]*ready media[^\r\n]*interpreted') {
    Add-AuditError "State metadata claims complete visual review, but $($mediaWithoutInterpretation.Count) media captures lack interpretations."
}

$requiresCompletion = $CompletionGate -or $lifecycle -eq 'completed'
if ($requiresCompletion -and $pendingCaptureIds.Count -gt 0) {
    Add-AuditError "Completion gate has $($pendingCaptureIds.Count) pending captures. Reconcile or scope-close every capture."
}
if ($requiresCompletion -and $pendingAttachmentIds.Count -gt 0) {
    Add-AuditError "Completion gate has $($pendingAttachmentIds.Count) pending-save-first attachments."
}

if ($lifecycle -eq 'completed') {
    foreach ($file in @(
        (Join-Path $contextRoot 'README.md'),
        (Join-Path $contextRoot 'open-questions.md'),
        (Join-Path $contextRoot 'guide\index.md'),
        (Join-Path $contextRoot 'journal\index.md')
    )) {
        if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { continue }
        $lineNumber = 0
        foreach ($line in @(Get-Content -LiteralPath $file)) {
            $lineNumber++
            if ($line -match '(?i)still open|remaining .*password|next objective|continue with') {
                Add-AuditWarning "Completed context has active-sounding wording at '$($file):$lineNumber'."
            }
        }
    }
}

$lockPath = Join-Path $evidenceRoot 'reconciliation.lock.json'
$lockState = 'unlocked'
$lockOwner = $null
$lockIsStale = $false
if (Test-Path -LiteralPath $lockPath -PathType Leaf) {
    try {
        $lock = Get-Content -LiteralPath $lockPath -Raw | ConvertFrom-Json -ErrorAction Stop
        $lockState = 'locked'
        $lockOwner = [string]$lock.owner_id
        $lockIsStale = ([DateTimeOffset]::Parse([string]$lock.expires_at) -le [DateTimeOffset]::Now)
        if ($lockIsStale) { Add-AuditWarning "Reconciliation lock owned by '$lockOwner' is stale." }
    }
    catch { Add-AuditError "Reconciliation lock is unreadable: $($_.Exception.Message)" }
}

$completionReady = $errors.Count -eq 0 -and
    $pendingCaptureIds.Count -eq 0 -and
    $pendingAttachmentIds.Count -eq 0
$result = [pscustomobject]@{
    State = 'audited'
    VaultPath = $vaultRoot
    Collection = $CollectionSlug
    Context = $ContextSlug
    Lifecycle = $lifecycle
    CaptureCount = $captureRecords.Count
    CaptureGroupCount = $groupIds.Count
    ProcessingEventCount = $eventCount
    LatestStateCounts = $latestStateCounts
    PendingCaptureCount = $pendingCaptureIds.Count
    PendingCaptureIds = @($pendingCaptureIds)
    PendingAttachmentCount = $pendingAttachmentIds.Count
    PendingAttachmentIds = @($pendingAttachmentIds)
    MediaCaptureCount = $mediaRecords.Count
    MediaWithoutInterpretationCount = $mediaWithoutInterpretation.Count
    MediaWithoutInterpretationIds = @($mediaWithoutInterpretation)
    MediaWithoutDescriptorCount = $mediaWithoutDescriptor.Count
    MediaWithoutDescriptorIds = @($mediaWithoutDescriptor)
    TrackerRecordCount = $trackerRecords.Count
    TrackerRecords = @($trackerRecords)
    RelationCount = $relationRecords.Count
    BrokenLinkCount = $brokenLinks.Count
    BrokenLinks = @($brokenLinks)
    LockState = $lockState
    LockOwner = $lockOwner
    LockIsStale = $lockIsStale
    IsConsistent = ($errors.Count -eq 0)
    CompletionReady = $completionReady
    Errors = @($errors)
    Warnings = @($warnings)
}

if ($RequireCompletionReady -and -not $completionReady) {
    $message = if ($errors.Count -gt 0) { $errors -join ' ' } else { 'Context is not completion-ready.' }
    throw $message
}
$result
