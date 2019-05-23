Function Get-JCUser ()
{
    [CmdletBinding(DefaultParameterSetName = 'SearchFilter')]

    param
    (

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter',
            Position = 0)]
        [String]$username,


        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID')]
        [Alias('_id', 'id')]
        [String]$userid,


        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [String]$firstname,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [String]$lastname,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [String]$email,


        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [String]$unix_guid,


        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [String]$unix_uid,


        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [bool]$sudo,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [bool]$enable_managed_uid,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [bool]$activated,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [bool]$password_expired,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [bool]$account_locked,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [bool]$passwordless_sudo,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [bool]$externally_managed,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [bool]$ldap_binding_user,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [bool]$enable_user_portal_multifactor,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [bool]$totp_enabled,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [bool]$allow_public_key,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [bool]$samba_service_user,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [bool]$password_never_expires,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter')]
        [ValidateSet('created', 'password_expiration_date')]
        [String]$filterDateProperty,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter')]
        [ValidateSet('created', 'password_expiration_date', 'account_locked', 'activated', 'addresses', 'allow_public_key', 'attributes', 'email', 'enable_managed_uid', 'enable_user_portal_multifactor', 'externally_managed', 'firstname', 'lastname', 'ldap_binding_user', 'passwordless_sudo', 'password_expired', 'password_never_expires', 'phoneNumbers', 'samba_service_user', 'ssh_keys', 'sudo', 'totp_enabled', 'unix_guid', 'unix_uid', 'username', 'middlename', 'displayname', 'jobTitle', 'employeeIdentifier', 'department', 'costCenter', 'company', 'employeeType', 'description', 'location')]
        [String[]]$returnProperties,

        #New parameters as of 1.8 release
        [Parameter(ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter')]
        [String]$middlename,

        [Parameter(ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter')]
        [String]$displayname,

        [Parameter(ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter')]
        [String]$jobTitle,

        [Parameter(ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter')]
        [String]$employeeIdentifier,

        [Parameter(ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter')]
        [String]$department,

        [Parameter(ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter')]
        [String]$costCenter,

        [Parameter(ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter')]
        [String]$company,

        [Parameter(ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter')]
        [String]$employeeType,

        [Parameter(ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter')]
        [String]$description,

        [Parameter(ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter')]
        [String]$location
    )

    DynamicParam
    {
        if ($filterDateProperty)
        {

            # Create the dictionary
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary


            # Set the dynamic parameters' name
            $ParamName_Filter = 'dateFilter'
            # Create the collection of attributes
            $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            # Create and set the parameters' attributes
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Mandatory = $true
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
            # Add the attributes to the attributes collection
            $AttributeCollection.Add($ParameterAttribute)
            # Create and return the dynamic parameter
            $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParamName_FilterDate, [string], $AttributeCollection)
            $RuntimeParameterDictionary.Add($ParamName_FilterDate, $RuntimeParameter)



            # Returns the dictionary
            return $RuntimeParameterDictionary

        }

    }


    begin

    {
        Write-Verbose 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JCOnline}

        Write-Verbose 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        if ($JCOrgID)
        {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }


        Write-Verbose 'Initilizing resultsArray'

        $resultsArrayList = New-Object -TypeName System.Collections.ArrayList

        Write-Verbose "Parameter Set: $($PSCmdlet.ParameterSetName)"

    }

    process

    {
        [int]$limit = '1000'
        Write-Verbose "Setting limit to $limit"

        [int]$skip = '0'
        Write-Verbose "Setting limit to $limit"

        [int]$Counter = 0

        switch ($PSCmdlet.ParameterSetName)
        {
            SearchFilter
            {


                while ((($resultsArrayList.Results).Count) -ge $Counter)
                {

                    if ($returnProperties)
                    {

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

                    else
                    {

                        $Search = @{
                            filter = @(
                                @{
                                }
                            )
                            limit  = $limit
                            skip   = $skip

                        } #Initialize search

                    }


                    foreach ($param in $PSBoundParameters.GetEnumerator())
                    {
                        if ([System.Management.Automation.PSCmdlet]::CommonParameters -contains $param.key) { continue }

                        if ($param.value -is [Boolean])
                        {
                            (($Search.filter).GetEnumerator()).add($param.Key, $param.value)

                            continue
                        }

                        if ($param.key -eq 'returnProperties')
                        {
                            continue
                        }

                        if ($param.key -eq 'filterDateProperty')
                        {
                            $DateProperty = $param.value

                            continue
                        }


                        if ($param.key -eq 'dateFilter')
                        {
                            switch ($param.value)
                            {
                                before { $DateQuery = '$lt' }
                                after { $DateQuery = '$gt'}
                            }

                            continue
                        }

                        if ($param.key -eq 'date')
                        {

                            $ConvertDate = [DateTime]$param.value
                            $Timestamp = Get-Date $ConvertDate -format o

                            continue
                        }


                        $Value = ($param.value).replace('*', '')

                        if (($param.Value -match '.+?\*$') -and ($param.Value -match '^\*.+?'))
                        {
                            # Front and back wildcard
                            (($Search.filter).GetEnumerator()).add($param.Key, @{'$regex' = "$Value"})
                        }
                        elseif ($param.Value -match '.+?\*$')
                        {
                            # Back wildcard
                            (($Search.filter).GetEnumerator()).add($param.Key, @{'$regex' = "^$Value"})
                        }
                        elseif ($param.Value -match '^\*.+?')
                        {
                            # Front wild card
                            (($Search.filter).GetEnumerator()).add($param.Key, @{'$regex' = "$Value`$"})
                        }
                        else
                        {
                            (($Search.filter).GetEnumerator()).add($param.Key, $Value)
                        }


                    } # End foreach

                    if ($filterDateProperty)
                    {
                        (($Search.filter).GetEnumerator()).add($DateProperty, @{$DateQuery = $Timestamp})
                    }

                    $SearchJSON = $Search | ConvertTo-Json -Compress -Depth 4

                    Write-Debug $SearchJSON

                    $URL = "$JCUrlBasePath/api/search/systemusers"

                    $Results = Invoke-RestMethod -Method POST -Uri $Url  -Header $hdrs -Body $SearchJSON -UserAgent:(Get-JCUserAgent)

                    $null = $resultsArrayList.Add($Results)

                    $Skip += $limit

                    $Counter += $limit

                } #End While

            } #End search

            ByID
            {

                $URL = "$JCUrlBasePath/api/Systemusers/$Userid"
                Write-Verbose $URL
                $results = Invoke-RestMethod -Method GET -Uri $URL -Headers $hdrs -UserAgent:(Get-JCUserAgent)
                $null = $resultsArrayList.add($Results)
            }

        } # End switch
    } # End process

    end

    {

        switch ($PSCmdlet.ParameterSetName)
        {
            SearchFilter
            {
                return $resultsArrayList.Results | Select-Object -Property *  -ExcludeProperty associatedTagCount
            }
            ByID
            {
                return $resultsArrayList | Select-Object -Property *  -ExcludeProperty associatedTagCount
            }
        }
    }
}