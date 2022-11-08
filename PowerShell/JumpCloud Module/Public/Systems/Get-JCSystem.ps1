Function Get-JCSystem () {
    [CmdletBinding(DefaultParameterSetName = 'SearchFilter')]

    param
    (
        #Strings

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID',
            HelpMessage = 'The _id or id of the System which you want to query.')]
        [Alias('_id', 'id')]
        [String]$SystemID,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID', HelpMessage = 'A switch parameter to reveal the SystemFDEKey')]
        [switch]$SystemFDEKey,


        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter',
            Position = 0,
            HelpMessage = 'A search filter to search systems by the hostname.')]
        [String]$hostname,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter',
            HelpMessage = 'A search filter to search systems by the displayName.'
        )]
        [String]$displayName,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter',
            HelpMessage = 'A search filter to search systems by the description.'
        )]
        [String]$description,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter',
            HelpMessage = 'A search filter to search systems by the version.'
        )]
        [String]$version,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter',
            HelpMessage = 'A search filter to search systems by the templateName.'
        )]
        [String]$templateName,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter',
            HelpMessage = 'A search filter to search systems by the OS.'
        )]
        [String]$os,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter',
            HelpMessage = 'A search filter to search systems by the remoteIP.'
        )]
        [String]$remoteIP,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter',
            HelpMessage = 'A search filter to search systems by the serialNumber.'
        )]
        [String]$serialNumber,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter',
            HelpMessage = 'A search filter to search systems by the processor arch.'
        )]
        [String]$arch,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter',
            HelpMessage = 'A search filter to search systems by the agentVersion.')]
        [String]$agentVersion,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter',
            HelpMessage = 'A search filter to search systems by the serialNumber. This field DOES NOT take wildcard input.'
        )]
        [String]$systemTimezone,

        ## Boolean

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter',
            HelpMessage = 'Filter for systems that are online or offline.')]
        [bool]$active,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter',
            HelpMessage = 'A search filter to show systems that are enabled ($true) or disabled ($true) for allowMultiFactorAuthentication')]
        [bool]$allowMultiFactorAuthentication,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter',
            HelpMessage = 'A search filter to show systems that are enabled ($true) or disabled ($true) for allowMultiFactorAuthentication')]
        [bool]$allowPublicKeyAuthentication,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter',
            HelpMessage = 'A search filter to show systems that are enabled ($true) or disabled ($true) for allowMultiFactorAuthentication')]
        [bool]$allowSshPasswordAuthentication,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter',
            HelpMessage = 'A search filter to show systems that are enabled ($true) or disabled ($true) for allowMultiFactorAuthentication'
        )]
        [bool]$allowSshRootLogin,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter',
            HelpMessage = 'A search filter to show systems that are enabled ($true) or disabled ($true) for modifySSHDConfig'
        )]
        [bool]$modifySSHDConfig,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter',
            HelpMessage = 'A search filter to show macOS systems that have the JumpCloud service account'
        )]
        [bool]$hasServiceAccount,


        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter',
            HelpMessage = 'A parameter that can filter on the property ''created'' or ''lastContact''. Only inactive systems will be returned when using the lastContact filter. This parameter if used creates two more dynamic parameters ''dateFilter'' and ''date''. See EXAMPLE 5 above for full syntax.')]
        [ValidateSet('created', 'lastContact')]
        [String]$filterDateProperty,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter',
            HelpMessage = 'Allows you to return select properties on JumpCloud system objects. Specifying what properties are returned can drastically increase the speed of the API call with a large data set. Valid properties that can be returned are: ''created'', ''active'', ''agentVersion'', ''allowMultiFactorAuthentication'', ''allowPublicKeyAuthentication'', ''allowSshPasswordAuthentication'', ''allowSshRootLogin'', ''arch'', ''created'', ''displayName'', ''hostname'', ''lastContact'', ''modifySSHDConfig'', ''organization'', ''os'', ''remoteIP'', ''serialNumber'', ''sshdParams'', ''systemTimezone'', ''templateName'', ''version''')]
        [ValidateSet('acknowledged', 'active', 'agentVersion', 'allowMultiFactorAuthentication', 'allowPublicKeyAuthentication', 'allowSshPasswordAuthentication', 'allowSshRootLogin', 'arch', 'azureAdJoined', 'connectionHistory', 'created', 'displayName', 'domainInfo', 'fde', 'fileSystem', 'hasServiceAccount', 'hostname', 'lastContact', 'mdm', 'modifySSHDConfig', 'networkInterfaces', 'organization', 'os', 'osFamily', 'provisionMetadata', 'remoteIP', 'serialNumber', 'serviceAccountState', 'sshdParams', 'systemInsights', 'systemTimezone', 'systemToken', 'templateName', 'userMetrics', 'usernameHashes', 'version')]
        [String[]]$returnProperties
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
        Write-Verbose "Setting skip to $skip"

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
                } else {

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
                        if ($param.key -eq 'parallel') {
                            continue
                        }

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

                    if ($param.key -eq 'date') {
                        $Timestamp = Get-Date $param.Value -format o

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

                $SearchJSON = $Search | ConvertTo-Json -Compress -Depth 4

                Write-Debug $SearchJSON

                $URL = "$JCUrlBasePath/api/search/systems"

                if ($Parallel) {
                    $resultsArrayList = Get-JCResults -URL $URL -method "POST" -limit $limit -body $SearchJSON -Parallel $true
                } else {
                    $resultsArrayList = Get-JCResults -URL $URL -method "POST" -limit $limit -body $SearchJSON
                }

            } #End search

            ByID {


                if ($SystemFDEKey) {

                    $URL = "$JCUrlBasePath/api/v2/systems/$SystemID/fdekey"
                    Write-Verbose $URL

                    $results = Get-JCResults -URL $URL -method "GET" -limit $limit

                    $FormattedObject = [PSCustomObject]@{
                        '_id' = $SystemID;
                        'key' = $results.key;
                    }

                    $null = $resultsArrayList.add($FormattedObject)

                }

                else {
                    $URL = "$JCUrlBasePath/api/Systems/$SystemID"
                    Write-Verbose $URL

                    $resultsArrayList = Get-JCResults -URL $URL -method "GET" -limit $limit
                }


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