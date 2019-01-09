function Get-JCPolicyResult () 
{
    [CmdletBinding(DefaultParameterSetName = 'ByPolicyName')]

    param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByPolicyID',
            Position = 0)]
        [Alias('_id', 'id')]
        [String]$PolicyID,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByPolicyName',
            Position = 0)]
        [Alias('name')]
        [String]$PolicyName,

        [Parameter(
            ParameterSetName = 'ReturnAll')]

        [Parameter(
            ParameterSetName = 'MaxResults')]

        [Parameter(
            ParameterSetName = 'ByPolicyName')]

        [Parameter(
            ParameterSetName = 'ByPolicyID')]

        [int]$Skip = 0,

        [Parameter(
            ParameterSetName = 'ReturnAll')]

        [Parameter(
            ParameterSetName = 'MaxResults')]

        [Parameter(
            ParameterSetName = 'ByPolicyName')]
    
        [Parameter(
            ParameterSetName = 'ByPolicyID')]

        [ValidateRange(0, 100)]
        [int]$Limit = 1,

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
        $resultsArray = @()
        $Url_Template1 = '{0}/api/v2/policies/{1}{2}'
        $Url_Template2 = '{0}/api/v2/policyresults{1}{2}'
        $Url_Template3 = '{0}/api/v2/systems{1}{2}'


        if ($PSCmdlet.ParameterSetName -eq 'ByPolicyName')
        {
            Write-Debug 'Populating PolicyNameHash'
            $PolicyNameHash = Get-Hash_PolicyName_ID
        }
    }

    process

    {

        switch ($PSCmdlet.ParameterSetName)
        {
            ReturnAll
            { 
                #$PolicyResults = @{}
                #$activepolicies = Get-jcpolicy | Select-Object id
                #$PolicyArrayList = New-Object -TypeName System.Collections.ArrayList

                #Write-Verbose "Setting skip to $skip"

                #[int]$Counter = 0 
    
                # while (($resultsArray.results).count -ge $Counter)
                # {
                #     foreach ($policy in $activepolicies)
                #     {
                #     $Uri = $Url_Template1 -f $JCUrlBasePath, $policy.id, "/policystatuses?limit=1&skip=$skip"
                #     $limitURL = "$JCUrlBasePath/api/commandresults?limit=$limit&skip=$skip"
                #     Write-Verbose $Uri
    
                #     $PolicyResults = Invoke-RestMethod -Method GET -Uri $Uri -Headers $hdrs -UserAgent $JCUserAgent
                #     $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs
    
                #     $PolicyArrayList += $PolicyResults
                #     $skip += $limit
                #     $Counter += $limit
                #     Write-Verbose "Setting skip to $skip"
                #     Write-Verbose "Setting Counter to $Counter"
    
                #     $resultsArray += $results
                #     $count = ($resultsArray.results.Count)
                #     Write-Verbose "Results count equals $count"
                #     }
                # }
                

                $PolicyResults = @{}
                $activepolicies = Get-jcpolicy | Select-Object id
                $PolicyArrayList = New-Object -TypeName System.Collections.ArrayList
                [int]$Counter = 0 
                #While($PolicyArrayList.Count -ge $counter)
                #{  
                foreach ($policy in $activepolicies)
                {
                    $Uri = $Url_Template1 -f $JCUrlBasePath, $policy.id, "/policystatuses?skip=$Skip"
                    Write-host $uri -BackgroundColor Cyan
                    $PolicyResults = Invoke-RestMethod -Method GET -Uri $Uri -Headers $hdrs -UserAgent $JCUserAgent
                    $PolicyArrayList += $PolicyResults
                    #$skip += $Limit
                    $Counter += $Limit
                    write-output $PolicyResults.count
                    Write-Output $PolicyArrayList.count
                    Write-Output "Limit - $Limit"
                    Write-Output "Counter - $Counter"
                    Write-Output "Skip - $skip"
                    #}
                }
                #return $PolicyArrayList
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
    
                    
                        $resultsArray += $results
                        $count = ($resultsArray).Count
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
            
                            $resultsArray += $results
                            $count = ($resultsArray.results.Count)
                            Write-Verbose "Results count equals $count"

                            if ($MaxResults -le $limit)
                            {
                                $limit = $MaxResults                                
                            }
                        }


                    }
                }
                
                
            }
            ByPolicyName
            {

                if ($PolicyNameHash.containsKey($PolicyName))
                {

                    $PolicyID = $PolicyNameHash.Get_Item($PolicyName)
                }

                else { Throw "Policy does not exist. Run 'Get-JCPolicy' to see a list of all your JumpCloud policies."}

                ## Implement skip / limit... same 0, 100 logic

                $URL = "$JCUrlBasePath/api/v2/policies/$PolicyID/policystatuses"
                Write-Verbose $URL

                $PolicyResults = Invoke-RestMethod -Method GET -Uri $URL -Headers $hdrs

                $resultsArray += $PolicyResults
            }
            ByPolicyID
            {
                $URL = "$JCUrlBasePath/api/v2/policies/$PolicyID/policystatuses"
                Write-Verbose $URL

                $PolicyResults = Invoke-RestMethod -Method GET -Uri $URL -Headers $hdrs

                $resultsArray += $PolicyResults
            }
            BySystemID
            {
                $URL = "$JCUrlBasePath/api/v2/systems/$SystemID/policystatuses"
                Write-Verbose $URL

                $PolicyResults = Invoke-RestMethod -Method GET -Uri $URL -Headers $hdrs

                $resultsArray += $PolicyResults
            }
            ByPolicyResultID
            {
                $URL = "$JCUrlBasePath/api/v2/policyresults/$PolicyResultID/"
                Write-Verbose $URL

                $PolicyResults = Invoke-RestMethod -Method GET -Uri $URL -Headers $hdrs

                $resultsArray += $PolicyResults
            }
        }
    }

    end

    {
        switch ($PSCmdlet.ParameterSetName)
        {
            # MaxResults {Return $resultsArray}
            ByPolicyID {Return  $resultsArray}
            BySystemID {Return  $resultsArray}
            # ByPolicyResultID {Return  $resultsArray}
            ByPolicyName {Return $resultsArray}
        }
    }
}
#Get-JCPolicyResult