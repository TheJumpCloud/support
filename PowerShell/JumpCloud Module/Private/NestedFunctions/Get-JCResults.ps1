Function Get-JCResults
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, HelpMessage = 'URL of Endpoint')][ValidateNotNullOrEmpty()]$URL,
        [Parameter(Mandatory = $true, HelpMessage = 'Method of WebRequest')][ValidateNotNullOrEmpty()]$method,
        [Parameter(Mandatory = $true, HelpMessage = 'Limit of WebRequest')][ValidateNotNullOrEmpty()]$limit,
        [Parameter(Mandatory = $false, HelpMessage = 'Body of WebRequest, if required')]$body,
        [Parameter(Mandatory = $false, HelpMessage = 'Boolean: True to run in parallel, False to run in sequential; Default value: false')][bool]$parallel = $false
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
        # Check if parallel is supported
        if (($PSVersionTable.PSVersion.Major -ge 7) -and ($parallel -eq $true)) {
            Write-Debug "Parallel set to True, PSVersion greater than 7"
            $resultsArray = [System.Collections.Concurrent.ConcurrentBag[object]]::new()
            $errorResults = [System.Collections.Concurrent.ConcurrentBag[object]]::new()
        }
        # Check if unsupported parallel, give warning
        elseif (($PSVersionTable.PSVersion.Major -lt 7) -and ($parallel -eq $true)) {
            Write-Warning "The installed version of PowerShell does not support Parallel functionality. Consider updating to PowerShell 7 to use this feature."
            Write-Warning "Visit aka.ms/powershell-release?tag=stable for latest release"
            Write-Debug "Unsupported Parallel configuration... Running in Sequential"
            $resultsArray = [System.Collections.Generic.List[PSObject]]::new()
        }
        else {
            Write-Debug "Running in Sequential"
            $resultsArray = [System.Collections.Generic.List[PSObject]]::new()
        }
        $totalCount = 1
        $limit = [int]$limit
        $skip = 0
    }
    process {
        # Concat complete URL
        $limitURL = $URL + "?limit=$limit&skip=$skip"
        Write-Debug $limitURL

        # Attempt initial call and collect first page of results
        try {
            $response = Invoke-WebRequest -Method GET -Uri $limitURL -Headers $hdrs -UserAgent:(Get-JCUserAgent)
        }
        catch {
            throw $_
        }

        # Find total amount of results
        $totalCount = $response.Headers."x-total-count"
        $totalCount = [int]$totalCount.Trim()
        Write-Debug "total count: $totalCount"

        # Divide amount of results by limit to find amount of passes to fully collect results
        $passCounter = [math]::ceiling($totalCount/$limit)
        Write-Debug "number of passes: $passCounter"

        # Running Function in Parallel
        if (($PSVersionTable.PSVersion.Major -ge 7) -and ($parallel -eq $true)) {

            # Add content to threadsafe object
            $content = $response.Content
            $resultsArray.Add($content)

            # If the amount of results are greater than 1 page, proceed with parallel processing
            if ($passCounter -gt 1) {

                # Store JCUserAgent in variable to reference in each parallel session
                $GetJCUserAgent = Get-JCUserAgent

                # Perform Parallel Loop
                1..$passCounter | ForEach-Object -Parallel {
                    # Variables for containing results and errors
                    $errorResults = $using:errorResults
                    $resultsArray = $using:resultsArray

                    # Increment skip by limit after each pass and update URL
                    $skip = $_ * $using:limit
                    $limitURL = $using:URL + "?limit=$using:limit&skip=$skip"

                    # Check if body is present
                    if ($using:body){
                        try {
                            # Collect results and add to threadsafe array
                            $response = Invoke-WebRequest -Method $using:method -Body $using:body -Uri $limitURL -Headers $using:hdrs -MaximumRetryCount 5 -RetryIntervalSec 5 -UserAgent:($using:GetJCUserAgent)
                            $content = $response.Content
                            $resultsArray.Add($content)
                        }
                        catch {
                            # If error is encountered, add error object to threadsafe error array
                            $errorMessage = $_
                            $errorResults.Add($errorMessage)
                        }
                    }
                    else {
                        try {
                            # Collect results and add to threadsafe array
                            $response = Invoke-WebRequest -Method $using:method -Uri $limitURL -Headers $using:hdrs -MaximumRetryCount 5 -RetryIntervalSec 5 -UserAgent:($using:GetJCUserAgent)
                            $content = $response.Content
                            $resultsArray.Add($content)
                        }
                        catch {
                            # If error is encountered, add error object to threadsafe error array
                            $errorMessage = $_
                            $errorResults.Add($errorMessage)
                        }
                    }
                }
            }

            # If any parallel session encountered error, throw array containing any/all errors
            if ($errorResults.Count -ge 1){
                throw $errorResults
            }
            else {
                # Convert threadsafe JSON list to hashtable
                $resultsArray = $resultsArray | ConvertFrom-Json
            }
        }
        # Running Function in Sequential
        else {
            # Add results to results list
            $content = $response.Content
            [void]$resultsArray.Add($content)

            # Perform Sequential loop; only if there is more than 1 page of results
            for($i = 1; $i -lt $passCounter; $i++) {

                # Increment skip by limit after each pass and update URL
                $skip += $limit
                $limitURL = $URL + "?limit=$limit&skip=$skip"

                # Check if body is present
                if ($body) {
                    try {
                        $response = Invoke-WebRequest -Method $method -Body $body -Uri $limitURL -Headers $hdrs -UserAgent:(Get-JCUserAgent)
                    }
                    catch {
                        throw $_
                    }
                }
                else {
                    try {
                        $response = Invoke-WebRequest -Method $method -Uri $limitURL -Headers $hdrs -UserAgent:(Get-JCUserAgent)
                    }
                    catch {
                        throw $_
                    }
                }

                # Add results to results list
                $content = $response.Content
                [void]$resultsArray.Add($content)
                Write-Debug ("Pass: $i Amount: " + ($response.Content | ConvertFrom-Json).Count)
            }

            # Convert JSON list to hashtable
            $resultsArray = $resultsArray | ConvertFrom-Json
        }
    }
    end {
        # Return complete results
        return $resultsArray
    }
}