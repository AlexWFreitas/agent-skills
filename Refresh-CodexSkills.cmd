@echo off
"C:\Program Files\PowerShell\7\pwsh.exe" -NoProfile -ExecutionPolicy Bypass -File "%~dp0Refresh-CodexSkills.ps1"
set "exitCode=%ERRORLEVEL%"
echo.
echo Exit code: %exitCode%
pause
exit /b %exitCode%