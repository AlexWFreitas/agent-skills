#requires -Version 5.1

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$script:Failures = New-Object System.Collections.ArrayList
$script:TestsRun = 0
$script:TemporaryRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('agent-skills-tests-' + [guid]::NewGuid().ToString('N'))

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

function Assert-False {
    param([bool]$Condition, [string]$Message)
    if ($Condition) { throw $Message }
}

function Assert-Equal {
    param($Expected, $Actual, [string]$Message)
    if ($Expected -ne $Actual) { throw "$Message Expected '$Expected', got '$Actual'." }
}

function Invoke-Test {
    param([string]$Name, [scriptblock]$Body)
    $script:TestsRun++
    try { & $Body; Write-Output "PASS: $Name" }
    catch { [void]$script:Failures.Add("$Name - $($_.Exception.Message)"); Write-Output "FAIL: $Name - $($_.Exception.Message)" }
}

try {
    [void](New-Item -ItemType Directory -Path $script:TemporaryRoot -Force)
    . (Join-Path $PSScriptRoot 'Test-RepositoryValidator.ps1')
    . (Join-Path $PSScriptRoot 'Test-Installer.ps1')
}
finally {
    if (Test-Path -LiteralPath $script:TemporaryRoot) { Remove-Item -LiteralPath $script:TemporaryRoot -Recurse -Force }
}

if ($script:Failures.Count -gt 0) {
    [Console]::Error.WriteLine("$($script:Failures.Count) of $script:TestsRun tests failed:")
    foreach ($failure in $script:Failures) { [Console]::Error.WriteLine(" - $failure") }
    exit 1
}
Write-Output "All $script:TestsRun tests passed."
exit 0
