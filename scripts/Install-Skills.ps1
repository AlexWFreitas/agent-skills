#requires -Version 5.1

[CmdletBinding()]
param(
    [switch]$List,
    [string[]]$Name,
    [switch]$All,
    [string]$RepositoryPath,
    [string]$DestinationPath
)

$ErrorActionPreference = 'Stop'
$modulePath = Join-Path $PSScriptRoot 'SkillCatalog.psm1'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$catalogRoot = Join-Path $repositoryRoot 'skills'
Import-Module $modulePath -Force

try {
    if ($Name -and $All) { throw '-Name and -All are mutually exclusive.' }
    if ($RepositoryPath -and $DestinationPath) { throw '-RepositoryPath and -DestinationPath are mutually exclusive.' }
    if ($List -and ($Name -or $All -or $RepositoryPath -or $DestinationPath)) { throw '-List cannot be combined with selection or destination options.' }

    $catalogNames = @(Get-CatalogSkillNames $catalogRoot)
    if ($List) {
        foreach ($skillName in $catalogNames) { Write-Output $skillName }
        exit 0
    }
    if (-not $Name -and -not $All) { throw 'Select at least one skill with -Name, or select the full catalog with -All.' }
    $selectedNames = if ($All) { $catalogNames } else { @($Name) }

    if ($RepositoryPath) {
        $resolvedRepository = Get-NormalizedPath $RepositoryPath
        if (-not (Test-Path -LiteralPath $resolvedRepository -PathType Container)) { throw "Repository path does not exist: $resolvedRepository" }
        if (-not (Test-Path -LiteralPath (Join-Path $resolvedRepository '.git'))) { throw "Repository path has no .git marker: $resolvedRepository" }
        if (Test-SamePath $resolvedRepository $repositoryRoot) { throw 'Repository scope cannot target this canonical skill catalog checkout.' }
        $destinationRoot = Join-Path $resolvedRepository '.agents\skills'
    }
    elseif ($DestinationPath) {
        $destinationRoot = Get-NormalizedPath $DestinationPath
    }
    else {
        if ([string]::IsNullOrWhiteSpace($HOME)) { throw 'HOME is unavailable; provide -DestinationPath explicitly.' }
        $destinationRoot = Join-Path $HOME '.agents\skills'
    }

    $result = Invoke-SkillRefreshTransaction -CatalogRoot $catalogRoot -DestinationRoot $destinationRoot -Names $selectedNames
    foreach ($warningText in $result.Warnings) { Write-Warning $warningText }
    if (-not $result.Success) {
        [Console]::Error.WriteLine("ERROR: $($result.Failure)")
        if ($result.RollbackStatus -ne 'NOT REQUIRED') { [Console]::Error.WriteLine("ROLLBACK $($result.RollbackStatus)") }
        if ($result.BackupPath) { [Console]::Error.WriteLine("Recovery backup retained at: $($result.BackupPath)") }
        exit 1
    }
    Write-Output ("Refreshed {0} skill(s) into {1}: {2}" -f $result.Changed.Count, (Get-NormalizedPath $destinationRoot), ($result.Changed -join ', '))
    exit 0
}
catch {
    [Console]::Error.WriteLine("ERROR: $($_.Exception.Message)")
    exit 1
}
