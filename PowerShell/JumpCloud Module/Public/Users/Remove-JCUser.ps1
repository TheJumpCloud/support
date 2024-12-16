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
        [ValidateSet('NULL', 'Automatic', 'User')]
        [string]$CascadeManager
    )
    DynamicParam {
        # Create a dynamic parameter to get the -CascadeManagerId
        if ($PSBoundParameters['CascadeManager'] -eq 'User') {
            $paramDictionary = New-Object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
            $paramAttributesCollect = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]

            $paramAttributes = New-Object -Type System.Management.Automation.ParameterAttribute
            $paramAttributes.Mandatory = $true
            $paramAttributesCollect.Add($paramAttributes)

            $dynParam1 = New-Object -Type System.Management.Automation.RuntimeDefinedParameter("CascadeManagerUser", [string], $paramAttributesCollect)
            $paramDictionary.Add('CascadeManagerUser', $dynParam1)
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
        if ($PSBoundParameters['CascadeManager'] -eq 'User') {
            $CascadeManagerValue = $PSBoundParameters['CascadeManagerUser']

            # Validate if ID or Username is passed
            $regexPattern = [Regex]'^[a-z0-9]{24}$'
            if ($CascadeManagerValue -match $regexPattern) {
                # Validate if the Id is a JC User from the $UserHash
                if ($UserHash.ContainsKey($CascadeManagerValue)) {
                    $CascadeManagerId = $CascadeManagerValue
                    Write-Debug "$CascadeManagerId is a valid JumpCloud User"
                } else {
                    Write-Error "User does not exist. Please enter a valid UserID."
                    # Throw the script
                    Throw
                }
            } else {
                # Validate if the Username is a JC User from the $UserHash
                if ($UserHash.Values.username -contains ($CascadeManagerValue)) {
                    Write-Debug "$CascadeManagerValue is a valid JumpCloud User usr"
                    # Get the UserID from the $UserHash
                    $CascadeManagerId = $UserHash.GetEnumerator().Where({ $_.Value.username -contains ($CascadeManagerValue) }).Name
                    Write-Debug "CascadeManagerId is a valid JumpCloud User $CascadeManagerId"

                } else {
                    Write-Error "User does not exist. Please enter a valid Username."
                    # Throw the script
                    Throw
                }
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
                $Username = $UserHash.GetEnumerator().Where({ $_.Name -contains ($UserID) }) | Select-Object -ExpandProperty Value | Select-Object -ExpandProperty username
                Write-Host "UserID $($UserId) is a valid JumpCloud User: $($Username)"
            } else {
                Write-Error "User does not exist. Please enter a valid UserID."
                # Throw the script
                Throw
            }
        }
        # Check if the user is a manager
        if ($UserHash.Values.manager -contains ($UserID)) {
            $isManager = $true
            # Count the number of users the manager is managing
            # $managerCount = ($UserHash.Values.manager -eq $UserID).Count
            # Save each user the manager is managing in a list
            $managedUsers = $UserHash.GetEnumerator().Where({ $_.Value.manager -eq $UserID }).Name
            Write-Debug "Manager $($Username) is managing $managedUsers users"
            $hasManagerId = Get-JcSdkUser -Id $UserID | Select-Object -ExpandProperty manager
            Write-Debug "Manager $($Username) is managed by $hasManagerId"
        } else {
            $isManager = $false
            Write-Debug "User $($Username) is not a manager"
        }

        if (!$force) {
            if ($PSBoundParameters['CascadeManager'] -and $isManager) {
                Write-Debug "Switching on $CascadeManager"
                Switch ($CascadeManager) {

                    'NULL' {
                        $URI = "$JCUrlBasePath/api/systemusers/$($UserID)?cascade_manager=null"
                        Write-Host "Deleting user: $Username" -ForegroundColor Yellow
                        $Status = 'Deleted'
                    }
                    'Automatic' {
                        if ($hasManagerId) {
                            Write-Host "Deleting user: $Username and cascading its managed users manager to $($hasManagerId)" -ForegroundColor Yellow
                            $URI = "$JCUrlBasePath/api/systemusers/$($UserID)?cascade_manager=$($hasManagerId)"
                            $Status = "Deleted"

                        } else {
                            $URI = "$JCUrlBasePath/api/systemusers/$($UserID)?cascade_manager=null"
                            Write-Host "Deleting user: $Username" -ForegroundColor Yellow
                            $Status = "Deleted"
                        }
                    }
                    'User' {
                        $URI = "$JCUrlBasePath/api/systemusers/$($UserID)?cascade_manager=$($CascadeManagerId)"
                        Write-Host "Deleting user: $Username and cascading the managed users manager to the manager $($CascadeManagerId)" -ForegroundColor Yellow
                        $Status = "Deleted"
                    }
                }
                try {
                    Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent:(Get-JCUserAgent) | Out-Null
                } catch {
                    # Get the error details
                    $Status = $_.ErrorDetails
                    Write-Error $_.ErrorDetails
                }
            } elseif ($isManager -and !$PSBoundParameters['CascadeManager']) {
                # Prompt for CascadeManager, user enters the ID of the new manager
                $cascade_manager = Read-Host "User $($Username) is a manager and is managing $($managedUsers.Count) user(s). Do you want to reassign their managed users to another manager? (Y / N)"
                if ($cascade_manager -eq 'Y') {
                    if ($hasManagerId) {
                        $managerUsername = $UserHash.GetEnumerator().Where({ $_.Name -contains ($hasManagerId) }) | Select-Object -ExpandProperty Value | Select-Object -ExpandProperty username
                        $cascade_manager = Read-Host "User $($Username) is managed by manager: $($managerUsername). Do you want to reassign the managed users to the manager: $($managerUsername)? (Y/N)"
                        if ($cascade_manager -eq 'Y') {
                            $newManagerId = $hasManagerId
                            $URI = "$JCUrlBasePath/api/systemusers/$($UserID)?cascade_manager=$($newManagerId)"
                            Write-Host "Deleting user: $Username and cascading the managed users manager to the manager $($newManagerId)" -ForegroundColor Yellow
                            $prompt = Read-Host "Are you sure you wish to delete the user: $($Username)? (Y/N)"
                            if ($prompt -eq 'Y') {
                                try {
                                    Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent:(Get-JCUserAgent) | Out-Null
                                    $Status = "Deleted"
                                } catch {
                                    # Get the error details
                                    $Status = $_.ErrorDetails
                                    Write-Error $_.ErrorDetails
                                }

                            } elseif ($prompt -eq 'N') {
                                $Status = 'Not Deleted'
                            } else {
                                Write-Error "Please enter Y or N"
                                Throw
                            }

                        } elseif ($cascade_manager -eq 'N') {
                            $newManagerId = Read-Host "Enter the UserID of the new manager"
                            # Validate if the Id is a JC User
                            if ($UserHash.ContainsKey($newManagerId)) {
                                Write-Host "User $newManagerId is a valid JumpCloud User"
                                $URI = "$JCUrlBasePath/api/systemusers/$($UserID)?cascade_manager=$($newManagerId)"
                                Write-Host "Deleting user: $Username and cascading the managed users manager to the manager $($newManagerId)" -ForegroundColor Yellow
                                $prompt = Read-Host "Are you sure you wish to delete the user: $($Username)? (Y/N)"
                                if ($prompt -eq 'Y') {
                                    try {
                                        Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent:(Get-JCUserAgent) | Out-Null
                                        $Status = "Deleted"
                                    } catch {
                                        # Get the error details
                                        $Status = $_.ErrorDetails
                                        Write-Error $_.ErrorDetails
                                    }
                                } elseif ($prompt -eq 'N') {
                                    $Status = 'Not Deleted'
                                } else {
                                    Write-Error "Please enter Y or N"
                                    Throw
                                }
                            } else {
                                Write-Error "User does not exist. Please enter a valid UserID."
                                # Throw the script
                                Throw
                            }
                        }
                    } else {
                        $newManagerId = Read-Host "Enter the UserID of the new manager"
                        # Validate if the Id is a JC User
                        if ($UserHash.ContainsKey($newManagerId)) {
                            Write-Host "User $newManagerId is a valid JumpCloud User"
                            $URI = "$JCUrlBasePath/api/systemusers/$($UserID)?cascade_manager=$($newManagerId)"
                            Write-Host "Deleting user: $Username and cascading the managed users manager to the manager $($newManagerId)" -ForegroundColor Yellow
                            $prompt = Read-Host "Are you sure you wish to delete the user: $($Username)? (Y/N)"
                            if ($prompt -eq 'Y') {
                                try {
                                    Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent:(Get-JCUserAgent) | Out-Null
                                    $Status = "Deleted"
                                } catch {
                                    # Get the error details
                                    $Status = $_.ErrorDetails
                                    Write-Error $_.ErrorDetails
                                }
                            } elseif ($prompt -eq 'N') {
                                $Status = 'Not Deleted'
                            } else {
                                Write-Error "Please enter Y or N"
                                Throw
                            }
                        } else {
                            Write-Error "User does not exist. Please enter a valid UserID."
                            # Throw the script
                            Throw
                        }
                    }
                } elseif ($cascade_manager -eq 'N') {
                    #$Status = Delete-JCUser -Id $UserID -managerId $null -Headers $hdrs -UserHash $UserHash
                    $URI = "$JCUrlBasePath/api/systemusers/$($UserID)?cascade_manager=null"
                    Write-Host "Deleting user: $Username" -ForegroundColor Yellow
                    $prompt = Read-Host "Are you sure you wish to delete the user: $($Username)? (Y/N)"
                    if ($prompt -eq 'Y') {
                        try {
                            Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent:(Get-JCUserAgent) | Out-Null
                            $Status = 'Deleted'
                        } catch {
                            $Status = $_.ErrorDetails
                        }
                    } elseif ($prompt -eq 'N') {
                        Write-Host "User not deleted"
                        $Status = 'Not Deleted'
                    } else {
                        Write-Error "Please enter Y or N"
                        Throw
                    }
                } else {
                    Write-Error "Please enter Y or N"
                    Throw
                }
            } else {
                $URI = "$JCUrlBasePath/api/systemusers/$($UserID)?cascade_manager=null"
                Write-Host "Deleting user: $Username" -ForegroundColor Yellow
                $prompt = Read-Host "Are you sure you wish to delete the user: $($Username)? (Y/N)"
                if ($prompt -eq 'Y') {
                    try {
                        Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent:(Get-JCUserAgent) | Out-Null
                        $Status = "Deleted"
                    } catch {
                        Write-Error $_.ErrorDetails
                    }

                } elseif ($prompt -eq 'N') {
                    $Status = 'Not Deleted'
                } else {
                    Write-Error "Please enter Y or N"
                    Throw
                }
            }
        }
        if ($force) {
            try {
                $URI = "$JCUrlBasePath/api/systemusers/$($UserID)?cascade_manager=null"
                Write-Host "Deleting user: $Username" -ForegroundColor Yellow
                Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent:(Get-JCUserAgent) | Out-Null
                $Status = "Deleted"
            } catch {
                $Status = $_.ErrorDetails
            }
        }

        try {
            $FormattedResults = [PSCustomObject]@{
                'User'    = $Username
                'Results' = $Status
            }
        } catch {
            $FormattedResults = [PSCustomObject]@{
                'User'    = $Username
                'Results' = $_.ErrorDetails
            }
            Write-Error $_.ErrorDetails
        }


        $deletedArray += $FormattedResults
    }
    end {
        return $deletedArray
    }

}