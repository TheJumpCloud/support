
Function Get-JCCommand () {
    [CmdletBinding(DefaultParameterSetName = 'SearchFilter')]

    param
    (

        [Parameter( ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'The command body text of the JumpCloud Command you wish to search for ex. Get-JCCommand -command <commandBody>')]
        [String]$command,
        [Parameter( ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'The name of the JumpCloud Command you wish to search for ex. Get-JCCommand -name <commandName>')]
        [String]$name,
        [Parameter( ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'The type (windows, mac, linux) of the JumpCloud Command you wish to search for ex. Get-JCCommand -commandType <commandType>')]
        [ValidateSet('windows', 'mac', 'linux')]
        [string]$commandType,
        [Parameter( ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'The launch type of the JumpCloud Command you wish to search for ex. Get-JCCommand -launchType <typeOfLaunch> ' )]
        [ValidateSet('repeated', 'one-time', 'manual', 'trigger')]
        [string]$launchType,
        [Parameter( ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'The trigger name of the JumpCloud Command you wish to search for ex. Get-JCCommand -trigger <triggerId> ')]
        [string]$trigger,
        [Parameter( ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'The scheduled command repeat type (minute, hour, day, week, month) of the JumpCloud Command you wish to search for ex. Get-JCCommand -scheduleRepeatType <repeatType>')]
        [ValidateSet('minute', 'hour', 'day', 'week', 'month')]
        [string]$scheduleRepeatType,
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'Allows you to return select properties on JumpCloud commands objects. Specifying what properties are returned can drastically increase the speed of the API call with a large data set. Valid properties that can be returned are: ''command'', ''name'',''launchType'',''commandType'',''trigger'',''scheduleRepeatType'',''listensTo'',''organization'',''commandRunners'',''schedule'',''shell'',''timeout'',''sudo'',''template'',''scheduleYear'',''timeToLiveSeconds'',''files'',''user'',''systems''')]
        [ValidateSet('command', 'name', 'launchType', 'commandType', 'trigger', 'scheduleRepeatType', 'listensTo', 'organization', 'commandRunners', 'schedule', 'shell', 'timeout', 'sudo', 'template', 'scheduleYear', 'timeToLiveSeconds', 'files', 'user', 'systems')]
        [String[]]$returnProperties,
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID',
            Position = 0, HelpMessage = 'The _id of the JumpCloud command you wish to query.
To find a JumpCloud CommandID run the command:
PS C:\> Get-JCCommand | Select name, _id
The CommandID will be the 24 character string populated for the _id field.
CommandID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically using a function that returns the JumpCloud CommandID. This is shown in EXAMPLES  3 and 4.')]
        [Alias('_id', 'id')]
        [String[]]$CommandID,

        [Parameter(
            ParameterSetName = 'ByID', HelpMessage = 'Use the -ByID parameter when you want to query the contents of a specific command or if the -CommandID is being passed over the pipeline to return the full contents of a JumpCloud command. The -ByID SwitchParameter will set the ParameterSet to ''ByID'' which queries one JumpCloud command at a time.')]
        [Switch]
        $ByID
    )
    begin {
        Write-Debug 'Verifying JCAPI Key'
        if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
            Connect-JConline
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
        [int]$limit = '100'
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
                            (($Search.filter).GetEnumerator()).add($param.Key, $param.value)

                        continue
                    }
                    if ($param.key -eq 'returnProperties') {
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

                $SearchJSON = $Search | ConvertTo-Json -Compress -Depth 4

                Write-Debug $SearchJSON

                $URL = "$JCUrlBasePath/api/search/commands"

                if ($Parallel) {
                    $resultsArrayList = Get-JCResults -URL $URL -method "POST" -limit $limit -body $SearchJSON -Parallel $true
                } else {
                    $resultsArrayList = Get-JCResults -URL $URL -method "POST" -limit $limit -body $SearchJSON
                }

            } # End Search
            ByID {
                foreach ($uid in $CommandID) {
                    $URL = "$JCUrlBasePath/api/commands/$uid"
                    Write-Debug $URL
                    $rawResults = Get-JCResults -URL $URL -method "GET" -limit $limit
                    $resultsArrayList.Add($rawResults)
                }
            }
        }# End Switch
    }
    end {
        switch ($PSCmdlet.ParameterSetName) {
            SearchFilter {
                return $resultsArrayList | Sort-Object name
            }
            ByID {
                return $resultsArrayList | Select-Object -Property *
            }
        }
    }

}