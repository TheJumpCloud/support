Function Get-JCUser () {
    [CmdletBinding(DefaultParameterSetName = 'SearchFilter')]

    param
    (

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', Position = 0, HelpMessage = 'The Username of the JumpCloud user you wish to search for.')]
        [String]$username,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ByID', HelpMessage = 'The _id of the User which you want to modify. UserID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically.')]
        [Alias('_id', 'id')]
        [String]$userid,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'The First Name of the JumpCloud user you wish to search for.')]
        [String]$firstname,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'The Last Name of the JumpCloud user you wish to search for.')]
        [String]$lastname,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'The Email of the JumpCloud user you wish to search for.')]
        [String]$email,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'A search filter to search for users with a specific unix_gid. DOES NOT accept wild card input.')]
        [String]$unix_guid,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'A search filter to search for users with a specific unix_uid. DOES NOT accept wild card input.')]
        [String]$unix_uid,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'A search filter to show accounts that are enabled ($true) or disabled ($false) for sudo')]
        [bool]$sudo,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'A search filter to show accounts that are enabled ($true) or disabled ($false) for enable_managed_uid')]
        [bool]$enable_managed_uid,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'A search filter to return users that are activated ($true) or those that have not set a password ($false).')]
        [bool]$activated,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'A search filter to show accounts that have expired passwords ($true) or valid passwords ($false)')]
        [bool]$password_expired,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'A search filter to return users that are in a locked ($true) or unlocked ($false) state.')]
        [bool]$account_locked,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'A search filter to show accounts that are enabled ($true) or disabled ($false) for passwordless_sudo')]
        [bool]$passwordless_sudo,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'A search filter to show accounts that are enabled ($true) or disabled ($false) for externally_managed')]
        [bool]$externally_managed,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'A search filter to show accounts that are enabled ($true) or disabled ($false) for ldap_binding_user')]
        [bool]$ldap_binding_user,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'A search filter to show accounts that are enabled ($true) or disabled ($false) for enable_user_portal_multifactor')]
        [bool]$enable_user_portal_multifactor,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'A search filter to show accounts that are enabled ($true) or disabled ($false) for totp_enabled')]
        [bool]$totp_enabled,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'A search filter to show accounts that are enabled ($true) or disabled ($true) to allow_public_key')]
        [bool]$allow_public_key,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'A search filter to show accounts that are enabled ($true) or disabled ($false) for samba_service_user')]
        [bool]$samba_service_user,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'A search filter to show accounts that are enabled ($true) or disabled ($false) for password_never_expires')]
        [bool]$password_never_expires,

        [Parameter(DontShow, ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'A search filter to show accounts that are enabled ($true) or disabled ($false) for password_never_expires')]
        [bool]$suspended,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'A parameter that can filter the properties ''created'' or ''password_expiration_date''. This parameter if used creates two more dynamic parameters ''dateFilter'' and ''date''. See EXAMPLE 4 above for full syntax.')]
        [ValidateSet('created', 'password_expiration_date')]
        [String]$filterDateProperty,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'Allows you to return select properties on JumpCloud user objects. Specifying what properties are returned can drastically increase the speed of the API call with a large data set. Valid properties that can be returned are: ''created'', ''password_expiration_date'', ''account_locked'', ''activated'', ''addresses'', ''allow_public_key'', ''attributes'', ''alternateEmail'',''email'', ''enable_managed_uid'', ''enable_user_portal_multifactor'', ''externally_managed'', ''firstname'', ''lastname'', ''ldap_binding_user'', ''passwordless_sudo'', ''password_expired'', ''password_never_expires'', ''phoneNumbers'', ''samba_service_user'', ''ssh_keys'', ''sudo'', ''totp_enabled'', ''unix_guid'', ''unix_uid'', ''managedAppleId'',''manager'',''username'',''suspended'',''recoveryEmail''')]
        [ValidateSet('created', 'password_expiration_date', 'account_locked', 'activated', 'addresses', 'allow_public_key', 'attributes', 'alternateEmail', 'recoveryEmail', 'managedAppleId', 'manager', 'email', 'enable_managed_uid', 'enable_user_portal_multifactor', 'externally_managed', 'firstname', 'lastname', 'ldap_binding_user', 'passwordless_sudo', 'password_expired', 'password_never_expires', 'phoneNumbers', 'samba_service_user', 'ssh_keys', 'sudo', 'totp_enabled', 'unix_guid', 'unix_uid', 'username', 'middlename', 'displayname', 'jobTitle', 'employeeIdentifier', 'department', 'costCenter', 'company', 'employeeType', 'description', 'location', 'external_source_type', 'external_dn', 'suspended', 'mfa', 'recoveryEmail')]
        [String[]]$returnProperties,

        #New parameters as of 1.8 release
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'The middlename of the JumpCloud user you wish to search for.')]
        [String]$middlename,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'The preferred name of the JumpCloud user you wish to search for.')]
        [String]$displayname,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'The jobTitle of the JumpCloud user you wish to search for.')]
        [String]$jobTitle,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'The employeeIdentifier of the JumpCloud user you wish to search for.')]
        [String]$employeeIdentifier,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'The department of the JumpCloud user you wish to search for.')]
        [String]$department,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'The costCenter of the JumpCloud user you wish to search for.')]
        [String]$costCenter,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'The company of the JumpCloud user you wish to search for.')]
        [String]$company,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'The employeeType of the JumpCloud user you wish to search for.')]
        [String]$employeeType,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'The description of the JumpCloud user you wish to search for.')]
        [String]$description,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'The location of the JumpCloud user you wish to search for.')]
        [String]$location,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'The distinguished name of the AD domain (ADB Externally managed users only)')]
        [String]$external_dn,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'The externally managed user source type (ADB Externally managed users only)')]
        [String]$external_source_type,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'The managedAppleId of the JumpCloud user you wish to search for.')]
        [String]$managedAppleId,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'The manager username, primary email or ID of the JumpCloud user you wish to search for.')]
        [String]$manager,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'A search filter to return users that are in an ACTIVATED, STAGED or SUSPENDED state')]
        [String]$state,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'The recovery email of the JumpCloud user you wish to search for.')]
        [String]$recoveryEmail
    )

    DynamicParam {
        If ((Get-PSCallStack).Command -like '*MarkdownHelp') {
            $filterDateProperty = 'created'
        }
        if ($filterDateProperty) {
            # Create the dictionary
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # Set the dynamic parameters' name
            $ParamName_Filter = 'dateFilter'
            # Create the collection of attributes
            $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            # Create and set the parameters' attributes
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Mandatory = $true
            $ParameterAttribute.HelpMessage = 'Condition to filter date on.'
            # Generate and set the ValidateSet
            $arrSet = @("before", "after")
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
            # Add the ValidateSet to the attributes collection
            $AttributeCollection.Add($ValidateSetAttribute)
            # Add the attributes to the attributes collection
            $AttributeCollection.Add($ParameterAttribute)
            # Create and return the dynamic parameter
            $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParamName_Filter, [string], $AttributeCollection)
            $RuntimeParameterDictionary.Add($ParamName_Filter, $RuntimeParameter)

            # Set the dynamic parameters' name
            $ParamName_FilterDate = 'date'
            # Create the collection of attributes
            $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            # Create and set the parameters' attributes
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Mandatory = $true
            $ParameterAttribute.HelpMessage = 'Date to filter on.'
            # Add the attributes to the attributes collection
            $AttributeCollection.Add($ParameterAttribute)
            # Create and return the dynamic parameter
            $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParamName_FilterDate, [datetime], $AttributeCollection)
            $RuntimeParameterDictionary.Add($ParamName_FilterDate, $RuntimeParameter)

            # Returns the dictionary
            return $RuntimeParameterDictionary

        }

    }

    begin {
        Write-Verbose 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {
            Connect-JCOnline
        }

        $Parallel = $JCConfig.parallel.Calculated

        if ($Parallel) {
            Write-Verbose 'Initilizing resultsArray'
            $resultsArrayList = [System.Collections.Concurrent.ConcurrentBag[object]]::new()
        } else {
            Write-Verbose 'Initilizing resultsArray'
            $resultsArrayList = New-Object -TypeName System.Collections.ArrayList
        }

        Write-Verbose "Parameter Set: $($PSCmdlet.ParameterSetName)"

    }

    process {
        [int]$limit = '1000'
        Write-Verbose "Setting limit to $limit"

        [int]$skip = '0'
        Write-Verbose "Setting limit to $limit"

        switch ($PSCmdlet.ParameterSetName) {
            SearchFilter {

                if ($returnProperties) {

                    $Search = @{
                        filter = @(
                            @{
                            }
                        )
                        limit  = $limit
                        skip   = $skip
                        fields = $returnProperties
                    } #Initialize search

                }

                else {
                    $Search = @{
                        filter = @(
                            @{
                            }
                        )
                        limit  = $limit
                        skip   = $skip

                    } #Initialize search

                }

                foreach ($param in $PSBoundParameters.GetEnumerator()) {
                    if ([System.Management.Automation.PSCmdlet]::CommonParameters -contains $param.key) {
                        continue
                    }

                    if ($param.value -is [Boolean]) {
                        (($Search.filter).GetEnumerator()).add($param.Key, $param.value)
                        continue
                    }
                    if ($param.key -eq 'returnProperties') {
                        continue
                    }

                    if ($param.key -eq 'filterDateProperty') {
                        $DateProperty = $param.value

                        continue
                    }

                    if ($param.key -eq 'dateFilter') {
                        switch ($param.value) {
                            before {
                                $DateQuery = '$lt'
                            }
                            after {
                                $DateQuery = '$gt'
                            }
                        }
                        continue
                    }

                    if ($param.key -eq 'recoveryEmail') {
                        $recoveryEmail = $param.value
                        continue
                    }

                    if ($param.key -eq 'date') {
                        $Timestamp = Get-Date $param.Value -format o

                        continue
                    }

                    # manager lookup
                    if ("manager" -eq $param.Key) {
                        if ([System.String]::isNullOrEmpty($param.value)) {
                            # If manager field is null skip
                            continue
                        } else {
                            # First check if manager returns valid user with id
                            # Regex match a userid
                            $regexPattern = [Regex]'^[a-z0-9]{24}$'
                            if (((Select-String -InputObject $param.Value -Pattern $regexPattern).Matches.value)::IsNullOrEmpty) {
                                # if we have a 24 characterid, try to match the id using the search endpoint
                                $managerSearch = @{
                                    searchFilter = @{
                                        searchTerm = @($param.Value)
                                        fields     = @('id')
                                    }
                                }
                                $managerResults = Search-JcSdkUser -Body:($managerSearch)
                                # Set managerValue; this is a validated user id
                                $managerValue = $managerResults.id
                                # if no value was returned, then assume the case this is actually a username and search
                                if (!$managerValue) {
                                    $managerSearch = @{
                                        searchFilter = @{
                                            searchTerm = @($param.Value)
                                            fields     = @('username')
                                        }
                                    }
                                    $managerResults = Search-JcSdkUser -Body:($managerSearch)
                                    # Set managerValue from the matched username
                                    $managerValue = $managerResults.id
                                }
                            }
                            # Use class mailaddress to check if $param.value is email
                            try {
                                $null = [mailaddress]$EmailAddress
                                # Search manager using email
                                $managerSearch = @{
                                    searchFilter = @{
                                        searchTerm = @($param.Value)
                                        fields     = @('email')
                                    }
                                }
                                $managerResults = Search-JcSdkUser -Body:($managerSearch)
                                # Set managerValue; this is a validated user id
                                $managerValue = $managerResults.id
                                if (!$managerValue) {
                                    $managerSearch = @{
                                        searchFilter = @{
                                            searchTerm = @($param.Value)
                                            fields     = @('username')
                                        }
                                    }
                                    $managerResults = Search-JcSdkUser -Body:($managerSearch)
                                    # Set managerValue from the matched username
                                    $managerValue = $managerResults.id
                                }
                            } catch {
                                # search the username in the search endpoint
                                $managerSearch = @{
                                    searchFilter = @{
                                        searchTerm = @($param.Value)
                                        fields     = @('username')
                                    }
                                }
                                $managerResults = Search-JcSdkUser -Body:($managerSearch)
                                # Set managerValue from the matched username
                                $managerValue = $managerResults.id
                            }
                            if ($managerValue) {
                                # if an ID was validated
                                ($Search.filter).GetEnumerator().add($param.Key, $managerValue)
                            } else {
                                # if id was not validated, return value, let the API manage the error message
                                ($Search.filter).GetEnumerator().add($param.Key, $param.Value)
                            }
                            continue
                        }
                    }

                    # case insensitve state param
                    if ("state" -eq $param.Key) {
                        if ($param.Value -cin @('ACTIVATED', 'SUSPENDED', 'STAGED')) {
                            $stateValue = $param.Value
                        } else {
                            $stateValue = ($param.Value).ToUpper()
                        }
                        continue
                    }

                    $Value = ($param.value).replace('*', '')

                    if (($param.Value -match '.+?\*$') -and ($param.Value -match '^\*.+?')) {
                        # Front and back wildcard
                            (($Search.filter).GetEnumerator()).add($param.Key, @{'$regex' = "(?i)$([regex]::Escape($Value))" })
                    } elseif ($param.Value -match '.+?\*$') {
                        # Back wildcard
                            (($Search.filter).GetEnumerator()).add($param.Key, @{'$regex' = "(?i)^$([regex]::Escape($Value))" })
                    } elseif ($param.Value -match '^\*.+?') {
                        # Front wild card
                            (($Search.filter).GetEnumerator()).add($param.Key, @{'$regex' = "(?i)$([regex]::Escape($Value))`$" })
                    } elseif ($param.Value -match '^[-+]?\d+$') {
                        # Check for integer value
                            (($Search.filter).GetEnumerator()).add($param.Key, $([regex]::Escape($Value)))
                    } else {
                            (($Search.filter).GetEnumerator()).add($param.Key, @{'$regex' = "(?i)(^$([regex]::Escape($Value))`$)" })
                    }

                } # End foreach

                if ($filterDateProperty) {
                    (($Search.filter).GetEnumerator()).add($DateProperty, @{$DateQuery = $Timestamp })
                }
                if ($recoveryEmail) {
                    (($Search.filter).GetEnumerator()).add('recoveryEmail.address', $recoveryEmail )
                }
                if ($stateValue) {
                        (($Search.filter).GetEnumerator()).add('state', $stateValue )
                }

                $SearchJSON = $Search | ConvertTo-Json -Compress -Depth 4

                Write-Debug $SearchJSON

                $URL = "$JCUrlBasePath/api/search/systemusers"

                if ($Parallel) {
                    $resultsArrayList = Get-JCResults -URL $URL -method "POST" -limit $limit -body $SearchJSON -Parallel $true
                } else {
                    $resultsArrayList = Get-JCResults -URL $URL -method "POST" -limit $limit -body $SearchJSON
                }

            } #End search

            ByID {

                $URL = "$JCUrlBasePath/api/Systemusers/$Userid"
                Write-Verbose $URL
                $resultsArrayList = Get-JCResults -URL $URL -method "GET" -limit $limit
            }

        } # End switch
    } # End process

    end {

        switch ($PSCmdlet.ParameterSetName) {
            SearchFilter {
                return $resultsArrayList | Select-Object -ExcludeProperty associatedTagCount, id, sshRootEnabled
            }
            ByID {
                return $resultsArrayList | Select-Object -ExcludeProperty associatedTagCount
            }
        }
    }
}