function Get-JCCommandResult () 
{
    [CmdletBinding(DefaultParameterSetName = 'ReturnAll')]

    param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID',
            Position = 0)]
        [Alias('_id', 'id')]
        [String]$CommandResultID,

        [Parameter(
            ParameterSetName = 'ByID')]
        [Switch]
        $ByID,

        [Parameter(
            ParameterSetName = 'TotalCount')]
        [Switch]
        $TotalCount,

        [Parameter(
            ParameterSetName = 'ReturnAll')]

        [Parameter(
            ParameterSetName = 'MaxResults')]

        [int]$Skip = 0,

        [Parameter(
            ParameterSetName = 'ReturnAll')]

        [Parameter(
            ParameterSetName = 'MaxResults')]

        [ValidateRange(0, 100)]
        [int]$Limit = 100,

        [Parameter(
            ParameterSetName = 'MaxResults')]
        [Int]
        $MaxResults
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

        Write-Verbose 'Initilizing resultsArraylist'
        $resultsArrayList = New-Object -TypeName System.Collections.ArrayList
    }

    process

    {

        switch ($PSCmdlet.ParameterSetName)
        {
            TotalCount
            { 

                $CountURL = "$JCUrlBasePath/api/commandresults?limit=1&skip=0"
                $results = Invoke-RestMethod -Method GET -Uri  $CountURL -Headers $hdrs
                $null = $resultsArrayList.Add($results.totalCount)


            }
            ReturnAll
            { 
                Write-Verbose "Setting skip to $skip"

                [int]$Counter = 0 
    
                while (($resultsArrayList.results).count -ge $Counter)
                {
                    $limitURL = "$JCUrlBasePath/api/commandresults?limit=$limit&skip=$skip"
                    Write-Verbose $limitURL
    
                    $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs
    
                    $skip += $limit
                    $Counter += $limit
                    Write-Verbose "Setting skip to $skip"
                    Write-Verbose "Setting Counter to $Counter"
    
                    $null = $resultsArrayList.Add($results)
                    $count = ($resultsArrayList.results.Count)
                    Write-Verbose "Results count equals $count"
                }
            }
            MaxResults
            { 

                switch ($MaxResults)
                {
                    { $_ -le $limit}
                    { 

                        $Limit = $MaxResults
                        $limitURL = "$JCUrlBasePath/api/commandresults?limit=$limit&skip=$skip"
                        Write-Verbose $limitURL
    
                        $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs
    
                    
                        $null = $resultsArrayList.Add($results)
                        $count = ($resultsArrayList).Count
                        Write-Verbose "Results count equals $count"

                    }
                    {$_ -gt $limit}
                    {

                        Write-Verbose "Setting skip to $skip"

                        [int]$Counter = 0 
            
                        while ($MaxResults -ne 0)
                        {
                            $limitURL = "$JCUrlBasePath/api/commandresults?limit=$limit&skip=$skip"
                            Write-Verbose $limitURL
            
                            $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs

                            $MaxResults = $MaxResults - $limit
           
                            $skip += $limit
                            $Counter += $limit
                            Write-Verbose "Setting skip to $skip"
                            Write-Verbose "Setting Counter to $Counter"
            
                            $null = $resultsArrayList.Add($results)
                            $count = ($resultsArrayList.results.Count)
                            Write-Verbose "Results count equals $count"

                            if ($MaxResults -le $limit)
                            {
                                $limit = $MaxResults                                
                            }
                        }


                    }
                }
                
                
            }
            ByID
            {
                $URL = "$JCUrlBasePath/api/commandresults/$CommandResultID"
                Write-Verbose $URL

                $CommandResults = Invoke-RestMethod -Method GET -Uri $URL -Headers $hdrs

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
    }

    end

    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ReturnAll {Return $resultsArrayList.results}
            MaxResults {Return $resultsArrayList.results}
            TotalCount {Return  $resultsArrayList }
            ByID {Return  $resultsArrayList }
        }
    }
}