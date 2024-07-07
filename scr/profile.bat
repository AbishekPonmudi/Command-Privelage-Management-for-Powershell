@echo off

REM Check if -noprofile flag is used
echo %* | find /I "-noprofile" > nul
if %errorlevel% equ 0 (
    echo The 'powershell -noprofile' command is blocked. Please use 'powershell' without the '-noprofile' flag.
    exit /b
)

REM Execute PowerShell with arguments
powershell.exe %*
