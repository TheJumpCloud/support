function Get-JCSystemApp () {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $false, HelpMessage = 'The System Id of the system you want to search for applications')]
        [string]$SystemID,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName, HelpMessage = 'The type (windows, mac, linux) of the JumpCloud Command you wish to search ex. (Windows, Mac, Linux))')]
        [ValidateSet('Windows', 'MacOs', 'Linux')]
        [string]$SystemOS,
        [Parameter(Mandatory = $false, HelpMessage = 'The name of the application you want to search for ex. (JumpCloud-Agent, Slack)')]
        [string]$SoftwareName,
        [Parameter(Mandatory = $false, HelpMessage = 'The version of the application you want to search for ex. (1.1.2)')]
        [string]$SoftwareVersion,
        [Parameter(Mandatory = $false, HelpMessage = 'Search for a specific application by name to all systems in the org')]
        [string]$Search
    )

    begin {
        Write-Verbose 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {
            Connect-JCOnline
        }

        $Parallel = $JCConfig.parallel.Calculated

        if ($Parallel) {
            Write-Verbose 'Initilizing resultsArray'
            $resultsArrayList = [System.Collections.Concurrent.ConcurrentBag[object]]::new()
            $searchAppResultsList = [System.Collections.Concurrent.ConcurrentBag[object]]::new()
        } else {
            Write-Verbose 'Initilizing resultsArray'
            $resultsArrayList = New-Object -TypeName System.Collections.ArrayList
            $searchAppResultsList = New-Object -TypeName System.Collections.ArrayList
        }
    }
    #TODO: Create a PR to add docs
    process {
        [int]$limit = '1000'
        Write-Verbose "Setting limit to $limit"

        [int]$skip = '0'
        Write-Verbose "Setting skip to $skip"
        # Create a global search for all endpoints(Windows, Mac, Linux) and regex software name
        if ($Search) {
            # Get all the results
            foreach ($x in @('programs', 'apps', 'linux_packages')) {
                Write-Debug $x
                $URL = "$JCUrlBasePath/api/v2/systeminsights/$($x)"
                $searchAppResults = Get-JCResults -URL $URL -Method "GET" -limit $limit
                $searchAppResultsList.Add($searchAppResults)
            }
            # Search for software name in the $searchAppResultsList
            $searchAppResultsList | ForEach-Object {
                $_ | Where-Object { $_.name -match $Search } | ForEach-Object {
                    $resultsArrayList.Add($_)
                }
            }
        }
        # If Parameter is SystemID then return all apps for that system
        if ($SystemId -or $SystemOs) {
            if ($SystemId) {
                $OSType = Get-JCSystem -ID $SystemID | Select-Object -ExpandProperty osFamily
            } elseif ($SystemOs) {
                $OSType = $SystemOs
            }
            if ($OsType -eq 'MacOs') { $Ostype = 'Darwin' } # OS Family for Mac is Darwin

            Write-Debug "OS: $OSType"
            switch ($OSType) {
                'Windows' {
                    # If Software title and system ID are passed then return specific app
                    if ($SoftwareVersion -and $SoftwareName ) {
                        # Handle Special Characters
                        $SoftwareName = [System.Web.HttpUtility]::UrlEncode($SoftwareName)
                        $URL = "$JCUrlBasePath/api/v2/systeminsights/programs?filter=name:eq:$SoftwareName&filter=version:eq:$SoftwareVersion"

                    } elseif ($SoftwareName -and $SystemID) {
                        # Handle Special Characters
                        $SoftwareName = [System.Web.HttpUtility]::UrlEncode($SoftwareName)
                        $URL = "$JCUrlBasePath/api/v2/systeminsights/programs?filter=system_id:eq:$SystemID&filter=name:eq:$SoftwareName"
                    } elseif ($SoftwareName) {
                        # Add filter for system ID to $Search
                        $SoftwareName = [System.Web.HttpUtility]::UrlEncode($SoftwareName)
                        $URL = "$JCUrlBasePath/api/v2/systeminsights/programs?filter=name:eq:$SoftwareName"
                    } elseif ($SystemID) {
                        $URL = "$JCUrlBasePath/api/v2/systeminsights/programs?filter=system_id:eq:$SystemID"
                    } else {
                        $URL = "$JCUrlBasePath/api/v2/systeminsights/programs"
                    }
                    Write-Debug $URL
                }
                'Darwin' {
                    # If Software title and system ID are passed then return specific app
                    if ($SoftwareVersion -and $SoftwareName) {
                        # Handle Special Characters
                        $SoftwareName = [System.Web.HttpUtility]::UrlEncode($SoftwareName)
                        $URL = "$JCUrlBasePath/api/v2/systeminsights/apps?filter=bundle_name:eq:$SoftwareName&filter=bundle_version:eq:$SoftwareVersion"

                    } elseif ($SoftwareName -and $SystemID) {
                        # Handle Special Characters
                        $SoftwareName = [System.Web.HttpUtility]::UrlEncode($SoftwareName)
                        $URL = "$JCUrlBasePath/api/v2/systeminsights/apps?filter=system_id:eq:$SystemID&filter=bundle_name:eq:$SoftwareName"
                    } elseif ($SoftwareName) {
                        # Add filter for system ID to $Search
                        $URL = "$JCUrlBasePath/api/v2/systeminsights/apps?filter=bundle_name:eq:$SoftwareName"
                    } elseif ($SystemID) {
                        $URL = "$JCUrlBasePath/api/v2/systeminsights/apps?filter=system_id:eq:$SystemID"
                    } else {
                        $URL = "$JCUrlBasePath/api/v2/systeminsights/apps"
                    }
                    Write-Debug $URL
                }
                'Linux' {
                    # If Software title and system ID are passed then return specific app
                    if ($SoftwareVersion -and $SoftwareName) {
                        # Handle Special Characters
                        $SoftwareName = [System.Web.HttpUtility]::UrlEncode($SoftwareName)
                        $URL = "$JCUrlBasePath/api/v2/systeminsights/linux_packages?filter=name:eq:$SoftwareName&filter=version:eq:$SoftwareVersion"

                    } elseif ($SoftwareName -and $SystemID) {
                        # Handle Special Characters
                        $SoftwareName = [System.Web.HttpUtility]::UrlEncode($SoftwareName)
                        $URL = "$JCUrlBasePath/api/v2/systeminsights/linux_packages?filter=system_id:eq:$SystemID&filter=name:eq:$SoftwareName"
                    } elseif ($SoftwareName) {
                        # Add filter for system ID to $Search
                        $URL = "$JCUrlBasePath/api/v2/systeminsights/linux_packages?filter=name:eq:$SoftwareName"
                    } elseif ($SystemID) {
                        $URL = "$JCUrlBasePath/api/v2/systeminsights/linux_packages?filter=system_id:eq:$SystemID"
                    } else {
                        $URL = "$JCUrlBasePath/api/v2/systeminsights/linux_packages"
                    }
                    Write-Debug $URL
                }

            }
            if ($Parallel) {
                $resultsArrayList = Get-JCResults -URL $URL -Method "GET" -limit $limit -parallel $true
            } else {
                $resultsArrayList = Get-JCResults -URL $URL -Method "GET" -limit $limit
            }

        } elseif ($SoftwareName) {
            $SoftwareName = [System.Web.HttpUtility]::UrlEncode($SoftwareName)
            # Foreach Mac, Windows, Linux
            foreach ($os in @('MacOs', 'Windows', 'Linux')) {
                if ($os -eq 'MacOs') {
                    $URL = "$JCUrlBasePath/api/v2/systeminsights/apps?filter=bundle_name:eq:$SoftwareName"
                    if ($Parallel) {
                        $resultsArray = Get-JCResults -URL $URL -Method "GET" -limit $limit -parallel $true
                    } else {
                        $resultsArray = Get-JCResults -URL $URL -Method "GET" -limit $limit
                    }
                    $resultsArray | Add-Member -MemberType NoteProperty -Name 'osFamily' -Value $os
                    $resultsArrayList.Add($resultsArray)
                } elseif ($os -eq 'Windows') {
                    $URL = "$JCUrlBasePath/api/v2/systeminsights/programs?filter=name:eq:$SoftwareName"
                    if ($Parallel) {
                        $resultsArray = Get-JCResults -URL $URL -Method "GET" -limit $limit -parallel $true
                    } else {
                        $resultsArray = Get-JCResults -URL $URL -Method "GET" -limit $limit
                    }
                    $resultsArray | Add-Member -MemberType NoteProperty -Name 'osFamily' -Value $os
                    $resultsArrayList.Add($resultsArray)
                } elseif ($os -eq 'Linux') {
                    $URL = "$JCUrlBasePath/api/v2/systeminsights/linux_packages?filter=name:eq:$SoftwareName"
                    if ($Parallel) {
                        $resultsArray = Get-JCResults -URL $URL -Method "GET" -limit $limit -parallel $true
                    } else {
                        $resultsArray = Get-JCResults -URL $URL -Method "GET" -limit $limit
                    }
                    $resultsArray | Add-Member -MemberType NoteProperty -Name 'osFamily' -Value $os
                    $resultsArrayList.Add($resultsArray)
                }
            }
        }
    }
    end {
        return $resultsArrayList
    }
} # End Function

