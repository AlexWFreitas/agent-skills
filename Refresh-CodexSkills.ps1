#requires -Version 5.1

[CmdletBinding()]
param()

$installer = Join-Path $PSScriptRoot 'scripts\Install-Skills.ps1'
& $installer -All
exit $LASTEXITCODE
