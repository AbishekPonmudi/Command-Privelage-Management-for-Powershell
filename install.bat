@echo off
setlocal

:: Check if the configuration file already exists
if exist "%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" (
    echo Installation already completed. The script is already installed.
    goto :end_installation
)

:: Set the name of the PowerShell script file
set "ps_script_name=popup.ps1"

:: Display options for applying credentials
echo Choose an option for applying credentials:
echo 1. Apply for ADMINISTRATION (Run as Administrator)
echo 2. Apply for WHOLE POWERSHELL

:: Prompt user for choice
set /p apply_admin=Enter your choice (1 or 2): 

:: Ensure the user input is valid (1 or 2)
if "%apply_admin%" NEQ "1" if "%apply_admin%" NEQ "2" (
    echo Invalid choice. Please choose either 1 or 2.
    exit /b 1
)

:username_input
:: Prompt user for username
set /p username=Enter username (must be at least 3 characters long): 

:: Validate username length
if "%username:~2%"=="" (
    echo Username must be at least 3 characters long.
    goto username_input
)

:password_input
:: Prompt user for password using PowerShell to mask input
for /f "delims=" %%P in ('powershell -command "$p = read-host 'Enter password (Password not must not contain username):' -AsSecureString; [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($p))"') do set "password=%%P"

:: Validate password length
if "%password:~4%"=="" (
    echo Password must be at least 5 characters long.
    goto password_input
)

:: Validate password does not contain username
echo %password% | findstr /i /c:"%username%" > nul
if not errorlevel 1 (
    echo Password cannot contain the username.
    goto password_input
)

:: Prompt user to confirm password using PowerShell to mask input
for /f "delims=" %%P in ('powershell -command "$p = read-host 'Confirm password:' -AsSecureString; [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($p))"') do set "confirm_password=%%P"

:: Check if passwords match
if "%password%" NEQ "%confirm_password%" (
    echo Passwords do not match. Please try again.
    goto password_input
)

:: Save username and password to XML file
(
  echo ^<credentials^>
  echo    ^<username^>%username%^</username^>
  echo    ^<password^>%password%^</password^>
  echo ^</credentials^>
) > credentials.xml

:: Ensure the directory structure exists for PowerShell profile script
mkdir "%USERPROFILE%\Documents\WindowsPowerShell" 2>nul

:: Set the PowerShell profile script path
set "profile_script=%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"

:: Set the full path to the PowerShell script
set "ps_script_path=%~dp0%ps_script_name%"

:: Add the command to run the PowerShell script with the chosen execution mode to the profile script
echo . '%ps_script_path%' %apply_admin% >> "%profile_script%"

:: Notify the user about the setup
echo PowerShell startup script has been configured.
echo Your PowerShell profile script is located at: %profile_script%

:end_installation
:: Pause to allow the user to see the message
pause
