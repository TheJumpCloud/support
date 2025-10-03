<#
.DESCRIPTION
    This script identifies JumpCloud managed systems that can have a Primary User assigned.
    It allows an administrator to provide a "ignore list" of usernames to exclude from consideration.

    Primary User is assigned in two cases:
    1.  The system has exactly one associated user (who is directly associated and not on the ignore list).
    2.  The system has multiple directly associated users, but all except one are on the ignore list.

    Before making any changes, a CSV file is generated for review and prompts for final confirmation.
    The script uses the JumpCloud PowerShell module for all reads/writes of the relevant JumpCloud organization.
#>

# Prerequisites:
# require PowerShell 7+
If ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Error "This script requires PowerShell 7 or higher. Please upgrade your PowerShell version."
    exit
}

# Initialize counters for the final summary report
$counters = @{
    totalSystemsProcessed  = 0
    updatedCount           = 0
    unaffectedCount        = 0 # Systems with 0 users, or multiple non-ignored users
    fullyIgnoredCount      = 0 # Systems where all users were on the ignore list
    singleUserOnIgnoreList = 0 # Systems with 1 user who was on the ignore list
    failedLookupCount      = 0 # Systems skipped because user details could not be found
}

try {
    # --- 1. Authentication ---
    Write-Host "Connecting to JumpCloud..." -ForegroundColor Cyan
    Connect-JCOnline

    if (-not $Global:JCAPIKEY) {
        throw "Failed to connect. Please ensure the JumpCloud module is installed and a valid API key is provided."
    }
    Write-Host "Successfully connected to JumpCloud." -ForegroundColor Green

    $changeKeyConfirmation = Read-Host -Prompt "A connection is established. Do you want to use a different API key for this session? (y/n)"
    if ($changeKeyConfirmation.ToLower() -eq 'y') {
        $newApiKey = Read-Host -Prompt "Please enter the new JumpCloud API Key"
        if ([string]::IsNullOrWhiteSpace($newApiKey)) {
            throw "New API Key cannot be empty. Halting script."
        }

        $addOrgId = Read-Host -Prompt "Do you want to provide an organization ID (only needed for multi tenant portals)? (y/n)"
        if ($addOrgId.ToLower() -eq 'y') {
            $newOrgId = Read-Host -Prompt "Please enter the new JumpCloud organization ID"
            if ([string]::IsNullOrWhiteSpace($newOrgId)) {
                throw "New Org ID cannot be empty. Halting script."
            }
        }

        Write-Host "Attempting to connect with the new API key..." -ForegroundColor Cyan
        Connect-JCOnline -JumpCloudApiKey $newApiKey -JumpCloudOrgId $newOrgId

        if (-not $Global:JCAPIKEY) {
            throw "Failed to connect with the new API key. Please run the script again."
        }
        Write-Host "API Key has been updated and a new connection is established." -ForegroundColor Green
    }
    Write-Host ""

    # --- 2. Get and Validate Ignore List ---
    while ($true) {
        Write-Host "You can provide a list of usernames to exclude from being assigned as a primary user." -ForegroundColor Cyan
        $ignoreListInput = Read-Host -Prompt "Enter a comma-separated list of usernames to ignore (such as IT Administrators, guest accounts, etc.) or press Enter to skip"
        $ignoreList = if (-not [string]::IsNullOrWhiteSpace($ignoreListInput)) { $ignoreListInput.Split(',') | ForEach-Object { $_.Trim() } } else { @() }

        if ($ignoreList.Count -eq 0) { break } # Exit loop if list is empty

        $invalidUsers = @()
        foreach ($user in $ignoreList) {
            # Check if the returned object is null or has an empty ID.
            $jcUser = Get-JCUser -Username $user -ErrorAction SilentlyContinue
            if ($null -eq $jcUser -or [string]::IsNullOrWhiteSpace($jcUser.id)) {
                $invalidUsers += $user
            }
        }

        if ($invalidUsers.Count -gt 0) {
            Write-Warning "The following users could not be found: $($invalidUsers -join ', '). Please check the usernames and try again."
        } else {
            break # Exit loop if all users are valid
        }
    }

    if ($ignoreList.Count -gt 0) {
        Write-Host "The following usernames will be skipped: $($ignoreList -join ', ')" -ForegroundColor Yellow
    }
    Write-Host ""

    # --- 3. Fetch Systems and Process ---
    Write-Host "Fetching all systems in the organization. This may take a moment..." -ForegroundColor Cyan
    $allSystems = Get-JCSystem
    $counters.totalSystemsProcessed = $allSystems.Count
    Write-Host "Found $($counters.totalSystemsProcessed) total systems."
    Write-Host ""

    Write-Host "Analyzing systems..." -ForegroundColor Cyan
    $report = New-JCReport -ReportType 'users-to-devices'
    do {
        $reportStatus = Get-JCReport | Where-object { $_.id -eq $report.id }
        Write-Host "Report status: $($reportStatus.Status)"
        Start-Sleep -Seconds 1
    } until ($reportStatus.Status -eq "COMPLETED")
    $reportContent = Get-JCReport -reportID $report.id -Type json

    # This list will hold a report item for EVERY system.
    $reportItems = [System.Collections.Generic.List[PSCustomObject]]::new()

    $progress = 0
    foreach ($system in $allSystems) {
        $progress++
        Write-Progress -Activity "Analyzing Systems" -Status "Processing $($system.hostname) ($progress of $($allSystems.Count))" -PercentComplete (($progress / $allSystems.Count) * 100)

        $associatedUsers = $reportContent | Where-Object { $_.resource_object_id -eq $system.id }
        $userCount = $associatedUsers.Count

        # Create a report object for the current system
        $reportObject = [PSCustomObject]@{
            SystemID                 = $system.id
            SystemHostname           = $system.hostname
            SystemDisplayname        = $system.displayName
            AssociatedUserCount      = $userCount
            ProposedPrimaryUserEmail = ''
            ProposedPrimaryUsername  = ''
            ProposedPrimaryUserID    = ''
            Reason                   = ''
        }

        if ($userCount -eq 0) {
            $reportObject.Reason = "No associated users"
            $counters.unaffectedCount++
        } else {
            # First, filter for only directly associated users, as they are the only eligible candidates.
            $directlyAssociatedUsers = $associatedUsers | Where-Object { $_.association_type -eq 'direct' }

            # Next, filter out ignored users from the list of directly associated users.
            $candidateUsers = $directlyAssociatedUsers | Where-Object { $_.Username -notin $ignoreList }

            if ($candidateUsers.Count -eq 1) {
                # We have a single candidate. Now, get the full user details for the report and update.
                $candidateUser = $candidateUsers[0]
                try {
                    # First, check if a primary user is already set on the system
                    $existingSystemInfo = Get-JCSystem -SystemID $system.id
                    if ($null -ne $existingSystemInfo.primarySystemUser.id) {
                        $reportObject.Reason = "System already has a Primary User assigned"
                    } else {
                        # No primary user is set, so we can proceed with our candidate
                        $fullUserObject = Get-JCUser -Username $candidateUser.Username -ErrorAction Stop

                        if ($null -eq $fullUserObject -or [string]::IsNullOrWhiteSpace($fullUserObject.id)) {
                            $reportObject.Reason = "Could not retrieve full details for candidate user $($candidateUser.Username)"
                            $counters.failedLookupCount++
                        } else {
                            # This is a valid system to update. Populate the object.
                            $reportObject.ProposedPrimaryUserEmail = $fullUserObject.email
                            $reportObject.ProposedPrimaryUsername = $fullUserObject.username
                            $reportObject.ProposedPrimaryUserID = $fullUserObject.id
                            $reportObject.Reason = if ($associatedUsers.Count -eq 1) {
                                "Exactly one associated user on system"
                            } else {
                                "All but exactly one eligible user are on the ignore list"
                            }
                        }
                    }
                } catch {
                    $reportObject.Reason = "Error retrieving details for user $($candidateUser.Username): $($_.Exception.Message)"
                    $counters.failedLookupCount++
                }
            } elseif ($candidateUsers.Count -eq 0) {
                if ($directlyAssociatedUsers.Count -eq 0) {
                    $reportObject.Reason = "All associated user(s) do not have a direct association to system"
                } else {
                    $reportObject.Reason = "All eligible directly associated users are on the ignore list"
                }
                $counters.fullyIgnoredCount++
            } else {
                # More than 1 non-ignored user
                $reportObject.Reason = "Multiple eligible (non-ignored, directly associated) users associated"
                $counters.unaffectedCount++
            }
        }

        # Final check to populate placeholder text if no valid user was assigned
        if ([string]::IsNullOrWhiteSpace($reportObject.ProposedPrimaryUserID)) {
            $reportObject.ProposedPrimaryUsername = "No Primary User can be assigned"
            $reportObject.ProposedPrimaryUserEmail = "No Primary User can be assigned"
        }

        # Add the report object for the current system to our list
        $reportItems.Add($reportObject)
    }

    Write-Progress -Activity "Analyzing Systems" -Completed
    Write-Host "Analysis complete." -ForegroundColor Green
    Write-Host ""


    # --- 4. Confirmation via CSV and Prompt ---
    # Filter the report to find only the systems we intend to update
    $systemsToUpdate = $reportItems | Where-Object { -not [string]::IsNullOrWhiteSpace($_.ProposedPrimaryUserID) }

    if ($reportItems.Count -eq 0) {
        Write-Host "No systems were found in the organization." -ForegroundColor Green
    } else {
        $saveLocationInput = Read-Host -Prompt "Enter a folder path to save the CSV report (press Enter to save to your Desktop)"

        $saveDirectory = if ([string]::IsNullOrWhiteSpace($saveLocationInput)) {
            [Environment]::GetFolderPath('Desktop')
        } else {
            $saveLocationInput
        }

        if (-not (Test-Path -Path $saveDirectory -PathType Container)) {
            $createDirConfirm = Read-Host -Prompt "Directory not found. Do you want to create it? (y/n)"
            if ($createDirConfirm.ToLower() -eq 'y') {
                try {
                    New-Item -Path $saveDirectory -ItemType Directory -Force | Out-Null
                    Write-Host "Directory '$saveDirectory' created." -ForegroundColor Green
                } catch {
                    throw "Failed to create directory. Please check permissions and run the script again."
                }
            } else {
                throw "Save directory not found. Halting script."
            }
        }

        $csvPath = Join-Path -Path $saveDirectory -ChildPath "JumpCloud_PrimaryUser_Changes_$(Get-Date -Format 'yyyy-MM-dd-HHmmss').csv"
        # Export the full report of all systems
        $reportItems | Select-Object SystemID, SystemHostname, SystemDisplayname, AssociatedUserCount, ProposedPrimaryUserEmail, ProposedPrimaryUsername, Reason | Export-Csv -Path $csvPath -NoTypeInformation

        Write-Host "A report of ALL systems has been generated." -ForegroundColor Cyan
        Write-Host "File location: $csvPath" -ForegroundColor Yellow

        # Ask user if they want to open the file now
        $openFileConfirm = Read-Host -Prompt "Do you want to open the report file now? (y/n)"
        if ($openFileConfirm.ToLower() -eq 'y') {
            try {
                Invoke-Item -Path $csvPath
                Write-Host "Opening file..."
            } catch {
                Write-Warning "Could not open the file. Please navigate to the path manually: $csvPath"
            }
        }

        Write-Host "Please review this file. Systems with a populated Username/Email are targeted for update."
        Write-Host ""

        if ($systemsToUpdate.Count -gt 0) {
            $confirmation = Read-Host -Prompt "Found $($systemsToUpdate.Count) systems to update. Do you want to assign these users as primary users? (y/n)"

            if ($confirmation.ToLower() -eq 'y') {
                Write-Host "Confirmation received. Applying changes..." -ForegroundColor Cyan
                $updateProgress = 0
                foreach ($item in $systemsToUpdate) {
                    $updateProgress++
                    Write-Progress -Activity "Applying Changes" -Status "Updating $($item.SystemHostname) ($updateProgress of $($systemsToUpdate.Count))" -PercentComplete (($updateProgress / $systemsToUpdate.Count) * 100)
                    try {
                        Set-JCSystem -SystemID $item.SystemID -primarySystemUser $item.ProposedPrimaryUserID
                        Write-Host "  -> Successfully assigned '$($item.ProposedPrimaryUsername)' as primary user for '$($item.SystemHostname)'." -ForegroundColor Green
                        $counters.updatedCount++
                    } catch {
                        Write-Error "  -> FAILED to update system '$($item.SystemHostname)'. Error: $($_.Exception.Message)"
                    }
                }
                Write-Progress -Activity "Applying Changes" -Completed
                Write-Host "All changes have been applied." -ForegroundColor Green
            } else {
                Write-Host "Operation cancelled by the administrator. No changes were made." -ForegroundColor Yellow
            }
        } else {
            Write-Host "No systems were identified for primary user assignment based on the criteria." -ForegroundColor Green
        }
    }

} catch {
    Write-Error "A critical error occurred: $($_.Exception.Message)"
} finally {
    Write-Host ""
    Write-Host "------------------- Final Summary -------------------" -ForegroundColor Cyan
    Write-Host "Total Systems Processed: $($counters.totalSystemsProcessed)"
    Write-Host "Systems with 0 or multiple non-ignored users (Unaffected): $($counters.unaffectedCount)"
    Write-Host "Systems where all associated users were on the ignore list: $($counters.fullyIgnoredCount)"
    Write-Host "Systems where user details could not be found (Skipped): $($counters.failedLookupCount)"
    Write-Host ""
    Write-Host "Systems Updated with a Primary User: $($counters.updatedCount)" -ForegroundColor Green
    Write-Host "-----------------------------------------------------"
}