 # Function to check if running as Administrator
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

# Function to recursively search for DisplayName and ProductName in the registry
function Find-JumpCloudGUID {
    $rootKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products"
    $uninstallKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
    $classesKey = "HKCR:\Installer\Products"
    
    $agentGUIDs = @()
    $msiGUIDs = @()

    # Searching Installer Products for JumpCloud Agent GUIDs
    Get-ChildItem -Path $rootKey | ForEach-Object {
        $installPropertiesPath = "$($_.PSPath)\InstallProperties"
        try {
            $displayName = (Get-ItemProperty -Path $installPropertiesPath -ErrorAction SilentlyContinue).DisplayName
            if ($displayName -like "*JumpCloud Agent*") {
                $guid = $_.PSChildName
                $agentGUIDs += $guid
            }
        } catch {
            Write-Host "Error accessing $installPropertiesPath"
        }
    }

    # Searching Uninstall Key for MSI GUIDs
    Get-ChildItem -Path $uninstallKey | ForEach-Object {
        try {
            $displayName = (Get-ItemProperty -Path $_.PSPath -ErrorAction SilentlyContinue).DisplayName
            if ($displayName -like "*JumpCloud Agent*") {
                $uninstallGUID = $_.PSChildName
                $msiGUIDs += $uninstallGUID
            }
        } catch {
            Write-Host "Error accessing $($_.PSPath)"
        }
    }

    # Searching HKEY_CLASSES_ROOT\Installer\Products for JumpCloud Agent GUIDs
    Get-ChildItem -Path $classesKey | ForEach-Object {
        try {
            $productName = (Get-ItemProperty -Path $_.PSPath -ErrorAction SilentlyContinue).ProductName
            if ($productName -like "*JumpCloud Agent*") {
                $guid = $_.PSChildName
                $agentGUIDs += $guid
            }
        } catch {
            Write-Host "Error accessing $($_.PSPath)"
        }
    }

    return @{ AgentGUIDs = $agentGUIDs; MSIGUIDs = $msiGUIDs }
}

# Function to remove registry keys, folder, and service
function Remove-JumpCloud {
    $guids = Find-JumpCloudGUID
    
    # Flag to track if items to remove were found
    $foundItemsToRemove = $false  
    
    foreach ($guid in $guids.AgentGUIDs) {
        # Removing registry keys
        $installerKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\$guid"
        $classesKey = "HKCR:\Installer\Products\$guid"
        $jumpcloudSoftwareKey = "HKLM:\Software\JumpCloud"
        
        foreach ($msiGuid in $guids.MSIGUIDs) {
            $uninstallKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$msiGuid"

            $keysToDelete = @($installerKey, $classesKey, $uninstallKey, $jumpcloudSoftwareKey)

            foreach ($key in $keysToDelete) {
                if (Test-Path $key) {
                    $foundItemsToRemove = $true
                    Remove-Item -Path $key -Recurse -Force
                    Write-Host "Successfully deleted registry key: $key"
                }
            }
        }

        # Stopping and removing the JumpCloud Agent service
        $serviceName = "jumpcloud-agent"
        if (Get-Service -Name $serviceName -ErrorAction SilentlyContinue) {
            $foundItemsToRemove = $true
            Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 6
            sc.exe delete $serviceName
            Start-Sleep -Seconds 6
            Write-Host "Service $serviceName successfully removed."
        } 

        # Removing the JumpCloudfolder
        $jumpcloudFolder = "C:\Program Files\JumpCloud"
        if (Test-Path $jumpcloudFolder) {
            $foundItemsToRemove = $true
            Remove-Item -Path $jumpcloudFolder -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Successfully deleted folder: $jumpcloudFolder"
        } 
    }

    # Check if nothing was found to remove
    if (-not $foundItemsToRemove) {
        Write-Host "Nothing was found to remove."
    }
}

# Run the removal function
Remove-JumpCloud

Remove-Variable * -ErrorAction SilentlyContinue