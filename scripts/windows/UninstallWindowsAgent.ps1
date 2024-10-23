# Function to check if Powershell is running as Administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Administrator)) {
    Write-Warning "This script needs to be run as an administrator."
    exit
}

# Create HKCR Mapping
New-PSDrive -Name "HKCR" -PSProvider Registry -Root "HKEY_CLASSES_ROOT" -ErrorAction SilentlyContinue

# Function to recursively search for DisplayName in the registry
function Find-JumpCloudGUID {
    $rootKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products"
    $uninstallKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
    $jumpcloudGUIDs = @()

    # Searching Installed Products
    Get-ChildItem -Path $rootKey | ForEach-Object {
        $installPropertiesPath = "$($_.PSPath)\InstallProperties"
        try {
            $displayName = (Get-ItemProperty -Path $installPropertiesPath -ErrorAction SilentlyContinue).DisplayName
            if ($displayName -like "*JumpCloud Agent*") {
                $guid = $_.PSChildName
                $jumpcloudGUIDs += $guid
            }
        } catch {
            Write-Host "Error accessing $installPropertiesPath"
        }
    }

    # Searching for the Uninstall Key
    Get-ChildItem -Path $uninstallKey | ForEach-Object {
        try {
            $displayName = (Get-ItemProperty -Path $_.PSPath -ErrorAction SilentlyContinue).DisplayName
            if ($displayName -like "*JumpCloud Agent*") {
                $uninstallGUID = $_.PSChildName
                $jumpcloudGUIDs += $uninstallGUID
            }
        } catch {
            Write-Host "Error accessing $($_.PSPath)"
        }
    }

    return $jumpcloudGUIDs
}

# Function to remove registry keys, JC folder, and JC service
function Remove-JumpCloud {
    $guids = Find-JumpCloudGUID

    foreach ($guid in $guids) {
        # Removing registry keys
        $installerKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\$guid"
        $classesKey = "HKCR:\Installer\Products\$guid"
        $uninstallKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$guid"
        $jumpcloudSoftwareKey = "HKLM:\Software\JumpCloud"
        $jumpcloudClasses = "HKLM:\SOFTWARE\Classes\Installer\Products\$guid"

        $keysToDelete = @($installerKey, $classesKey, $uninstallKey, $jumpcloudSoftwareKey)

        foreach ($key in $keysToDelete) {
            if (Test-Path $key) {
                Remove-Item -Path $key -Recurse -Force -Verbose -ErrorAction SilentlyContinue
            } else {
                Write-Host "Registry key $key not found."
            }
        }

        # Stopping and removing the service
        $serviceName = "jumpcloud-agent"
        if (Get-Service -Name $serviceName -ErrorAction SilentlyContinue) {
            Stop-Service -Name $serviceName -Force -Verbose
            start-sleep 6
            sc.exe delete $serviceName
            start-sleep 6
        } else {
            Write-Host "Service $serviceName not found."
        }

        # Removing folder
        $jumpcloudFolder = "C:\Program Files\JumpCloud"
        if (Test-Path $jumpcloudFolder) {
            Remove-Item -Path $jumpcloudFolder -Recurse -ErrorAction SilentlyContinue
        }

    }
}

# Run the removal function
Remove-JumpCloud
