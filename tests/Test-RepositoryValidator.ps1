$repositoryRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $repositoryRoot 'scripts\SkillCatalog.psm1') -Force
$fixtureRoot = Join-Path $PSScriptRoot 'fixtures'

function New-EmptyRepositoryFixture {
    param([string]$Root)
    [void](New-Item -ItemType Directory -Path (Join-Path $Root 'skills') -Force)
    [void](New-Item -ItemType Directory -Path (Join-Path $Root 'scripts') -Force)
    foreach ($relativePath in @('README.md', 'AGENTS.md', '.gitignore', 'Refresh-CodexSkills.ps1', 'scripts\Install-Skills.ps1', 'scripts\Test-Repository.ps1')) {
        Copy-Item -LiteralPath (Join-Path $repositoryRoot $relativePath) -Destination (Join-Path $Root $relativePath)
    }
    [System.IO.File]::WriteAllText((Join-Path $Root 'skills\.gitkeep'), '')
    $Root
}

Invoke-Test 'repository layout is valid' {
    $result = Test-RepositoryLayout $repositoryRoot
    Assert-True $result.IsValid ($result.Errors -join '; ')
}

Invoke-Test 'empty catalog with Git placeholder is valid and lists no skills' {
    $emptyRepository = New-EmptyRepositoryFixture (Join-Path $script:TemporaryRoot 'empty-repository')
    $result = Test-RepositoryLayout $emptyRepository
    Assert-True $result.IsValid ($result.Errors -join '; ')
    Assert-Equal 0 @(Get-CatalogSkillNames (Join-Path $emptyRepository 'skills')).Count 'Placeholder was treated as a skill.'
}

Invoke-Test 'catalog still rejects files other than the Git placeholder' {
    $invalidRepository = New-EmptyRepositoryFixture (Join-Path $script:TemporaryRoot 'invalid-catalog-file')
    Set-Content -LiteralPath (Join-Path $invalidRepository 'skills\unexpected.txt') -Value 'invalid'
    $result = Test-RepositoryLayout $invalidRepository
    Assert-False $result.IsValid 'Unexpected catalog file passed validation.'
    Assert-True (($result.Errors -join '; ') -match 'unexpected\.txt') 'Diagnostic did not identify the unexpected file.'
}

Invoke-Test 'minimal portable skill is valid without Codex metadata' {
    $result = Test-SkillDirectory (Join-Path $fixtureRoot 'valid\minimal-skill')
    Assert-True $result.IsValid ($result.Errors -join '; ')
    Assert-True ($result.Warnings.Count -gt 0) 'Expected an advisory warning for absent optional Codex metadata.'
}

Invoke-Test 'extended skill and local reference are valid' {
    $result = Test-SkillDirectory (Join-Path $fixtureRoot 'valid\extended-skill')
    Assert-True $result.IsValid ($result.Errors -join '; ')
}

Invoke-Test 'advanced YAML is rejected' {
    $result = Test-SkillDirectory (Join-Path $fixtureRoot 'invalid\advanced-yaml')
    Assert-False $result.IsValid 'Advanced YAML unexpectedly passed.'
    Assert-True (($result.Errors -join ' ') -match 'advanced YAML') 'The diagnostic did not identify advanced YAML.'
}

Invoke-Test 'broken local reference is rejected' {
    $result = Test-SkillDirectory (Join-Path $fixtureRoot 'invalid\broken-reference')
    Assert-False $result.IsValid 'Broken reference unexpectedly passed.'
    Assert-True (($result.Errors -join ' ') -match 'Broken') 'The diagnostic did not identify the broken reference.'
}

Invoke-Test 'public validator is independent of current directory' {
    Push-Location $script:TemporaryRoot
    try {
        & (Join-Path $repositoryRoot 'scripts\Test-Repository.ps1') *> $null
        Assert-Equal 0 $LASTEXITCODE 'Validator failed from an unrelated directory.'
    }
    finally { Pop-Location }
}
