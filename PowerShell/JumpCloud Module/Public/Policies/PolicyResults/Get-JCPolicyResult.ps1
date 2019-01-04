function Get-JCPolicyResult () 
{
    [CmdletBinding(DefaultParameterSetName = 'ReturnAll')]

    param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByPolicyID',
            Position = 0)]
        [Alias('_id', 'id')]
        [String]$PolicyID,

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
        $MaxResults,

        [Parameter(
            ParameterSetName = 'BySystemID')]
        [String]
        $SystemID,

        [Parameter(
            ParameterSetName = 'ByPolicyResultID')]
        [String]
        $PolicyResultID
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
        #$Url_Template = 'https://events.jumpcloud.com/events?startDate={0}&endDate={1}'
    }

    process

    {

        switch ($PSCmdlet.ParameterSetName)
        {
            TotalCount
            { 

                $activepolicies = Get-jcpolicy | select id
                $3 = New-Object -TypeName System.Collections.ArrayList

                    foreach ($1 in $activepolicies)
                    {
                        $2 = "https://console.jumpcloud.com/api/v2/policies/" + $1.id + "/policystatuses"
                        $PolicyResults = Invoke-RestMethod -Method GET -Uri $2 -Headers $hdrs -UserAgent $JCUserAgent
                        $3 += $PolicyResults
                    }

                $null = $resultsArrayList.Add($3.Count)
            }
            ReturnAll
            { 

                $activepolicies = Get-jcpolicy | select id
                $3 = New-Object -TypeName System.Collections.ArrayList

                    foreach ($1 in $activepolicies)
                    {
                        $2 = "https://console.jumpcloud.com/api/v2/policies/" + $1.id + "/policystatuses"
                        $PolicyResults = Invoke-RestMethod -Method GET -Uri $2 -Headers $hdrs -UserAgent $JCUserAgent
                        $3 += $PolicyResults
                    }
                    return $3

                # Write-Verbose "Setting skip to $skip"

                # [int]$Counter = 0 
    
                # while (($resultsArrayList.results).count -ge $Counter)
                # {
                #     $limitURL = "$JCUrlBasePath/api/commandresults?limit=$limit&skip=$skip"
                #     Write-Verbose $limitURL
    
                #     $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs
    
                #     $skip += $limit
                #     $Counter += $limit
                #     Write-Verbose "Setting skip to $skip"
                #     Write-Verbose "Setting Counter to $Counter"
    
                #     $null = $resultsArrayList.Add($results)
                #     $count = ($resultsArrayList.results.Count)
                #     Write-Verbose "Results count equals $count"
                # }
            }
            MaxResults
            { 

                switch ($MaxResults)
                {
                    { $_ -le $limit}
                    { 

                        $Limit = $MaxResults
                        $limitURL = "$JCUrlBasePath/api/v2/policyresults?limit=$limit&skip=$skip"
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
                            $limitURL = "$JCUrlBasePath/api/v2/policyresults?limit=$limit&skip=$skip"
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
            ByPolicyID
            {
                $URL = "$JCUrlBasePath/api/v2/policies/$PolicyID/policystatuses"
                Write-Verbose $URL

                $PolicyResults = Invoke-RestMethod -Method GET -Uri $URL -Headers $hdrs

                $null = $resultsArrayList.Add($PolicyResults)
            }
            BySystemID
            {
                $URL = "$JCUrlBasePath/api/v2/systems/$SystemID/policystatuses"
                Write-Verbose $URL

                $PolicyResults = Invoke-RestMethod -Method GET -Uri $URL -Headers $hdrs

                $null = $resultsArrayList.Add($PolicyResults)
            }
            ByPolicyResultID
            {
                $URL = "$JCUrlBasePath/api/v2/policyresults/$PolicyResultID/"
                Write-Verbose $URL

                $PolicyResults = Invoke-RestMethod -Method GET -Uri $URL -Headers $hdrs

                $null = $resultsArrayList.Add($PolicyResults)
            }
        }
    }

    end

    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ReturnAll {Return $resultsArrayList.results}
            MaxResults {Return $resultsArrayList}
            TotalCount {Return  $resultsArrayList }
            ByPolicyID {Return  $resultsArrayList }
            BySystemID {Return  $resultsArrayList }
            ByPolicyResultID {Return  $resultsArrayList }
        }
    }
}