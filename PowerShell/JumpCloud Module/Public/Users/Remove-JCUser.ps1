function Remove-JCUser () {
    [CmdletBinding(DefaultParameterSetName = 'Username')]

    param
    (
        [Parameter(Mandatory,
            ParameterSetName = 'Username',
            ValueFromPipelineByPropertyName,
            Position = 0,
            HelpMessage = 'The Username of the JumpCloud user you wish to remove.')]
        [String] $Username,

        [Parameter(Mandatory,
            ParameterSetName = 'UserID',
            ValueFromPipelineByPropertyName,
            HelpMessage = 'The _id of the User which you want to delete.
To find a JumpCloud UserID run the command:
PS C:\> Get-JCUser | Select username, _id
The UserID will be the 24 character string populated for the _id field.
UserID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically.')]

        [Alias('_id')]
        [String] $UserID,

        [Parameter(ParameterSetName = 'UserID',
            HelpMessage = 'Use the -ByID parameter when the UserID is passed over the pipeline to the Remove-JCUser function. The -ByID SwitchParameter will set the ParameterSet to ''ByID'' which will increase the function speed and performance.')]
        [Switch]
        $ByID,
        # Do not use $CascadeManager if $force is used
        [Parameter(HelpMessage = 'A SwitchParameter which suppresses the warning message when removing a JumpCloud User.')]
        [Switch]
        $force,
        [Parameter(HelpMessage = 'A SwitchParameter for Cascading the manager of the user to the users managed by the user. NULL, AUTOMATIC (bubble up), ID (prompt for manager ID)')]
        [ValidateSet('NULL', 'Auto', 'ID')]
        [string]$CascadeManager
    )
    DynamicParam {
        if ($CascadeManager -eq 'ID' -and !$force) {
            # Prompt for cascade_manager, user enters the ID of the new manager
            $newManagerId = Read-Host "Enter the UserID of the new manager"
            # Validate if the Id is a JC User
            $validateUser = Get-JcSdkUser -Id $newManagerId
            if ($validateUser) {
                Write-Debug "User $newManagerId is a valid JumpCloud User"
                return $newManagerId
            } else {
                Write-Error "User does not exist. Please enter a valid UserID."
                # Exit the script
                Exit
            }
        }
    }
    begin {
        Write-Debug 'Verifying JCAPI Key'
        if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
            Connect-JConline
        }
        Write-Debug 'Populating API headers'
        $hdrs = @{
            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY
        }

        if ($JCOrgID) {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }

        $deletedArray = @()
        # If $cascadeManager and $force are used, throw an error
        if ($CascadeManager -and $force) {
            Throw "Cannot use -CascadeManager and -Force together. Please use one or the other."
        }

        $UserHash = Get-DynamicHash -Object User -returnProperties 'username', 'manager'

    }
    process {
        if ($PSCmdlet.ParameterSetName -eq 'Username' ) {
            if ($UserHash.Values.username -contains ($Username)) {
                $UserID = $UserHash.GetEnumerator().Where({ $_.Value.username -contains ($Username) }).Name
                Write-Debug "UserID: $UserID"
            } else {
                Throw "Username does not exist. Run 'Get-JCUser | Select-Object username' to see a list of all your JumpCloud users."
            }
        } elseif ($PSCmdlet.ParameterSetName -eq 'UserID') {
            # Validate if the Id is a JC User from the $UserHash
            if ($UserHash.ContainsKey($UserID)) {
                Write-Debug "UserID is a valid JumpCloud User"
                $UserId = $UserHash.GetEnumerator().Where({ $_.Name -contains ($UserID) }).Name
                $Username = $UserHash.GetEnumerator().Where({ $_.Name -contains ($UserID) }) | Select-Object -ExpandProperty Value | Select-Object -ExpandProperty username
                Write-Debug "UserID: $UserID"
                Write-Debug "Username: $Username"

            } else {
                Write-Error "User does not exist. Please enter a valid UserID."
                # Exit the script
                Exit
            }
        }
        # Check if the user is a manager
        if ($UserHash.Values.manager -contains ($UserID)) {
            $isManager = $true
            # Count the number of users the manager is managing
            # $managerCount = ($UserHash.Values.manager -eq $UserID).Count
            # Save each user the manager is managing in a list
            $managedUsers = $UserHash.GetEnumerator().Where({ $_.Value.manager -eq $UserID }).Name
            Write-Debug "Manager is managing $managedUsers users"
            $hasManagerId = Get-JcSdkUser -Id $UserID | Select-Object -ExpandProperty manager
            Write-Debug "Manager is managed by $hasManagerId"
        } else {
            $isManager = $false
            Write-Debug "User is not a manager"
        }

        # Check if the user is managed by another manager


        # TODO: If force or does not have a manager, default to cascade_manager=Null -- Done
        # TODO: If not force, prompt for cascade_manager if the user is a manager -- Done
        # TODO: If manager is managed by another manager, cascade_manager to users managed by the manager -- Done
        if (!$force) {
            if ($CascadeManager -and $isManager) {
                Switch ($CascadeManager) {
                    'NULL' {
                        $Status = Delete-JCUser -Id $UserID -managerId $null -Headers $hdrs
                    }
                    'Auto' {
                        if ($hasManagerId) {
                            $Status = Delete-JCUser -Id $UserID -managerId $hasManagerId -Headers $hdrs
                        } else {
                            $Status = Delete-JCUser -Id $UserID -managerId $null -Headers $hdrs
                        }
                    }
                    'ID' {
                        $Status = Delete-JCUser -Id $UserID -managerId $newManagerId -Headers $hdrs
                    }
                }
            } elseif ($isManager -and !$CascadeManager) {
                # Prompt for cascade_managerk, user enters the ID of the new manager
                $cascade_manager = Read-Host "User $($Username) is a manager. Do you want to reassign their managed users to another manager? (Y / N)"
                while ($cascade_manager -ne 'Y' -and $cascade_manager -ne 'N') {
                    $cascade_manager = Read-Host "Please enter Y (Yes) or N (No)"
                }
                if ($cascade_manager -eq 'Y') {
                    if ($hasManagerId) {
                        $managerUsername = $UserHash.GetEnumerator().Where({ $_.Name -contains ($hasManagerId) }) | Select-Object -ExpandProperty Value | Select-Object -ExpandProperty username
                        $prompt = "User $($Username) is managed by manager: $($managerUsername). Do you want to reassign their managed users to the manager who is managing this user? (Y/N)"
                        $cascade_manager = Read-Host $prompt
                        if ($cascade_manager -eq 'Y') {
                            $newManagerId = $hasManagerId
                            $Status = Delete-JCUser -Id $UserID -managerId $newManagerId -Headers $hdrs
                        } else {
                            $newManagerId = Read-Host "Enter the UserID of the new manager"
                            $Status = Delete-JCUser -Id $UserID -managerId $newManagerId -Headers $hdrs
                        }
                    } else {
                        $newManagerId = Read-Host "Enter the UserID of the new manager"
                        $Status = Delete-JCUser -Id $UserID -managerId $newManagerId -Headers $hdrs
                    }
                } elseif ($cascade_manager -eq 'N') {
                    $Status = Delete-JCUser -Id $UserID -managerId $null -Headers $hdrs
                }
            } else {
                $Status = Delete-JCUser -Id $UserID -managerId $null -Headers $hdrs
            }
        }
        if ($force) {
            try {
                $Status = Delete-JCUser -Id $UserID -managerId $null -Headers $hdrs
            } catch {
                $Status = $_.ErrorDetails
            }
        }
        $FormattedResults = $Status
        $deletedArray += $FormattedResults
    }
    end {

        return $deletedArray

    }

}