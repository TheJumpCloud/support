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
        $searchAppResultsList = New-Object -TypeName System.Collections.ArrayList

        Write-Verbose 'Initilizing resultsArray'
        $resultsArrayList = New-Object -TypeName System.Collections.ArrayList

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

                    if ($SystemID) {
                        $OSType = Get-JcSdkSystem -ID $SystemID | Select-Object -ExpandProperty OSFamily
                    } else {
                        $OSType = $SystemOS
                        if ($OSType -eq 'macOS') {
                            $OSType = 'Darwin'
                        }
                    }
                    Write-Debug "OSType: $OSType"
                    switch ($OSType) {
                        'Windows' {
                            # If Software title, version, and system ID are passed then return specific app
                            if ($SoftwareVersion -and $SoftwareName) {
                                # Handle Special Characters
                                $SoftwareName = [System.Web.HttpUtility]::UrlEncode($SoftwareName)
                                if ($SystemID) {
                                    Get-JcSdkSystemInsightProgram -Filter @("system_id:eq:$SystemID", "name:eq:$SoftwareName", "version:eq:$SoftwareVersion") | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                } elseif ($SystemOS) {
                                    Get-JcSdkSystemInsightProgram -Filter @("name:eq:$SoftwareName", "version:eq:$SoftwareVersion") | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                }
                            } elseif ($SoftwareName) {
                                # Handle Special Characters
                                $SoftwareName = [System.Web.HttpUtility]::UrlEncode($SoftwareName)
                                if ($SystemID) {
                                    Get-JcSdkSystemInsightProgram -Filter @("system_id:eq:$SystemID", "name:eq:$SoftwareName") | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                } elseif ($SystemOS) {
                                    Get-JcSdkSystemInsightProgram -Filter @("name:eq:$SoftwareName") | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                }
                            } elseif ($SystemID) {
                                if ($SoftwareVersion) {
                                    Write-Error "Cannot search for software version on Windows without software name."
                                } else {
                                    Get-JcSdkSystemInsightProgram -Filter @("system_id:eq:$SystemID") | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                }
                            } elseif ($SystemOS) {
                                if ($SoftwareVersion) {
                                    Write-Error "Cannot search for software version on Windows without software name."
                                } else {
                                    Get-JcSdkSystemInsightProgram | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                }
                            }
                        }
                        'Darwin' {

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
                            }

                            # If Software title, version, and system ID are passed then return specific app
                            if ($SoftwareVersion -and $SoftwareName) {
                                # Handle Special Characters
                                Write-Debug "Trying to get app with name $SoftwareName and version $SoftwareVersion"
                                $SoftwareName = [System.Web.HttpUtility]::UrlEncode($SoftwareName)
                                if ($SystemID) {

                                    Get-JcSdkSystemInsightApp -Filter @("system_id:eq:$SystemID", "name:eq:$SoftwareName", "bundle_short_version:eq:$SoftwareVersion") | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                } elseif ($SystemOS) {
                                    Get-JcSdkSystemInsightApp -Filter @("name:eq:$SoftwareName", "bundle_short_version:eq:$SoftwareVersion") | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                }
                            } elseif ($SoftwareName) {
                                # Handle Special Characters
                                $SoftwareName = [System.Web.HttpUtility]::UrlEncode($SoftwareName)
                                if ($SystemID) {
                                    Get-JcSdkSystemInsightApp -Filter @("system_id:eq:$SystemID", "name:eq:$SoftwareName") | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                } elseif ($SystemOS) {
                                    Get-JcSdkSystemInsightApp -Filter @("name:eq:$SoftwareName") | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                }
                            } elseif ($SystemID) {
                                if ($SoftwareVersion) {
                                    Write-Error "Cannot search for software version on MacOs without software name."
                                } else {
                                    Get-JcSdkSystemInsightApp -Filter @("system_id:eq:$SystemID") | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                }
                            } elseif ($SystemOS) {
                                if ($SoftwareVersion) {
                                    Write-Error "Cannot search for software version on MacOs without software name."
                                } else {
                                    Get-JcSdkSystemInsightApp | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                }
                            }

                        }
                        'Linux' {

                            if ($SoftwareVersion -and $SoftwareName) {
                                # Handle Special Characters
                                $SoftwareName = [System.Web.HttpUtility]::UrlEncode($SoftwareName)
                                if ($SystemID) {
                                    Get-JcSdkSystemInsightLinuxPackage -Filter @("system_id:eq:$SystemID", "name:eq:$SoftwareName", "version:eq:$SoftwareVersion") | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                } elseif ($SystemOS) {
                                    Get-JcSdkSystemInsightLinuxPackage -Filter @("name:eq:$SoftwareName", "version:eq:$SoftwareVersion") | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                }
                            } elseif ($SoftwareName) {
                                # Handle Special Characters
                                $SoftwareName = [System.Web.HttpUtility]::UrlEncode($SoftwareName)
                                if ($SystemID) {
                                    Get-JcSdkSystemInsightLinuxPackage -Filter @("system_id:eq:$SystemID", "name:eq:$SoftwareName") | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                } elseif ($SystemOS) {
                                    Get-JcSdkSystemInsightLinuxPackage -Filter @("name:eq:$SoftwareName") | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                }
                            } elseif ($SystemID) {
                                if ($SoftwareVersion) {
                                    Write-Error "Cannot search for software version on Linux without software name."
                                } else {
                                    Get-JcSdkSystemInsightLinuxPackage -Filter @("system_id:eq:$SystemID") | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                }

                            } elseif ($SystemOS) {
                                if ($SoftwareVersion) {
                                    Write-Error "Cannot search for software version on Linux without software name."
                                } else {
                                    Get-JcSdkSystemInsightLinuxPackage | ForEach-Object {
                                        [void]$resultsArrayList.Add($_)
                                    }
                                }
                            }
                        }

                    }
                } elseif ($SoftwareName) {
                    # Loop through each OS and get the results
                    Write-Debug "SoftwareName"
                    foreach ($os in @('Windows', 'MacOs', 'Linux')) {
                        if ($os -eq 'Windows') {
                            Get-JcSdkSystemInsightProgram -Filter @("name:eq:$SoftwareName") | ForEach-Object {
                                [void]$resultsArrayList.Add($_)
                            }
                        } elseif ($os -eq 'MacOs') {
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
                            Get-JcSdkSystemInsightApp -Filter @("name:eq:$SoftwareName") | ForEach-Object {

                                [void]$resultsArrayList.Add($_)
                            }
                        } elseif ($os -eq 'Linux') {
                            Get-JcSdkSystemInsightLinuxPackage -Filter @("name:eq:$SoftwareName") | ForEach-Object {
                                [void]$resultsArrayList.Add($_)
                            }
                        }
                    }
                }

                else {
                    # Default/All
                    Write-Debug "Test All"
                    #TODO: Parallelize this
                    foreach ($os in @('Windows', 'MacOs', 'Linux')) {
                        if ($os -eq 'Windows') {
                            Get-JcSdkSystemInsightProgram | ForEach-Object {
                                [void]$resultsArrayList.Add($_)
                            }
                        } elseif ($os -eq 'MacOs') {
                            Get-JcSdkSystemInsightApp | ForEach-Object {
                                [void]$resultsArrayList.Add($_)
                            }
                        } elseif ($os -eq 'Linux') {
                            Get-JcSdkSystemInsightLinuxPackage | ForEach-Object {
                                [void]$resultsArrayList.Add($_)
                            }
                        }

                    }
                }
            } Search {
                # Search for softwareName
                Write-Debug "Search $SoftwareName"
                if ($SoftwareName) {
                    if ($SoftwareVersion) {
                        Throw 'You cannot specify software version when using -search for a software name'
                    } elseif ($SystemId) {
                        $OSType = Get-JcSdkSystem -ID $SystemID | Select-Object -ExpandProperty OSFamily
                        $OSType
                        if ($OSType -eq 'Windows') {
                            Get-JcSdkSystemInsightProgram -Filter @("system_id:eq:$SystemID") | ForEach-Object {
                                [void]$searchAppResultsList.Add($_)
                            }
                        } elseif ($OSType -eq 'Darwin') {
                            Get-JcSdkSystemInsightApp -Filter @("system_id:eq:$SystemID") | ForEach-Object {
                                [void]$searchAppResultsList.Add($_)
                            }
                        } elseif ($OSType -eq 'Linux') {
                            Get-JcSdkSystemInsightLinuxPackage -Filter @("system_id:eq:$SystemID") | ForEach-Object {
                                [void]$searchAppResultsList.Add($_)
                            }
                        }
                        $searchAppResultsList.Count

                        $searchAppResultsList | ForEach-Object {
                            $results = $_ | Where-Object { ($_.name -match $SoftwareName) }
                            $results | ForEach-Object {
                                [void]$resultsArrayList.Add($_)
                            }
                        }
                    } elseif ($SystemOS) {
                        Write-Debug "SystemOS $SystemOS"
                        if ($SystemOS -eq 'Windows') {
                            Get-JcSdkSystemInsightProgram | ForEach-Object {
                                [void]$searchAppResultsList.Add($_)
                            }
                        } elseif ($SystemOS -eq 'MacOs') {
                            Get-JcSdkSystemInsightApp  | ForEach-Object {
                                [void]$searchAppResultsList.Add($_)
                            }
                        } elseif ($SystemOS -eq 'Linux') {
                            Get-JcSdkSystemInsightLinuxPackage | ForEach-Object {
                                [void]$searchAppResultsList.Add($_)
                            }
                        }
                        $searchAppResultsList | ForEach-Object {
                            $results = $_ | Where-Object { ($_.name -match $SoftwareName) }
                            $results | ForEach-Object {
                                [void]$resultsArrayList.Add($_)
                            }
                        }
                    } else {
                        Write-Debug "Test All"
                        # Get all the results with only softwarename
                        # Loop through each OS and get the results
                        foreach ($os in @('Windows', 'MacOs', 'Linux')) {
                            if ($os -eq 'Windows') {
                                Get-JcSdkSystemInsightProgram | ForEach-Object {
                                    [void]$searchAppResultsList.Add($_)
                                }
                            } elseif ($os -eq 'MacOs') {
                                Get-JcSdkSystemInsightApp | ForEach-Object {
                                    [void]$searchAppResultsList.Add($_)
                                }
                            } elseif ($os -eq 'Linux') {
                                Get-JcSdkSystemInsightLinuxPackage | ForEach-Object {
                                    [void]$searchAppResultsList.Add($_)
                                }
                            }
                        }

                        $searchAppResultsList | ForEach-Object {
                            $results = $_ | Where-Object { ($_.name -match $SoftwareName) }
                            $results | ForEach-Object {
                                [void]$resultsArrayList.Add($_)
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