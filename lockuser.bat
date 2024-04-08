@echo off
setlocal

:: Define the path to the PowerShell script
set "ps_script_path=C:\Users\Abishek\Desktop\powershell_project\popup.ps1"

:: Check if the script path is valid
if not exist "%ps_script_path%" (
  echo Error: PowerShell script not found at "%ps_script_path%"
  pause
  goto :eof
)

:: Run the PowerShell script with administrative privileges
powershell.exe -Command "Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -File ""%ps_script_path%""' -Verb RunAs"

:: Wait for the user to press any key before closing the window
pause
