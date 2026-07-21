$repositoryRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repositoryRoot 'scripts\SkillCatalog.psm1'
Import-Module $modulePath -Force

function New-TestCatalog {
    param([string]$Root)
    $catalog = Join-Path $Root 'skills'
    [void](New-Item -ItemType Directory -Path $catalog -Force)
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'fixtures\valid\minimal-skill') -Destination (Join-Path $catalog 'minimal-skill') -Recurse
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'fixtures\valid\extended-skill') -Destination (Join-Path $catalog 'extended-skill') -Recurse
    $catalog
}

Invoke-Test 'named refresh replaces stale files and preserves parent and sibling' {
    $caseRoot = Join-Path $script:TemporaryRoot 'named-refresh'
    $catalog = New-TestCatalog $caseRoot
    $destination = Join-Path $caseRoot 'destination'
    $target = Join-Path $destination 'minimal-skill'
    $sibling = Join-Path $destination 'unmanaged-sibling'
    [void](New-Item -ItemType Directory -Path $target -Force)
    [void](New-Item -ItemType Directory -Path $sibling -Force)
    Set-Content -LiteralPath (Join-Path $destination 'parent.txt') -Value 'keep'
    Set-Content -LiteralPath (Join-Path $target 'stale.txt') -Value 'remove'
    Set-Content -LiteralPath (Join-Path $sibling 'keep.txt') -Value 'keep'
    $result = Invoke-SkillRefreshTransaction $catalog $destination @('minimal-skill')
    Assert-True $result.Success $result.Failure
    Assert-False (Test-Path -LiteralPath (Join-Path $target 'stale.txt')) 'Stale file remained after refresh.'
    Assert-True (Compare-SkillTrees (Join-Path $catalog 'minimal-skill') $target) 'Installed tree differs from the source.'
    Assert-True (Test-Path -LiteralPath (Join-Path $destination 'parent.txt')) 'Parent file was changed.'
    Assert-True (Test-Path -LiteralPath (Join-Path $sibling 'keep.txt')) 'Sibling was changed.'
}

Invoke-Test 'bulk failure rolls back every selected skill' {
    $caseRoot = Join-Path $script:TemporaryRoot 'rollback'
    $catalog = New-TestCatalog $caseRoot
    $destination = Join-Path $caseRoot 'destination'
    foreach ($name in @('minimal-skill', 'extended-skill')) {
        $target = Join-Path $destination $name
        [void](New-Item -ItemType Directory -Path $target -Force)
        Set-Content -LiteralPath (Join-Path $target 'old.txt') -Value $name
    }
    $injector = { param($Phase, $Name) if ($Phase -eq 'AfterSwap' -and $Name -eq 'extended-skill') { throw 'injected swap failure' } }
    $result = Invoke-SkillRefreshTransaction $catalog $destination @('minimal-skill', 'extended-skill') $injector
    Assert-False $result.Success 'Injected failure unexpectedly succeeded.'
    Assert-Equal 'SUCCEEDED' $result.RollbackStatus 'Rollback outcome was not prominent.'
    foreach ($name in @('minimal-skill', 'extended-skill')) {
        Assert-True (Test-Path -LiteralPath (Join-Path $destination "$name\old.txt")) "$name was not restored."
        Assert-False (Test-Path -LiteralPath (Join-Path $destination "$name\SKILL.md")) "$name retained staged content."
    }
}

Invoke-Test 'overlap and missing selection fail without writes' {
    $caseRoot = Join-Path $script:TemporaryRoot 'preflight'
    $catalog = New-TestCatalog $caseRoot
    $overlap = Invoke-SkillRefreshTransaction $catalog (Join-Path $catalog 'nested') @('minimal-skill')
    Assert-False $overlap.Success 'Catalog overlap unexpectedly succeeded.'
    $empty = Invoke-SkillRefreshTransaction $catalog (Join-Path $caseRoot 'safe') @()
    Assert-False $empty.Success 'Empty selection unexpectedly succeeded.'
}

Invoke-Test 'source reparse points are rejected before staging' {
    $caseRoot = Join-Path $script:TemporaryRoot 'reparse-source'
    $catalog = New-TestCatalog $caseRoot
    $outside = Join-Path $caseRoot 'outside'
    [void](New-Item -ItemType Directory -Path $outside -Force)
    Set-Content -LiteralPath (Join-Path $outside 'outside.txt') -Value 'outside'
    $junction = Join-Path $catalog 'minimal-skill\references\linked'
    [void](New-Item -ItemType Junction -Path $junction -Target $outside -Force)
    $result = Invoke-SkillRefreshTransaction $catalog (Join-Path $caseRoot 'destination') @('minimal-skill')
    Assert-False $result.Success 'Source junction unexpectedly passed.'
    Assert-True ($result.Failure -match 'Reparse point') 'Failure did not identify the source reparse point.'
}

Invoke-Test 'general installer supports list and explicit destination from unrelated cwd' {
    $destination = Join-Path $script:TemporaryRoot 'public-destination'
    Push-Location $script:TemporaryRoot
    try {
        $listed = @(& (Join-Path $repositoryRoot 'scripts\Install-Skills.ps1') -List)
        Assert-Equal 0 $LASTEXITCODE 'List failed.'
        Assert-True ($listed -contains 'task-discovery') 'Catalog skill was not listed.'
        & (Join-Path $repositoryRoot 'scripts\Install-Skills.ps1') -Name task-discovery -DestinationPath $destination *> $null
        Assert-Equal 0 $LASTEXITCODE 'Explicit destination install failed.'
        Assert-True (Test-Path -LiteralPath (Join-Path $destination 'task-discovery\SKILL.md')) 'Selected skill was not installed.'
    }
    finally { Pop-Location }
}

Invoke-Test 'repository destination requires an external Git checkout' {
    $external = Join-Path $script:TemporaryRoot 'external-repository'
    [void](New-Item -ItemType Directory -Path (Join-Path $external '.git') -Force)
    & (Join-Path $repositoryRoot 'scripts\Install-Skills.ps1') -Name task-discovery -RepositoryPath $external *> $null
    Assert-Equal 0 $LASTEXITCODE 'External repository install failed.'
    Assert-True (Test-Path -LiteralPath (Join-Path $external '.agents\skills\task-discovery\SKILL.md')) 'Repository destination was not resolved.'
}

Invoke-Test 'public installer rejects conflicts, overlap, and catalog repository scope' {
    $installer = Join-Path $repositoryRoot 'scripts\Install-Skills.ps1'
    & $installer -Name task-discovery -All -DestinationPath (Join-Path $script:TemporaryRoot 'conflict') *> $null
    Assert-True ($LASTEXITCODE -ne 0) 'Conflicting selection unexpectedly succeeded.'
    & $installer -Name task-discovery -DestinationPath (Join-Path $repositoryRoot 'skills\nested') *> $null
    Assert-True ($LASTEXITCODE -ne 0) 'Catalog-overlapping destination unexpectedly succeeded.'
    & $installer -Name task-discovery -RepositoryPath $repositoryRoot *> $null
    Assert-True ($LASTEXITCODE -ne 0) 'Catalog repository scope unexpectedly succeeded.'
}

Invoke-Test 'refresh convenience entry point uses isolated HOME and refreshes all' {
    $isolatedHome = Join-Path $script:TemporaryRoot 'isolated-home'
    [void](New-Item -ItemType Directory -Path $isolatedHome -Force)
    $oldHome = $env:HOME
    $oldUserProfile = $env:USERPROFILE
    try {
        $env:HOME = $isolatedHome
        $env:USERPROFILE = $isolatedHome
        $powerShellExecutable = (Get-Process -Id $PID).Path
        Push-Location $script:TemporaryRoot
        try {
            & $powerShellExecutable -NoLogo -NoProfile -File (Join-Path $repositoryRoot 'Refresh-CodexSkills.ps1') *> $null
            Assert-Equal 0 $LASTEXITCODE 'Convenience refresh failed.'
        }
        finally { Pop-Location }
        Assert-True (Test-Path -LiteralPath (Join-Path $isolatedHome '.agents\skills\task-discovery\SKILL.md')) 'Convenience refresh did not use isolated HOME.'
    }
    finally { $env:HOME = $oldHome; $env:USERPROFILE = $oldUserProfile }
}
