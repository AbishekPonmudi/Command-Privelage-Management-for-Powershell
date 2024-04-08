@echo off
setlocal

:: Define the path to the PowerShell profile script
set "profile_script=%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"

:: Check if the configuration file exists
if not exist "%profile_script%" (
    echo Error: Installation not found. The script might not be installed properly.
    exit /b 1
)

:: Check if the credentials file exists
if not exist credentials.xml (
    echo Error: Credentials file not found. The script might not be installed properly.
    exit /b 1
)

:: Read the username and password from the credentials.xml file
for /f "tokens=2 delims=<>" %%G in (credentials.xml) do (
    if not defined stored_username (
        set "stored_username=%%G"
    ) else (
        set "stored_password=%%G"
    )
)

:: Prompt user for username
set /p "input_username=Enter your username: "

:: Prompt user for password using PowerShell to mask input
for /f "delims=" %%P in ('powershell -command "$p = read-host 'Enter your password:' -AsSecureString; [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($p))"') do set "input_password=%%P"

:: Validate entered credentials
if "%input_username%" NEQ "%stored_username%" (
    echo Error: Incorrect username.
    exit /b 1
)

:: Validate entered password
powershell -command "& { $input_password=ConvertTo-SecureString '%input_password%' -AsPlainText -Force; $stored_password=ConvertTo-SecureString '%stored_password%' -AsPlainText -Force; if ((ConvertFrom-SecureString $input_password) -ne (ConvertFrom-SecureString $stored_password)) { exit 1 } }"
if %errorlevel% NEQ 0 (
    echo Error: Incorrect password.
    exit /b 1
)

:: Delete the PowerShell profile script
del "%profile_script%"
echo PowerShell profile script has been deleted.

:: Notify user about the completion
echo Uninstallation complete.

:: Pause to allow the user to see the message
pause
