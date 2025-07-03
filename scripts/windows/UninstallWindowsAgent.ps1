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

function Get-UninstallExeCommand($uninstallString) {
    $index = $uninstallString.IndexOf("`"", 0)
    $index = $uninstallString.IndexOf("`"", $index + 1)

    $cmd = $uninstallString.SubString(1, $index - 1)
    $arguments = $uninstallString.SubString($index + 1).Trim()

    return @{
        Cmd       = $cmd
        Arguments = $arguments
        Key       = ""
    }
}

function Get-UninstallMsiCommand($productCode) {
    $cmd = "msiexec.exe"
    $arguments = "/x `"$productCode`" /qn /l*v `"$env:SystemRoot\temp\jcagentforceuninstall.log`""

    return @{
        Cmd       = $cmd
        Arguments = $arguments
        Key       = ""
    }
}

function Find-UninstallCommands($uninstallKey) {
    $uninstallCommands = @()

    Get-ChildItem -Path $uninstallKey | ForEach-Object {
        try {
            $displayName = (Get-ItemProperty -Path $_.PSPath -ErrorAction SilentlyContinue).DisplayName
            if ($displayName -like "*JumpCloud Agent*") {
                $uninstallString = (Get-ItemProperty -Path $_.PSPath -ErrorAction SilentlyContinue).UninstallString
                if ($uninstallString -like "MsiExec.exe*") {
                    $command = Get-UninstallMsiCommand $_.PSChildName
                    $command.Key = "$uninstallKey/$($_.PSChildName)"
                    $uninstallCommands += $command
                }
            }

            # if uninstall agent, remote assist or tray apps will not work anymore so, unisntall them also
            #  jumpcloud tray is uninstalled by the MSI installer so there is not separate installer.
            if ($displayName -like "*JumpCloud Remote Assist*" -or $displayName -like "*jumpcloud-agent-app*") {
                $uninstallString = (Get-ItemProperty -Path $_.PSPath -ErrorAction SilentlyContinue).QuietUninstallString
                $command = Get-UninstallExeCommand $uninstallString
                $command.Key = "$uninstallKey/$($_.PSChildName)"
                $uninstallCommands += $command
            }
        } catch {
            Write-Host "Error accessing $($_.PSPath)"
        }
    }

    return @{ Commands = $uninstallCommands }
}

# Function to recursively search for DisplayName and ProductName in the registry
function Find-JumpCloudGUID {
    $rootKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products"
    $uninstallKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
    $uninstallWowKey = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    $classesKey = "HKCR:\Installer\Products"

    $agentGUIDs = @()
    $msiGUIDs = @()
    $uninstallCommands = @()

    (Find-UninstallCommands $uninstallKey).Commands | ForEach-Object { $uninstallCommands += $_ }
    (Find-UninstallCommands $uninstallWowKey).Commands | ForEach-Object { $uninstallCommands += $_ }

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

    return @{ AgentGUIDs = $agentGUIDs; MSIGUIDs = $msiGUIDs; Uninstalls = $uninstallCommands }
}

function Remove-Folder($folder) {
    if (Test-Path $folder) {
        Remove-Item -Path $folder -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Successfully deleted folder: $folder"
    }
}

# Function to remove registry keys, folder, and service
function Remove-JumpCloud {
    $guids = Find-JumpCloudGUID

    # Flag to track if items to remove were found
    $foundItemsToRemove = $false

    # if the MSI was used to install, we want to uninstall that route first
    foreach ($uninst in $guids.Uninstalls) {
        if (-not(Test-Path -Path $uninst.Key)) {
            Write-Host "$($uninst.Key) already removed"
            continue;
        }

        $foundItemsToRemove = $true
        Write-Output "Uninstallation of $($uninst.Cmd) $($uninst.Arguments) started."

        # Uninstall the MSI package, PS will fail without quotes around product code
        # puposely give uninstall log a different name to differentiate
        Start-Process $uninst.Cmd -ArgumentList $uninst.Arguments -Wait

        Write-Output "Uninstallation of $($uninst.Cmd) $($uninst.Arguments) completed."
    }

    # remove installation registry keys if left behind.
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
    }

    # Stopping and removing the JumpCloud Agent service if exists
    $serviceName = "jumpcloud-agent"
    if (Get-Service -Name $serviceName -ErrorAction SilentlyContinue) {
        $foundItemsToRemove = $true
        Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 6
        sc.exe delete $serviceName
        Start-Sleep -Seconds 6
        Write-Host "Service $serviceName successfully removed."
    }

    # stop and remove jumpcloud try if it exists
    Get-Process -Name jumpcloudtray -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Host "stopping tray process $($_.Id)"
        Stop-Process -id $_.Id -ErrorAction SilentlyContinue
    }

    # Removing the JumpCloudfolder
    $folder = "$($env:ProgramFiles)\JumpCloud"
    Remove-Folder $folder

    # remove tray folder
    $folder = "$($env:ProgramFiles)\JumpCloudTray"
    Remove-Folder $folder

    $folder = "$env:APPDATA\JumpCloud"
    Remove-Folder $folder

    # remove older credential provider files if they exists in sys dir
    if (Test-Path "$env:SystemRoot\System32\JumpCloud*.dll") {
        $foundItemsToRemove = $true
        Remove-Item -Path "$env:SystemRoot\System32\JumpCloud*.dll" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Successfully deleted files from system32"
    }

    # remove windows runs on startups
    $runKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"

    # Get the registry key
    (Get-Item -Path $runKeyPath).Property | ForEach-Object {
        try {
            if ($_ -like "*jumpcloud-*") {
                Write-Host "Delete $runKeyPath $_"
                Remove-ItemProperty -Path $runKeyPath -Name $_
            }
        } catch {
            Write-Host "Error accessing $($_)"
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