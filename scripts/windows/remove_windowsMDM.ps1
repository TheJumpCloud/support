<#
  =============================================================================
  MDM Cleanup Tool

  What this script does:
  It locates broken/partial MDM enrollments and removes the leftover pieces.

  The logic:
  1. Check Task Scheduler first for GUIDs. (Stuck devices usually have tasks left behind).
  2. Scrape the Registry for known Enrollment IDs.
  3. Perform a targeted cleanup of the IDs we found.
  4. ForcePrune: Go to specific registry locations and remove an orphaned GUIDs
  =============================================================================
#>

#### Edit to output verbose messages ####
# Flip this to $true if you want to see everything happening in the console window.
$Script:AdminDebug = $false
#### End Edit ####

# Just grabbing the system drive (usually C:) so we aren't hardcoding paths.
function Get-WindowsDrive {
    $drive = (Get-WmiObject Win32_OperatingSystem).SystemDrive
    return $drive
}

# Standard logging wrapper.
function Write-ToLog {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][ValidateNotNullOrEmpty()][Alias("LogContent")][string]$Message
        , [Parameter(Mandatory = $false)][Alias('LogPath')][string]$Path = "$(Get-WindowsDrive)\Windows\Temp\jcMDMCleanup.log"
        , [Parameter(Mandatory = $false)][ValidateSet("Error", "Warn", "Info", "Verbose")][string]$Level = "Info"
    )
    begin {
        $VerbosePreference = 'Continue'
    }
    process {
        # Make sure the log file actually exists before we write to it
        if (!(Test-Path $Path)) {
            Write-Verbose "Creating $Path."
            New-Item $Path -Force -ItemType File | Out-Null
        }
        $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

        # Decide how much information to output to the console
        if ($Script:AdminDebug) {
            switch ($Level) {
                'Error' { Write-Error $Message; $LevelText = 'ERROR:' }
                'Warn' { Write-Warning $Message; $LevelText = 'WARNING:' }
                'Info' { Write-Verbose $Message; $LevelText = 'INFO:' }
                'Verbose' { Write-Verbose $Message; $LevelText = 'INFO:' }
            }
        } else {
            # Quiet mode: only errors show up in console, but we still tag the log file correctly
            switch ($Level) {
                'Error' { Write-Error $Message; $LevelText = 'ERROR:' }
                'Warn' { $LevelText = 'WARNING:' }
                'Info' { $LevelText = 'INFO:' }
                'Verbose' { Write-Verbose $Message; $LevelText = 'INFO:' }
            }
        }
        # Dump the line into the text file
        Add-Content -Value "$FormattedDate $LevelText $Message" -Path $Path -Encoding utf8
    }
}

# This is our primary way to find the GUID.
# We look at the "EnterpriseMgmt" folder in Task Scheduler.
#startregion Get-MdmEnrollmentGuidFromTaskScheduler
function Get-MdmEnrollmentGuidFromTaskScheduler {
    [CmdletBinding()]
    param()

    Write-ToLog "Searching for MDM enrollment GUIDs in Task Scheduler folder: \Microsoft\Windows\EnterpriseMgmt\"
    $taskPathBase = "\Microsoft\Windows\EnterpriseMgmt\"
    # Looking for that standard GUID format (8-4-4-4-12 chars)
    $guidPattern = '([A-Fa-f0-9]{8}-([A-Fa-f0-9]{4}-){3}[A-Fa-f0-9]{12})'
    $foundGuids = @()

    try {
        $mdmTasks = Get-ScheduledTask -TaskPath "$taskPathBase*" -ErrorAction SilentlyContinue
        if (-not $mdmTasks) {
            Write-ToLog "No scheduled tasks found in the EnterpriseMgmt folder." -Level Info
            return $foundGuids
        }
        # Iterate through the tasks to pull the GUID out of the folder path
        $mdmTasks | ForEach-Object {
            $taskPath = $_.TaskPath
            if ($taskPath -match $guidPattern) {
                $guid = $Matches[1]
                if ($guid -notin $foundGuids) {
                    $foundGuids += $guid
                    Write-ToLog "Found GUID from scheduled task path: $guid" -Level Verbose
                }
            }
        }
    } catch {
        Write-ToLog "Error accessing Scheduled Tasks: $($_.Exception.Message)" -Level Error
    }
    return $foundGuids | Sort-Object -Unique
}
#endregion Get-MdmEnrollmentGuidFromTaskScheduler

# Helper to verify if our cleanup worked at the end.
#startregion Get-MdmEnrollmentInfo
function Get-MdmEnrollmentInfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$MdmEnrollmentKey = 'HKLM:\SOFTWARE\Microsoft\Enrollments\'
    )

    Write-ToLog "Checking for MDM Enrollment Key at: $MdmEnrollmentKey"
    if (!(Test-Path $MdmEnrollmentKey)) {
        Write-ToLog "MDM enrollment key: '$MdmEnrollmentKey' not found." -Level Warn
        return
    }

    $enrollmentGuids = Get-ChildItem $MdmEnrollmentKey -ErrorAction SilentlyContinue
    if (!$enrollmentGuids) {
        Write-ToLog "MDM enrollment key exists, but no specific enrollment GUIDs were found."
        return
    }

    $foundDetails = $false
    # We only care about subkeys that look like GUIDs and have actual data (ProviderID/UPN)
    foreach ($guidItem in $enrollmentGuids) {
        if ($guidItem.PSChildName -match '^[A-Fa-f0-9]{8}-([A-Fa-f0-9]{4}-){3}[A-Fa-f0-9]{12}$') {
            $enrollmentPropertiesPath = $guidItem.PSPath
            $providerID = (Get-ItemProperty -Path $enrollmentPropertiesPath -Name 'ProviderID' -ErrorAction SilentlyContinue).ProviderID
            $upn = (Get-ItemProperty -Path $enrollmentPropertiesPath -Name 'UPN' -ErrorAction SilentlyContinue).UPN

            if ($providerID -and $upn) {
                Write-ToLog "Found ProviderID '$providerID' and UPN '$upn' for enrollment $($guidItem.PSChildName)."
                [PSCustomObject]@{
                    EnrollmentGUID = $guidItem.PSChildName
                    ProviderID     = $providerID
                    UPN            = $upn
                }
                $foundDetails = $true
            }
        }
    }
    if (-not $foundDetails) {
        Write-ToLog "No enrollments found with both ProviderID and UPN under '$MdmEnrollmentKey'."
        return $null
    }
}
#endregion Get-MdmEnrollmentInfo

#startregion Remove-WindowsMDMProvider
function Remove-WindowsMDMProvider {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$EnrollmentGUID,
        [Parameter(Mandatory = $false)]
        [switch]$ForcePrune
    )
    begin {
        Write-ToLog "Script execution started: $(Get-Date)" -Level Verbose
        Write-ToLog "Logging to: C:\Windows\Temp\jcMDMCleanup.log" -Level Verbose
        Write-ToLog "-----------------------------------------" -Level Verbose

        $valueName = "ProviderID"
        $mdmEnrollmentKey = "HKLM:\SOFTWARE\Microsoft\Enrollments"
        $GuidsToProcess = @()

        if (-not (Test-Path -Path $mdmEnrollmentKey)) {
            Write-ToLog "Registry path 'HKLM:\SOFTWARE\Microsoft\Enrollments\' does not exist. Exiting." -Level Error
            exit 1
        }
    }
    process {
        try {
            if ($EnrollmentGUID) {
                $GuidsToProcess += $EnrollmentGUID
                Write-ToLog "Specific Enrollment GUID provided: $EnrollmentGUID. Proceeding with targeted cleanup." -Level Info
            } else {
                Write-ToLog "No specific Enrollment GUID provided. Proceeding with discovery." -Level Info
                # --- Phase 1: GUIDs Discovery ---
                Write-ToLog "####### Discovery Phase #######" -Level Verbose

                # Try Task Scheduler first.
                $taskSchedulerGuids = Get-MdmEnrollmentGuidFromTaskScheduler
                if ($taskSchedulerGuids.Count -gt 0) {
                    Write-ToLog "Using GUIDs discovered via Task Scheduler."
                    $GuidsToProcess = $taskSchedulerGuids
                } else {
                    # Fallback to Registry scan if no tasks exist.
                    Write-ToLog "No GUIDs found in Task Scheduler. Falling back to Registry discovery." -Level Warn
                    Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Enrollments\" -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
                        $EnrollID = $_.PSChildName
                        if ($EnrollID -match '^[A-Fa-f0-9]{8}-([A-Fa-f0-9]{4}-){3}[A-Fa-f0-9]{12}$') {
                            if (Get-ItemProperty -LiteralPath $_.PsPath -Name $valueName -ErrorAction SilentlyContinue) {
                                if ($EnrollID -notin $GuidsToProcess) {
                                    $GuidsToProcess += $EnrollID
                                }
                            }
                        }
                    }
                }
                if ($GuidsToProcess.Count -eq 0) {
                    if ($ForcePrune) {
                        Write-ToLog "No MDM Enrollment GUIDs found via Tasks or Registry. Moving to ForcePrune sweep." -Level Info
                    } else {
                        Write-ToLog "No MDM Enrollment GUIDs found via Tasks or Registry. Exiting." -Level Info
                        exit 0
                    }
                }
            }
            # --- Phase 2: Targeted Cleanup ---
            Write-ToLog "####### Targeted Cleanup Phase #######" -Level Verbose

            foreach ($EnrollID in $GuidsToProcess) {
                Write-ToLog "Processing Enrollment ID: $EnrollID"

                # Grab ProviderID for Cert cleanup later
                $regPath = "HKLM:\SOFTWARE\Microsoft\Enrollments\$EnrollID"
                $providerIdValue = $null
                if (Test-Path $regPath) {
                    $providerIdValue = Get-ItemProperty -LiteralPath $regPath -Name "ProviderID" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty ProviderID -ErrorAction SilentlyContinue
                    if ($providerIdValue) { Write-ToLog "ProviderID associated with this enrollment: $providerIdValue" }
                }

                # 1. Remove the Scheduled Tasks
                Write-ToLog "--- Step 1: Removing Scheduled Tasks ---"
                $Tasks = Get-ScheduledTask | Where-Object { $psitem.TaskPath -like "*$EnrollID*" -and $psitem.TaskPath -like "\Microsoft\Windows\EnterpriseMgmt\*" }
                if ($Tasks) {
                    try {
                        $Tasks | ForEach-Object {
                            $taskName = $_.TaskName
                            Write-ToLog "Removing task: $taskName"
                            Unregister-ScheduledTask -InputObject $psitem -Confirm:$false -ErrorAction Stop
                        }
                        Write-ToLog "Successfully removed scheduled tasks."
                    } catch {
                        Write-ToLog "Error removing task: $($taskName). Error: $($_.Exception.Message)" -Level Error
                    }
                } else {
                    Write-ToLog "No active scheduled tasks objects found."
                }

                # 2. Delete the Task Folder
                Write-ToLog "--- Step 2: Removing Task Folders ---"
                $TaskFolder = "C:\windows\System32\Tasks\Microsoft\Windows\EnterpriseMgmt\$EnrollID"
                try {
                    if (Test-Path $TaskFolder) {
                        Remove-Item -Path $TaskFolder -Force -Recurse
                        Write-ToLog "Removed Task Folder: $TaskFolder"
                    }
                } catch {
                    Write-ToLog "Error removing task folder. Error: $($_.Exception.Message)" -Level Error
                }

                # 3. Clean up the known Registry Keys
                Write-ToLog "--- Step 3: Removing Registry Keys ---"
                $keysToRemove = @(
                    "HKLM:\SOFTWARE\Microsoft\Enrollments\Status\$EnrollID",
                    "HKLM:\SOFTWARE\Microsoft\Enrollments\Context\$EnrollID",
                    "HKLM:\SOFTWARE\Microsoft\EnterpriseResourceManager\Tracked\$EnrollID",
                    "HKLM:\SOFTWARE\Microsoft\PolicyManager\AdmxInstalled\$EnrollID",
                    "HKLM:\SOFTWARE\Microsoft\PolicyManager\Providers\$EnrollID",
                    "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\$EnrollID",
                    "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Logger\$EnrollID",
                    "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Sessions\$EnrollID",
                    "HKLM:\SOFTWARE\Microsoft\Enrollments\$EnrollID"
                )

                foreach ($key in $keysToRemove) {
                    if (Test-Path -Path $key) {
                        try {
                            Remove-Item -Path $key -Recurse -Force -ErrorAction Stop
                            Write-ToLog "Removed key: $key"
                        } catch {
                            Write-ToLog "Failed to remove key: $key. Error: $($_.Exception.Message)" -Level Error
                        }
                    }
                }

                # 4. Remove WNS References
                Write-ToLog "--- Step 4: Removing Push Notification Keys ---"
                $pushKeyBase = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications\Applications\Windows.SystemToast.Background.Management"
                if (Test-Path $pushKeyBase) {
                    Get-ChildItem $pushKeyBase -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -eq $EnrollID } | ForEach-Object {
                        try {
                            Write-ToLog "Removing WNS Push Key: $($_.PSPath)"
                            Remove-Item -Path $_.PSPath -Recurse -Force -ErrorAction Stop
                        } catch {
                            Write-ToLog "Failed to remove WNS key. Error: $($_.Exception.Message)" -Level Warn
                        }
                    }
                }

                # 5. Delete Client Certificates
                Write-ToLog "--- Step 5: Checking for Client Certificates ---"
                if ($providerIdValue) {
                    try {
                        $certs = Get-ChildItem -Path Cert:\LocalMachine\My -Recurse | Where-Object { $_.Issuer -match $providerIdValue }
                        if ($certs) {
                            foreach ($cert in $certs) {
                                Write-ToLog "Removing Certificate associated with Provider $providerIdValue. Subject: $($cert.Subject)"
                                Remove-Item -Path $cert.PSPath -Force -ErrorAction Stop
                            }
                        } else {
                            Write-ToLog "No certificates found matching ProviderID: $providerIdValue"
                        }
                    } catch {
                        Write-ToLog "Error processing certificates: $($_.Exception.Message)" -Level Warn
                    }
                } else {
                    Write-ToLog "Skipping certificate removal (No ProviderID found to match against)."
                }

                Write-ToLog "Finished processing Enrollment ID $EnrollID" -Level Verbose
                Write-ToLog "-----------------------------------------" -Level Verbose

            } # End of the targeted loop

            Write-ToLog "--- Step 6: Set MmpcEnrollmentFlag Key ---"
            $MmpcEnrollmentFlagKeyBase = "HKLM:\SOFTWARE\Microsoft\Enrollments"
            if (Test-Path $MmpcEnrollmentFlagKeyBase) {
                $currentValue = Get-ItemProperty -Path $MmpcEnrollmentFlagKeyBase -Name "MmpcEnrollmentFlag" -ErrorAction SilentlyContinue
                if ($null -ne $currentValue) {
                    Write-ToLog "Current MmpcEnrollmentFlag is: $($currentValue.MmpcEnrollmentFlag)"
                    # 3. If the value is NOT 0, set it to 0
                    if ($currentValue.MmpcEnrollmentFlag -ne 0) {
                        Write-ToLog "Value is not 0. Resetting to 0..."
                        try {
                            Set-ItemProperty -Path $MmpcEnrollmentFlagKeyBase -Name "MmpcEnrollmentFlag" -Value 0 -Type DWord
                            Write-ToLog "Successfully set MmpcEnrollmentFlag to 0."
                        } catch {
                            Write-ToLog "Failed to set registry value. Ensure you are running as Administrator." -Level Error
                        }
                    } else {
                        Write-ToLog "MmpcEnrollmentFlag is already 0. No action needed."
                    }
                } else {
                    Write-ToLog "Value 'MmpcEnrollmentFlag' does not exist in $MmpcEnrollmentFlagKeyBase. Nothing to reset."
                }
            } else {
                Write-ToLog "Registry path $MmpcEnrollmentFlagKeyBase not found." -Level Warn
            }

            # --- Phase 3: Force Prune Sweep ---
            if ($ForcePrune) {
                # This checks specific registry locations for ANY orphaned keys with a GUID format.
                Write-ToLog "####### Phase 3: Force Prune - Generic GUID Sweep #######" -Level Verbose

                # 3. Sweep standard GUID keys
                $sweepLocations = @(
                    "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts",
                    "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Logger",
                    "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Sessions"
                )

                # Regex for standard GUID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
                $guidRegex = '^[0-9A-Fa-f]{8}-([0-9A-Fa-f]{4}-){3}[0-9A-Fa-f]{12}$'

                foreach ($parentPath in $sweepLocations) {
                    Write-ToLog "Sweeping path for orphaned GUIDs: $parentPath"
                    if (Test-Path $parentPath) {
                        # Get all subkeys
                        $subKeys = Get-ChildItem -Path $parentPath -ErrorAction SilentlyContinue

                        foreach ($key in $subKeys) {
                            # Check if the folder name is a GUID
                            if ($key.PSChildName -match $guidRegex) {
                                Write-ToLog "Found orphaned GUID key in sweep: $($key.PSChildName). Force removing."
                                try {
                                    Remove-Item -Path $key.PSPath -Recurse -Force -ErrorAction Stop
                                    Write-ToLog "Deleted: $($key.PSPath)"
                                } catch {
                                    if ($parentPath -match "TaskCache") {
                                        Write-ToLog "Skipped locked key in TaskCache: $($key.PSChildName) (Expected/Ignorable)" -Level Verbose
                                    } else {
                                        Write-ToLog "Failed to delete $($key.PSPath). Error: $($_.Exception.Message)" -Level Error
                                    }
                                }
                            }
                        }
                    } else {
                        Write-ToLog "Path not found (skipping): $parentPath" -Level Info
                    }
                }
            }
        } catch {
            Write-ToLog "A terminating error occurred: $($_.Exception.Message)" -Level Error
            Write-ToLog "Script execution failed: $(Get-Date)" -Level Error
        }
    }
    end {
        # --- Phase 4: Final Verification ---
        $mdmEnrollmentDetails = Get-MdmEnrollmentInfo
        if ($mdmEnrollmentDetails) {
            Write-ToLog "MDM enrollment keys still exist after cleanup. Please check the log for details." -Level Warn
        } else {
            Write-ToLog "####### No MDM enrollment keys found after cleanup. Cleanup was successful! ######" -Level Verbose
        }
        Write-ToLog "-----------------------------------------" -Level Verbose
        Write-ToLog "Script execution finished: $(Get-Date)" -Level Verbose
    }
}
#endregion Remove-WindowsMDMProvider

# ==========================================
# LET'S GET STARTED
# ==========================================
Remove-WindowsMDMProvider -ForcePrune