Function Get-JCSystem ()
{
    [CmdletBinding(DefaultParameterSetName = 'SearchFilter')]

    param
    (
        #Strings

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID')]
        [Alias('_id', 'id')]
        [String]$SystemID,


        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter',
            Position = 0)]
        [String]$hostname,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [String]$displayName,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [String]$version,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [String]$templateName,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [String]$os,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [String]$remoteIP,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [String]$serialNumber,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [String]$arch,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [String]$agentVersion,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [String]$systemTimezone,

        ## Boolean

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [bool]$active,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [bool]$allowMultiFactorAuthentication,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [bool]$allowPublicKeyAuthentication,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [bool]$allowSshPasswordAuthentication,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [bool]$allowSshRootLogin,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [bool]$modifySSHDConfig,


        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter')]
        [ValidateSet('created')]
        [String]$filterDateProperty,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter')]
        [ValidateSet('created', 'active', 'agentVersion', 'allowMultiFactorAuthentication', 'allowPublicKeyAuthentication', 'allowSshPasswordAuthentication', 'allowSshRootLogin', 'arch', 'created', 'displayName', 'hostname', 'lastContact', 'modifySSHDConfig', 'organization', 'os', 'remoteIP', 'serialNumber', 'sshdParams', 'systemTimezone', 'templateName', 'version')]
        [String[]]$returnProperties

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


                while ((($resultsArrayList.results).Count) -ge $Counter)
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

                    $URL = "$JCUrlBasePath/api/search/systems"

                    $Results = Invoke-RestMethod -Method POST -Uri $Url  -Header $hdrs -Body $SearchJSON -UserAgent:(Get-JCUserAgent -PSCallStack:(Get-PSCallStack))

                    $null = $resultsArrayList.Add($Results)

                    $Skip += $limit

                    $Counter += $limit
                } #End While

            } #End search

            ByID
            {

                $URL = "$JCUrlBasePath/api/Systems/$SystemID"
                Write-Verbose $URL
                $results = Invoke-RestMethod -Method GET -Uri $URL -Headers $hdrs -UserAgent:(Get-JCUserAgent -PSCallStack:(Get-PSCallStack))
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
                return $resultsArrayList.Results | Select-Object -Property *  -ExcludeProperty associatedTagCount, id, sshRootEnabled
            }
            ByID
            {
                return $resultsArrayList | Select-Object -Property *  -ExcludeProperty associatedTagCount
            }

        }

    }

}