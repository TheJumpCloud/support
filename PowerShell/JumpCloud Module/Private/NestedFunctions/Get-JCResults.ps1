Function Get-JCResults
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, HelpMessage = 'URL of Endpoint')][ValidateNotNullOrEmpty()]$URL
    )
    begin {
        $hdrs = @{
            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY
        }
        $resultsArray = @()
        $totalCount = 1
        $limit = 100
        $skip = 0
    }
    process {
        $limitURL = "$URL?limit=$limit&skip=$skip"
        Write-Debug $limitURL
        $response = Invoke-WebRequest -Method GET -Uri $limitURL -Headers $hdrs -UserAgent:(Get-JCUserAgent)
        $totalCount = $response.Headers."x-total-count"
        Write-Debug "total count: $totalCount"
        $passCounter = [math]::ceiling($totalCount/$limit)
        Write-Debug "number of passes: $passCounter"
        $resultsArray += $response.Content | ConvertFrom-Json

        for($i = 1; $i -lt $passCounter; $i++) {
            $skip += $limit
            $limitURL = "$URL?limit=$limit&skip=$skip"
            $response = Invoke-WebRequest -Method GET -Uri $limitURL -Headers $hdrs -UserAgent:(Get-JCUserAgent)
            $resultsArray += $response.Content | ConvertFrom-Json
            Write-Debug ($response.Content | ConvertFrom-Json).Count
        }
        return $resultsArray
    }
}