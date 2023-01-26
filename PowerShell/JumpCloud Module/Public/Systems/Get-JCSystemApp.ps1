function Get-JCSystemApp () {
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (

        [Parameter(Mandatory = $false, HelpMessage = 'The System Id of the system you want to search for applications')][ValidateNotNullorEmpty()]
        [string]$SystemID,
        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName, HelpMessage = 'The type (windows, mac, linux) of the JumpCloud Command you wish to search ex. (Windows, Mac, Linux))')]
        [ValidateSet('Windows', 'MacOs', 'Linux')][ValidateNotNullorEmpty()]
        [string]$SystemOS,
        [Parameter(Mandatory = $false, HelpMessage = 'The name of the application you want to search for ex. (JumpCloud-Agent, Slack)')][ValidateNotNullorEmpty()]
        [string]$SoftwareName,
        [Parameter(Mandatory = $false, HelpMessage = 'The version of the application you want to search for ex. (1.1.2)')][ValidateNotNullorEmpty()]
        [string]$SoftwareVersion,
        [Parameter(Mandatory = $false, ParameterSetName = "Search", HelpMessage = 'Search for a specific application by name from all systems in the org')]
        [switch]$Search,
        [Parameter(DontShow, Mandatory = $false, ParameterSetName = "All", HelpMessage = 'Search for a specific application by name from all systems in the org')]
        [switch]$Software

    )
    begin {
        Write-Verbose 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {
            Connect-JCOnline
        }
        $Parallel = $JCConfig.parallel.Calculated
        $searchAppResultsList = New-Object -TypeName System.Collections.ArrayList
        if ($Parallel) {
            Write-Verbose 'Initilizing resultsArray'
            $resultsArrayList = [System.Collections.Concurrent.ConcurrentBag[object]]::new()
        } else {
            Write-Verbose 'Initilizing resultsArray'
            $resultsArrayList = New-Object -TypeName System.Collections.ArrayList
        }
        Write-Verbose "Parameter Set: $($PSCmdlet.ParameterSetName)"
    }
    process {
        [int]$limit = '1000'
        Write-Verbose "Setting limit to $limit"

        [int]$skip = '0'
        Write-Verbose "Setting skip to $skip"
        $applicationArray = @('programs', 'apps', 'linux_packages')

        switch ($PSCmdlet.ParameterSetName) {
            All {
                if ($SystemId) {
                    Write-Debug "SystemId"
                    $OSType = Get-JCSystem -ID $SystemID | Select-Object -ExpandProperty osFamily
                    if ($OsType -eq 'MacOs') { $Ostype = 'Darwin' }
                    switch ($OSType) {
                        'Windows' {
                            # If Software title, version, and system ID are passed then return specific app
                            if ($SoftwareVersion -and $SoftwareName -and $SystemID) {
                                # Handle Special Characters
                                $SoftwareName = [System.Web.HttpUtility]::UrlEncode($SoftwareName)
                                $URL = "$JCUrlBasePath/api/v2/systeminsights/programs?filter=system_id:eq:$SystemId&filter=name:eq:$SoftwareName&filter=version:eq:$SoftwareVersion"

                            } elseif ($SoftwareName -and $SystemID) {
                                # Handle Special Characters
                                $SoftwareName = [System.Web.HttpUtility]::UrlEncode($SoftwareName)
                                $URL = "$JCUrlBasePath/api/v2/systeminsights/programs?filter=system_id:eq:$SystemID&filter=name:eq:$SoftwareName"
                            } elseif ($SystemID) {
                                $URL = "$JCUrlBasePath/api/v2/systeminsights/programs?filter=system_id:eq:$SystemID"
                            }
                            Write-Debug $URL
                        }
                        'Darwin' {
                            # If Software title, version, and system ID are passed then return specific app
                            if ($SoftwareVersion -and $SoftwareName -and $SystemID) {
                                # Handle Special Characters
                                $SoftwareName = [System.Web.HttpUtility]::UrlEncode($SoftwareName)
                                $URL = "$JCUrlBasePath/api/v2/systeminsights/apps?filter=system_id:eq:$SystemId&filter=bundle_name:eq:$SoftwareName&filter=bundle_short_version:eq:$SoftwareVersion"

                            } elseif ($SoftwareName -and $SystemID) {
                                # Handle Special Characters
                                $SoftwareName = [System.Web.HttpUtility]::UrlEncode($SoftwareName)
                                $URL = "$JCUrlBasePath/api/v2/systeminsights/apps?filter=system_id:eq:$SystemID&filter=bundle_name:eq:$SoftwareName"
                            } elseif ($SystemID) {
                                $URL = "$JCUrlBasePath/api/v2/systeminsights/apps?filter=system_id:eq:$SystemID"
                            }
                            Write-Debug $URL
                        }
                        'Linux' {
                            # If Software title, version and system ID are passed then return specific app
                            if ($SoftwareVersion -and $SoftwareName -and $SystemID) {
                                # Handle Special Characters
                                $SoftwareName = [System.Web.HttpUtility]::UrlEncode($SoftwareName)
                                $URL = "$JCUrlBasePath/api/v2/systeminsights/linux_packages?filter=system_id:eq:$SystemId&filter=name:eq:$SoftwareName&filter=version:eq:$SoftwareVersion&filter=system_id:eq:$SystemID"

                            } elseif ($SoftwareName -and $SystemID) {
                                # Handle Special Characters
                                $SoftwareName = [System.Web.HttpUtility]::UrlEncode($SoftwareName)
                                $URL = "$JCUrlBasePath/api/v2/systeminsights/linux_packages?filter=system_id:eq:$SystemID&filter=name:eq:$SoftwareName"
                            } elseif ($SystemID) {
                                $URL = "$JCUrlBasePath/api/v2/systeminsights/linux_packages?filter=system_id:eq:$SystemID"
                            }
                            Write-Debug $URL
                        }

                    }
                    if ($Parallel) {
                        $resultsArrayList = Get-JCResults -URL $URL -Method "GET" -limit $limit -parallel $true
                    } else {
                        $resultsArrayList = Get-JCResults -URL $URL -Method "GET" -limit $limit
                    }

                } elseif ($SystemOS) {
                    $OSType = $SystemOS
                    if ($OSType -eq 'MacOs') { $OSType = 'Darwin' } # OS Family for Mac is Darwin

                    Write-Debug "OS: $SystemOs"
                    switch ($OSType) {
                        'Windows' {
                            # If Software title, version, and system ID are passed then return specific app
                            if ($SoftwareVersion -and $SoftwareName -and $SystemOS) {
                                # Handle Special Characters
                                $SoftwareName = [System.Web.HttpUtility]::UrlEncode($SoftwareName)
                                $URL = "$JCUrlBasePath/api/v2/systeminsights/programs?filter=name:eq:$SoftwareName&filter=version:eq:$SoftwareVersion"

                            } elseif ($SoftwareName -and $SystemOS) {
                                # Handle Special Characters
                                $SoftwareName = [System.Web.HttpUtility]::UrlEncode($SoftwareName)
                                $URL = "$JCUrlBasePath/api/v2/systeminsights/programs?filter=name:eq:$SoftwareName"
                            } elseif ($SystemOs) {
                                $URL = "$JCUrlBasePath/api/v2/systeminsights/programs"
                            }
                            Write-Debug $URL
                        }
                        'Darwin' {
                            # If Software title, version, and system ID are passed then return specific app
                            if ($SoftwareVersion -and $SoftwareName -and $SystemOS) {
                                # Handle Special Characters
                                $SoftwareName = [System.Web.HttpUtility]::UrlEncode($SoftwareName)
                                $URL = "$JCUrlBasePath/api/v2/systeminsights/apps?filter=bundle_name:eq:$SoftwareName&filter=bundle_short_version:eq:$SoftwareVersion"

                            } elseif ($SoftwareName -and $SystemOS) {
                                # Handle Special Characters
                                $SoftwareName = [System.Web.HttpUtility]::UrlEncode($SoftwareName)
                                $URL = "$JCUrlBasePath/api/v2/systeminsights/apps?&filter=bundle_name:eq:$SoftwareName"
                            } elseif ($SystemOs) {
                                # Add filter for system ID to $Search
                                $URL = "$JCUrlBasePath/api/v2/systeminsights/apps"
                            }
                            Write-Debug $URL
                        }
                        'Linux' {
                            # If Software title, version, and system ID are passed then return specific app
                            if ($SoftwareVersion -and $SoftwareName -and $SystemOS) {
                                # Handle Special Characters
                                $SoftwareName = [System.Web.HttpUtility]::UrlEncode($SoftwareName)
                                $URL = "$JCUrlBasePath/api/v2/systeminsights/linux_packages?filter=name:eq:$SoftwareName&filter=version:eq:$SoftwareVersion"

                            } elseif ($SoftwareName -and $SystemOS) {
                                # Handle Special Characters
                                $SoftwareName = [System.Web.HttpUtility]::UrlEncode($SoftwareName)
                                $URL = "$JCUrlBasePath/api/v2/systeminsights/linux_packages?filter=name:eq:$SoftwareName"
                            } elseif ($SystemOs) {
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
                } elseif ($SoftwareName ) {
                    Write-Debug "SoftwareName: $SoftwareName"
                    $SoftwareName = [System.Web.HttpUtility]::UrlEncode($SoftwareName)
                    # Foreach Mac, Windows, Linux
                    foreach ($os in @('MacOs', 'Windows', 'Linux')) {
                        if ($os -eq 'MacOs') {
                            if ($SoftwareVersion -and $SoftwareName) {
                                $URL = "$JCUrlBasePath/api/v2/systeminsights/apps?filter=bundle_name:eq:$SoftwareName&filter=bundle_short_version:eq:$softwareVersion"
                            } else {
                                $URL = "$JCUrlBasePath/api/v2/systeminsights/apps?filter=bundle_name:eq:$SoftwareName"
                            }

                            if ($Parallel) {
                                $resultsArray = Get-JCResults -URL $URL -Method "GET" -limit $limit -parallel $true
                            } else {
                                $resultsArray = Get-JCResults -URL $URL -Method "GET" -limit $limit
                            }
                            # If no results, skip to next OS
                            if ($resultsArray.count -eq 0) {
                                continue
                            }
                            $resultsArray | Add-Member -MemberType NoteProperty -Name 'osFamily' -Value $os
                            $resultsArrayList.Add($resultsArray)
                        } elseif ($os -eq 'Windows') {
                            if ($SoftwareVersion -and $SoftwareName) {
                                $URL = "$JCUrlBasePath/api/v2/systeminsights/programs?filter=name:eq:$SoftwareName&filter=version:eq:$softwareVersion"
                            } else {
                                $URL = "$JCUrlBasePath/api/v2/systeminsights/programs?filter=name:eq:$SoftwareName"
                            }
                            if ($Parallel) {
                                $resultsArray = Get-JCResults -URL $URL -Method "GET" -limit $limit -parallel $true
                            } else {
                                $resultsArray = Get-JCResults -URL $URL -Method "GET" -limit $limit
                            }
                            if ($resultsArray.count -eq 0) { continue }
                            $resultsArray | Add-Member -MemberType NoteProperty -Name 'osFamily' -Value $os
                            $resultsArrayList.Add($resultsArray)
                        } elseif ($os -eq 'Linux') {
                            if ($SoftwareVersion -and $SoftwareName) {
                                $URL = "$JCUrlBasePath/api/v2/systeminsights/linux_packages?filter=name:eq:$SoftwareName&filter=version:eq:$softwareVersion"
                            } else {
                                $URL = "$JCUrlBasePath/api/v2/systeminsights/linux_packages?filter=name:eq:$SoftwareName"
                            }
                            if ($Parallel) {
                                $resultsArray = Get-JCResults -URL $URL -Method "GET" -limit $limit -parallel $true
                            } else {
                                $resultsArray = Get-JCResults -URL $URL -Method "GET" -limit $limit
                            }
                            if ($resultsArray.count -eq 0) { continue }
                            $resultsArray | Add-Member -MemberType NoteProperty -Name 'osFamily' -Value $os
                            $resultsArrayList.Add($resultsArray)
                        }
                    }
                } else {
                    # Print all software
                    foreach ($os in @('programs', 'apps', 'linux_packages')) {
                        $URL = "$JCUrlBasePath/api/v2/systeminsights/$os"
                        if ($Parallel) {
                            $resultsArray = Get-JCResults -URL $URL -Method "GET" -limit $limit -parallel $true
                        } else {
                            $resultsArray = Get-JCResults -URL $URL -Method "GET" -limit $limit
                        }
                        if ($resultsArray.count -eq 0) { continue }
                        # Add OS Family to results
                        if ($os -eq 'programs') { $os = 'Windows' }
                        elseif ($os -eq 'apps') { $os = 'MacOs' }
                        elseif ($os -eq 'linux_packages') { $os = 'Linux' }
                        $resultsArray | Add-Member -MemberType NoteProperty -Name 'osFamily' -Value $os
                        $resultsArrayList.Add($resultsArray)

                    }
                }

            } Search {
                # IF only software name and no system ID or OS or version
                if ($SoftwareName -and $Search) {
                    # Check if other parameters are set
                    if ($SoftwareVersion) {
                        Write-Error 'You cannot specify a system ID or version when using -search for a software name'
                    } elseif ($SystemId) {
                        $applicationArray | ForEach-Object {
                            $URL = "$JCUrlBasePath/api/v2/systeminsights/$_"
                            Write-Verbose "Searching for $SoftwareName and $SystemId in $_ "
                            if ($Parallel) {
                                $searchAppResults = Get-JCResults -URL $URL -Method "GET" -limit $limit -parallel $true
                            } else {
                                $searchAppResults = Get-JCResults -URL $URL -Method "GET" -limit $limit
                            }
                            # Add OS Family to results
                            if ($_ -eq 'programs') { $os = 'Windows' }
                            elseif ($_ -eq 'apps') { $os = 'MacOs' }
                            elseif ($_ -eq 'linux_packages') { $os = 'Linux' }
                            $searchAppResults | Add-Member -MemberType NoteProperty -Name 'osFamily' -Value $os
                            [void]$searchAppResultsList.Add($searchAppResults)
                        }
                        $searchAppResultsList | ForEach-Object {
                            $results = $_ | Where-Object { ($_.name -match $SoftwareName) -and ($_.System_id -match $SystemId) }
                            $results | ForEach-Object {
                                $resultsArrayList.Add($_)
                            }
                        }
                    } elseif ($SystemOS) {
                        # Get all the results if softwarename elseif softwarename and version

                        $applicationArray | ForEach-Object {
                            $URL = "$JCUrlBasePath/api/v2/systeminsights/$_"
                            Write-Verbose "Searching for $SoftwareName and $SystemOs in $_ "
                            if ($Parallel) {
                                $searchAppResults = Get-JCResults -URL $URL -Method "GET" -limit $limit -parallel $true
                            } else {
                                $searchAppResults = Get-JCResults -URL $URL -Method "GET" -limit $limit
                            }
                            # Add OS Family to results
                            if ($_ -eq 'programs') { $os = 'Windows' }
                            elseif ($_ -eq 'apps') { $os = 'MacOs' }
                            elseif ($_ -eq 'linux_packages') { $os = 'Linux' }
                            $searchAppResults | Add-Member -MemberType NoteProperty -Name 'osFamily' -Value $os
                            [void]$searchAppResultsList.Add($searchAppResults)
                        }
                        $searchAppResultsList | ForEach-Object {
                            $results = $_ | Where-Object { ($_.name -match $SoftwareName) -and ($_.osFamily -match $SystemOs) }
                            $results | ForEach-Object {
                                $resultsArrayList.Add($_)
                            }
                        }
                    } else {
                        # Get all the results with only softwarename
                        $applicationArray | ForEach-Object {
                            $URL = "$JCUrlBasePath/api/v2/systeminsights/$_"
                            Write-Verbose "Searching for $SoftwareName in $_ "
                            if ($Parallel) {
                                $searchAppResults = Get-JCResults -URL $URL -Method "GET" -limit $limit -parallel $true
                            } else {
                                $searchAppResults = Get-JCResults -URL $URL -Method "GET" -limit $limit
                            }
                            # Add OS Family to results
                            if ($_ -eq 'programs') { $os = 'Windows' }
                            elseif ($_ -eq 'apps') { $os = 'MacOs' }
                            elseif ($_ -eq 'linux_packages') { $os = 'Linux' }
                            $searchAppResults | Add-Member -MemberType NoteProperty -Name 'osFamily' -Value $os
                            [void]$searchAppResultsList.Add($searchAppResults)

                        }
                        $searchAppResultsList | ForEach-Object {
                            $results = $_ | Where-Object { ($_.name -match $SoftwareName) -and ($_.osFamily -match $SystemOs) }
                            $results | ForEach-Object {
                                $resultsArrayList.Add($_)
                            }
                        }
                    }

                }
            }

        }

    }
    end {
        switch ($PSCmdlet.ParameterSetName) {
            Search {
                return $resultsArrayList
            }
            All {
                return $resultsArrayList
            }
        }
    }
}

