
Function Get-JCCommand ()
{
    [CmdletBinding(DefaultParameterSetName = 'SearchFilter')]

    param
    (

    #### NEW PARAMS
        [Parameter( ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', Position = 0, HelpMessage = 'The command to execute on the server.')]
        [String]$command,
        [Parameter( ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', Position = 0, HelpMessage = 'Name of the command')]
        [String]$name,
        [Parameter( ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', Position = 0, HelpMessage = 'Command Type')]
        [string]$commandType,
        [Parameter( ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', Position = 0, HelpMessage = 'Launch Type')]
        [string]$launchType,
        [Parameter( ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', Position = 0, HelpMessage = 'Listens To')]
        [string]$listensTo,
        [Parameter( ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', Position = 0, HelpMessage = 'Schedule')]
        [string]$schedule,
        [Parameter( ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', Position = 0, HelpMessage = 'The name of the command trigger')]
        [string]$trigger,
        [Parameter( ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', Position = 0, HelpMessage = 'When the command will repeat')]
        [string]$scheduleRepeatType,
        [Parameter( ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', Position = 0, HelpMessage = 'The ID of the organization')]
        [string]$organization,
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SearchFilter', HelpMessage = 'Allows you to return select properties on JumpCloud user objects. Specifying what properties are returned can drastically increase the speed of the API call with a large data set. Valid properties that can be returned are: ''command'', ''name'',''commandType'', ''launchType'',''schedule'',''trigger'',''scheduleRepeatType'',''organization''')]
        [ValidateSet('command', 'name', 'commandType', 'launchType', 'schedule', 'trigger', 'scheduleRepeatType', 'organization')]
        [String[]]$returnProperties,
    #### NEW PARAMS END
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
    begin

    {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Debug 'Populating API headers'
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
        [int]$limit = '100'
        Write-Verbose "Setting limit to $limit"

        [int]$skip = '0'
        Write-Verbose "Setting limit to $limit"

        [int]$Counter = 0

        if ($PSCmdlet.ParameterSetName -eq 'ReturnAll')

        {

            Write-Debug 'Setting skip to zero'
            [int]$skip = 0 #Do not change!

            while (($resultsArrayList).Count -ge $skip)
            {
                $limitURL = "$JCUrlBasePath/api/commands?sort=type,_id&limit=$limit&skip=$skip"
                Write-Debug $limitURL

                $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs -UserAgent:(Get-JCUserAgent)

                $skip += $limit
                Write-Debug "Setting skip to $skip"
                $resultsArrayList += $results.results
                $count = ($resultsArrayList).Count
                Write-Debug "Results count equals $count"
            }
        }

 
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

                        $Value = ($param.value).replace('*', '')

                        if (($param.Value -match '.+?\*$') -and ($param.Value -match '^\*.+?'))
                        {
                            # Front and back wildcard
                            (($Search.filter).GetEnumerator()).add($param.Key, @{'$regex' = "$Value" })
                        }
                        elseif ($param.Value -match '.+?\*$')
                        {
                            # Back wildcard
                            (($Search.filter).GetEnumerator()).add($param.Key, @{'$regex' = "^$Value" })
                        }
                        elseif ($param.Value -match '^\*.+?')
                        {
                            # Front wild card
                            (($Search.filter).GetEnumerator()).add($param.Key, @{'$regex' = "$Value`$" })
                        }
                        else
                        {
                            (($Search.filter).GetEnumerator()).add($param.Key, $Value)
                        }
                        
                    } # End foreach
  

                    $SearchJSON = $Search | ConvertTo-Json -Compress -Depth 4

                    Write-Debug $SearchJSON

                    $URL = "$JCUrlBasePath/api/search/commands"

                    $Results = Invoke-RestMethod -Method POST -Uri $Url  -Header $hdrs -Body $SearchJSON -UserAgent:(Get-JCUserAgent)

                    $null = $resultsArrayList.Add($Results)

                    $Skip += $limit

                    $Counter += $limit
                } #End While

    } # End Search
    ByID
    {
        foreach ($uid in $CommandID)
            {
                $URL = "$JCUrlBasePath/api/commands/$uid"
                Write-Debug $URL
                $CommandResults = Invoke-RestMethod -Method GET -Uri $URL -Headers $hdrs -UserAgent:(Get-JCUserAgent)
                $null = $resultsArrayList.add($CommandResults)

            }
    }
}# End Switch
    }
    end
    {

        switch ($PSCmdlet.ParameterSetName)
        {
            SearchFilter
            {
                return $resultsArrayList.Results | Select-Object -Property * 
            }
            ByID
            {
                return $resultsArrayList | Select-Object -Property * 
            }

        }

    }

}

  
    
