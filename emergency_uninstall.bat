@echo off
setlocal

:: Define the path to the PowerShell profile script
set "profile_script=%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"

:: Delete the PowerShell profile script if it exists
if exist "%profile_script%" (
    del "%profile_script%"
    echo PowerShell profile script has been deleted.
) else (
    echo PowerShell profile script does not exist.
)

:: Notify user about the completion
echo Uninstallation complete.

:: Pause to allow the user to see the message
pause
