#requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$VaultPath,

    [Parameter(Mandatory = $true)]
    [string]$CollectionName,

    [string]$CollectionSlug,

    [string]$VaultTitle = 'AI Second Brain',

    [string]$ContextTitle = 'Main',

    [string]$ContextScope,

    [string]$ActivityTemplate = 'game-playthrough',

    [ValidateSet('auto', 'markdown', 'obsidian')]
    [string]$LinkStyle = 'auto',

    [ValidateSet('auto', 'off', 'lexical', 'hybrid')]
    [string]$SearchMode = 'auto',

    [string]$EmbeddingModel = 'embeddinggemma',

    [string]$EmbeddingEndpoint = 'http://127.0.0.1:11434',

    [ValidateRange(1, 30)]
    [int]$EmbeddingProbeTimeoutSeconds = 2,

    [string]$PythonPath
)

$ErrorActionPreference = 'Stop'
$script:Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$script:SearchModeExplicit = $PSBoundParameters.ContainsKey('SearchMode')
$script:EmbeddingModelExplicit = $PSBoundParameters.ContainsKey('EmbeddingModel')
$script:EmbeddingEndpointExplicit = $PSBoundParameters.ContainsKey('EmbeddingEndpoint')

function ConvertTo-Slug {
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
    if (-not $slug) { throw "CollectionName '$Value' cannot produce a non-empty ASCII slug." }
    return $slug
}

function Write-NewUtf8File {
    param(
        [Parameter(Mandatory = $true)][string]$LiteralPath,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Content
    )

    $stream = New-Object IO.FileStream(
        $LiteralPath,
        [IO.FileMode]::CreateNew,
        [IO.FileAccess]::Write,
        [IO.FileShare]::Read
    )
    try {
        $writer = New-Object IO.StreamWriter($stream, $script:Utf8NoBom)
        try { $writer.Write($Content) }
        finally { $writer.Dispose() }
    }
    finally {
        if ($stream) { $stream.Dispose() }
    }
}

function Complete-Initialization {
    param(
        [Parameter(Mandatory = $true)][string]$InitializationState,
        [string]$SelectedLinkStyle
    )

    $ensureScript = Join-Path $PSScriptRoot 'Ensure-SecondBrainSearchIndex.ps1'
    $searchResult = $null
    if ($SearchMode -eq 'off') {
        $searchResult = [pscustomobject]@{
            State = 'skipped'
            Action = 'unchanged'
            SearchMode = 'files'
            IndexPath = Join-Path $vaultRoot ".index\ai-second-brain\$CollectionSlug--main.sqlite"
            EmbeddingModel = $null
            Reason = 'Automatic local indexing is disabled for this context.'
        }
    }
    else {
        try {
            if (-not (Test-Path -LiteralPath $ensureScript -PathType Leaf)) {
                throw "Automatic search-index helper is missing: $ensureScript"
            }
            $ensureParameters = @{
                VaultPath = $vaultRoot
                CollectionSlug = $CollectionSlug
                ContextSlug = 'main'
                SearchMode = $SearchMode
                EmbeddingModel = $EmbeddingModel
                EmbeddingEndpoint = $EmbeddingEndpoint
                EmbeddingProbeTimeoutSeconds = $EmbeddingProbeTimeoutSeconds
                ForceRebuild = $true
            }
            if ($PythonPath) { $ensureParameters.PythonPath = $PythonPath }
            $searchResult = & $ensureScript @ensureParameters
        }
        catch {
            $searchResult = [pscustomobject]@{
                State = 'unavailable'
                Action = 'unchanged'
                SearchMode = 'files'
                IndexPath = Join-Path $vaultRoot ".index\ai-second-brain\$CollectionSlug--main.sqlite"
                EmbeddingModel = $null
                Reason = "Automatic search setup failed without invalidating the vault: $($_.Exception.Message)"
            }
        }
    }

    if ($searchResult.State -eq 'unavailable') {
        Write-Warning $searchResult.Reason
    }

    return [pscustomobject]@{
        State = $InitializationState
        VaultPath = $vaultRoot
        Collection = $CollectionSlug
        Context = 'main'
        LinkStyle = $SelectedLinkStyle
        ConfiguredSearchMode = $SearchMode
        SearchIndexState = $searchResult.State
        SearchIndexAction = $searchResult.Action
        EffectiveSearchMode = $searchResult.SearchMode
        SearchIndexPath = $searchResult.IndexPath
        EmbeddingModel = $searchResult.EmbeddingModel
        SearchSetupReason = $searchResult.Reason
    }
}

if (-not [IO.Path]::IsPathRooted($VaultPath)) {
    throw 'VaultPath must be an absolute path.'
}

$vaultRoot = [IO.Path]::GetFullPath($VaultPath)
if (-not $CollectionSlug) { $CollectionSlug = ConvertTo-Slug $CollectionName }
if ($CollectionSlug -notmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') {
    throw 'CollectionSlug must be lowercase ASCII kebab-case.'
}
if ($ActivityTemplate -notmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') {
    throw 'ActivityTemplate must be lowercase ASCII kebab-case.'
}
if (-not $ContextScope) {
    $ContextScope = "User-provided knowledge for $CollectionName."
}

$skillRoot = Split-Path -Parent $PSScriptRoot
$assetRoot = Join-Path $skillRoot 'assets\vault'
$collectionRoot = Join-Path $vaultRoot "collections\$CollectionSlug"
$contextRoot = Join-Path $collectionRoot 'contexts\main'
$timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK'
$resolvedLinkStyle = $LinkStyle.ToLowerInvariant()
if ($resolvedLinkStyle -eq 'auto') {
    $resolvedLinkStyle = if (Test-Path -LiteralPath (Join-Path $collectionRoot '.obsidian') -PathType Container) {
        'obsidian'
    }
    else {
        'markdown'
    }
}

$directories = @(
    $vaultRoot,
    (Join-Path $vaultRoot 'collections'),
    (Join-Path $vaultRoot "collections\$CollectionSlug"),
    (Join-Path $vaultRoot "collections\$CollectionSlug\contexts"),
    $contextRoot,
    (Join-Path $contextRoot 'guide'),
    (Join-Path $contextRoot 'journal'),
    (Join-Path $contextRoot '_evidence'),
    (Join-Path $contextRoot '_evidence\captures'),
    (Join-Path $contextRoot '_evidence\interpretations'),
    (Join-Path $contextRoot '_evidence\media-processing'),
    (Join-Path $contextRoot 'attachments'),
    (Join-Path $contextRoot 'external')
)

$templateFiles = @(
    @{ Source = (Join-Path $assetRoot 'AGENTS.md'); Target = (Join-Path $vaultRoot 'AGENTS.md') },
    @{ Source = (Join-Path $assetRoot 'second-brain.md'); Target = (Join-Path $vaultRoot 'second-brain.md') },
    @{ Source = (Join-Path $assetRoot 'home.md'); Target = (Join-Path $contextRoot 'README.md') },
    @{ Source = (Join-Path $assetRoot 'guide\index.md'); Target = (Join-Path $contextRoot 'guide\index.md') },
    @{ Source = (Join-Path $assetRoot 'journal\index.md'); Target = (Join-Path $contextRoot 'journal\index.md') },
    @{ Source = (Join-Path $assetRoot 'open-questions.md'); Target = (Join-Path $contextRoot 'open-questions.md') },
    @{ Source = (Join-Path $assetRoot 'state.md'); Target = (Join-Path $contextRoot '_evidence\state.md') }
)
$ledgerPath = Join-Path $contextRoot '_evidence\processing-events.jsonl'
$allTargetFiles = @($templateFiles | ForEach-Object { $_.Target }) + @($ledgerPath)
$existingTargets = @($allTargetFiles | Where-Object { Test-Path -LiteralPath $_ })

if ($existingTargets.Count -gt 0) {
    $allExist = @($allTargetFiles | Where-Object { -not (Test-Path -LiteralPath $_) }).Count -eq 0
    $compatible = $false
    if ($allExist) {
        $rootIndex = Get-Content -LiteralPath (Join-Path $vaultRoot 'second-brain.md') -Raw
        $contextIndex = Get-Content -LiteralPath (Join-Path $contextRoot '_evidence\state.md') -Raw
        $compatible =
            $rootIndex.Contains("Schema version: ``2``") -and
            $rootIndex.Contains("Active collection: ``$CollectionSlug``") -and
            $contextIndex.Contains("Collection: ``$CollectionSlug``") -and
            $contextIndex.Contains('Context: `main`')
    }

    if ($compatible) {
        if (-not $script:SearchModeExplicit) {
            $match = [regex]::Match($contextIndex, '(?m)^Search mode:\s+`(auto|off|lexical|hybrid)`\s*$')
            if ($match.Success) { $SearchMode = $match.Groups[1].Value }
        }
        if (-not $script:EmbeddingModelExplicit) {
            $match = [regex]::Match($contextIndex, '(?m)^Embedding model:\s+`([^`]+)`\s*$')
            if ($match.Success) { $EmbeddingModel = $match.Groups[1].Value }
        }
        if (-not $script:EmbeddingEndpointExplicit) {
            $match = [regex]::Match($contextIndex, '(?m)^Embedding endpoint:\s+`([^`]+)`\s*$')
            if ($match.Success) { $EmbeddingEndpoint = $match.Groups[1].Value }
        }
        Complete-Initialization `
            -InitializationState 'existing-compatible' `
            -SelectedLinkStyle $null
        return
    }

    throw "Initialization target is partial or incompatible. Refusing to overwrite: $($existingTargets -join ', ')"
}

$createdDirectories = New-Object Collections.Generic.List[string]
$createdFiles = New-Object Collections.Generic.List[string]

try {
    foreach ($directory in $directories) {
        if (-not (Test-Path -LiteralPath $directory)) {
            [void](New-Item -ItemType Directory -Path $directory)
            [void]$createdDirectories.Add([IO.Path]::GetFullPath($directory))
        }
    }

    $tokens = @{
        '{{VAULT_TITLE}}' = $VaultTitle
        '{{COLLECTION_NAME}}' = $CollectionName
        '{{COLLECTION_SLUG}}' = $CollectionSlug
        '{{ACTIVITY_TEMPLATE}}' = $ActivityTemplate
        '{{TIMESTAMP}}' = $timestamp
        '{{CREATED}}' = $timestamp
        '{{LAST_UPDATED}}' = $timestamp
        '{{LATEST_CHECKPOINT}}' = 'none'
        '{{LIFECYCLE}}' = 'active'
        '{{EPISTEMIC_MODE}}' = 'firsthand-only'
        '{{LINK_STYLE}}' = $resolvedLinkStyle
        '{{SEARCH_MODE}}' = $SearchMode
        '{{EMBEDDING_MODEL}}' = $EmbeddingModel
        '{{EMBEDDING_ENDPOINT}}' = $EmbeddingEndpoint
        '{{GUIDE_LINK}}' = if ($resolvedLinkStyle -eq 'obsidian') {
            '[[contexts/main/guide/index|Guide]]'
        }
        else {
            '[Guide](guide/index.md)'
        }
        '{{JOURNAL_LINK}}' = if ($resolvedLinkStyle -eq 'obsidian') {
            '[[contexts/main/journal/index|Journal]]'
        }
        else {
            '[Journal](journal/index.md)'
        }
        '{{OPEN_QUESTIONS_LINK}}' = if ($resolvedLinkStyle -eq 'obsidian') {
            '[[contexts/main/open-questions|Open questions]]'
        }
        else {
            '[Open questions](open-questions.md)'
        }
        '{{CONTEXT_TITLE}}' = $ContextTitle
        '{{CONTEXT_SCOPE}}' = $ContextScope
    }

    foreach ($file in $templateFiles) {
        $content = Get-Content -LiteralPath $file.Source -Raw
        foreach ($token in $tokens.Keys) { $content = $content.Replace($token, $tokens[$token]) }
        Write-NewUtf8File -LiteralPath $file.Target -Content $content
        [void]$createdFiles.Add([IO.Path]::GetFullPath($file.Target))
    }

    Write-NewUtf8File -LiteralPath $ledgerPath -Content ''
    [void]$createdFiles.Add([IO.Path]::GetFullPath($ledgerPath))

}
catch {
    foreach ($file in @($createdFiles) | Sort-Object Length -Descending) {
        if (Test-Path -LiteralPath $file) { Remove-Item -LiteralPath $file -Force }
    }
    foreach ($directory in @($createdDirectories) | Sort-Object Length -Descending) {
        if ((Test-Path -LiteralPath $directory) -and
            @((Get-ChildItem -LiteralPath $directory -Force)).Count -eq 0) {
            Remove-Item -LiteralPath $directory -Force
        }
    }
    throw
}

Complete-Initialization `
    -InitializationState 'initialized' `
    -SelectedLinkStyle $resolvedLinkStyle
