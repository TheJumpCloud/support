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
        # Create a dynamic parameter to get the -CascadeManagerId
        if ($CascadeManager -eq 'ID') {
            $paramDictionary = New-Object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
            $paramAttributesCollect = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]

            $paramAttributes = New-Object -Type System.Management.Automation.ParameterAttribute
            $paramAttributes.Mandatory = $true
            $paramAttributesCollect.Add($paramAttributes)

            $dynParam1 = New-Object -Type System.Management.Automation.RuntimeDefinedParameter("CascadeManagerId", [string], $paramAttributesCollect)
            $paramDictionary.Add('CascadeManagerId', $dynParam1)
            return $paramDictionary
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
        # Validate dynamic parameter
        if ($CascadeManager -eq 'ID') {
            $CascadeManagerId = $PSBoundParameters['CascadeManagerId']
            # Validate if the Id is a JC User from the $UserHash
            if ($UserHash.ContainsKey($CascadeManagerId)) {
                Write-Debug "CascadeManagerId is a valid JumpCloud User"
            } else {
                Write-Error "User does not exist. Please enter a valid UserID."
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
        } elseif ($PSCmdlet.ParameterSetName -eq 'UserID') {
            # Validate if the Id is a JC User from the $UserHash
            if ($UserHash.ContainsKey($UserID)) {
                Write-Debug "UserID is a valid JumpCloud User"
                $UserId = $UserHash.GetEnumerator().Where({ $_.Name -contains ($UserID) }).Name
                $Username = $UserHash.GetEnumerator().Where({ $_.Name -contains ($UserID) }) | Select-Object -ExpandProperty Value | Select-Object -ExpandProperty username
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

        if (!$force) {
            if ($CascadeManager -and $isManager) {
                Switch ($CascadeManager) {
                    'NULL' {
                        $Status = Delete-JCUser -Id $UserID -managerId $null -Headers $hdrs -UserHash $UserHash
                    }
                    'Auto' {
                        if ($hasManagerId) {
                            $Status = Delete-JCUser -Id $UserID -managerId $hasManagerId -Headers $hdrs -UserHash $UserHash
                        } else {
                            $Status = Delete-JCUser -Id $UserID -managerId $null -Headers $hdrs -UserHash $UserHash
                        }
                    }
                    'ID' {
                        $Status = Delete-JCUser -Id $UserID -managerId $CascadeManagerId -Headers $hdrs -UserHash $UserHash
                    }
                }
            } elseif ($isManager -and !$CascadeManager) {
                # Prompt for CascadeManager, user enters the ID of the new manager
                $cascade_manager = Read-Host "User $($Username) is a manager. Do you want to reassign their managed users to another manager? (Y / N)"
                if ($cascade_manager -eq 'Y') {
                    if ($hasManagerId) {
                        $managerUsername = $UserHash.GetEnumerator().Where({ $_.Name -contains ($hasManagerId) }) | Select-Object -ExpandProperty Value | Select-Object -ExpandProperty username
                        $cascade_manager = Read-Host "User $($Username) is managed by manager: $($managerUsername). Do you want to reassign the managed users to the manager: $($managerUsername)? (Y/N)"
                        if ($cascade_manager -eq 'Y') {
                            $newManagerId = $hasManagerId
                            $Status = Delete-JCUser -Id $UserID -managerId $newManagerId -Headers $hdrs -UserHash $UserHash
                        } elseif ($cascade_manager -eq 'N') {
                            $newManagerId = Read-Host "Enter the UserID of the new manager"
                            # Validate if the Id is a JC User
                            try {
                                $validateUser = Get-JcSdkUser -Id $newManagerId
                                Write-Debug "User $newManagerId is a valid JumpCloud User"
                                $Status = Delete-JCUser -Id $UserID -managerId $newManagerId -Headers $hdrs -UserHash $UserHash
                            } catch {
                                Write-Error "User does not exist. Please enter a valid UserID."
                                # Exit the script
                                Exit
                            }
                        }
                    } else {
                        $newManagerId = Read-Host "Enter the UserID of the new manager"
                        # Validate if the Id is a JC User
                        try {
                            $validateUser = Get-JcSdkUser -Id $newManagerId
                            Write-Debug "User $newManagerId is a valid JumpCloud User"
                            $Status = Delete-JCUser -Id $UserID -managerId $newManagerId -Headers $hdrs -UserHash $UserHash
                        } catch {
                            Write-Error "User does not exist. Please enter a valid UserID."
                            # Exit the script
                            Exit
                        }
                    }
                } elseif ($cascade_manager -eq 'N') {
                    $Status = Delete-JCUser -Id $UserID -managerId $null -Headers $hdrs -UserHash $UserHash
                } else {
                    Write-Error "Please enter Y or N"
                    Exit
                }
            } else {
                $Status = Delete-JCUser -Id $UserID -managerId $null -Headers $hdrs -UserHash $UserHash
            }
        }
        if ($force) {
            try {
                $Status = Delete-JCUser -Id $UserID -managerId $null -Headers $hdrs -force -UserHash $UserHash
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