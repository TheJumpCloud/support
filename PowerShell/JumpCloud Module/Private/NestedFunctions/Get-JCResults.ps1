Function Get-JCResults
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, HelpMessage = 'URL of Endpoint')][ValidateNotNullOrEmpty()]$URL,
        [Parameter(Mandatory = $true, HelpMessage = 'Method of WebRequest')][ValidateNotNullOrEmpty()]$method,
        [Parameter(Mandatory = $true, HelpMessage = 'Limit of WebRequest')][ValidateNotNullOrEmpty()]$limit,
        [Parameter(Mandatory = $false, HelpMessage = 'Body of WebRequest, if required')]$body,
        [Parameter(Mandatory = $false, HelpMessage = 'Boolean: True to run in parallel, False to run in sequential')][bool]$parallel = $false
    )
    begin {
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
        }
        else {
            Write-Debug "Running in Sequential"
            $resultsArray = @()
        }
        $totalCount = 1
        $limit = [int]$limit
        $skip = 0
    }
    process {
        $limitURL = $URL + "?limit=$limit&skip=$skip"
        Write-Debug $limitURL
        $response = Invoke-WebRequest -Method GET -Uri $limitURL -Headers $hdrs -UserAgent:(Get-JCUserAgent)
        $totalCount = $response.Headers."x-total-count"
        $totalCount = [int]$totalCount.Trim()
        Write-Debug "total count: $totalCount"
        $passCounter = [math]::ceiling($totalCount/$limit)
        Write-Debug "number of passes: $passCounter"

        # Running Function in Parallel
        if (($PSVersionTable.PSVersion.Major -ge 7) -and ($parallel -eq $true)) {
            $content = $response.Content
            $resultsArray.Add($content)
            if ($passCounter -gt 1) {
                1..$passCounter | ForEach-Object -Parallel {
                    $resultsArray = $using:resultsArray
                    $skip = $_ * $using:limit
                    $limitURL = $using:URL + "?limit=$using:limit&skip=$skip"
                    if ($using:body){
                        $response = Invoke-WebRequest -Method $using:method -Body $using:body -Uri $limitURL -Headers $using:hdrs -UserAgent:(Get-JCUserAgent)
                    }
                    else {
                        $response = Invoke-WebRequest -Method $using:method -Uri $limitURL -Headers $using:hdrs -UserAgent:(Get-JCUserAgent)
                    }
                    $content = $response.Content
                    $resultsArray.Add($content)
                }
            }
            $resultsArray = $resultsArray | ConvertFrom-Json
        }
        # Running Function in Sequential
        else {
            $resultsArray += $response.Content | ConvertFrom-Json
            for($i = 1; $i -lt $passCounter; $i++) {
                $skip += $limit
                $limitURL = $URL + "?limit=$limit&skip=$skip"
                if ($body){
                    $response = Invoke-WebRequest -Method $method -Body $body -Uri $limitURL -Headers $hdrs -UserAgent:(Get-JCUserAgent)
                }
                else {
                    $response = Invoke-WebRequest -Method $method -Uri $limitURL -Headers $hdrs -UserAgent:(Get-JCUserAgent)
                }
                $resultsArray += $response.Content | ConvertFrom-Json
                Write-Debug ("Pass: $i Amount: " + ($response.Content | ConvertFrom-Json).Count)
            }
        }
    }
    end {
        return $resultsArray
    }
}