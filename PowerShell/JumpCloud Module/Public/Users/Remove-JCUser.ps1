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

        [Parameter(HelpMessage = 'A SwitchParameter which suppresses the warning message when removing a JumpCloud User.')]
        [Switch]
        $force,
        [Parameter(HelpMessage = 'A SwitchParameter for Cascading the manager of the user to the users managed by the user. NULL, AUTOMATIC (bubble up), ID (prompt for manager ID)')]
        [ValidateSet('NULL', 'AUTOMATIC', 'ID')]
        [string]$CascadeManager
    )

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

        if ($PSCmdlet.ParameterSetName -eq 'Username' ) {
            $UserHash = Get-DynamicHash -Object User -returnProperties username, manager
            $UserCount = ($UserHash).Count
            Write-Debug "Populated UserHash with $UserCount users"
        }

        # Check if CascadeManager is set to ID
        if ($CascadeManager -eq 'ID') {
            # Prompt for cascade_manager, user enters the ID of the new manager
            $newManagerId = Read-Host "Enter the UserID of the new manager"
            # Validate if the Id is a JC User
            $validateUser = Get-JcSdkUser -Id $newManagerId
            if ($validateUser) {
                Write-Debug "User $newManagerId is a valid JumpCloud User"
            } else {
                Write-Host "User does not exist. Please enter a valid UserID."
                # Exit the script
                Exit
            }
        }

    }
    process {
        if ($PSCmdlet.ParameterSetName -eq 'Username' ) {
            if ($UserHash.Values.username -contains ($Username)) {
                $UserID = $UserHash.GetEnumerator().Where({ $_.Value.username -contains ($Username) }).Name
            } else {
                Throw "Username does not exist. Run 'Get-JCUser | Select-Object username' to see a list of all your JumpCloud users."
            }
        }

        if ($PSCmdlet.ParameterSetName -eq 'UserID' ) {
            $Username = $UserID
            Write-Debug "UserID is $UserID"
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
            if ($CascadeManager) {
                Switch ($CascadeManager) {
                    'NULL' {
                        $Status = Delete-JCUser -Id $UserID -managerId $null -Headers $hdrs
                    }
                    'AUTOMATIC' {
                        $Status = Delete-JCUser -Id $UserID -managerId 'AUTOMATIC' -Headers $hdrs
                    }
                    'ID' {
                        $Status = Delete-JCUser -Id $UserID -managerId $newManagerId -Headers $hdrs
                    }
                }
            } elseif ($isManager -and !$CascadeManager) {
                # Prompt for cascade_managerk, user enters the ID of the new manager
                $cascade_manager = Read-Host "User is a manager. Do you want to reassign their managed users to another manager? (Y/N)"
                if ($cascade_manager -eq 'Y') {
                    if ($hasManagerId) {
                        $prompt = "User is managed by another manager. Do you want to reassign their managed users to the manager who is managing this user? (Y/N)"
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
            $FormattedResults = [PSCustomObject]@{
                'User'    = $Username
                'Results' = $Status
            }
            $deletedArray += $FormattedResults
        }

        if ($force) {
            try {
                $Status = Delete-JCUser -Id $UserID -managerId $null -Headers $hdrs
            } catch {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{
                'User'    = $Username
                'Results' = $Status
            }

            $deletedArray += $FormattedResults

        }
    }
    end {

        return $deletedArray

    }

}