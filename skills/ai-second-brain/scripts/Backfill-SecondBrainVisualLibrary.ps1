#requires -Version 5.1

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory = $true)]
    [string]$VaultPath,

    [string]$CollectionSlug,

    [string]$ContextSlug,

    [switch]$UpdateExisting,

    [switch]$IncludePendingMedia
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

function ConvertTo-SafeSlug {
    param([Parameter(Mandatory = $true)][string]$Value)

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
    if ($slug.Length -gt 96) { $slug = $slug.Substring(0, 96).Trim('-') }
    if (-not $slug) { return 'media-capture' }
    return $slug
}

function Get-FrontmatterValue {
    param([string]$Markdown, [string]$Name)

    $match = [regex]::Match($Markdown, '(?m)^' + [regex]::Escape($Name) + ':\s*(.*?)\s*$')
    if (-not $match.Success) { return $null }
    return $match.Groups[1].Value.Trim()
}

function Get-MarkdownSection {
    param([string]$Markdown, [string]$Heading)

    $pattern = '(?ms)^#\s+' + [regex]::Escape($Heading) + '\s*\r?\n\s*(.*?)(?=^#\s+|\z)'
    $match = [regex]::Match($Markdown, $pattern)
    if (-not $match.Success) { return '' }
    return $match.Groups[1].Value.Trim()
}

function ConvertTo-CompactText {
    param([string]$Value, [int]$MaximumLength = 180)

    if (-not $Value) { return '' }
    $compact = $Value.Replace('`n', ' ').Replace('`r', ' ')
    $compact = [regex]::Replace($compact, '\s+', ' ').Trim()
    if ($compact.Length -le $MaximumLength) { return $compact }
    $candidate = $compact.Substring(0, $MaximumLength)
    $breakAt = $candidate.LastIndexOf(' ')
    if ($breakAt -gt 60) { $candidate = $candidate.Substring(0, $breakAt) }
    return $candidate.TrimEnd(' ', '.', ',', ';', ':') + '...'
}

function Test-GenericHeading {
    param([string]$Heading, [string]$CaptureId)

    if (-not $Heading) { return $true }
    $normalized = $Heading.Trim()
    if ($normalized -eq "Interpretation: $CaptureId") { return $true }
    return $normalized -match '^(Interpretation|Screenshot interpretation|Video interpretation|Text interpretation|Direct observations?|Direct user statement|Media and coverage)$'
}

function Get-FirstUsefulBullet {
    param([string]$Interpretation)

    if (-not $Interpretation) { return '' }
    foreach ($match in [regex]::Matches($Interpretation, '(?m)^-\s+(.+)$')) {
        $bullet = ConvertTo-CompactText -Value $match.Groups[1].Value -MaximumLength 180
        if (-not $bullet) { continue }
        if ($bullet -match '^(Source:|The immutable (video|screenshot) attachment is stored at|Capture:|Processing status:)') {
            continue
        }
        return $bullet
    }
    return ''
}

function Get-MeaningfulCaption {
    param([string]$Caption)

    $value = ConvertTo-CompactText -Value $Caption -MaximumLength 180
    if (-not $value -or $value -eq 'None') { return '' }
    if ($value -match '^(?:Screenshot|Image)\s*#?\d+(?:\s+of\s+\d+)?\s*:\s*(.+)$') {
        return $matches[1].Trim()
    }
    if ($value -match '^(?:Screenshot|Image)\s*#?\d+(?:\s+of\s+\d+)?$') { return '' }
    return $value
}

function Get-DisplayTitle {
    param(
        [string]$CaptureId,
        [string]$InputType,
        [string]$Content,
        [string]$Caption,
        [string]$Interpretation
    )

    $heading = ''
    if ($Interpretation) {
        $heading = [regex]::Match($Interpretation, '(?m)^#\s+(.+)$').Groups[1].Value.Trim()
    }
    if (-not (Test-GenericHeading -Heading $heading -CaptureId $CaptureId)) {
        $heading = $heading -replace '^Interpretation:\s*', ''
        return ConvertTo-CompactText -Value $heading -MaximumLength 120
    }

    $meaningfulCaption = Get-MeaningfulCaption -Caption $Caption
    if ($meaningfulCaption) { return ConvertTo-CompactText -Value $meaningfulCaption -MaximumLength 120 }

    $firstBullet = Get-FirstUsefulBullet -Interpretation $Interpretation
    if ($firstBullet) { return ConvertTo-CompactText -Value $firstBullet -MaximumLength 120 }

    $compactContent = ConvertTo-CompactText -Value $Content -MaximumLength 120
    if ($compactContent) { return $compactContent }

    return "$InputType capture $CaptureId"
}

function Get-SearchKeywords {
    param([string]$Title, [string]$ContextText)

    $stopWords = @(
        'about', 'after', 'also', 'another', 'because', 'before', 'being',
        'capture', 'from', 'have', 'image', 'into', 'shows', 'showing',
        'screenshot', 'that', 'their', 'there', 'these', 'this', 'through',
        'user', 'video', 'where', 'which', 'with'
    )
    $keywords = @()
    $source = "$Title $ContextText"
    foreach ($match in [regex]::Matches($source.ToLowerInvariant(), '[a-z0-9][a-z0-9''-]{2,}')) {
        $word = $match.Value.Trim("'", '-')
        if (-not $word -or $word -in $stopWords -or $word -in $keywords) { continue }
        $keywords += $word
        if ($keywords.Count -ge 16) { break }
    }
    return @($keywords)
}

function ConvertTo-MarkdownCell {
    param([string]$Value)

    if (-not $Value) { return '' }
    return $Value.Replace('|', '\|').Replace("`r", ' ').Replace("`n", ' ')
}

function Write-Utf8Atomically {
    param(
        [Parameter(Mandatory = $true)][string]$LiteralPath,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Content
    )

    $parent = Split-Path -Parent $LiteralPath
    $temporaryPath = Join-Path $parent ('.' + [IO.Path]::GetFileName($LiteralPath) + '.' + [guid]::NewGuid().ToString('N') + '.tmp')
    [IO.File]::WriteAllText($temporaryPath, $Content, $script:Utf8NoBom)
    try {
        if (Test-Path -LiteralPath $LiteralPath -PathType Leaf) {
            $backupPath = $LiteralPath + '.replace-' + [guid]::NewGuid().ToString('N') + '.bak'
            try {
                [IO.File]::Replace($temporaryPath, $LiteralPath, $backupPath)
                if (Test-Path -LiteralPath $backupPath) { Remove-Item -LiteralPath $backupPath -Force }
            }
            catch {
                if (Test-Path -LiteralPath $backupPath -PathType Leaf) {
                    if (-not (Test-Path -LiteralPath $LiteralPath -PathType Leaf)) {
                        Move-Item -LiteralPath $backupPath -Destination $LiteralPath
                    }
                }
                throw
            }
        }
        else {
            [IO.File]::Move($temporaryPath, $LiteralPath)
        }
    }
    finally {
        if (Test-Path -LiteralPath $temporaryPath) { Remove-Item -LiteralPath $temporaryPath -Force }
    }
}

function Read-Utf8File {
    param([Parameter(Mandatory = $true)][string]$LiteralPath)

    return [IO.File]::ReadAllText($LiteralPath, [Text.Encoding]::UTF8)
}

if (-not [IO.Path]::IsPathRooted($VaultPath)) {
    throw 'VaultPath must be an absolute path.'
}
$vaultRoot = [IO.Path]::GetFullPath($VaultPath)
$rootIndexPath = Join-Path $vaultRoot 'second-brain.md'
if (-not (Test-Path -LiteralPath $rootIndexPath -PathType Leaf)) {
    throw "Not an initialized second-brain vault: $vaultRoot"
}

$rootIndex = Read-Utf8File -LiteralPath $rootIndexPath
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
if (-not (Test-Path -LiteralPath $contextRoot -PathType Container)) {
    throw "Selected context does not exist: $contextRoot"
}
$evidenceRoot = Resolve-EvidenceRoot -ContextRoot $contextRoot
$captureRoot = Join-Path $evidenceRoot 'captures'
$interpretationRoot = Join-Path $evidenceRoot 'interpretations'
$attachmentRoot = Join-Path $contextRoot 'attachments'
$libraryRoot = Join-Path $contextRoot 'library'
$descriptorRoot = Join-Path $libraryRoot 'captures'
$referenceRoot = Join-Path $libraryRoot 'references'
$indexPath = Join-Path $libraryRoot 'index.md'

foreach ($requiredPath in @($captureRoot, $interpretationRoot, $attachmentRoot)) {
    if (-not (Test-Path -LiteralPath $requiredPath -PathType Container)) {
        throw "Active context is incomplete; missing '$requiredPath'."
    }
}

$records = @()
$captureFiles = @(Get-ChildItem -LiteralPath $captureRoot -Recurse -File -Filter '*.md' | Sort-Object FullName)
foreach ($captureFile in $captureFiles) {
    $captureText = Read-Utf8File -LiteralPath $captureFile.FullName
    $inputType = (Get-FrontmatterValue -Markdown $captureText -Name 'input_type')
    if (-not $inputType) { continue }
    $inputType = $inputType.ToLowerInvariant()
    if ($inputType -notin @('screenshot', 'video')) { continue }

    $captureId = Get-FrontmatterValue -Markdown $captureText -Name 'capture_id'
    if (-not $captureId -or $captureId -notmatch '^CAP-\d{8}-\d{6}-[A-Za-z0-9][A-Za-z0-9-]*$') {
        throw "Media capture has an invalid or missing capture ID: $($captureFile.FullName)"
    }
    $capturedAt = Get-FrontmatterValue -Markdown $captureText -Name 'captured_at'
    $attachmentState = Get-FrontmatterValue -Markdown $captureText -Name 'attachment_state'
    $attachmentValue = Get-FrontmatterValue -Markdown $captureText -Name 'attachment'
    if (-not $IncludePendingMedia -and $attachmentState -ne 'ready') { continue }

    $content = Get-MarkdownSection -Markdown $captureText -Heading 'Original input'
    $caption = Get-MarkdownSection -Markdown $captureText -Heading 'User caption'
    $interpretationPath = Join-Path $interpretationRoot "$captureId.md"
    $interpretation = ''
    if (Test-Path -LiteralPath $interpretationPath -PathType Leaf) {
        $interpretation = Read-Utf8File -LiteralPath $interpretationPath
    }

    $title = Get-DisplayTitle `
        -CaptureId $captureId `
        -InputType $inputType `
        -Content $content `
        -Caption $caption `
        -Interpretation $interpretation
    $slug = ConvertTo-SafeSlug -Value $title
    $descriptorFileName = "$slug--$captureId.md"
    $visualReview = if ($interpretation) { 'interpreted' } else { 'pending' }

    $attachmentFile = $null
    if ($attachmentValue -and $attachmentValue -ne 'none') {
        $attachmentLeaf = Split-Path -Leaf ($attachmentValue.Replace('/', '\'))
        $candidateAttachment = Join-Path $attachmentRoot $attachmentLeaf
        if (Test-Path -LiteralPath $candidateAttachment -PathType Leaf) {
            $attachmentFile = Get-Item -LiteralPath $candidateAttachment
        }
    }
    if (-not $attachmentFile) {
        $attachmentMatches = @(Get-ChildItem -LiteralPath $attachmentRoot -Filter "$captureId*" -File)
        if ($attachmentMatches.Count -eq 1) { $attachmentFile = $attachmentMatches[0] }
    }

    $firstBullet = Get-FirstUsefulBullet -Interpretation $interpretation
    $meaningfulCaption = Get-MeaningfulCaption -Caption $caption
    $searchContext = if ($meaningfulCaption) {
        $meaningfulCaption
    }
    elseif ($firstBullet) {
        $firstBullet
    }
    else {
        ConvertTo-CompactText -Value $content -MaximumLength 240
    }
    $keywords = Get-SearchKeywords -Title $title -ContextText $searchContext

    $captureDate = $captureId.Substring(4, 8)
    $dateDirectory = '{0}-{1}-{2}' -f
        $captureDate.Substring(0, 4),
        $captureDate.Substring(4, 2),
        $captureDate.Substring(6, 2)
    $captureLink = "../../$([IO.Path]::GetFileName($evidenceRoot))/captures/$dateDirectory/$captureId.md"
    $interpretationLink = "../../$([IO.Path]::GetFileName($evidenceRoot))/interpretations/$captureId.md"

    $mediaLink = $null
    $previewLink = $null
    if ($attachmentFile) {
        $mediaLink = '../../attachments/' + $attachmentFile.Name
        if ($inputType -eq 'screenshot') {
            $previewLink = $mediaLink
        }
        else {
            $framesRoot = Join-Path $evidenceRoot "media-processing\$captureId\frames"
            if (Test-Path -LiteralPath $framesRoot -PathType Container) {
                $frames = @(Get-ChildItem -LiteralPath $framesRoot -File -Filter 'frame-*.jpg' | Sort-Object Name)
                if ($frames.Count -gt 0) {
                    $middleIndex = [int][Math]::Floor(($frames.Count - 1) / 2)
                    $previewLink = "../../$([IO.Path]::GetFileName($evidenceRoot))/media-processing/$captureId/frames/$($frames[$middleIndex].Name)"
                }
            }
        }
    }

    $records += [pscustomobject][ordered]@{
        CaptureId = $captureId
        CapturedAt = $capturedAt
        InputType = $inputType
        AttachmentState = $attachmentState
        AttachmentFile = $attachmentFile
        Title = $title
        Slug = $slug
        DescriptorFileName = $descriptorFileName
        CaptureLink = $captureLink.Replace('\', '/')
        InterpretationLink = $interpretationLink.Replace('\', '/')
        HasInterpretation = [bool]$interpretation
        VisualReview = $visualReview
        SearchContext = $searchContext
        Keywords = @($keywords)
        MediaLink = if ($mediaLink) { $mediaLink.Replace('\', '/') } else { $null }
        PreviewLink = if ($previewLink) { $previewLink.Replace('\', '/') } else { $null }
    }
}

$plannedCreates = 0
$plannedUpdates = 0
$plannedSkips = 0
$indexRows = @()
$descriptorPlans = @()
foreach ($record in $records) {
    $existingDescriptor = $null
    if (Test-Path -LiteralPath $descriptorRoot -PathType Container) {
        $matches = @(Get-ChildItem -LiteralPath $descriptorRoot -File -Filter "*--$($record.CaptureId).md")
        if ($matches.Count -gt 1) {
            throw "Multiple semantic descriptors exist for '$($record.CaptureId)'."
        }
        if ($matches.Count -eq 1) { $existingDescriptor = $matches[0] }
    }

    $targetDescriptorPath = if ($existingDescriptor) {
        $existingDescriptor.FullName
    }
    else {
        Join-Path $descriptorRoot $record.DescriptorFileName
    }
    if ($existingDescriptor -and -not $UpdateExisting) { $plannedSkips++ }
    elseif ($existingDescriptor) { $plannedUpdates++ }
    else { $plannedCreates++ }

    $referenceIdsValue = '[]'
    $visualReferencesText = 'None assigned during mechanical backfill.'
    if ($existingDescriptor) {
        $existingDescriptorText = Read-Utf8File -LiteralPath $existingDescriptor.FullName
        $referenceMatch = [regex]::Match($existingDescriptorText, '(?m)^reference_ids:\s*(.*?)\s*$')
        if ($referenceMatch.Success -and $referenceMatch.Groups[1].Value.Trim()) {
            $referenceIdsValue = $referenceMatch.Groups[1].Value.Trim()
        }
        $visualReferenceMatch = [regex]::Match(
            $existingDescriptorText,
            '(?ms)^## Visual references\s*\r?\n\s*(.*?)(?=^##\s+|\z)'
        )
        if ($visualReferenceMatch.Success -and $visualReferenceMatch.Groups[1].Value.Trim()) {
            $visualReferencesText = $visualReferenceMatch.Groups[1].Value.Trim()
        }
    }

    $keywordsJson = ConvertTo-Json -InputObject @($record.Keywords) -Compress
    $titleJson = ConvertTo-Json -InputObject $record.Title -Compress
    $lines = @(
        '---',
        "capture_id: $($record.CaptureId)",
        "display_title: $titleJson",
        "input_type: $($record.InputType)",
        "captured_at: $($record.CapturedAt)",
        "attachment_state: $($record.AttachmentState)",
        "visual_review: $($record.VisualReview)",
        "search_keywords: $keywordsJson",
        "reference_ids: $referenceIdsValue",
        '---',
        '',
        "# $($record.Title)",
        '',
        ('Capture type: `{0}`  ' -f $record.InputType),
        ('Visual review: `{0}`' -f $record.VisualReview),
        '',
        '## Preview',
        ''
    )
    if ($record.PreviewLink) {
        $lines += "![$($record.Title)]($($record.PreviewLink))"
    }
    elseif ($record.AttachmentState -eq 'pending-save-first') {
        $lines += 'No durable local media is available yet (`pending-save-first`).'
    }
    else {
        $lines += 'No representative preview derivative is available.'
    }
    $lines += @('', '## Search context', '')
    if ($record.SearchContext) { $lines += $record.SearchContext }
    else { $lines += 'No user-grounded search context was available.' }
    $lines += @('', '## Visual references', '', $visualReferencesText, '', '## Sources', '')
    $sourceLinks = @("[Immutable capture]($($record.CaptureLink))")
    if ($record.HasInterpretation) { $sourceLinks += "[Interpretation]($($record.InterpretationLink))" }
    if ($record.MediaLink) { $sourceLinks += "[Original media]($($record.MediaLink))" }
    $lines += ($sourceLinks -join ' · ')
    $lines += ''

    $descriptorPlans += [pscustomobject]@{
        Path = $targetDescriptorPath
        Content = ($lines -join [Environment]::NewLine)
        ShouldWrite = (-not $existingDescriptor -or $UpdateExisting)
    }
    $descriptorLeaf = Split-Path -Leaf $targetDescriptorPath
    $indexTitle = ConvertTo-MarkdownCell -Value $record.Title
    $indexRows += "| $($record.CapturedAt) | $($record.InputType) | [$indexTitle](captures/$descriptorLeaf) | $($record.VisualReview) |"
}

$interpretedCount = @($records | Where-Object { $_.HasInterpretation }).Count
$pendingReviewCount = $records.Count - $interpretedCount
$pendingAttachmentCount = @($records | Where-Object { $_.AttachmentState -ne 'ready' }).Count
$generatedAt = Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK'
$indexContent = @(
    '# Media library',
    '',
    ('Generated: `{0}`  ' -f $generatedAt),
    ('Cataloged media: `{0}`  ' -f $records.Count),
    ('Previously interpreted: `{0}`  ' -f $interpretedCount),
    ('Pending visual review: `{0}`  ' -f $pendingReviewCount),
    ('Pending local attachment: `{0}`' -f $pendingAttachmentCount),
    '',
    '## Recurring visual references',
    '',
    'Canonical object, terrain, symbol, item, and glyph references live under `references/`.',
    '',
    '## Capture catalog',
    '',
    '| Captured | Type | Semantic title | Visual review |',
    '| --- | --- | --- | --- |'
) + @($indexRows) + @('')
$indexText = $indexContent -join [Environment]::NewLine

$state = if ($WhatIfPreference) { 'preview' } else { 'backfilled' }
if (-not $WhatIfPreference -and $PSCmdlet.ShouldProcess($libraryRoot, "Backfill $($records.Count) semantic media descriptors")) {
    foreach ($directory in @($libraryRoot, $descriptorRoot, $referenceRoot)) {
        if (-not (Test-Path -LiteralPath $directory -PathType Container)) {
            [void](New-Item -ItemType Directory -Path $directory)
        }
    }
    foreach ($plan in $descriptorPlans) {
        if ($plan.ShouldWrite) {
            Write-Utf8Atomically -LiteralPath $plan.Path -Content $plan.Content
        }
    }
    Write-Utf8Atomically -LiteralPath $indexPath -Content $indexText
}

[pscustomobject]@{
    State = $state
    VaultPath = $vaultRoot
    Collection = $CollectionSlug
    Context = $ContextSlug
    MediaCaptures = $records.Count
    PreviouslyInterpreted = $interpretedCount
    PendingVisualReview = $pendingReviewCount
    PendingAttachment = $pendingAttachmentCount
    DescriptorCreates = $plannedCreates
    DescriptorUpdates = $plannedUpdates
    DescriptorSkips = $plannedSkips
    IndexPath = $indexPath
    SampleTitles = @($records | Select-Object -First 5 -ExpandProperty Title)
}
