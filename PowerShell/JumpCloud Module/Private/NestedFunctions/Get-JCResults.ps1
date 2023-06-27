Function Get-JCResults {
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
        if ($JCOrgID) {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }

        if ($parallel) {
            $resultsArray = [System.Collections.Concurrent.ConcurrentBag[object]]::new()
            $errorResults = [System.Collections.Concurrent.ConcurrentQueue[Exception]]::new()
        } else {
            Write-Debug "Running in Sequential"
            $resultsArray = [System.Collections.Generic.List[object]]::new()
        }
        $totalCount = 1
        $limit = [int]$limit
        $skip = 0
    }
    process {
        # Concat complete URL
        if ($URL.Contains("?")) {
            $limitURL = $URL + "&limit=$limit&skip=$skip"
        } else {
            $limitURL = $URL + "?limit=$limit&skip=$skip"
        }
        Write-Debug $limitURL

        # Attempt initial call and collect first page of results
        try {
            if ($body) {
                $ProgressPreference = "SilentlyContinue"
                $response = Invoke-WebRequest -Method $method -Body $body -Uri $limitURL -Headers $hdrs -UserAgent:(Get-JCUserAgent) -UseBasicParsing
            } else {
                $ProgressPreference = "SilentlyContinue"
                $response = Invoke-WebRequest -Method $method -Uri $limitURL -Headers $hdrs -UserAgent:(Get-JCUserAgent) -UseBasicParsing
            }

        } catch {
            throw $_
        }

        # Find total amount of results
        if ($null -eq $response.Headers."x-total-count") {
            # Search Endpoint
            Write-Debug "No x-total-count header, checking response content for totalCount"
            $totalCountHeader = $false
            $content = $response.Content | ConvertFrom-Json
            $totalCount = $content.totalCount
            $totalCount = [int]$totalCount
            Write-Debug "total count: $totalCount"
        } else {
            Write-Debug "x-total-count header present"
            $totalCountHeader = $true
            $totalCount = $response.Headers."x-total-count"
            $totalCount = [int]$totalCount.Trim()
            Write-Debug "total count: $totalCount"
        }

        # Divide amount of results by limit to find amount of pages to fully collect results
        $pageCounter = [math]::ceiling($totalCount / $limit)
        Write-Debug "number of pages: $pageCounter"

        # Running Function in Parallel
        if ($parallel) {
            Write-Debug "Parallel validated"
            if ($totalCountHeader) {
                # Add content to threadsafe object
                $content = $response.Content
                $resultsArray.Add($content)
            } else {
                # Add content to threadsafe object
                $results = $content.results
                ForEach ($result in $results) {
                    [void]$resultsArray.Add($result)
                }
            }

            # If the amount of results are greater than 1 page, proceed with parallel processing
            if ($pageCounter -gt 1) {

                # Store JCUserAgent in variable to reference in each parallel session
                $GetJCUserAgent = Get-JCUserAgent

                # Perform Parallel Loop
                1..$pageCounter | ForEach-Object -Parallel {
                    # Variables for containing results and errors
                    $errorResults = $using:errorResults
                    $resultsArray = $using:resultsArray
                    $totalCountHeader = $using:totalCountHeader
                    $body = $using:body
                    $URL = $using:URL

                    # Increment skip by limit after each page and update URL
                    $skip = $_ * $using:limit
                    if ($URL.Contains("?")) {
                        $limitURL = $URL + "&limit=$using:limit&skip=$skip"
                    } else {
                        $limitURL = $URL + "?limit=$using:limit&skip=$skip"
                    }

                    # Check if body is present
                    if ($body) {
                        try {
                            if ($limitURL -like "*/search/*") {
                                $updatedBody = $body | ConvertFrom-Json -AsHashtable
                                $updatedBody["limit"] = $using:limit
                                $updatedBody["skip"] = $skip
                                $updatedBody = $updatedBody | ConvertTo-Json -Compress -Depth 4
                            }
                            # Collect results and add to threadsafe array
                            $response = Invoke-WebRequest -Method $using:method -Body $updatedBody -Uri $limitURL -Headers $using:hdrs -MaximumRetryCount 5 -RetryIntervalSec 5 -UserAgent:($using:GetJCUserAgent) -UseBasicParsing
                        } catch {
                            # If error is encountered, add error object to threadsafe error array
                            $errorResults.Enqueue($_.ToString())
                        }
                        if ($totalCountHeader) {
                            # Add content to threadsafe object
                            $content = $response.Content
                            $resultsArray.Add($content)
                        } else {
                            # Add content to threadsafe object
                            $content = $response.Content | ConvertFrom-Json
                            $results = $content.results
                            ForEach ($result in $results) {
                                [void]$resultsArray.Add($result)
                            }
                        }
                    } else {
                        try {
                            # Collect results and add to threadsafe array
                            $response = Invoke-WebRequest -Method $using:method -Uri $limitURL -Headers $using:hdrs -MaximumRetryCount 5 -RetryIntervalSec 5 -UserAgent:($using:GetJCUserAgent) -UseBasicParsing
                        } catch {
                            # If error is encountered, add error object to threadsafe error array
                            $errorResults.Enqueue($_.ToString())
                        }

                        if ($totalCountHeader) {
                            # Add content to threadsafe object
                            $content = $response.Content
                            $resultsArray.Add($content)
                        } else {
                            # Add content to threadsafe object
                            $content = $response.Content | ConvertFrom-Json
                            $results = $content.results
                            ForEach ($result in $results) {
                                [void]$resultsArray.Add($result)
                            }
                        }
                    }
                }
            }
            # If any parallel session encountered error, throw array containing any/all errors
            if (!$errorResults.IsEmpty) {
                throw [AggregateException]::new($errorResults)
            }
        }
        # Running Function in Sequential
        else {
            if ($totalCountHeader) {
                # Add results to results list
                $content = $response.Content
                [void]$resultsArray.Add($content)
            } else {
                # Add results to results list
                $content = $response.Content | ConvertFrom-Json
                if ($null -eq $content.results) {
                    [void]$resultsArray.Add($content)
                } else {
                    [void]$resultsArray.AddRange($content.results)
                }
            }

            # Perform Sequential loop; only if there is more than 1 page of results
            for ($i = 1; $i -lt $pageCounter; $i++) {

                # Increment skip by limit after each page and update URL
                $skip += $limit
                if ($URL.Contains("?")) {
                    $limitURL = $URL + "&limit=$limit&skip=$skip"
                } else {
                    $limitURL = $URL + "?limit=$limit&skip=$skip"
                }
                Write-Debug $limitURL

                # Check if body is present
                if ($body) {
                    try {
                        if ($limitURL -like "*/search/*") {
                            $body = $body | ConvertFrom-Json
                            $body.limit = $limit
                            $body.skip = $skip
                            $body = $body | ConvertTo-Json -Compress -Depth 4
                        }
                        $ProgressPreference = "SilentlyContinue"
                        $response = Invoke-WebRequest -Method $method -Body $body -Uri $limitURL -Headers $hdrs -UserAgent:(Get-JCUserAgent) -UseBasicParsing
                    } catch {
                        throw $_
                    }
                } else {
                    try {
                        $ProgressPreference = "SilentlyContinue"
                        $response = Invoke-WebRequest -Method $method -Uri $limitURL -Headers $hdrs -UserAgent:(Get-JCUserAgent) -UseBasicParsing
                    } catch {
                        throw $_
                    }
                }

                # Add results to results list
                if ($totalCountHeader) {
                    # Add results to results list
                    $content = $response.Content
                    [void]$resultsArray.Add($content)
                    Write-Debug ("Page: $($i+1) Amount: " + ($content | ConvertFrom-Json).Count)
                } else {
                    # Add results to results list
                    $content = $response.Content | ConvertFrom-Json
                    if ($null -eq $content.results) {
                        [void]$resultsArray.Add($content)
                        Write-Debug ("Page: $($i+1) Amount: " + ($content | ConvertFrom-Json).Count)
                    } else {
                        [void]$resultsArray.AddRange($content.results)
                        Write-Debug ("Page: $($i+1) Amount: " + ($content.results).Count)
                    }
                }
            }
        }
    }
    end {
        if ($totalCountHeader) {
            $resultsArray = $resultsArray | ConvertFrom-Json
        }
        # Return complete results
        return $resultsArray
    }
}