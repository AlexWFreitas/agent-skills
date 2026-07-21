$repositoryRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $repositoryRoot 'scripts\SkillCatalog.psm1') -Force
$fixtureRoot = Join-Path $PSScriptRoot 'fixtures'

Invoke-Test 'repository layout is valid' {
    $result = Test-RepositoryLayout $repositoryRoot
    Assert-True $result.IsValid ($result.Errors -join '; ')
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
