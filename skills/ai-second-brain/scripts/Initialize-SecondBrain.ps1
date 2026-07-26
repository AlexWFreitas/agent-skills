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

    [string]$ActivityTemplate = 'game-playthrough'
)

$ErrorActionPreference = 'Stop'
$script:Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

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
$contextRoot = Join-Path $vaultRoot "collections\$CollectionSlug\contexts\main"
$timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK'

$directories = @(
    $vaultRoot,
    (Join-Path $vaultRoot 'collections'),
    (Join-Path $vaultRoot "collections\$CollectionSlug"),
    (Join-Path $vaultRoot "collections\$CollectionSlug\contexts"),
    $contextRoot,
    (Join-Path $contextRoot 'inbox'),
    (Join-Path $contextRoot 'inbox\captures'),
    (Join-Path $contextRoot 'inbox\interpretations'),
    (Join-Path $contextRoot 'topics'),
    (Join-Path $contextRoot 'attachments'),
    (Join-Path $contextRoot 'external')
)

$templateFiles = @(
    @{ Source = (Join-Path $assetRoot 'AGENTS.md'); Target = (Join-Path $vaultRoot 'AGENTS.md') },
    @{ Source = (Join-Path $assetRoot 'second-brain.md'); Target = (Join-Path $vaultRoot 'second-brain.md') },
    @{ Source = (Join-Path $assetRoot 'context.md'); Target = (Join-Path $contextRoot 'context.md') },
    @{ Source = (Join-Path $assetRoot 'timeline.md'); Target = (Join-Path $contextRoot 'timeline.md') },
    @{ Source = (Join-Path $assetRoot 'open-items.md'); Target = (Join-Path $contextRoot 'open-items.md') }
)
$ledgerPath = Join-Path $contextRoot 'inbox\processing-events.jsonl'
$allTargetFiles = @($templateFiles | ForEach-Object { $_.Target }) + @($ledgerPath)
$existingTargets = @($allTargetFiles | Where-Object { Test-Path -LiteralPath $_ })

if ($existingTargets.Count -gt 0) {
    $allExist = @($allTargetFiles | Where-Object { -not (Test-Path -LiteralPath $_) }).Count -eq 0
    $compatible = $false
    if ($allExist) {
        $rootIndex = Get-Content -LiteralPath (Join-Path $vaultRoot 'second-brain.md') -Raw
        $contextIndex = Get-Content -LiteralPath (Join-Path $contextRoot 'context.md') -Raw
        $compatible =
            $rootIndex.Contains("Schema version: ``1``") -and
            $rootIndex.Contains("Active collection: ``$CollectionSlug``") -and
            $contextIndex.Contains("Collection: ``$CollectionSlug``") -and
            $contextIndex.Contains('Context: `main`')
    }

    if ($compatible) {
        [pscustomobject]@{
            State = 'existing-compatible'
            VaultPath = $vaultRoot
            Collection = $CollectionSlug
            Context = 'main'
        }
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
        '{{COLLECTION_SLUG}}' = $CollectionSlug
        '{{ACTIVITY_TEMPLATE}}' = $ActivityTemplate
        '{{TIMESTAMP}}' = $timestamp
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

    [pscustomobject]@{
        State = 'initialized'
        VaultPath = $vaultRoot
        Collection = $CollectionSlug
        Context = 'main'
    }
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
