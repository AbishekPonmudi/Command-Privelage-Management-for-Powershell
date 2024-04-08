
# Windows Powershell authenticator

The Windows Authenticator is a security script designed to provide an additional layer of authentication for Windows PowerShell and Command Prompt users. It ensures advanced-level security by authenticating users before granting access to sensitive operations or resources.

Why Windows Authenticator?
While Windows is generally considered secure, it may lack some of the authentication features commonly found in Linux systems, such as the sudo command. The Windows Authenticator addresses this gap by introducing an authentication mechanism similar to the one found in Linux systems, ensuring enhanced security and user control.

# let's discuss How It Works ?

• Registry Configuration: The script sets a registry key to control access to PowerShell and Command Prompt.

• User Authentication: Users are prompted to enter their credentials when attempting to access PowerShell or Command Prompt.

• Credential Validation: The entered credentials are validated against predefined username and password variables.

• Access Granting: If the credentials match, access to PowerShell and Command Prompt is granted. Otherwise, access is denied.


This is mainly used for secure authentication and secure from unauthorished usages within the administration previlages , which secures from reverse shell and even powershell related backdoor , 

which is further integrated with reverse shell detection, ssh authentication and further related to powershell acticity , if the reverse shell , ssh detected it ask user credintial to login which act like a security guard for the powershell even it is not accessable even it hacked.

And lot understanble while using .




## Installation

for more information first Run the 'install.bat'.

```bash
./install.bat

```

For uninstall this authenticator Simply run this application either powershell or manuallly

```bash
./uninstall.bat
```

If it not works on windows 11 and This feature may not applicable with windows 10 and below that so then after installation run this command whether using windows 10 or below that

```bash
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass

```
And press Y to apply the changes Don't worry about the script it is just a enable command 


    
## code preview 

the username and password will be taken by ```install.bat``` script
you can set your desired username and password  .

```powershell
# Check if the script is running with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "This script requires administrative privileges. Please run PowerShell as administrator."
    Exit
}

# Check if the script is running in non-administration mode (based on user input from install.bat)
$executeMode = $args[0]

# If the script is running in non-administration mode, do something specific
if ($executeMode -eq "0") {
    Write-Host "Running in administration mode."
    # You can add non-administrative specific functionality here
}

# If the script is running in administration mode (1), or the user chose non-administration mode (0) and entered credentials
if ($executeMode -eq "1" -or $executeMode -eq "0") {
    # Define variables
    $registryKey = "HKCU:\Software\MyApplication"
    $registryValueName = "DisableCMD"

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

        # Get the directory where the script is located using $PSScriptRoot
        $scriptDirectory = $PSScriptRoot

        # Construct the path to the credentials file relative to the script's location
        $credentialsFile = Join-Path -Path $scriptDirectory -ChildPath "credentials.xml"

        # Load credentials from XML file
        try {
            $xml = [xml](Get-Content $credentialsFile)
            $storedUsername = $xml.credentials.username
            $storedPassword = $xml.credentials.password

            # Prompt user for credentials
            if ($attempt -lt 3) {
                $usernameInput = Read-Host "Enter your username"
                $passwordInput = Read-Host -Prompt "Enter your password" -AsSecureString
                $credential = New-Object System.Management.Automation.PSCredential ($usernameInput, $passwordInput)
            } else {
                $credential = Get-Credential -Message "Enter your credentials"
            }

            # Check if the user canceled the prompt
            if ($credential -eq $null) {
                Write-Host "Credential prompt canceled. PowerShell remains usable."
                Close-PowerShellWindow
            }

            # Validate user credentials
            elseif (($credential.UserName -eq $storedUsername) -and ($credential.GetNetworkCredential().Password -eq ($storedPassword))) {
                Write-Host "Authentication successful. Access granted."
                return $true
            } else {
                Write-Host "Authentication failed. Access denied."
                return $false
            }
        } catch {
            Write-Host "Error occurred while loading credentials: $_"
        }
    }

    # Enable command prompt and PowerShell with user authentication
    try {
        # Set registry value to enable command prompt
        Set-RegistryValue -Key $registryKey -ValueName $registryValueName -ValueData 0

        $authenticated = $false
        $attempts = 0

        while (-not $authenticated) {
            $authenticated = Prompt-ForCredentials -attempt $attempts

            # Increment attempt count if authentication fails
            if (-not $authenticated) {
                $attempts++
                if ($attempts -ge 3) {
                    Write-Host "Maximum attempts reached. Opening popup window for credential entry."
                    $authenticated = Prompt-ForCredentials -attempt $attempts
                }
                if ($attempts -ge 3) {
                    Write-Host "Maximum attempts reached. Exiting script."
                    Close-PowerShellWindow
                }
            }
        }

        # Additional operations can be performed here if needed after successful authentication

    } catch {
        Write-Host "Error occurred: $_"
    }
}


## Video reference


[![Alt text](https://img.youtube.com/vi/x5J5b6u99pM/0.jpg)](https://www.youtube.com/watch?v=x5J5b6u99pM)

## Related

Here are some related projects

[Awesome README](https://www.bing.com/ck/a?!&&p=6b8285be0210fe7dJmltdHM9MTcwNzc4MjQwMCZpZ3VpZD0yZDJiMWM2ZS1kOGI0LTYzMWYtMDVmZi0wZmI1ZDkxOTYyOTYmaW5zaWQ9NTI1NA&ptn=3&ver=2&hsh=3&fclid=2d2b1c6e-d8b4-631f-05ff-0fb5d9196296&psq=powershell+authenticator&u=a1aHR0cHM6Ly9sZWFybi5taWNyb3NvZnQuY29tL2VuLXVzL3Bvd2Vyc2hlbGwvbWljcm9zb2Z0Z3JhcGgvYXV0aGVudGljYXRpb24tY29tbWFuZHM_dmlldz1ncmFwaC1wb3dlcnNoZWxsLTEuMA&ntb=1)

