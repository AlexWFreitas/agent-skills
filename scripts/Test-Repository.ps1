#requires -Version 5.1

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot 'SkillCatalog.psm1') -Force

try {
    $result = Test-RepositoryLayout $repositoryRoot
    foreach ($warningText in $result.Warnings) { Write-Output "WARNING: $warningText" }
    foreach ($errorText in $result.Errors) { [Console]::Error.WriteLine("ERROR: $errorText") }
    if (-not $result.IsValid) { exit 1 }
    Write-Output "Repository validation succeeded with $($result.Warnings.Count) warning(s)."
    exit 0
}
catch {
    [Console]::Error.WriteLine("ERROR: Repository validation could not complete: $($_.Exception.Message)")
    exit 1
}
