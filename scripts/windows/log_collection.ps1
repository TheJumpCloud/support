 ##################### Do Not Modify Below ######################
# set to $true if running via a JumpCloud command (recommended)
$automate = $false

################################################################

# Function to Check if the Script is Running as an Administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Administrator)) {
    Write-Warning "This script needs to be run as an administrator."
    exit
}

# Function to get PowerShell Version
function Check-PowerShellVersion {
    $requiredVersion = 5
    $currentVersion = $PSVersionTable.PSVersion.Major

    if ($currentVersion -lt $requiredVersion) {
        Write-Warning "This script requires PowerShell version 5.0 or higher. Current version: $currentVersion. Exiting..."
        exit
    } else {
        Write-Host "PowerShell version $currentVersion detected. Proceeding..."
    }
}

# Call the function to check the version
Check-PowerShellVersion



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
            "Device Policies",
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

        # Check if the Temp Directory Already Exists and Remove it if it Does
        if (Test-Path $tempDir) {
            Remove-Item -Path $tempDir -Recurse -Force
        }

        # Create the Temp Directory
        New-Item -ItemType Directory -Path $tempDir > $null

        # Gather Windows Version Information
        $winVersion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ProductName
        $winVersion += " - Version " + (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId
        $winVersionFile = Join-Path $tempDir "WinVersion.txt"
        $winVersion | Out-File -FilePath $winVersionFile -ErrorAction SilentlyContinue



        # List of Log Files and Event Logs to Gather
        $fileList = @{
            "AgentLogs"           = @(
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
                "C:\Program Files\JumpCloud\Plugins\Contrib\version.txt"
            )
            "RemoteAssistLogs"    = @(
                "C:\Windows\System32\config\systemprofile\AppData\Roaming\JumpCloud-Remote-Assist\logs\*.log",
                "C:\Windows\Temp\jc_raasvc.log"
            )

            "ChocolateyLogs"      = @(
                "C:\ProgramData\chocolatey\logs\choco.summary.log",
                "C:\ProgramData\chocolatey\logs\chocolatey.log",
                "C:\windows\temp\jcagent.log"
            )
            "ADLogs"              = @(
                "C:\Program Files\JumpCloud\AD Integration\JumpCloud AD Import\JumpCloud_AD_Import_Grpc*.log",
                "C:\Windows\Temp\JumpCloud_AD_Integration.log",
                "C:\Program Files\JumpCloud\AD Integration\JumpCloud AD Import\jcadimportagent.config.json",
                "C:\Program Files\JumpCloud\AD Integration\JumpCloud AD Sync\JumpCloud_AD_Sync.log",
                "C:\Program Files\JumpCloud\AD Integration\JumpCloud AD Sync\config.json"

            )
            "Policies"            = @(
                "C:\windows\temp\jcagent.log"
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
        }

        $files = @()
        $eventLogs = @()
        $nonExistentFiles = @()

        if ($PSCmdlet.ParameterSetName -eq 'SearchFilter') {
            $selectedSections = $selections
        } elseif ($PSCmdlet.ParameterSetName -eq 'All Logs') {
            # "Active Directory Logs" are not returned with "All Logs"
            $selectedSections = @("JumpCloud Agent Logs",
                "Remote Assist logs",
                "Password Manager Logs",
                "MDM Enrollment and Hosted Software Management",
                "Bitlocker",
                "Software Management: Chocolatey",
                "Software Management: Windows Store and App Catalog",
                "Device Policies")
        }
    }


    process {

        foreach ($logType in $selectedSections) {

            Write-Host "Getting $($logType)"
            switch ($logType) {
                "JumpCloud Agent Logs" {
                    $files += $fileList["AgentLogs"]
                    $eventLogs += $eventLogList["EssentialEvents"]
                    # Handle jc-user-agent.log and jcupdate.log
                    $allUsers = Get-LocalUser
                    foreach ($user in $allUsers) {
                        if ( Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$($user.SID)" -Name "ProfileImagePath" -ErrorAction SilentlyContinue) {
                            $profilePath = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$($user.SID)" -Name "ProfileImagePath"
                            $profileImagePath = $profilePath.ProfileImagePath
                        }

                        # Define paths to jc-user-agent.log and jcupdate.log
                        $jcUserAgentLog = "$profileImagePath\AppData\Local\Temp\jc-user-agent.log"
                        $jcUpdateLog = "$profileImagePath\AppData\Local\Temp\jcupdate.log"

                        # Check and copy jc-user-agent.log if it exists
                        if (Test-Path -Path $jcUserAgentLog) {
                            $destinationPath = "$tempDir\$($user.Name).jc-user-agent.log"
                            Copy-Item -Path $jcUserAgentLog -Destination $destinationPath -ErrorAction SilentlyContinue
                        }

                        # Check and copy jcupdate.log if it exists
                        if (Test-Path -Path $jcUpdateLog) {
                            $destinationPath = "$tempDir\$($user.Name).jcupdate.log"
                            Copy-Item -Path $jcUpdateLog -Destination $destinationPath -ErrorAction SilentlyContinue
                        }
                    }
                }
                "Remote Assist logs" {
                    $files += $fileList["RemoteAssistLogs"]
                }
                "Password Manager Logs" {
                    $allUsers = Get-LocalUser
                    foreach ($user in $allUsers) {
                        if ( Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$($user.SID)" -Name "ProfileImagePath" -ErrorAction SilentlyContinue) {
                            $profilePath = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$($user.SID)" -Name "ProfileImagePath"
                            $profileImagePath = $profilePath.ProfileImagePath
                        }

                        if (Test-Path -Path "$profileImagePath\AppData\Roaming\JumpCloud Password Manager\logs\logs-live.log") {
                            $passwordManagerLogPath = "$profileImagePath\AppData\Roaming\JumpCloud Password Manager\logs\logs-live.log"
                            $files += $passwordManagerLogPath
                        }
                        if (Test-Path -Path "$profileImagePath\AppData\Roaming\JumpCloud Password Manager\data\daemon\log\*.log") {
                            $passwordManagerLogPath = "$profileImagePath\AppData\Roaming\JumpCloud Password Manager\data\daemon\log\*.log"
                            $files += $passwordManagerLogPath
                            }
                    }
                }
                "MDM Enrollment and Hosted Software Management" {
                    $eventLogs += $eventLogList["EssentialEvents"]
                    $mdmDiagDir = Join-Path $tempDir "MDMDiag"
                    New-Item -ItemType Directory -Path $mdmDiagDir
                    $mdmDiagCmd = "mdmdiagnosticstool.exe -area 'DeviceEnrollment;DeviceProvisioning;Autopilot' -zip $mdmDiagDir\MDMDiag.zip"
                    Invoke-Expression $mdmDiagCmd
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
                "Device Policies" {
                    $files += $fileList["Policies"]

                    # Generate RSOP Output
                    $rsopOutputPath = Join-Path $tempDir "RSOP.html"
                    $rsopCmd = "gpresult /SCOPE COMPUTER /H $rsopOutputPath"
                    Invoke-Expression $rsopCmd
                }
                "Active Directory Integration Logs" {
                    $files += $fileList["ADLogs"]
                    $eventLogs += $eventLogList["EssentialEvents"]
                    # Export AD Integration Registry Keys
                    # test for import agent files
                    if ( Get-ItemProperty -Path "HKLM:\SOFTWARE\JumpCloud\AD Integration Import Agent" -ErrorAction SilentlyContinue ) {
                        reg export "HKEY_LOCAL_MACHINE\SOFTWARE\JumpCloud\AD Integration Import Agent" "$tempDir\ADIntegrationImportAgent.reg" /y
                    } else {
                        Write-Warning "No AD Import Agent Keys exist"
                    }
                    # test for sync agent files
                    if ( Get-ItemProperty -Path "HKLM:\SOFTWARE\Jumpcloud\AD Integration Sync Agent" -ErrorAction SilentlyContinue ) {
                        reg export "HKEY_LOCAL_MACHINE\SOFTWARE\JumpCloud\AD Integration Sync Agent" "$tempDir\ADIntegrationSyncAgent.reg" /y
                    } else {
                        Write-Warning "No AD Sync Agent Keys exist"
                    }
                    # Output DistinguishedName to a Text File
                    Import-Module ActiveDirectory
                    if (Get-Module -Name ActiveDirectory) {
                        $distinguishedName = (Get-ADDomain).DistinguishedName
                        $distinguishedName | Out-File -FilePath (Join-Path $tempDir "AD_DistinguishedName.txt")
                    } else {
                        Write-Warning "The Active Directory PowerShell Module was not installed"
                    }
                }
            }
        }

        # Check if the Zip File Already Exists and Remove it if it Does
        $zipFilePath = "C:\Windows\Temp\Jumpcloud_Agent_Logs.zip"
        if (Test-Path $zipFilePath) {
            Remove-Item $zipFilePath
        }

        # Copy the Files to the Temporary Directory if They Exist
        foreach ($file in $files) {
            if (Test-Path $file) {
                if ($file -match "logs-live") {

                    $pwmFile = $file | Select-String -Pattern "C:\\Users\\([\s\S]+)\\AppData"
                    $pwnFileUsername = $pwmFile.matches.groups[1].value
                    Copy-Item -Path $file -Destination "$tempDir/$pwnFileUsername-logs-live.txt" -ErrorAction SilentlyContinue
                } else {
                    Copy-Item -Path $file -Destination $tempDir -ErrorAction SilentlyContinue
                }
            } else {
                $nonExistentFiles += $file
            }
        }

        # Export Event Logs to Temporary Directory
        foreach ($log in $eventLogs) {
            $evtFile = Join-Path $tempDir "$($log -replace '/', '-').evtx"
            if (Test-Path -Path $evtFile) {
                Remove-Item -Path $evtFile -Force
            }
            try {
                wevtutil epl $log $evtFile
            } catch {
                Write-Host "Skipping $log event log: $_"
            }
        }
    }
    end {

        # Create a Log File of All Copied Files and include it in the ZIP
        $logFilePath = Join-Path $tempDir "CopiedFiles.log"
        $files | Out-File -FilePath $logFilePath -ErrorAction SilentlyContinue

        # Create the Zip File
        $hostname = $env:COMPUTERNAME
        $selectedSectionsString = $selectedSections -join "_"
        $zipFileName = "${hostname}_Jumpcloud_Agent_Logs.zip"
        $zipFilePath = Join-Path "C:\Windows\Temp" $zipFileName
        if (Test-Path $zipFilePath) {
            Remove-Item -Path $zipFilePath -Recurse -Force
        }
        Compress-Archive -Path $tempDir\* -DestinationPath $zipFilePath -Force

        Write-Host "Logs have been gathered and compressed into $zipFilePath"

        # Open the Folder Containing the Zip File
        Start-Process "explorer.exe" -ArgumentList "/select,`"$zipFilepath`""

        # Cleanup Temporary Directory
        Remove-Item -Path $tempDir -Recurse -Force
    }
}



# if automate is selected, do not prompt, set all logs
if ($automate) {
    Gather-Logs -All
} else {

    # Prompt the User to Select the Sections to Gather Logs From
    $sections = @(
        "All Logs (No Active Directory)",
        "JumpCloud Agent Logs",
        "Remote Assist logs",
        "Password Manager Logs",
        "MDM Enrollment, CSP Policies, and Hosted Software Management",
        "Bitlocker",
        "Software Management: Chocolatey",
        "Software Management: Windows Store and App Catalog",
        "Device Policies",
        "Active Directory Integration Logs"
    )

    $selectionPrompt = "Please select the sections to gather logs from:`n"
    for ($i = 0; $i -lt $sections.Count; $i++) {
        $selectionPrompt += "$($i + 1). $($sections[$i])`n"
    }
    $selectionPrompt += "Enter your selection (e.g., 1, 3, 5-7)"

    $input = Read-Host -Prompt $selectionPrompt
    $selectedIndexes = $input -split ",|-" | ForEach-Object { $_.Trim() } | Where-Object { $_ -match "^\d+$" } | ForEach-Object { [int]$_ - 1 }

    if ($selectedIndexes -contains 0) {
        Gather-Logs -All
    } else {
        $selectedSections = $selectedIndexes | ForEach-Object { $sections[$_] } -ErrorAction SilentlyContinue
        Gather-Logs -selections $selectedSections
    }
} 
