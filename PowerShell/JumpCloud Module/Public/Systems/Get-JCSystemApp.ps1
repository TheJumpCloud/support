function Get-JCSystemApp () {
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (

        [Parameter(Mandatory = $false, HelpMessage = 'The System Id of the system you want to search for applications')][ValidateNotNullorEmpty()]
        [string]$SystemID,
        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName, HelpMessage = 'The type (windows, macOS, linux) of the JumpCloud system you wish to search. Ex. (Windows, macOS, Linux))')]
        [ValidateSet('Windows', 'macOS', 'Linux')][ValidateNotNullorEmpty()]
        [string]$SystemOS,
        [Parameter(Mandatory = $false, HelpMessage = 'The name of the application you want to search for ex. (JumpCloud-Agent, Slack). SoftwareName will always query the "name" property from system insights. Note, for macOS systems, ".app" will be applied. This field is case sensitive.' )][ValidateNotNullorEmpty()]
        [string]$SoftwareName,
        [Parameter(Mandatory = $false, HelpMessage = 'The version of the application you want to search for ex. 1.1.2')][ValidateNotNullorEmpty()]
        [string]$SoftwareVersion,
        [Parameter(Mandatory = $false, ParameterSetName = "Search", HelpMessage = "The Search parameter can be used in conjunction with the 'SoftwareName' parameter to perform a case-insensitive search for software. This is parameter switch is inherently slower than using just the 'softwareName' parameter but can be useful to identify the names of software titles on systems. If the exact name of a software title isn't known, the 'search' parameter can be used to find that name. Ex. Get-JCSoftwareApp -SystemID '63c9654cb357249876bfc05b' -SoftwareName 'chrome' -Search will attempt to perform a match for the term 'chrome' on all applications/ programs for the specified system. If a match, partial-match, case-insensitive match is found, it would be returned in the results. In this case, the 'name' of the software title is 'Google Chrome'. A subsequent search could be run to return all macOS systems which have 'Google Chrome' installed. Ex. Get-JCSystemApp -SystemOS macOS -softwareName 'Google Chrome', this would perform an exact match search for macOS systems that have google chrome which is substantially quicker than running: Get-JCSystemApp -SystemOS macOS -softwareName 'google chrome' -Search. The search parameter is a tool to help identify the 'name' attribute of software titles when searching bulk systems its recommended to not use the search parameter and instead specify the exact (case sensitive) name of the software title.")]
        [switch]$Search,
        [Parameter(DontShow, Mandatory = $false, ParameterSetName = "All", HelpMessage = 'Search for a specific application by name from all systems in the org')]
        [switch]$SearchAllSystems

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
                    if ($SystemOS) { Throw "SystemID and SystemOS cannot be used together" }
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
                            # If $softwareName does not have .app at the end then add it
                            if ((!$SoftwareName) -and (!$SystemOs) -and (!$SoftwareVersion)) {
                                # Add filter for system ID to $Search
                                $URL = "$JCUrlBasePath/api/v2/systeminsights/apps"
                            }
                            if ($SoftwareName) {
                                # Check for .app at the end of the software name
                                if (-not $SoftwareName.EndsWith('.app')) {
                                    Write-Debug "Adding .app to $SoftwareName"
                                    if ($SoftwareName.EndsWith('.App')) {
                                        Write-Debug "Replacing .App with .app"
                                        $SoftwareName = $SoftwareName.Replace('.App', '.app')
                                    } else {
                                        $SoftwareName = "$SoftwareName.app"
                                    }
                                } else {
                                    Write-Debug "$SoftwareName already ends with .app"
                                }
                                if ($SoftwareVersion -and $SoftwareName -and $SystemId) {
                                    # Handle Special Characters
                                    $SoftwareName = [System.Web.HttpUtility]::UrlEncode($SoftwareName)
                                    $URL = "$JCUrlBasePath/api/v2/systeminsights/apps?filter=name:eq:$SoftwareName&filter=bundle_short_version:eq:$SoftwareVersion&filter=system_id:eq:$SystemID"

                                } elseif ($SoftwareName -and $SystemId) {
                                    # Handle Special Characters
                                    $SoftwareName = [System.Web.HttpUtility]::UrlEncode($SoftwareName)
                                    $URL = "$JCUrlBasePath/api/v2/systeminsights/apps?&filter=name:eq:$SoftwareName&filter=system_id:eq:$SystemID"
                                }
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
                    if ($SystemID) { Throw "SystemID and SystemOS cannot be used together" }
                    Write-Debug "OS: $SystemOs"
                    switch ($OSType) {
                        'Windows' {
                            # If Software title, version, and system OS are passed then return specific app
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
                            # If Software title, version, and system OS are passed then return specific app and not null
                            if ((!$SoftwareName) -and (!$SoftwareVersion)) {
                                # Add filter for system ID to $Search
                                $URL = "$JCUrlBasePath/api/v2/systeminsights/apps"
                            }
                            if ($SoftwareName) {
                                if (-not $SoftwareName.EndsWith('.app')) {
                                    Write-Debug "Adding .app to $SoftwareName"
                                    if ($SoftwareName.EndsWith('.App')) {
                                        Write-Debug "Replacing .App with .app"
                                        $SoftwareName = $SoftwareName.Replace('.App', '.app')
                                    } else {
                                        $SoftwareName = "$SoftwareName.app"
                                    }
                                } else {
                                    Write-Debug "$SoftwareName already ends with .app"
                                }

                                if ($SoftwareVersion -and $SoftwareName -and $SystemOS) {
                                    # Handle Special Characters
                                    $SoftwareName = [System.Web.HttpUtility]::UrlEncode($SoftwareName)
                                    $URL = "$JCUrlBasePath/api/v2/systeminsights/apps?filter=name:eq:$SoftwareName&filter=bundle_short_version:eq:$SoftwareVersion"

                                } elseif ($SoftwareName -and $SystemOS) {
                                    # Handle Special Characters
                                    $SoftwareName = [System.Web.HttpUtility]::UrlEncode($SoftwareName)
                                    $URL = "$JCUrlBasePath/api/v2/systeminsights/apps?&filter=name:eq:$SoftwareName"
                                }
                            }
                            Write-Debug $URL
                        }
                        'Linux' {
                            # If Software title, version, and system OS are passed then return specific app
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
                } elseif ($SoftwareName) {
                    $SoftwareName = [System.Web.HttpUtility]::UrlEncode($SoftwareName)
                    # Search each apps endpoint for software name
                    foreach ($os in @('MacOs', 'Windows', 'Linux')) {
                        if ($os -eq 'MacOs') {
                            if (-not $SoftwareName.EndsWith('.app')) {
                                if ($SoftwareName.EndsWith('.App')) {
                                    $MacSoftwareName = $SoftwareName
                                    $MacSoftwareName = $MacSoftwareName.Replace('.App', '.app')
                                } else {
                                    $MacSoftwareName = "$MacSoftwareName.app"
                                }
                            }
                            if ($SoftwareVersion -and $SoftwareName) {
                                $URL = "$JCUrlBasePath/api/v2/systeminsights/apps?filter=name:eq:$MacSoftwareName&filter=bundle_short_version:eq:$softwareVersion"
                            } else {
                                $URL = "$JCUrlBasePath/api/v2/systeminsights/apps?filter=name:eq:$MacSoftwareName"
                            }
                        } elseif ($os -eq 'Windows') {
                            if ($SoftwareVersion -and $SoftwareName) {
                                $URL = "$JCUrlBasePath/api/v2/systeminsights/programs?filter=name:eq:$SoftwareName&filter=version:eq:$softwareVersion"
                            } else {
                                $URL = "$JCUrlBasePath/api/v2/systeminsights/programs?filter=name:eq:$SoftwareName"
                            }
                        } elseif ($os -eq 'Linux') {
                            if ($SoftwareVersion -and $SoftwareName) {
                                $URL = "$JCUrlBasePath/api/v2/systeminsights/linux_packages?filter=name:eq:$SoftwareName&filter=version:eq:$softwareVersion"
                            } else {
                                $URL = "$JCUrlBasePath/api/v2/systeminsights/linux_packages?filter=name:eq:$SoftwareName"
                            }
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
                    }
                } else {
                    # Default/All
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
                # Search for softwareName
                if ($SoftwareName) {
                    if ($SoftwareVersion) {
                        Throw 'You cannot specify software version when using -search for a software name'
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
                            $results = $_ | Where-Object { ($_.name -match $SoftwareName) }
                            $results | ForEach-Object {
                                $resultsArrayList.Add($_)
                            }
                        }
                    }

                } else {
                    Throw "You must specify a software name and/or systemId when using -search"
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

