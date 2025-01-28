Function Set-JCSystem () {
    [CmdletBinding()]

    param
    (

        [Parameter(Mandatory, ValueFromPipelineByPropertyName = $true, Position = 0, HelpMessage = 'The _id of the System which you want to remove from JumpCloud. The SystemID will be the 24 character string populated for the _id field. SystemID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically by calling a JumpCloud function that returns the SystemID. This is shown in EXAMPLE 2')]
        [string]
        [Alias('_id', 'id')]
        $SystemID,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'The system displayName. The displayName is set to the hostname of the system during agent installation. When the system hostname updates the displayName does not update.')]
        [string]
        $displayName,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'The system description. String param to set system description')]
        [string]
        $description,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'A boolean $true/$false value to allow for ssh password authentication.')]
        [bool]
        $allowSshPasswordAuthentication,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'A boolean $true/$false value to allow for ssh root login.')]
        [bool]
        $allowSshRootLogin,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'A boolean $true/$false value to allow for MFA during system login. Note this setting only applies systems running Linux or Mac.')]
        [bool]
        $allowMultiFactorAuthentication,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'A boolean $true/$false value to allow for public key authentication.')]
        [bool]
        $allowPublicKeyAuthentication,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'Setting this value to $true will enable systemInsights and collect data for this system. Setting this value to $false will disable systemInsights and data collection for the system.')]
        [bool]
        $systemInsights,

        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'A string value indicating a JumpCloud users email, username or userID. This will add the user to the device associations')]
        [string]
        $primarySystemUser
    )

    begin {

        Write-Debug 'Verifying JCAPI Key'
        if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
            Connect-JConline
        }

        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY
        }

        if ($JCOrgID) {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }

        $UpdatedSystems = @()
    }

    process {
        $body = @{ }

        foreach ($param in $PSBoundParameters.GetEnumerator()) {
            if ([System.Management.Automation.PSCmdlet]::CommonParameters -contains $param.key) {
                continue
            }
            if ($param.key -eq 'SystemID', 'JCAPIKey') {
                continue
            }
            if ($param.key -eq 'systemInsights') {
                $state = switch ($systemInsights) {
                    true {
                        'enabled'
                    }
                    false {
                        'deferred'
                    }
                }
                $body.add('systemInsights', @{'state' = $state })
                continue
            }
            if ($param.key -eq "primarySystemUser") {
                    $userInfo = $param.value
                    # First check if primarySystemUser returns valid user with id
                    # Regex match a userid
                    $regexPattern = [Regex]'^[a-z0-9]{24}$'
                    if (((Select-String -InputObject $userInfo -Pattern $regexPattern).Matches.value)::IsNullOrEmpty) {
                        # if we have a 24 characterid, try to match the id using the search endpoint
                        $primarySystemUserSearch = @{
                            filter = @{
                                'and' = @(
                                    @{'_id' = @{'$eq' = "$($userInfo)" } }
                                )
                            }
                            fields = 'id'
                        }
                        $primarySystemUserResults = Search-JcSdkUser -Body:($primarySystemUserSearch)
                        # Set primarySystemUserValue; this is a validated user id
                        $primarySystemUserValue = $primarySystemUserResults.id
                    } else {
                        # Use class mailaddress to check if $_.value is email
                        try {
                            $null = [mailaddress]$userInfo
                            Write-Debug "This is true"
                            # Search for primarySystemUser using email
                            $primarySystemUserSearch = @{
                                filter = @{
                                    'and' = @(
                                        @{'email' = @{'$regex' = "(?i)(`^$($userInfo)`$)" } }
                                    )
                                }
                                fields = 'email'
                            }
                            $primarySystemUserResults = Search-JcSdkUser -Body:($primarySystemUserSearch)
                            # Set primarySystemUserValue; this is a validated user id
                            $primarySystemUserValue = $primarySystemUserResults.id
                            # if no value was returned, then assume the case this is actually a username and search
                            if (!$primarySystemUserValue) {
                                $primarySystemUserSearch = @{
                                    filter = @{
                                        'and' = @(
                                            @{'username' = @{'$regex' = "(?i)(`^$($userInfo)`$)" } }
                                        )
                                    }
                                    fields = 'username'
                                }
                                $primarySystemUserResults = Search-JcSdkUser -Body:($primarySystemUserSearch)
                                # Set primarySystemUserValue from the matched username
                                $primarySystemUserValue = $primarySystemUserResults.id
                            }
                        } catch {
                            # search the username in the search endpoint
                            $primarySystemUserSearch = @{
                                filter = @{
                                    'and' = @(
                                        @{'username' = @{'$regex' = "(?i)(`^$($userInfo)`$)" } }
                                    )
                                }
                                fields = 'username'
                            }
                            $primarySystemUserResults = Search-JcSdkUser -Body:($primarySystemUserSearch)
                            # Set primarySystemUserValue from the matched username
                            $primarySystemUserValue = $primarySystemUserResults.id
                        }
                    }
                    if ($null -eq $primarySystemUserValue) {
                        Write-Warning "Could not validate $userInfo. Please ensure the information was entered correctly"
                    }
                    try {
                        $association = Set-JcSdkSystemAssociation -SystemId $DeviceUpdate.DeviceID -Op "add" -Type "user" -Id $primarySystemUserValue
                        # Set-JcSdkSystemAssociation doesn't return anything, make custom return if function doesn't throw
                        $associationResults = @{
                            "primarySystemUser" = $primarySystemUserValue
                        }
                    } catch {
                        $associationResults = @{
                            "primarySystemUser" = $_
                        }
                    }
                }
            $body.add($param.Key, $param.Value)
            }

        $jsonbody = $body | ConvertTo-Json
        Write-Debug $jsonbody
        $URL = "$JCUrlBasePath/api/systems/$SystemID"
        Write-Debug $URL
        $System = Invoke-RestMethod -Method PUT -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent)

        if ($associationResults) {
            $UpdatedSystems += $System | Add-Member -MemberType NoteProperty -Name "primarySystemUser" -Value $associationResults.primarySystemUser
        } else {
            $UpdatedSystems += $System
        }
    }
    end {
        return $UpdatedSystems
    }
}
