function Get-JCSystemApp () {
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (
        [Parameter(Mandatory = $false, HelpMessage = 'The System Id of the system you want to search for applications')][ValidateNotNullorEmpty()]
        [string]$SystemID,
        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName, HelpMessage = 'The type (windows, macOS, linux) of the JumpCloud system you wish to search. Ex. (Windows, macOS, Linux))')]
        [ValidateSet('Windows', 'macOS', 'Linux')][ValidateNotNullorEmpty()]
        [string]$SystemOS,
        [Parameter(Mandatory = $false, HelpMessage = 'The name of the application you want to search for ex. (JumpCloud-Agent, Slack). SoftwareName will always query the "name" property from system insights. Note, for macOS systems, ".app" will be applied. This field is case sensitive.' )][ValidateNotNullorEmpty()]
        [string]$name,
        [Parameter(Mandatory = $false, HelpMessage = 'The version of the application you want to search for ex. 1.1.2')][ValidateNotNullorEmpty()]
        [string]$version,
        [Parameter(Mandatory = $false, ParameterSetName = "Search", HelpMessage = "The Search parameter can be used in conjunction with the 'SoftwareName' parameter to perform a case-insensitive search for software. This is parameter switch is inherently slower than using just the 'softwareName' parameter but can be useful to identify the names of software titles on systems. If the exact name of a software title isn't known, the 'search' parameter can be used to find that name. Ex. Get-JCSoftwareApp -SystemID '63c9654cb357249876bfc05b' -name 'chrome' -Search will attempt to perform a match for the term 'chrome' on all applications/ programs for the specified system. If a match, partial-match, case-insensitive match is found, it would be returned in the results. In this case, the 'name' of the software title is 'Google Chrome'. A subsequent search could be run to return all macOS systems which have 'Google Chrome' installed. Ex. Get-JCSystemApp -SystemOS macOS -name 'Google Chrome', this would perform an exact match search for macOS systems that have google chrome which is substantially quicker than running: Get-JCSystemApp -SystemOS macOS -name 'google chrome' -Search. The search parameter is a tool to help identify the 'name' attribute of software titles when searching bulk systems its recommended to not use the search parameter and instead specify the exact (case sensitive) name of the software title.")]
        [switch]$Search,
        [Parameter(DontShow, Mandatory = $false, ParameterSetName = "All", HelpMessage = 'Search for a specific application by name from all systems in the org')]
        [switch]$SearchAllSystems
    )
    begin {
        Write-Verbose 'Verifying JCAPI Key'
        if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
            Connect-JCOnline
        }
        $Parallel = $JCConfig.parallel.Calculated
        $searchAppResultsList = New-Object -TypeName System.Collections.ArrayList
        $resultsArrayList = New-Object -TypeName System.Collections.ArrayList
        $commands = @("Get-JcSdkSystemInsightProgram", "Get-JcSdkSystemInsightApp", "Get-JcSdkSystemInsightLinuxPackage")
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
                if ($SystemId -or $SystemOS) {
                    if ($SystemID -and $SystemOS) {
                        Throw "Cannot specify both SystemID and SystemOS"
                    }
                    # Get the OS Type
                    if ($SystemID) {
                        $OSType = Get-JcSdkSystem -Id $SystemID -Fields osFamily | Select-Object -ExpandProperty OSFamily
                    } else {
                        $OSType = $SystemOS
                        if ($OSType -eq 'macOS') {
                            $OSType = 'Darwin'
                        }
                    }
                    Write-Debug "OSType: $OSType"
                    # Switch for OS Type
                    switch ($OSType) {
                        # Check whether a systemId or systemOS is used
                        'Windows' {
                            if ($version -and $name) {


                                if ($SystemID) {
                                    Get-JcSdkSystemInsightProgram -Filter @("system_id:eq:$SystemID", "name:eq:$name", "version:eq:$version") | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                } elseif ($SystemOS) {
                                    Get-JcSdkSystemInsightProgram -Filter @("name:eq:$name", "version:eq:$version") | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                }
                            } elseif ($name) {


                                if ($SystemID) {
                                    Get-JcSdkSystemInsightProgram -Filter @("system_id:eq:$SystemID", "name:eq:$name") | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                } elseif ($SystemOS) {
                                    Get-JcSdkSystemInsightProgram -Filter @("name:eq:$name") | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                }
                            } elseif ($SystemID) {
                                if ($version) {
                                    Write-Error "Cannot search for software version on Windows without software name."
                                } else {
                                    Get-JcSdkSystemInsightProgram -Filter @("system_id:eq:$SystemID") | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                }
                            } elseif ($SystemOS) {
                                if ($version) {
                                    Write-Error "Cannot search for software version on Windows without software name."
                                } else {
                                    Get-JcSdkSystemInsightProgram | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                }
                            }
                        }
                        'Darwin' {

                            if ($name) {
                                # Check for .app at the end of the software name
                                $macOsSoftwareName = $name
                                if ($macOsSoftwareName -match '.app') {
                                    $ending = $macOsSoftwareName.Substring($macOsSoftwareName.Length - 4)
                                    $macOsSoftwareName = $macOsSoftwareName.Replace($ending, $ending.toLower())
                                    Write-Debug "$macOsSoftwareName"
                                } else {
                                    $macOsSoftwareName = "$macOsSoftwareName.app"
                                    Write-Debug "$macOsSoftwareName"
                                }
                            }

                            # If Software title, version, and system ID are passed then return specific app
                            if ($version -and $macOsSoftwareName) {

                                Write-Debug "Trying to get app with name $macOsSoftwareName and version $version"

                                if ($SystemID) {

                                    Get-JcSdkSystemInsightApp -Filter @("system_id:eq:$SystemID", "name:eq:$macOsSoftwareName", "bundle_short_version:eq:$version") | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                } elseif ($SystemOS) {
                                    Get-JcSdkSystemInsightApp -Filter @("name:eq:$macOsSoftwareName", "bundle_short_version:eq:$version") | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                }
                            } elseif ($macOsSoftwareName) {


                                if ($SystemID) {
                                    Get-JcSdkSystemInsightApp -Filter @("system_id:eq:$SystemID", "name:eq:$macOsSoftwareName") | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                } elseif ($SystemOS) {
                                    Get-JcSdkSystemInsightApp -Filter @("name:eq:$macOsSoftwareName") | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                }
                            } elseif ($SystemID) {
                                if ($version) {
                                    Write-Error "Cannot search for software version on MacOs without software name."
                                } else {
                                    Get-JcSdkSystemInsightApp -Filter @("system_id:eq:$SystemID") | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                }
                            } elseif ($SystemOS) {
                                if ($version) {
                                    Write-Error "Cannot search for software version on MacOs without software name."
                                } else {
                                    Get-JcSdkSystemInsightApp | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                }
                            }

                        }
                        'Linux' {
                            if ($version -and $name) {
                                if ($SystemID) {
                                    Get-JcSdkSystemInsightLinuxPackage -Filter @("system_id:eq:$SystemID", "name:eq:$name", "version:eq:$version") | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                } elseif ($SystemOS) {
                                    Get-JcSdkSystemInsightLinuxPackage -Filter @("name:eq:$name", "version:eq:$version") | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                }
                            } elseif ($name) {
                                if ($SystemID) {
                                    Get-JcSdkSystemInsightLinuxPackage -Filter @("system_id:eq:$SystemID", "name:eq:$name") | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                } elseif ($SystemOS) {
                                    Get-JcSdkSystemInsightLinuxPackage -Filter @("name:eq:$name") | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                }
                            } elseif ($SystemID) {
                                if ($version) {
                                    Write-Error "Cannot search for software version on Linux without software name."
                                } else {
                                    Get-JcSdkSystemInsightLinuxPackage -Filter @("system_id:eq:$SystemID") | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                }

                            } elseif ($SystemOS) {
                                if ($version) {
                                    Write-Error "Cannot search for software version on Linux without software name."
                                } else {
                                    Get-JcSdkSystemInsightLinuxPackage | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                }
                            }
                        }
                    }
                    # IF no systemOs or systemID is passed with name
                } elseif ($name) {
                    # Loop through each OS and get the results
                    Write-Debug "name and or version only passed. Getting all software with name $name"

                    foreach ($os in @('Windows', 'MacOs', 'Linux')) {
                        if ($os -eq 'Windows') {
                            if ($version) {
                                Get-JcSdkSystemInsightProgram -Filter @("name:eq:$name", "version:eq:$version") | ForEach-Object {
                                    [void]$resultsArrayList.Add($_)
                                }
                            } else {
                                Get-JcSdkSystemInsightProgram -Filter @("name:eq:$name") | ForEach-Object {
                                    [void]$resultsArrayList.Add($_)
                                }
                            }

                        } elseif ($os -eq 'MacOs') {
                            $macOsSoftwareName = $name
                            if ($macOsSoftwareName -match '.app') {
                                $ending = $macOsSoftwareName.Substring($macOsSoftwareName.Length - 4)
                                $macOsSoftwareName = $macOsSoftwareName.Replace($ending, $ending.toLower())
                                Write-Debug "$macOsSoftwareName"
                            } else {
                                $macOsSoftwareName = "$macOsSoftwareName.app"
                                Write-Debug "$macOsSoftwareName"
                            }
                            if ($version) {
                                Get-JcSdkSystemInsightApp -Filter @("name:eq:$macOsSoftwareName", "bundle_short_version:eq:$version") | ForEach-Object {
                                    [void]$resultsArrayList.Add($_)
                                }
                            } else {
                                Get-JcSdkSystemInsightApp -Filter @("name:eq:$macOsSoftwareName") | ForEach-Object {
                                    [void]$resultsArrayList.Add($_)
                                }
                            }

                        } elseif ($os -eq 'Linux') {
                            if ($version) {
                                Get-JcSdkSystemInsightLinuxPackage -Filter @("name:eq:$name", "version:eq:$version") | ForEach-Object {
                                    [void]$resultsArrayList.Add($_)
                                }
                            } else {
                                Get-JcSdkSystemInsightLinuxPackage -Filter @("name:eq:$name") | ForEach-Object {
                                    [void]$resultsArrayList.Add($_)
                                }
                            }

                        }
                    }
                } # End of name and or version only passed
                else {
                    # Get all software in all systems in the org
                    # Default/All
                    Write-Debug "Get All"
                    if ($Parallel) {
                        Write-Debug "Getting all software in parallel"
                        $result = $commands | ForEach-Object -Parallel { & $_ }
                        $resultsArrayList = $result
                    } else {
                        $result = $commands | ForEach-Object { & $_ }
                        $resultsArrayList = $result
                    }
                }
            } Search {
                # Case-insensitive search
                # Search for softwareName
                Write-Debug "Search $name"
                if ($name) {
                    if ($version) {
                        Throw 'You cannot specify software version when using -search for a software name'
                    } elseif ($SystemId) {
                        $OSType = Get-JcSdkSystem -Id $SystemID | Select-Object -ExpandProperty OSFamily
                        Switch ($OSType) {
                            "Windows" {
                                $result = Get-JcSdkSystemInsightProgram -Filter @("system_id:eq:$SystemID")
                                if ($result) {
                                    $searchAppResultsList.AddRange($result)
                                }
                            }
                            "Darwin" {
                                $result = Get-JcSdkSystemInsightApp -Filter @("system_id:eq:$SystemID")
                                if ($result) {
                                    $searchAppResultsList.AddRange($result)
                                }
                            }
                            "Linux" {
                                $result = Get-JcSdkSystemInsightLinuxPackage -Filter @("system_id:eq:$SystemID")
                                if ($result) {
                                    $searchAppResultsList.AddRange($result)
                                }
                            }
                        }
                        $filteredResults = $searchAppResultsList | Where-Object { ($_.name -match $name) }
                        $resultsArrayList = $filteredResults
                    } elseif ($SystemOS) {
                        Write-Debug "SystemOS $SystemOS"
                        if ($SystemOS -eq 'Windows') {
                            $result = Get-JcSdkSystemInsightProgram
                            if ($result) {
                                $searchAppResultsList.AddRange($result)
                            }
                        } elseif ($SystemOS -eq 'MacOs') {
                            $result = Get-JcSdkSystemInsightApp
                            if ($result) {
                                $searchAppResultsList.AddRange($result)
                            }
                        } elseif ($SystemOS -eq 'Linux') {
                            $result = Get-JcSdkSystemInsightLinuxPackage
                            if ($result) {
                                $searchAppResultsList.AddRange($result)
                            }
                        }
                        $filteredResults = $searchAppResultsList | Where-Object { ($_.name -match $name) }
                        $resultsArrayList = $filteredResults
                    } else {

                        if ($Parallel) {
                            Write-Debug "Parallel"
                            $result = $commands | ForEach-Object -Parallel { & $_ }
                            if ($result) {
                                [void]$searchAppResultsList.AddRange($result)
                            }

                        } else {
                            $result = $commands | ForEach-Object { & $_ }
                            if ($result) {
                                [void]$searchAppResultsList.AddRange($result)
                            }
                        }
                        $filteredResults = $searchAppResultsList | Where-Object { ($_.name -match $name) }
                        $resultsArrayList = $filteredResults

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