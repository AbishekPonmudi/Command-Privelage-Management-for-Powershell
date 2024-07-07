# Check if the script is running with administrative privileges
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Define the path where the credentials will be stored
$credentialsFile = Join-Path -Path $env:USERPROFILE -ChildPath "Documents\WindowsPowerShell\credentials.xml"

# Function to set registry value
function Set-RegistryValue {
    param (
        [string]$key,
        [string]$valueName,
        [int]$valueData
    )

    try {
        # Check if the registry key exists, if not, create it
        if (-not (Test-Path -Path $key)) {
            New-Item -Path $key -Force | Out-Null
        }

        Set-ItemProperty -Path $key -Name $valueName -Value $valueData -ErrorAction Stop
        Write-Host "Registry value set successfully."
    } catch {
        Write-Host "Error setting registry value: $_"
    }
}

# Function to close the PowerShell window
function Close-PowerShellWindow {
    $host.SetShouldExit(0)
}

# Function to prompt for credentials
function Prompt-ForCredentials {
    param (
        [int]$attempt
    )

    # Load credentials from XML file
    try {
        $xml = [xml](Get-Content $credentialsFile)
        $storedUsername = $xml.credentials.username
        $storedPassword = $xml.credentials.password

        # Prompt user for credentials
        if ($attempt -lt 3) {
            $usernameInput = Read-Host "Username for Windows:"
            $passwordInput = Read-Host -Prompt "Password for Windows:" -AsSecureString
            $credential = New-Object System.Management.Automation.PSCredential ($usernameInput, $passwordInput)
        } else {
            $credential = Get-Credential -Message "Credentials for Windows"
        }

        # Check if the user canceled the prompt
        if ($credential -eq $null) {
            Write-Warning "Credential prompt canceled. PowerShell remains usable. If not, close it manually."
            Close-PowerShellWindow
        }

        # Validate user credentials
        elseif (($credential.UserName -eq $storedUsername) -and ($credential.GetNetworkCredential().Password -eq ($storedPassword))) {
            Write-Warning "Authentication successful. Access granted."
            return $true
        } else {
            Write-Warning "Authentication failed. Access denied."
            return $false
        }
    } catch {
        Write-Warning "[Windows] requires credentials"
    }
}

# Enable command prompt and PowerShell with user authentication
try {
    # If the script is running with administrative privileges
    if ($isAdmin) {
        # Prompt for credentials
        $authenticated = $false
        $attempts = 0

        while (-not $authenticated) {
            $authenticated = Prompt-ForCredentials -attempt $attempts

            # Increment attempt count if authentication fails
            if (-not $authenticated) {
                $attempts++
                if ($attempts -ge 3) {
                    Write-Warning "Maximum attempts reached. Exiting script."
                    Close-PowerShellWindow
                }
            }
        }

        # Set registry value to enable command prompt
        Set-RegistryValue -Key "HKCU:\Software\MyApplication" -ValueName "DisableCMD" -ValueData 0
    } else {
        # If the script is not running with administrative privileges
        Write-Warning "This script must be run with administrative privileges."
    }
} catch {
    Write-Host "An error occurred: $_"
}
