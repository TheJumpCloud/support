
Function Get-JCCommand ()
{
    [CmdletBinding(DefaultParameterSetName = 'ReturnAll')]

    param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID',
            Position = 0)]
        [Alias('_id', 'id')]
        [String[]]$CommandID,

        [Parameter(
            ParameterSetName = 'ByID')]
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

        [int]$limit = '100'
        Write-Debug "Setting limit to $limit"

        Write-Debug 'Initilizing resultsArray and resultsArrayByID'
        $resultsArray = @()
    }

    process

    {

        if ($PSCmdlet.ParameterSetName -eq 'ReturnAll')

        {

            Write-Debug 'Setting skip to zero'
            [int]$skip = 0 #Do not change!

            while (($resultsArray).Count -ge $skip)
            {
                $limitURL = "$JCUrlBasePath/api/commands?sort=type,_id&limit=$limit&skip=$skip"
                Write-Debug $limitURL

                $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs -UserAgent:(Get-JCUserAgent -PSCallStack:(Get-PSCallStack))

                $skip += $limit
                Write-Debug "Setting skip to $skip"

                $resultsArray += $results.results
                $count = ($resultsArray).Count
                Write-Debug "Results count equals $count"
            }
        }

        elseif ($PSCmdlet.ParameterSetName -eq 'ByID')

        {
            foreach ($uid in $CommandID)
            {
                $URL = "$JCUrlBasePath/api/commands/$uid"
                Write-Debug $URL
                $CommandResults = Invoke-RestMethod -Method GET -Uri $URL -Headers $hdrs -UserAgent:(Get-JCUserAgent -PSCallStack:(Get-PSCallStack))
                $resultsArray += $CommandResults

            }
        }

    }

    end

    {
        return $resultsArray
    }
}