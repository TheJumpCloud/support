Function Get-JCPolicy ()
{
    [CmdletBinding(DefaultParameterSetName = 'ReturnAll')]

    param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID',
            Position = 0)]
        [Alias('_id', 'id')]
        [String]$PolicyID,

        [Parameter(
            ParameterSetName = 'Name')]
        [String]
        $Name
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

        [int]$limit = '100'
        Write-Debug "Setting limit to $limit"

        Write-Debug 'Initilizing resultsArray and resultsArrayByID'
        $resultsArray = @()
    }

    process

    {

        switch ($PSCmdlet.ParameterSetName) 
        {
            "ReturnAll"
            {              
                
                Write-Debug 'Setting skip to zero'
                [int]$skip = 0 #Do not change!

                while (($resultsArray).Count -ge $skip)
                {
                    $limitURL = "$JCUrlBasePath/api/v2/policies?limit=$limit&skip=$skip"
                    Write-Debug $limitURL

                    $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs -UserAgent $JCUserAgent

                    $formattedResults = $results | Select-object name, id

                    $skip += $limit
                    Write-Debug "Setting skip to $skip"

                    $resultsArray += $formattedResults
                    $count = ($resultsArray).Count
                    Write-Debug "Results count equals $count"
                }
            }
            "ByID"
            {
                
                foreach ($uid in $PolicyID)
                {
                    $URL = "$JCUrlBasePath/api/v2/policies/$uid"
                    Write-Debug $URL
                    $PolicyResults = Invoke-RestMethod -Method GET -Uri $URL -Headers $hdrs -UserAgent $JCUserAgent
                    $formattedResults = $PolicyResults | Select-object name, id
                    $resultsArray += $formattedResults
    
                }
            }
            "Name"
            {

                Write-Debug 'Setting skip to zero'
                [int]$skip = 0 #Do not change!

                while (($resultsArray).Count -ge $skip)
                {
                    $limitURL = "$JCUrlBasePath/api/v2/policies?limit=$limit&skip=$skip&sort=name&filter=name%3Asearch%3A$Name"
                    Write-Debug $limitURL

                    $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs -UserAgent $JCUserAgent

                    $formattedResults = $results | Select-object name, id

                    $skip += $limit
                    Write-Debug "Setting skip to $skip"

                    $resultsArray += $formattedResults
                    $count = ($resultsArray).Count
                    Write-Debug "Results count equals $count"
                }

            }
        }
        
        

    }

    end

    {
        return $resultsArray
    }
}
