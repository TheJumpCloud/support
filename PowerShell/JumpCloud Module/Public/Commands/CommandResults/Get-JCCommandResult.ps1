function Get-JCCommandResult ()
{
    [CmdletBinding(DefaultParameterSetName = 'ReturnAll')]

    param
    (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ByID', Position = 0, HelpMessage = 'The _id of the JumpCloud Command Result you wish to query.')]
        [Alias('_id', 'id')]
        [String]$CommandResultID,

        [Parameter(ParameterSetName = 'ByID', HelpMessage = 'Use the -ByID parameter when you want to query the contents of a specific Command Result or if the -CommandResultID is being passed over the pipeline to return the full contents of a JumpCloud Command Result. The -ByID SwitchParameter will set the ParameterSet to ''ByID'' which queries one JumpCloud Command Result at a time.')]
        [Switch]$ByID,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ByCommandID', HelpMessage = 'The _id of the JumpCloud Command you wish to query.')]
        [Alias('WorkflowID')]
        [String]$CommandID,

        [Parameter(ParameterSetName = 'TotalCount', HelpMessage = 'A switch parameter to only return the number of command results.')]
        [Switch]$TotalCount,

        [Parameter(ValueFromPipelineByPropertyName , HelpMessage = 'Boolean: $true to run in parallel, $false to run in sequential; Default value: false')]
        [Bool]$Parallel=$false
    )
    begin
    {
        Write-Verbose 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

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

        if (($PSVersionTable.PSVersion.Major -ge 7) -and ($parallel -eq $true)) {
            Write-Debug "Parallel set to True, PSVersion greater than 7"
            $resultsArray = [System.Collections.Concurrent.ConcurrentBag[object]]::new()
            $resultsArrayList = [System.Collections.Concurrent.ConcurrentBag[object]]::new()
        }
        else {
            $parallel = $false
            Write-Verbose 'Initilizing resultsArraylist'
            $resultsArray = New-Object -TypeName System.Collections.ArrayList
            $resultsArrayList = New-Object -TypeName System.Collections.ArrayList
        }
        $limit = 100
    }
    process
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            TotalCount
            {
                $CountURL = "$JCUrlBasePath/api/commandresults?limit=1&skip=0"
                $results = Invoke-RestMethod -Method GET -Uri  $CountURL -Headers $hdrs -UserAgent:(Get-JCUserAgent)
                $null = $resultsArrayList.Add($results.totalCount)
            }#End TotalCount
            ReturnAll
            {
                $limitURL = "$JCUrlBasePath/api/commandresults"
                if ($Parallel) {
                    $resultsArrayList = Get-JCResults -Url $limitURL -method "GET" -limit $limit -parallel $true
                }
                else {
                    $resultsArrayList = Get-JCResults -Url $limitURL -method "GET" -limit $limit
                }
                $count = ($resultsArrayList.Count)
                Write-Verbose "Results count equals $count"
            }#End ReturnAll
            ByCommandID 
            {
                $limitURL = "$JCUrlBasePath/api/commandresults"
                if ($Parallel) {
                    $resultsArray = Get-JCResults -Url $limitURL -method "GET" -limit $limit -parallel $true
                }
                else {
                    $resultsArray = Get-JCResults -Url $limitURL -method "GET" -limit $limit
                }
                if (($resultsArray.count -gt 1) -and $Parallel) {
                    $GetJCUserAgent = Get-JCUserAgent
                    $resultsArray | Foreach-Object -Parallel {
                        $CommandID = $using:CommandID
                        if ($_.workflowId -ne $CommandID) { return }
                        $resultsArrayList = $using:resultsArrayList
                        $URL = "$using:JCUrlBasePath/api/commandresults/$($_._id)"
                        $CommandResults = Invoke-RestMethod -Method GET -Uri $URL -Headers $using:hdrs -MaximumRetryCount 5 -RetryIntervalSec 5 -UserAgent:$using:GetJCUserAgent

                        $FormattedResults = [PSCustomObject]@{
                            name               = $CommandResults.name
                            command            = $CommandResults.command
                            system             = $CommandResults.system
                            systemId           = $CommandResults.systemId
                            organization       = $CommandResults.organization
                            workflowId         = $CommandResults.workflowId
                            workflowInstanceId = $CommandResults.workflowInstanceId
                            output             = $CommandResults.response.data.output
                            exitCode           = $CommandResults.response.data.exitCode
                            user               = $CommandResults.user
                            sudo               = $CommandResults.sudo
                            requestTime        = $CommandResults.requestTime
                            responseTime       = $CommandResults.responseTime
                            _id                = $CommandResults._id
                            error              = $CommandResults.response.error
                        }
                        $null = $resultsArrayList.Add($FormattedResults)
                    }
                    $resultsArrayList = $resultsArrayList | Sort-Object -Property requestTime
                }
                else {
                    $resultsArray | Foreach-Object {
                        if ($_.workflowId -ne $CommandID) { return }
                        $URL = "$JCUrlBasePath/api/commandresults/$($_._id)"
                        $CommandResults = Get-JCResults -Method "GET" -URL $URL -limit $limit

                        $FormattedResults = [PSCustomObject]@{
                            name               = $CommandResults.name
                            command            = $CommandResults.command
                            system             = $CommandResults.system
                            systemId           = $CommandResults.systemId
                            organization       = $CommandResults.organization
                            workflowId         = $CommandResults.workflowId
                            workflowInstanceId = $CommandResults.workflowInstanceId
                            output             = $CommandResults.response.data.output
                            exitCode           = $CommandResults.response.data.exitCode
                            user               = $CommandResults.user
                            sudo               = $CommandResults.sudo
                            requestTime        = $CommandResults.requestTime
                            responseTime       = $CommandResults.responseTime
                            _id                = $CommandResults._id
                            error              = $CommandResults.response.error
                        }
                        $null = $resultsArrayList.Add($FormattedResults)
                    }
                }
                if ($resultsArrayList.count -eq 0) {
                    throw "No command results found"
                }
            }#End ByCommandID
            ByID
            {
                $URL = "$JCUrlBasePath/api/commandresults/$CommandResultID"
                Write-Verbose $URL
                $CommandResults = Invoke-RestMethod -Method GET -Uri $URL -Headers $hdrs -UserAgent:(Get-JCUserAgent)
                $FormattedResults = [PSCustomObject]@{

                    name               = $CommandResults.name
                    command            = $CommandResults.command
                    system             = $CommandResults.system
                    systemId           = $CommandResults.systemId
                    organization       = $CommandResults.organization
                    workflowId         = $CommandResults.workflowId
                    workflowInstanceId = $CommandResults.workflowInstanceId
                    output             = $CommandResults.response.data.output
                    exitCode           = $CommandResults.response.data.exitCode
                    user               = $CommandResults.user
                    sudo               = $CommandResults.sudo
                    requestTime        = $CommandResults.requestTime
                    responseTime       = $CommandResults.responseTime
                    _id                = $CommandResults._id
                    error              = $CommandResults.response.error
                }
                $null = $resultsArrayList.Add($FormattedResults)
            }#End ByID
        }
    }
    end
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ReturnAll {Return $resultsArrayList}
            TotalCount {Return  $resultsArrayList }
            ByCommandID {Return  $resultsArrayList }
            ByID {Return  $resultsArrayList }
        }
    }
}