# Check if the configuration file already exists
if (Test-Path "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1") {
    Write-Host "Installation already completed. The script is already installed."
    exit
}

# Display options for applying credentials
Write-Host "Choose an option for applying credentials:"
Write-Host "1. Apply for ADMINISTRATION (Run as Administrator)"
Write-Host "2. Apply for WHOLE POWERSHELL"

# Prompt user for choice
$apply_admin = Read-Host "Enter your choice (1 or 2):"

# Ensure the user input is valid (1 or 2)
if ($apply_admin -ne "1" -and $apply_admin -ne "2") {
    Write-Host "Invalid choice. Please choose either 1 or 2."
    exit 1
}

# Bypass execution policy for current user
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force

# Prompt user for username
do {
    $username = Read-Host "New username (must be at least 3 characters long):"
    if ($username.Length -lt 3) {
        Write-Host "Username must be at least 3 characters long."
    }
} while ($username.Length -lt 3)

# Prompt user for password and mask input
$password = Read-Host "New password (Password must not contain username):" -AsSecureString
$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

# Validate password length
if ($password.Length -lt 5) {
    Write-Host "Password must be at least 5 characters long."
    exit 1
}

# Validate password does not contain username
if ($password.ToLower().Contains($username.ToLower())) {
    Write-Host "Password cannot contain the username."
    exit 1
}

# Prompt user to confirm password and mask input
do {
    $confirm_password = Read-Host "Confirm password:" -AsSecureString
    $confirm_password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($confirm_password))
    if ($password -ne $confirm_password) {
        Write-Host "Passwords do not match. Try again."
    }
} while ($password -ne $confirm_password)

# Save username and password to XML file
$credentials = @"
<credentials>
    <username>$username</username>
    <password>$password</password>
</credentials>
"@
$credentials | Out-File -FilePath "credentials.xml"

# Ensure the directory structure exists for PowerShell profile script
New-Item -ItemType Directory -Path "$env:USERPROFILE\Documents\WindowsPowerShell" -ErrorAction SilentlyContinue

# Set the PowerShell profile script path
$profile_script = "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"

# Set the full path to the PowerShell script dynamically using $PSScriptRoot
$ps_script_path = Join-Path -Path $PSScriptRoot -ChildPath "popup.ps1"

# Add the command to run the PowerShell script with the chosen execution mode to the profile script
$executionModeCommand = switch ($apply_admin) {
    "1" { ". '$ps_script_path' ADMINISTRATION" }
    "2" { ". '$ps_script_path' WHOLE POWERSHELL" }
}
Add-Content -Path $profile_script -Value $executionModeCommand

# Notify the user about the setup
Write-Host "PowerShell startup script has been configured."
Write-Host "Your PowerShell profile script is located at: $profile_script"

# Pause to allow the user to see the message
Pause
