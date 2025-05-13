#### Edit to output verbose messages ####
# Set $Script:AdminDebug to $true to enable verbose logging
$Script:AdminDebug = $false
#### End Edit ####

Function Get-WindowsDrive {
    $drive = (Get-WmiObject Win32_OperatingSystem).SystemDrive
    return $drive
}
Function Write-ToLog {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][ValidateNotNullOrEmpty()][Alias("LogContent")][string]$Message
        , [Parameter(Mandatory = $false)][Alias('LogPath')][string]$Path = "$(Get-WindowsDrive)\Windows\Temp\jcMDMCleanup.log"
        , [Parameter(Mandatory = $false)][ValidateSet("Error", "Warn", "Info", "Verbose")][string]$Level = "Info"
        # Log all messages if $VerbosePreference is set to
    )
    Begin {
        # Set VerbosePreference to Continue so that verbose messages are displayed.
        $VerbosePreference = 'Continue'
    }
    Process {
        # If attempting to write to a log file in a folder/path that doesn't exist create the file including the path.
        If (!(Test-Path $Path)) {
            Write-Verbose "Creating $Path."
            New-Item $Path -Force -ItemType File | Out-Null
        }
        # Format Date for our Log File
        $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        # Write message to error, warning, or verbose pipeline and specify $LevelText
        if ($Script:AdminDebug) {
            Switch ($Level) {
                'Error' {
                    Write-Error $Message
                    $LevelText = 'ERROR:'
                }
                'Warn' {
                    Write-Warning $Message
                    $LevelText = 'WARNING:'
                }
                'Info' {
                    Write-Verbose $Message
                    $LevelText = 'INFO:'
                }
                'Verbose' {
                    Write-Verbose $Message
                    $LevelText = 'INFO:'
                }
            }
        } else {
            Switch ($Level) {
                'Error' {
                    Write-Error $Message
                    $LevelText = 'ERROR:'
                }
                'Warn' {
                    $LevelText = 'WARNING:'
                }
                'Info' {
                    $LevelText = 'INFO:'
                }
                'Verbose' {
                    Write-Verbose $Message
                    $LevelText = 'INFO:'
                }
            }
        }
        # Write log entry to $Path
        Add-Content -Value "$FormattedDate $LevelText $Message" -Path $Path -Encoding utf8
    }
    End {

    }
}
function Get-MdmEnrollmentInfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$MdmEnrollmentKey = 'HKLM:\SOFTWARE\Microsoft\Enrollments\'
    )

    Write-ToLog "Checking for MDM Enrollment Key at: $MdmEnrollmentKey"
    if (!(Test-Path $MdmEnrollmentKey)) {
        Write-ToLog "MDM enrollment key: '$MdmEnrollmentKey' not found." -Level Warn
        return # Exit the function if the base key doesn't exist
    }

    $enrollmentGuids = Get-ChildItem $MdmEnrollmentKey -ErrorAction SilentlyContinue
    if (!$enrollmentGuids) {
        Write-ToLog "MDM enrollment key exists at '$MdmEnrollmentKey', but no specific enrollment GUIDs (subkeys) were found under it."
        return # Exit if no subkeys
    }

    Write-ToLog "MDM Enrollment Keys Found. Checking for ProviderID and UPN..."
    $foundDetails = $false

    foreach ($guidItem in $enrollmentGuids) {
        if ($guidItem.PSChildName -match '^[A-Fa-f0-9]{8}-([A-Fa-f0-9]{4}-){3}[A-Fa-f0-9]{12}$') {
            $enrollmentPropertiesPath = $guidItem.PSPath
            $providerID = (Get-ItemProperty -Path $enrollmentPropertiesPath -Name 'ProviderID' -ErrorAction SilentlyContinue).ProviderID
            $upn = (Get-ItemProperty -Path $enrollmentPropertiesPath -Name 'UPN' -ErrorAction SilentlyContinue).UPN

            if ($providerID -and $upn) {
                Write-ToLog "Found ProviderID '$providerID' and UPN '$upn' for enrollment $($guidItem.PSChildName)."
                # Output the object
                [PSCustomObject]@{
                    EnrollmentGUID = $guidItem.PSChildName
                    ProviderID     = $providerID
                    UPN            = $upn
                }
                $foundDetails = $true
            }
        } else {
            Write-ToLog "Skipping non-GUID subkey: $($guidItem.PSChildName)"
        }
    }

    if (-not $foundDetails) {
        Write-ToLog "No enrollments found with both ProviderID and UPN under '$MdmEnrollmentKey'."
        return $null
    }
}

try {
    Write-ToLog "Script execution started: $(Get-Date)" -Level Verbose
    Write-ToLog "Logging to: C:\Windows\Temp\jcMDMCleanup.log" -Level Verbose
    Write-ToLog "-----------------------------------------" -Level Verbose

    ###Initialize an array to store Enrollment IDs###
    $valueName = "ProviderID"
    $EnrollIDs = @()
    $mdmEnrollmentKey = "HKLM:\SOFTWARE\Microsoft\Enrollments" # Define the key path

    ###Check if the registry path exists###
    if (-not (Test-Path -Path $mdmEnrollmentKey)) {
        Write-ToLog "Registry path 'HKLM:\SOFTWARE\Microsoft\Enrollments\' does not exist. Exiting." -Level Error
        exit 1 # Exit if the base key isn't there
    }

    $mdmInfo = Get-MdmEnrollmentInfo | Format-Table -AutoSize
    if ($mdmInfo) {
        Write-ToLog "MDM Enrollment Information: $($mdmInfo | Out-String)" -Level Verbose
    }
    $entraStatus = dsregcmd /Status
    # Get deviceId
    $deviceId = $entraStatus | Select-String -Pattern "DeviceId" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }

    Write-ToLog "DeviceId: $deviceId" -Level Verbose

    # PowerShell script snippet to check for UPN and ProviderID in MDM enrollments
    # Get MDM Details


    ###Get enrollment IDs and perform cleanup###
    Write-ToLog "####### Cleaning up MDM Enrollment in the Registry #######" -Level Verbose
    # Process only direct children that look like GUIDs
    Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Enrollments\" -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
        $currentItemPath = $_.PsPath
        $EnrollID = $_.PSChildName # Get the GUID directly

        ###Check if the registry key has the ProviderID property###
        if ($item = Get-ItemProperty -LiteralPath $currentItemPath -Name $valueName -ErrorAction SilentlyContinue) {

            # Output the UPN and ProviderID if they exist
            $providerIdValue = Get-ItemProperty -LiteralPath $currentItemPath -Name "ProviderID" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty ProviderID -ErrorAction SilentlyContinue
            $upnValue = Get-ItemProperty -LiteralPath $currentItemPath -Name "UPN" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty UPN -ErrorAction SilentlyContinue

            if ($providerIdValue) {
                Write-ToLog "ProviderID: $providerIdValue"
            } else {
                Write-ToLog "ProviderID not found for $EnrollID"
            }
            if ($upnValue) {
                Write-ToLog "UPN: $upnValue"
                Write-ToLog "UPN not found for $EnrollID"
            }

            ###Add the enrollment ID to the array###
            $EnrollIDs += $EnrollID

            ###Output the enrollment ID for each iteration###
            Write-ToLog "Processing Enrollment ID: $EnrollID"

            ###Removing Associated Scheduled Tasks###
            if ($EnrollID -match '\w{8}-\w{4}-\w{4}-\w{4}-\w{12}') {
                Write-ToLog "Found EnrollID - $EnrollID"
            } else {
                Write-ToLog "Error parsing EnrollID. Stopping"
                Break
            }

            Write-ToLog "Looking for scheduled tasks associated with $EnrollID"
            $Tasks = Get-ScheduledTask | Where-Object { $psitem.TaskPath -like "\Microsoft\Windows\EnterpriseMgmt\*" }
            if ($Tasks) {
                Write-ToLog "Removing scheduled tasks for $EnrollID"
                Try {
                    $Tasks | ForEach-Object {
                        $taskName = $_.TaskName
                        Write-ToLog "Removing task: $taskName"
                        Unregister-ScheduledTask -InputObject $psitem -Confirm:$false -ErrorAction Stop # Add -ErrorAction Stop
                    }
                    Write-ToLog "Successfully removed scheduled tasks for $EnrollID."
                } catch {
                    Write-ToLog "Error removing task: $($taskName) associated with $EnrollID. Error: $($_.Exception.Message)" -Level Error
                }
                Write-ToLog "Trying to remove tasks folder for $EnrollID"
                $TaskFolder = Test-Path "C:\windows\System32\Tasks\Microsoft\Windows\EnterpriseMgmt\$EnrollID"
                try {
                    if ($TaskFolder) {
                        Remove-Item -Path "C:\windows\System32\Tasks\Microsoft\Windows\EnterpriseMgmt\$EnrollID" -Force
                    }
                } catch {
                    Write-ToLog "Error removing task folder: $($TaskFolder) associated with $EnrollID. Error: $($_.Exception.Message)" -Level Error
                    Throw $_.Exception.Message
                }
            } else {
                Write-ToLog "No scheduled tasks found for $EnrollID."
            }

            ### Removing Associated Reg Keys ###
            Write-ToLog "Removing Enrollment registry keys associated with $EnrollID" -Level Verbose
            ### Removing Associated Reg Keys ###
            $EnrollmentReg = Test-Path -Path HKLM:\SOFTWARE\Microsoft\Enrollments\Status\$EnrollID
            if ($EnrollmentReg) {
                Remove-Item -Path HKLM:\SOFTWARE\Microsoft\Enrollments\Status\$EnrollID -Recurse -Force
            }
            $EnrollmentReg = Test-Path -Path HKLM:\SOFTWARE\Microsoft\EnterpriseResourceManager\Tracked\$EnrollID
            if ($EnrollmentReg) {
                Remove-Item -Path HKLM:\SOFTWARE\Microsoft\EnterpriseResourceManager\Tracked\$EnrollID -Recurse -Force
            }
            $EnrollmentReg = Test-Path -Path HKLM:\SOFTWARE\Microsoft\PolicyManager\AdmxInstalled\$EnrollID
            if ($EnrollmentReg) {
                Remove-Item -Path HKLM:\SOFTWARE\Microsoft\PolicyManager\AdmxInstalled\$EnrollID -Recurse -Force
            }
            $EnrollmentReg = Test-Path -Path HKLM:\SOFTWARE\Microsoft\PolicyManager\Providers\$EnrollID
            if ($EnrollmentReg) {
                Remove-Item -Path HKLM:\SOFTWARE\Microsoft\PolicyManager\Providers\$EnrollID -Recurse -Force
            }
            $EnrollmentReg = Test-Path -Path HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\$EnrollID
            if ($EnrollmentReg) {
                Remove-Item -Path HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\$EnrollID -Recurse -Force
            }
            $EnrollmentReg = Test-Path -Path HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Logger\$EnrollID
            if ($EnrollmentReg) {
                Remove-Item -Path HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Logger\$EnrollID -Recurse -Force
            }
            $EnrollmentReg = Test-Path -Path HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Sessions\$EnrollID
            if ($EnrollmentReg) {
                Remove-Item -Path HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Sessions\$EnrollID -Recurse -Force
            }
            $EnrollmentReg = Test-Path -Path HKLM:\SOFTWARE\Microsoft\Enrollments\$EnrollID
            if ($EnrollmentReg) {
                Remove-Item -Path HKLM:\SOFTWARE\Microsoft\Enrollments\$EnrollID -Recurse -Force
            }
            Write-ToLog "Finished removing registry keys for the Enrollment ID $EnrollID" -Level Verbose
            Write-ToLog "-----------------------------------------" -Level Verbose
        }
    } # End ForEach-Object (looping through enrollment GUIDs)

    ###List Removed Enrollment GUIDs###
    if ($EnrollIDs.Count -gt 0) {
        Write-ToLog "Attempted cleanup for the following MDM GUIDs: $($EnrollIDs -join ', ')"
    } else {
        Write-ToLog "No MDM Enrollments with a 'ProviderID' property were found to process."
    }

    # Validate that no MDM enrollment keys remain
    $mdmEnrollmentDetails = Get-MdmEnrollmentInfo
    if ($mdmEnrollmentDetails) {
        Write-ToLog "MDM enrollment keys still exist after cleanup. Please check the log for details." -Level Verbose
    } else {
        Write-ToLog "####### No MDM enrollment keys found after cleanup. Cleanup was successful! ######" -Level Verbose
    }
    Write-ToLog "-----------------------------------------" -Level Verbose
    Write-ToLog "Script execution finished: $(Get-Date)" -Level Verbose
} # End try block
catch {
    # Log any terminating errors that occurred in the main try block
    Write-ToLog "A terminating error occurred: $($_.Exception.Message)" -Level Error
    Write-ToLog "Error Details: $($_.ToString())" -Level Error
    Write-ToLog "Script execution failed: $(Get-Date)" -Level Error
    Write-ToLog "-----------------------------------------" -Level Error
}