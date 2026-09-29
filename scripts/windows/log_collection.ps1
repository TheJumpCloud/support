########################### Settings ###########################
# set to $true if running via a JumpCloud command (recommended)
$automate = $false

##################### Do Not Modify Below ######################

# Function to Check if the Script is Running as an Administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Administrator)) {
    Write-Warning "This script needs to be run as an administrator."
    exit 1
}

# Function to get PowerShell Version
function Check-PowerShellVersion {
    $requiredVersion = 5
    $currentVersion = $PSVersionTable.PSVersion.Major

    if ($currentVersion -lt $requiredVersion) {
        Write-Warning "This script requires PowerShell version 5.0 or higher. Current version: $currentVersion. Exiting..."
        exit 1
    } else {
        Write-Host "PowerShell version $currentVersion detected. Proceeding..."
    }
}

# Call the function to check the version
Check-PowerShellVersion

# Function to Copy Log Files, Including Files Locked by Another Process
function Copy-LogFile {
    param (
        [string]$Path,
        [string]$Destination
    )
    try {
        Copy-Item -Path $Path -Destination $Destination -ErrorAction Stop
    } catch {
        $sourceStream = [System.IO.File]::Open($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]'ReadWrite, Delete')
        try {
            $destStream = [System.IO.File]::Create($Destination)
            try {
                $sourceStream.CopyTo($destStream, 1MB)
            } finally {
                $destStream.Dispose()
            }
        } finally {
            $sourceStream.Dispose()
        }
    }
}

# Function to Get All Values Under a Registry Policy Key
function Get-RegistryPolicyValues {
    param (
        [string]$RegPath
    )
    $keys = @(Get-Item -Path "Registry::$RegPath" -ErrorAction SilentlyContinue)
    $keys += Get-ChildItem -Path "Registry::$RegPath" -Recurse -ErrorAction SilentlyContinue
    foreach ($key in $keys) {
        if (-not $key) { continue }
        $subPath = $key.Name.Substring([Math]::Min($RegPath.Length, $key.Name.Length)).TrimStart('\')
        foreach ($valueName in $key.GetValueNames()) {
            $value = $key.GetValue($valueName)
            [PSCustomObject]@{
                Policy = if ($subPath) { "$subPath\$valueName" } else { $valueName }
                Value  = if ($value -is [array]) { $value -join "; " } else { $value }
            }
        }
        $key.Close()
    }
}

# Function to Gather Logs Based on User Selection
function Gather-Logs {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = 'SearchFilter')]
        [ValidateSet( "JumpCloud Agent Logs",
            "Remote Assist logs",
            "Password Manager Logs",
            "MDM Enrollment, CSP Policies, and Hosted Software Management",
            "Bitlocker",
            "Software Management: Chocolatey",
            "Software Management: Windows Store and App Catalog",
            "Device Policies and Patching",
            "Active Directory Integration Logs")]
        [String[]]
        $selections,
        [Parameter(ParameterSetName = 'All Logs')]
        [switch]
        $All
    )

    begin {
        # Temp Directory Used During Log Gathering
        $tempDir = Join-Path $env:TEMP "Jumpcloud_Temp_Logs"

        if (Test-Path $tempDir) {
            Remove-Item -Path $tempDir -Recurse -Force
        }
        New-Item -ItemType Directory -Path $tempDir > $null

        # List of Log Files and Event Logs to Gather
        $fileList = @{
            "AgentLogs"        = @(
                "C:\windows\temp\jcagent.log",
                "C:\windows\temp\jcagent.log.*",
                "C:\Windows\Temp\jcagent_updater.log",
                "C:\Windows\Temp\jcExecUpgradeScript.log",
                "C:\Windows\Temp\jcUninstallUpgrade.log",
                "C:\Windows\Temp\jcUpdate.log",
                "C:\Windows\Temp\jcUpgradeScript.log",
                "C:\Windows\Temp\jcUninstallUpgrade.log",
                "C:\windows\temp\jcagent.log.prev",
                "C:\windows\temp\pid-agent-updater.txt",
                "C:\Windows\Logs\JCCredentialProvider\provider.log",
                "C:\Program Files\JumpCloud\Plugins\Contrib\jcagent.conf",
                "C:\Program Files\JumpCloud\Plugins\Contrib\lockoutCache.json",
                "C:\Program Files\JumpCloud\Plugins\Contrib\managedUsers.json",
                "C:\Program Files\JumpCloud\policyConf.json",
                "c:\Windows\system32\drivers\etc\jcagent-proxy.conf"
            )
            "RemoteAssistLogs" = @(
                "C:\Windows\System32\config\systemprofile\AppData\Roaming\JumpCloud-Remote-Assist\logs\*.log",
                "C:\Windows\Temp\jc_raasvc.log"
            )
            "ChocolateyLogs"   = @(
                "C:\ProgramData\chocolatey\logs\choco.summary.log",
                "C:\ProgramData\chocolatey\logs\chocolatey.log",
                "C:\windows\temp\jcagent.log"
            )
            "ADLogs"           = @(
                "C:\Program Files\JumpCloud\AD Integration\JumpCloud AD Import\JumpCloud_AD_Import_Grpc*.log",
                "C:\Windows\Temp\JumpCloud_AD_Integration.log",
                "C:\Program Files\JumpCloud\AD Integration\JumpCloud AD Import\jcadimportagent.config.json",
                "C:\Program Files\JumpCloud\AD Integration\JumpCloud AD Sync\JumpCloud_AD_Sync.log",
                "C:\Program Files\JumpCloud\AD Integration\JumpCloud AD Sync\config.json"
            )
            "Policies"         = @(
                "C:\windows\temp\jcagent.log"
            )
            "PatchingLogs"     = @(
                "C:\Windows\Logs\CBS\CBS.log",
                "C:\Windows\Logs\CBS\CbsPersist_*",
                "C:\Windows\Logs\DISM\dism.log",
                "C:\Windows\SoftwareDistribution\ReportingEvents.log"
            )
        }

        $eventLogList = @{
            "EssentialEvents"    = @("Application", "Security", "System", "Windows PowerShell")
            "BitLockerEvents"    = @("Microsoft-Windows-BitLocker/BitLocker Management")
            "WindowsStoreEvents" = @(
                "Microsoft-Windows-AppXDeployment/Operational",
                "Microsoft-Windows-AppXDeploymentServer/Operational",
                "Microsoft-Windows-AppxPackaging/Operational"
            )
            "PatchingEvents"     = @(
                "Microsoft-Windows-WindowsUpdateClient/Operational",
                "Setup",
                "Microsoft-Windows-Bits-Client/Operational",
                "Microsoft-Windows-DeliveryOptimization/Operational",
                "Microsoft-Windows-UpdateOrchestrator/Operational",
                "Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Admin"
            )
        }

        $files = @()
        $eventLogs = @()
        $copyLog = @()

        # Gather System Information
        try {
            $winInfo = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
            $winProductName = (Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue).Caption -replace '^Microsoft ', ''
            if (-not $winProductName) { $winProductName = $winInfo.ProductName }

            $systemKey = "Not found"
            $agentConf = "C:\Program Files\JumpCloud\Plugins\Contrib\jcagent.conf"
            if (Test-Path $agentConf) {
                $confContent = Get-Content -Path $agentConf -Raw -ErrorAction SilentlyContinue
                if ($confContent -match '"systemKey"\s*:\s*"([^"]+)"') { $systemKey = $Matches[1] }
            }

            # Getting installed JumpCloud software
            $jcProducts = @(Get-ItemProperty -Path @(
                    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
                    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
                    "Registry::HKEY_USERS\*\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
                ) -ErrorAction SilentlyContinue |
                Where-Object { $_.DisplayName -like "*JumpCloud*" } |
                Select-Object DisplayName, DisplayVersion |
                Sort-Object DisplayName, DisplayVersion -Unique)
            $getProductVersion = {
                param ($namePattern)
                $versions = @($jcProducts | Where-Object { $_.DisplayName -like $namePattern } | ForEach-Object { $_.DisplayVersion } | Select-Object -Unique)
                if ($versions) { $versions -join ", " } else { "Not installed" }
            }

            $agentVersion = & $getProductVersion "*JumpCloud Agent*"
            $versionFile = "C:\Program Files\JumpCloud\Plugins\Contrib\version.txt"
            if (Test-Path $versionFile) {
                $versionText = Get-Content -Path $versionFile -Raw -ErrorAction SilentlyContinue
                if ($versionText -and $versionText.Trim()) { $agentVersion = $versionText.Trim() }
            }

            $trayVersion = & $getProductVersion "*Tray*"
            $trayExe = "C:\Program Files\JumpCloudTray\JumpCloudTray.exe"
            if (Test-Path $trayExe) {
                $trayVersion = (Get-Item -Path $trayExe).VersionInfo.ProductVersion
            }

            $systemInfo = @(
                "Collected:      $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')",
                "Hostname:       $env:COMPUTERNAME",
                "System Key:     $systemKey",
                "Windows:        $winProductName $($winInfo.DisplayVersion) (Build $($winInfo.CurrentBuild).$($winInfo.UBR))",
                "Agent Version:  $agentVersion",
                "Remote Assist:  $(& $getProductVersion '*Remote Assist*')",
                "Tray App:       $trayVersion",
                "",
                "All Installed JumpCloud Software"
            ) -join "`r`n"
            $systemInfo += "`r`n" + $(if ($jcProducts) { $jcProducts | Format-Table -AutoSize | Out-String -Width 4096 } else { "None found`r`n" })

            $systemInfo | Out-File -FilePath (Join-Path $tempDir "SystemInfo.txt")
            $copyLog += "SUCCESS: Gathered system info to SystemInfo.txt"
        } catch {
            $copyLog += "FAILED: Gathering system info - $($_.Exception.Message)"
        }

        if ($PSCmdlet.ParameterSetName -eq 'SearchFilter') {
            $selectedSections = $selections
        } elseif ($PSCmdlet.ParameterSetName -eq 'All Logs') {
            $selectedSections = @("JumpCloud Agent Logs",
                "Remote Assist logs",
                "Password Manager Logs",
                "MDM Enrollment, CSP Policies, and Hosted Software Management",
                "Bitlocker",
                "Software Management: Chocolatey",
                "Software Management: Windows Store and App Catalog",
                "Device Policies and Patching")
        }
    }

    process {
        foreach ($logType in $selectedSections) {
            Write-Host "Getting $($logType)"
            switch ($logType) {
                "JumpCloud Agent Logs" {
                    $files += $fileList["AgentLogs"]
                    $eventLogs += $eventLogList["EssentialEvents"]

                    # Gather Local User and Group Membership Information
                    try {
                        Get-LocalUser | ForEach-Object {
                            $user = $_
                            $userSID = $user.SID
                            $memberOf = Get-LocalGroup | Where-Object {
                                try {
                                    $members = Get-LocalGroupMember -Group $_.Name -ErrorAction SilentlyContinue
                                    $members.SID -contains $userSID
                                } catch { $false }
                            }
                            [PSCustomObject]@{
                                UserName    = $user.Name
                                SID         = $userSID.Value
                                Description = $user.Description
                                Groups      = ($memberOf.Name -join ", ")
                                Enabled     = $user.Enabled
                            }
                        } | Sort-Object UserName | Format-Table -AutoSize | Out-String -Width 4096 | Out-File -FilePath "$tempDir\SystemUsers.log"
                        $copyLog += "SUCCESS: Gathered Local Users to SystemUsers.log"
                    } catch {
                        $copyLog += "FAILED: Gathering Local Users - $($_.Exception.Message)"
                    }

                    # Gather Credential Providers Information
                    try {
                        $LastUsedGUID = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI").LastLoggedOnProvider
                        $providers = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers" | 
                        ForEach-Object {
                            $id = $_.PSChildName
                            $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers\$id"
                            $clsidPath = "HKLM:\Software\Classes\CLSID\$id\InprocServer32"
                            $name = (Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue)."(default)"
                            $dll = (Get-ItemProperty -Path $clsidPath -ErrorAction SilentlyContinue)."(default)"
                            $Status = if ($id -eq $LastUsedGUID) { "Active (Last Used)" } else { "Available" }
                            [PSCustomObject]@{
                                Status       = $Status
                                ProviderName = if ($name) { $name } else { "Windows Internal / Generic" }
                                GUID         = $id
                                DLLPath      = $dll
                            }
                        }

                        $active = $providers | Where-Object { $_.Status -eq "Active (Last Used)" }
                        $available = $providers | Where-Object { $_.Status -ne "Active (Last Used)" } | Sort-Object ProviderName

                        $credLogContent = $active | Format-Table -AutoSize | Out-String -Width 4096
                        $credLogContent += "`r`n" # Blank Line
                        $credLogContent += $available | Format-Table -AutoSize | Out-String -Width 4096
                        
                        $credLogContent | Out-File -FilePath "$tempDir\CredentialProviders.txt"
                        $copyLog += "SUCCESS: Gathered Credential Providers to CredentialProviders.txt"
                    } catch {
                        $copyLog += "FAILED: Gathering Credential Providers - $($_.Exception.Message)"
                    }

                    # Getting per-user logs
                    $allUsers = Get-LocalUser
                    foreach ($user in $allUsers) {
                        # Getting Profile-Specific Logs
                        if ( Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$($user.SID)" -Name "ProfileImagePath" -ErrorAction SilentlyContinue) {
                            $profilePath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$($user.SID)").ProfileImagePath
                            
                            $logPatterns = @(
                                "$profilePath\AppData\Local\Temp\jc-user-agent.log",
                                "$profilePath\AppData\Local\Temp\jcupdate.log",
                                "$profilePath\AppData\Local\Temp\jc-native-messaging-host*.log"
                            )

                            foreach ($pattern in $logPatterns) {
                                $matchedFiles = Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue
                                foreach ($file in $matchedFiles) {
                                    try {
                                        $destName = "$tempDir\$($user.Name)-$($file.Name)"
                                        Copy-LogFile -Path $file.FullName -Destination $destName
                                        $copyLog += "SUCCESS: $($file.FullName) -> $destName"
                                    } catch {
                                        $copyLog += "FAILED: $($file.FullName) - $($_.Exception.Message)"
                                    }
                                }
                            }
                        }
                    }

                    # Getting JumpCloud ProgramData logs
                    $programDataRoot = "C:\ProgramData\JumpCloud"
                    $includePatterns = @("*.log", "*.log.*", "*.txt", "*.json", "*.conf")
                    $excludePatterns = @("*.key", "*.pem", "*.pfx", "*.crt")
                    $programDataFiles = @(Get-ChildItem -Path $programDataRoot -Recurse -File -ErrorAction SilentlyContinue | Where-Object {
                        $fileName = $_.Name
                        -not ($excludePatterns | Where-Object { $fileName -like $_ }) -and
                        ($includePatterns | Where-Object { $fileName -like $_ })
                    })

                    # Getting user names for per-user folders
                    $userNames = @(Get-LocalUser | ForEach-Object { $_.Name })
                    $userNames += Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" -ErrorAction SilentlyContinue |
                        ForEach-Object { (Get-ItemProperty -Path $_.PSPath -ErrorAction SilentlyContinue).ProfileImagePath } |
                        Where-Object { $_ } | ForEach-Object { Split-Path $_ -Leaf }

                    # Getting file names that need a folder prefix
                    $nameCounts = @{}
                    $programDataFiles | Group-Object Name | ForEach-Object { $nameCounts[$_.Name] = $_.Count }
                    $reservedNames = @($fileList.Values | ForEach-Object { $_ } | ForEach-Object { Split-Path $_ -Leaf } | Where-Object { $_ -notmatch '[*?]' })

                    foreach ($file in $programDataFiles) {
                        try {
                            $parentFolder = Split-Path $file.DirectoryName -Leaf
                            $needsPrefix = ($userNames -contains $parentFolder) -or
                                ($nameCounts[$file.Name] -gt 1) -or
                                ($reservedNames -contains $file.Name) -or
                                (Test-Path (Join-Path $tempDir $file.Name))
                            $destName = if ($needsPrefix) { Join-Path $tempDir "$parentFolder-$($file.Name)" } else { Join-Path $tempDir $file.Name }

                            # Use the full relative path if the name is still taken
                            if (Test-Path $destName) {
                                $relativePath = $file.FullName.Substring($programDataRoot.Length).TrimStart('\')
                                $destName = Join-Path $tempDir ($relativePath -replace '\\', '-')
                            }

                            Copy-LogFile -Path $file.FullName -Destination $destName
                            $copyLog += "SUCCESS: $($file.FullName) -> $destName"
                        } catch {
                            $copyLog += "FAILED: $($file.FullName) - $($_.Exception.Message)"
                        }
                    }

                    # Getting local security policy export
                    secedit /export /cfg "$tempDir\secpol_backup.inf" > $null 2>&1
                    if ($LASTEXITCODE -eq 0) {
                        $copyLog += "SUCCESS: Exported local security policy to $tempDir\secpol_backup.inf"
                    } else {
                        $copyLog += "FAILED: Exporting local security policy - secedit exit code $LASTEXITCODE"
                    }
                }
                "Remote Assist logs" {
                    $files += $fileList["RemoteAssistLogs"]
                }
                "Password Manager Logs" {
                    $allUsers = Get-LocalUser
                    foreach ($user in $allUsers) {
                        if ( Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$($user.SID)" -Name "ProfileImagePath" -ErrorAction SilentlyContinue) {
                            $profilePath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$($user.SID)").ProfileImagePath

                            foreach ($pattern in @(
                                    "$profilePath\AppData\Roaming\JumpCloud Password Manager\logs\logs-live.log",
                                    "$profilePath\AppData\Roaming\JumpCloud Password Manager\data\daemon\log\*.log"
                                )) {
                                $matchedFiles = Get-ChildItem -Path $pattern -File -ErrorAction SilentlyContinue
                                if (-not $matchedFiles) {
                                    $copyLog += "FAILED: $pattern - File does not exist"
                                }
                                # Prefix with user name to avoid overwriting
                                foreach ($file in $matchedFiles) {
                                    try {
                                        $destName = "$tempDir\$($user.Name)-PWM-$($file.Name)"
                                        Copy-LogFile -Path $file.FullName -Destination $destName
                                        $copyLog += "SUCCESS: $($file.FullName) -> $destName"
                                    } catch {
                                        $copyLog += "FAILED: $($file.FullName) - $($_.Exception.Message)"
                                    }
                                }
                            }
                        }
                    }
                }
                "MDM Enrollment, CSP Policies, and Hosted Software Management" {
                    $eventLogs += $eventLogList["EssentialEvents"]
                    $mdmDiagDir = Join-Path $tempDir "MDMDiag"
                    New-Item -ItemType Directory -Path $mdmDiagDir > $null
                    # Check the tool exists first, otherwise $LASTEXITCODE is left over from the previous native command
                    if (Get-Command mdmdiagnosticstool.exe -ErrorAction SilentlyContinue) {
                        mdmdiagnosticstool.exe -area "DeviceEnrollment;DeviceProvisioning;Autopilot" -zip "$mdmDiagDir\MDMDiag.zip" > $null 2>&1
                        if ($LASTEXITCODE -eq 0) {
                            $copyLog += "SUCCESS: Generated MDM diagnostics to MDMDiag\MDMDiag.zip"
                        } else {
                            $copyLog += "FAILED: Generating MDM diagnostics - mdmdiagnosticstool exit code $LASTEXITCODE"
                        }
                    } else {
                        $copyLog += "FAILED: Generating MDM diagnostics - mdmdiagnosticstool.exe not found"
                    }
                }
                "Bitlocker" {
                    $files += $fileList["AgentLogs"]
                    $eventLogs += $eventLogList["EssentialEvents"]
                    $eventLogs += $eventLogList["BitLockerEvents"]
                }
                "Software Management: Chocolatey" {
                    $files += $fileList["ChocolateyLogs"]
                    $eventLogs += $eventLogList["EssentialEvents"]
                }
                "Software Management: Windows Store and App Catalog" {
                    $eventLogs += $eventLogList["EssentialEvents"]
                    $eventLogs += $eventLogList["WindowsStoreEvents"]
                }
                "Device Policies and Patching" {
                    $files += $fileList["Policies"]
                    $eventLogs += $eventLogList["EssentialEvents"]
                    $eventLogs += $eventLogList["PatchingEvents"]

                    # Getting RSOP Output
                    $rsopOutputPath = Join-Path $tempDir "RSOP.html"
                    gpresult /SCOPE COMPUTER /H "$rsopOutputPath" /F > $null 2>&1
                    if ($LASTEXITCODE -eq 0) {
                        $copyLog += "SUCCESS: Generated RSOP report to RSOP.html"
                    } else {
                        $copyLog += "FAILED: Generating RSOP report - gpresult exit code $LASTEXITCODE"
                    }

                    $patchDir = Join-Path $tempDir "Patching"
                    New-Item -ItemType Directory -Path $patchDir -Force > $null

                    # Getting Windows servicing and update logs
                    $patchFiles = @()
                    foreach ($pattern in $fileList["PatchingLogs"]) {
                        $matchedFiles = Get-ChildItem -Path $pattern -File -ErrorAction SilentlyContinue
                        if ($matchedFiles) {
                            $patchFiles += $matchedFiles
                        } else {
                            $copyLog += "FAILED: $pattern - File does not exist"
                        }
                    }
                    foreach ($file in $patchFiles) {
                        try {
                            $parentFolder = Split-Path $file.DirectoryName -Leaf
                            $destName = Join-Path $patchDir "$parentFolder-$($file.Name)"
                            Copy-LogFile -Path $file.FullName -Destination $destName
                            $copyLog += "SUCCESS: $($file.FullName) -> $destName"
                        } catch {
                            $copyLog += "FAILED: $($file.FullName) - $($_.Exception.Message)"
                        }
                    }

                    # Getting WindowsUpdate.log
                    if (Get-Command Get-WindowsUpdateLog -ErrorAction SilentlyContinue) {
                        try {
                            Write-Host "Generating WindowsUpdate.log (this can take a few minutes)..."
                            Get-WindowsUpdateLog -LogPath "$patchDir\WindowsUpdate.log" -ErrorAction Stop *> $null
                            $copyLog += "SUCCESS: Generated WindowsUpdate.log"
                        } catch {
                            $copyLog += "FAILED: Generating WindowsUpdate.log - $($_.Exception.Message)"
                        }
                    }

                    # Getting Windows Update history
                    try {
                        $updateSearcher = (New-Object -ComObject Microsoft.Update.Session).CreateUpdateSearcher()
                        $historyCount = $updateSearcher.GetTotalHistoryCount()
                        if ($historyCount -gt 0) {
                            $updateSearcher.QueryHistory(0, $historyCount) | ForEach-Object {
                                [PSCustomObject]@{
                                    # Windows Update history dates are UTC; convert to local time to match the other logs
                                    Date      = if ($_.Date) { [DateTime]::SpecifyKind($_.Date, 'Utc').ToLocalTime() } else { $null }
                                    Operation = switch ($_.Operation) { 1 { "Install" } 2 { "Uninstall" } default { "Other" } }
                                    Result    = switch ($_.ResultCode) { 0 { "NotStarted" } 1 { "InProgress" } 2 { "Succeeded" } 3 { "SucceededWithErrors" } 4 { "Failed" } 5 { "Aborted" } default { $_ } }
                                    HResult   = '0x{0:X8}' -f $_.HResult
                                    KB        = if ($_.Title -match "KB\d+") { $Matches[0] } else { "" }
                                    Title     = $_.Title
                                }
                            } | Sort-Object Date -Descending | Format-Table -AutoSize | Out-String -Width 4096 | Out-File -FilePath "$patchDir\UpdateHistory.txt"
                        } else {
                            "No Windows Update history found." | Out-File -FilePath "$patchDir\UpdateHistory.txt"
                        }
                        $copyLog += "SUCCESS: Gathered Windows Update history to UpdateHistory.txt"
                    } catch {
                        $copyLog += "FAILED: Gathering Windows Update history - $($_.Exception.Message)"
                    }

                    # Getting installed hotfixes
                    try {
                        Get-HotFix -ErrorAction Stop | Sort-Object InstalledOn -Descending |
                            Format-Table HotFixID, Description, InstalledOn, InstalledBy -AutoSize |
                            Out-String -Width 4096 | Out-File -FilePath "$patchDir\InstalledHotfixes.txt"
                        $copyLog += "SUCCESS: Gathered installed hotfixes to InstalledHotfixes.txt"
                    } catch {
                        $copyLog += "FAILED: Gathering installed hotfixes - $($_.Exception.Message)"
                    }

                    # Getting Windows Update policy registry keys
                    $updateRegKeys = @{
                        "WindowsUpdatePolicies.reg"   = "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
                        "MDMUpdatePolicies.reg"       = "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Update"
                        "WindowsUpdateUXSettings.reg" = "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"
                    }
                    foreach ($regFile in $updateRegKeys.Keys) {
                        $regKey = $updateRegKeys[$regFile]
                        if (Test-Path "Registry::$regKey") {
                            reg export $regKey "$patchDir\$regFile" /y > $null
                            if ($LASTEXITCODE -eq 0) {
                                $copyLog += "SUCCESS: Exported $regKey to $regFile"
                            } else {
                                $copyLog += "FAILED: Exporting $regKey - reg exit code $LASTEXITCODE"
                            }
                        } else {
                            $copyLog += "FAILED: $regKey - Registry key does not exist"
                        }
                    }

                    # Getting pending reboot and update service status
                    try {
                        $pendingReboot = [PSCustomObject]@{
                            CBSRebootPending            = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending"
                            WindowsUpdateRebootRequired = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"
                            PendingFileRenameOperations = [bool](Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -ErrorAction SilentlyContinue)
                        }
                        $updateServices = Get-Service -Name wuauserv, UsoSvc, BITS, DoSvc, CryptSvc, TrustedInstaller -ErrorAction SilentlyContinue |
                            Select-Object Name, DisplayName, Status, StartType

                        $patchStatusContent = "Pending Reboot Status" + "`r`n"
                        $patchStatusContent += $pendingReboot | Format-List | Out-String -Width 4096
                        $patchStatusContent += "Update Services" + "`r`n"
                        $patchStatusContent += $updateServices | Format-Table -AutoSize | Out-String -Width 4096

                        $patchStatusContent | Out-File -FilePath "$patchDir\PatchingStatus.txt"
                        $copyLog += "SUCCESS: Gathered pending reboot and update service status to PatchingStatus.txt"
                    } catch {
                        $copyLog += "FAILED: Gathering patching status - $($_.Exception.Message)"
                    }

                    # Getting Chrome and Edge policies
                    $browserDir = Join-Path $tempDir "BrowserPolicies"
                    New-Item -ItemType Directory -Path $browserDir -Force > $null
                    $browserPolicyKeys = [ordered]@{
                        "Chrome"       = "SOFTWARE\Policies\Google\Chrome"
                        "ChromeUpdate" = "SOFTWARE\Policies\Google\Update"
                        "Edge"         = "SOFTWARE\Policies\Microsoft\Edge"
                        "EdgeUpdate"   = "SOFTWARE\Policies\Microsoft\EdgeUpdate"
                    }
                    $browserPolicies = @()

                    # Export browser policies from a registry hive
                    $exportBrowserPolicies = {
                        param ($scope, $hiveRoot, $keyNames)
                        foreach ($keyName in $keyNames) {
                            $regPath = "$hiveRoot\$($browserPolicyKeys[$keyName])"
                            if (-not (Test-Path "Registry::$regPath")) { continue }
                            $regFile = Join-Path $browserDir "$scope-$keyName.reg"
                            reg export $regPath $regFile /y > $null
                            if ($LASTEXITCODE -eq 0) {
                                $copyLog += "SUCCESS: Exported $regPath to $regFile"
                            } else {
                                $copyLog += "FAILED: Exporting $regPath - reg exit code $LASTEXITCODE"
                            }
                            $browserPolicies += Get-RegistryPolicyValues -RegPath $regPath | ForEach-Object {
                                [PSCustomObject]@{ Browser = $keyName; Scope = $scope; Policy = $_.Policy; Value = $_.Value }
                            }
                        }
                    }

                    # Getting device policies
                    . $exportBrowserPolicies "Device" "HKEY_LOCAL_MACHINE" $browserPolicyKeys.Keys

                    # Getting per-user policies, loading hives for signed-out users
                    $profileKeys = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" -ErrorAction SilentlyContinue |
                        Where-Object { $_.PSChildName -match "^S-1-5-21-|^S-1-12-1-" }
                    foreach ($profileKey in $profileKeys) {
                        $sid = $profileKey.PSChildName
                        $profilePath = (Get-ItemProperty -Path $profileKey.PSPath -ErrorAction SilentlyContinue).ProfileImagePath
                        try {
                            $userName = (New-Object System.Security.Principal.SecurityIdentifier($sid)).Translate([System.Security.Principal.NTAccount]).Value
                        } catch {
                            $userName = Split-Path $profilePath -Leaf
                        }
                        $scope = $userName -replace '[\\/:*?"<>|]', '_'

                        if (Test-Path "Registry::HKEY_USERS\$sid") {
                            . $exportBrowserPolicies $scope "HKEY_USERS\$sid" @("Chrome", "Edge")
                        } else {
                            $ntUserDat = Join-Path $profilePath "NTUSER.DAT"
                            if (-not (Test-Path $ntUserDat)) {
                                $copyLog += "FAILED: Browser policies for $userName - NTUSER.DAT not found"
                                continue
                            }
                            $tempHive = "JC_LogCollection_$($sid -replace '-', '_')"
                            reg load "HKU\$tempHive" $ntUserDat > $null 2>&1
                            if ($LASTEXITCODE -ne 0) {
                                $copyLog += "FAILED: Browser policies for $userName - Could not load NTUSER.DAT (reg exit code $LASTEXITCODE)"
                                continue
                            }
                            try {
                                . $exportBrowserPolicies $scope "HKEY_USERS\$tempHive" @("Chrome", "Edge")
                            } finally {
                                # Release registry handles before unloading the hive
                                [GC]::Collect()
                                [GC]::WaitForPendingFinalizers()
                                reg unload "HKU\$tempHive" > $null 2>&1
                                if ($LASTEXITCODE -ne 0) {
                                    $copyLog += "WARNING: Could not unload temporary hive HKU\$tempHive for $userName (it will unload at next reboot)"
                                }
                            }
                        }
                    }

                    # Getting browser versions and policy summary
                    try {
                        $browserExes = @(
                            @{ Browser = "Chrome"; Path = "$env:ProgramFiles\Google\Chrome\Application\chrome.exe" },
                            @{ Browser = "Chrome"; Path = "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe" },
                            @{ Browser = "Edge"; Path = "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe" },
                            @{ Browser = "Edge"; Path = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe" }
                        )
                        $browserVersions = foreach ($exe in $browserExes) {
                            if (Test-Path $exe.Path) {
                                [PSCustomObject]@{ Browser = $exe.Browser; Version = (Get-Item $exe.Path).VersionInfo.ProductVersion; Path = $exe.Path }
                            }
                        }

                        $browserSummary = "Installed Browsers" + "`r`n"
                        $browserSummary += if ($browserVersions) { $browserVersions | Format-Table -AutoSize | Out-String -Width 4096 } else { "Chrome and Edge not found in Program Files.`r`n`r`n" }
                        $browserSummary += "Browser Policies" + "`r`n"
                        $browserSummary += if ($browserPolicies) { $browserPolicies | Format-Table -AutoSize -Wrap | Out-String -Width 4096 } else { "No Chrome or Edge policies found.`r`n" }

                        $browserSummary | Out-File -FilePath "$browserDir\BrowserPolicies.txt"
                        $copyLog += "SUCCESS: Gathered $(@($browserPolicies).Count) browser policy values to BrowserPolicies.txt"
                    } catch {
                        $copyLog += "FAILED: Gathering browser policy summary - $($_.Exception.Message)"
                    }
                }
                "Active Directory Integration Logs" {
                    $files += $fileList["ADLogs"]
                    $eventLogs += $eventLogList["EssentialEvents"]
                    $adRegKeys = @{
                        "ADIntegrationImportAgent.reg" = "HKEY_LOCAL_MACHINE\SOFTWARE\JumpCloud\AD Integration Import Agent"
                        "ADIntegrationSyncAgent.reg"   = "HKEY_LOCAL_MACHINE\SOFTWARE\JumpCloud\AD Integration Sync Agent"
                    }
                    foreach ($regFile in $adRegKeys.Keys) {
                        $regKey = $adRegKeys[$regFile]
                        if (Test-Path "Registry::$regKey") {
                            reg export $regKey "$tempDir\$regFile" /y > $null 2>&1
                            if ($LASTEXITCODE -eq 0) {
                                $copyLog += "SUCCESS: Exported $regKey to $regFile"
                            } else {
                                $copyLog += "FAILED: Exporting $regKey - reg exit code $LASTEXITCODE"
                            }
                        } else {
                            $copyLog += "FAILED: $regKey - Registry key does not exist"
                        }
                    }
                    if (Get-Module -ListAvailable ActiveDirectory) {
                        try {
                            Import-Module ActiveDirectory -ErrorAction Stop
                            $distinguishedName = (Get-ADDomain -ErrorAction Stop).DistinguishedName
                            $distinguishedName | Out-File -FilePath (Join-Path $tempDir "AD_DistinguishedName.txt")
                            $copyLog += "SUCCESS: Gathered AD domain distinguished name to AD_DistinguishedName.txt"
                        } catch {
                            $copyLog += "FAILED: Getting AD domain distinguished name - $($_.Exception.Message)"
                        }
                    } else {
                        $copyLog += "FAILED: Getting AD domain distinguished name - ActiveDirectory module not installed"
                    }
                }
            }
        }

        # Remove duplicate files and event logs
        $files = @($files | Sort-Object -Unique)
        $eventLogs = @($eventLogs | Sort-Object -Unique)

        # Copy the Files in $files list
        foreach ($pattern in $files) {
            $matchedFiles = Get-ChildItem -Path $pattern -File -ErrorAction SilentlyContinue
            if (-not $matchedFiles) {
                $copyLog += "FAILED: $pattern - File does not exist"
            }
            foreach ($file in $matchedFiles) {
                try {
                    $destName = Join-Path $tempDir $file.Name
                    Copy-LogFile -Path $file.FullName -Destination $destName
                    $copyLog += "SUCCESS: $($file.FullName)"
                } catch {
                    $copyLog += "FAILED: $($file.FullName) - $($_.Exception.Message)"
                }
            }
        }

        # Export Event Logs
        foreach ($log in $eventLogs) {
            $evtFile = Join-Path $tempDir "$($log -replace '/', '-').evtx"
            if (Test-Path -Path $evtFile) { Remove-Item -Path $evtFile -Force }
            try {
                wevtutil epl $log $evtFile 2>$null
                if ($LASTEXITCODE -eq 0) {
                    $copyLog += "SUCCESS EventLog: $log"
                } else {
                    $copyLog += "FAILED EventLog: $log - wevtutil exit code $LASTEXITCODE (log may not exist on this OS version)"
                }
            } catch { $copyLog += "FAILED EventLog: $log - $($_.Exception.Message)" }
        }
    }

    end {
        $hostname = $env:COMPUTERNAME
        $zipFileName = "${hostname}_Jumpcloud_Agent_Logs.zip"
        $zipFilePath = Join-Path "C:\Windows\Temp" $zipFileName

        # Check free disk space
        try {
            $gatheredBytes = (Get-ChildItem -Path $tempDir -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            $zipDrive = Get-PSDrive -Name (Split-Path $zipFilePath -Qualifier).TrimEnd(':')
            $sizeMessage = "Gathered logs: {0:N2} GB; free space on {1}: {2:N2} GB" -f ($gatheredBytes / 1GB), $zipDrive.Root, ($zipDrive.Free / 1GB)
            Write-Host $sizeMessage
            $copyLog += "INFO: $sizeMessage"
            if ($zipDrive.Free -lt $gatheredBytes) {
                Write-Warning "Free disk space may be insufficient to create the zip file."
                $copyLog += "WARNING: Free disk space may be insufficient to create the zip file"
            }
        } catch {
            $copyLog += "FAILED: Checking free disk space - $($_.Exception.Message)"
        }

        # Write copy results
        $logFilePath = Join-Path $tempDir "CopiedFiles.log"
        $copyLog | Out-File -FilePath $logFilePath -ErrorAction SilentlyContinue

        # Zip using .NET ZipFile to support files over 2 GB
        if (Test-Path $zipFilePath) { Remove-Item -Path $zipFilePath -Recurse -Force }
        Write-Host "Compressing logs (this can take a while for large logs)..."
        try {
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            [System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $zipFilePath, [System.IO.Compression.CompressionLevel]::Optimal, $false)
        } catch {
            Write-Warning "Failed to create zip file: $($_.Exception.Message)"
            Write-Warning "Gathered logs have been left in $tempDir"
            exit 1
        }

        Write-Host "Logs have been gathered and compressed into $zipFilePath"
        # Open Explorer when not automated
        if (-not $automate) {
            Start-Process "explorer.exe" -ArgumentList "/select,`"$zipFilepath`""
        }

        Remove-Item -Path $tempDir -Recurse -Force
    }
}

# if automate is selected, do not prompt, set all logs
if ($automate) {
    Gather-Logs -All
} else {
    $sections = @(
        "All Logs (No Active Directory)",
        "JumpCloud Agent Logs",
        "Remote Assist logs",
        "Password Manager Logs",
        "MDM Enrollment, CSP Policies, and Hosted Software Management",
        "Bitlocker",
        "Software Management: Chocolatey",
        "Software Management: Windows Store and App Catalog",
        "Device Policies and Patching",
        "Active Directory Integration Logs"
    )

    $selectionPrompt = "Please select the sections to gather logs from:`n"
    for ($i = 0; $i -lt $sections.Count; $i++) {
        $selectionPrompt += "$($i + 1). $($sections[$i])`n"
    }
    $selectionPrompt += "Enter your selection (e.g., 1, 3, 5-7): "

    $userSelection = Read-Host -Prompt $selectionPrompt

    # Parse selection, including ranges
    $selectedIndexes = @()
    foreach ($entry in ($userSelection -split ",")) {
        $entry = $entry.Trim()
        if ($entry -match "^(\d+)\s*-\s*(\d+)$") {
            $start = [int]$Matches[1]
            $end = [int]$Matches[2]
            if ($start -gt $end) { $start, $end = $end, $start }
            $selectedIndexes += ($start..$end | ForEach-Object { $_ - 1 })
        } elseif ($entry -match "^\d+$") {
            $selectedIndexes += [int]$entry - 1
        }
    }
    $selectedIndexes = @($selectedIndexes | Where-Object { $_ -ge 0 -and $_ -lt $sections.Count } | Select-Object -Unique)

    if ($selectedIndexes.Count -eq 0) {
        Write-Warning "No valid selections entered. Exiting..."
        exit 1
    }

    if ($selectedIndexes -contains 0) {
        Gather-Logs -All
    } else {
        $selectedSections = $selectedIndexes | ForEach-Object { $sections[$_] }
        Gather-Logs -selections $selectedSections
    }
}