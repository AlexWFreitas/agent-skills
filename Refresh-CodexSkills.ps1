#requires -Version 5.1

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$installer = Join-Path $PSScriptRoot 'scripts\Install-Skills.ps1'

try {
    if ([string]::IsNullOrWhiteSpace($HOME)) { throw 'HOME is unavailable.' }

    $powerShellExecutable = (Get-Process -Id $PID).Path
    $destinations = @(
        (Join-Path $HOME '.agents\skills'),
        (Join-Path $HOME '.gemini\skills')
    )

    foreach ($destination in $destinations) {
        & $powerShellExecutable -NoLogo -NoProfile -File $installer -All -DestinationPath $destination
        if ($LASTEXITCODE -ne 0) {
            throw "Skill refresh failed for destination: $destination"
        }
    }

    exit 0
}
catch {
    [Console]::Error.WriteLine("ERROR: $($_.Exception.Message)")
    exit 1
}
