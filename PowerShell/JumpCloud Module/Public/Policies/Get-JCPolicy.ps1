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
        [String]$Name
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
        #$resultsArray = @()
    }

    process

    {

        switch ($PSCmdlet.ParameterSetName) 
        {
            "ReturnAll"
            {              
                $URL = "$JCUrlBasePath/api/v2/policies"
                # Write-Debug 'Setting skip to zero'
                # [int]$skip = 0 #Do not change!

                # while (($resultsArray).Count -ge $skip)
                # {
                #     $limitURL = "$JCUrlBasePath/api/v2/policies?limit=$limit&skip=$skip"
                #     Write-Debug $limitURL

                #     $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs -UserAgent $JCUserAgent

                #     $formattedResults = $results | Select-object name, id

                #     $skip += $limit
                #     Write-Debug "Setting skip to $skip"

                #     $resultsArray += $formattedResults
                #     $count = ($resultsArray).Count
                #     Write-Debug "Results count equals $count"
                # }
            }
            "ByID"
            {
                $URL = "$JCUrlBasePath/api/v2/policies$uid"
                # foreach ($uid in $PolicyID)
                # {
                #     $URL = "$JCUrlBasePath/api/v2/policies/$uid"
                #     Write-Debug $URL
                #     $PolicyResults = Invoke-RestMethod -Method GET -Uri $URL -Headers $hdrs -UserAgent $JCUserAgent
                #     $formattedResults = $PolicyResults | Select-object name, id
                #     $resultsArray += $formattedResults
    
                # }
            }
            "Name"
            {
                $URL = "$JCUrlBasePath/api/v2/policies?sort=name&filter=name%3Asearch%3A$Name"

                # Write-Debug 'Setting skip to zero'
                # [int]$skip = 0 #Do not change!

                # while (($resultsArray).Count -ge $skip)
                # {
                #     $limitURL = "$JCUrlBasePath/api/v2/policies?limit=$limit&skip=$skip&sort=name&filter=name%3Asearch%3A$Name"
                #     Write-Debug $limitURL

                #     $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs -UserAgent $JCUserAgent

                #     $formattedResults = $results | Select-object name, id

                #     $skip += $limit
                #     Write-Debug "Setting skip to $skip"

                #     $resultsArray += $formattedResults
                #     $count = ($resultsArray).Count
                #     Write-Debug "Results count equals $count"
                # }

            }
        }
    }

    end

    {
        $Result = Invoke-JCApiGet -URL $URL 
        $Result | Select-object name, id
        #return $resultsArray
    }
}
