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

function New-TestInstallerRepository {
    param([string]$Root)
    [void](New-TestCatalog $Root)
    [void](New-Item -ItemType Directory -Path (Join-Path $Root '.git') -Force)
    Copy-Item -LiteralPath (Join-Path $repositoryRoot 'scripts') -Destination (Join-Path $Root 'scripts') -Recurse
    Copy-Item -LiteralPath (Join-Path $repositoryRoot 'Refresh-CodexSkills.ps1') -Destination (Join-Path $Root 'Refresh-CodexSkills.ps1')
    $Root
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
    $installerRepository = New-TestInstallerRepository (Join-Path $script:TemporaryRoot 'public-installer')
    $installer = Join-Path $installerRepository 'scripts\Install-Skills.ps1'
    $destination = Join-Path $script:TemporaryRoot 'public-destination'
    Push-Location $script:TemporaryRoot
    try {
        $listed = @(& $installer -List)
        Assert-Equal 0 $LASTEXITCODE 'List failed.'
        Assert-True ($listed -contains 'minimal-skill') 'Catalog skill was not listed.'
        & $installer -Name minimal-skill -DestinationPath $destination *> $null
        Assert-Equal 0 $LASTEXITCODE 'Explicit destination install failed.'
        Assert-True (Test-Path -LiteralPath (Join-Path $destination 'minimal-skill\SKILL.md')) 'Selected skill was not installed.'
    }
    finally { Pop-Location }
}

Invoke-Test 'repository destination requires an external Git checkout' {
    $installerRepository = New-TestInstallerRepository (Join-Path $script:TemporaryRoot 'repository-installer')
    $external = Join-Path $script:TemporaryRoot 'external-repository'
    [void](New-Item -ItemType Directory -Path (Join-Path $external '.git') -Force)
    & (Join-Path $installerRepository 'scripts\Install-Skills.ps1') -Name minimal-skill -RepositoryPath $external *> $null
    Assert-Equal 0 $LASTEXITCODE 'External repository install failed.'
    Assert-True (Test-Path -LiteralPath (Join-Path $external '.agents\skills\minimal-skill\SKILL.md')) 'Repository destination was not resolved.'
}

Invoke-Test 'public installer rejects conflicts, overlap, and catalog repository scope' {
    $installerRepository = New-TestInstallerRepository (Join-Path $script:TemporaryRoot 'rejected-installer')
    $installer = Join-Path $installerRepository 'scripts\Install-Skills.ps1'
    & $installer -Name minimal-skill -All -DestinationPath (Join-Path $script:TemporaryRoot 'conflict') *> $null
    Assert-True ($LASTEXITCODE -ne 0) 'Conflicting selection unexpectedly succeeded.'
    & $installer -Name minimal-skill -DestinationPath (Join-Path $installerRepository 'skills\nested') *> $null
    Assert-True ($LASTEXITCODE -ne 0) 'Catalog-overlapping destination unexpectedly succeeded.'
    & $installer -Name minimal-skill -RepositoryPath $installerRepository *> $null
    Assert-True ($LASTEXITCODE -ne 0) 'Catalog repository scope unexpectedly succeeded.'
}

Invoke-Test 'refresh convenience entry point uses isolated HOME and refreshes all for Codex and Gemini' {
    $installerRepository = New-TestInstallerRepository (Join-Path $script:TemporaryRoot 'convenience-installer')
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
            & $powerShellExecutable -NoLogo -NoProfile -File (Join-Path $installerRepository 'Refresh-CodexSkills.ps1') *> $null
            Assert-Equal 0 $LASTEXITCODE 'Convenience refresh failed.'
        }
        finally { Pop-Location }
        foreach ($destination in @('.agents\skills', '.gemini\config\skills')) {
            foreach ($name in @('minimal-skill', 'extended-skill')) {
                Assert-True (Test-Path -LiteralPath (Join-Path (Join-Path $isolatedHome $destination) "$name\SKILL.md")) "Convenience refresh did not populate $name in $destination under isolated HOME."
            }
        }
    }
    finally { $env:HOME = $oldHome; $env:USERPROFILE = $oldUserProfile }
}

Invoke-Test 'empty catalog lists nothing and bulk install preserves existing destination' {
    $installerRepository = New-TestInstallerRepository (Join-Path $script:TemporaryRoot 'empty-installer')
    $catalogRoot = Join-Path $installerRepository 'skills'
    foreach ($name in @('minimal-skill', 'extended-skill')) {
        $source = Get-NormalizedPath (Join-Path $catalogRoot $name)
        Assert-True (Test-StrictChildPath $script:TemporaryRoot $source) 'Fixture cleanup escaped the temporary root.'
        Remove-Item -LiteralPath $source -Recurse -Force
    }
    [System.IO.File]::WriteAllText((Join-Path $catalogRoot '.gitkeep'), '')
    $installer = Join-Path $installerRepository 'scripts\Install-Skills.ps1'
    $listed = @(& $installer -List)
    Assert-Equal 0 $LASTEXITCODE 'Empty catalog list failed.'
    Assert-Equal 0 $listed.Count 'Empty catalog listed a skill.'
    $destination = Join-Path $script:TemporaryRoot 'empty-catalog-destination'
    [void](New-Item -ItemType Directory -Path $destination -Force)
    $sentinel = Join-Path $destination 'keep.txt'
    Set-Content -LiteralPath $sentinel -Value 'preserve'
    & $installer -All -DestinationPath $destination *> $null
    Assert-True ($LASTEXITCODE -ne 0) 'Empty bulk install unexpectedly succeeded.'
    Assert-Equal 'preserve' (Get-Content -LiteralPath $sentinel) 'Existing destination content changed.'
    Assert-Equal 1 @(Get-ChildItem -LiteralPath $destination -Force).Count 'Empty bulk install wrote destination artifacts.'
}
