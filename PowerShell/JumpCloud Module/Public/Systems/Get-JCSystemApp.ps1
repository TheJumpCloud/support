function Get-JCSystemApp () {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $false, HelpMessage = 'The System Id of the system you want to search for applications')]
        [string]$SystemID,
        [Parameter( ValueFromPipelineByPropertyName, HelpMessage = 'The type (windows, mac, linux) of the JumpCloud Command you wish to search ex. (Windows, Mac, Linux))')]
        [ValidateSet('Windows', 'MacOs', 'Linux')]
        [string]$SystemOS,
        [Parameter(Mandatory = $false, HelpMessage = 'The name of the application you want to search for ex. (JumpCloud-Agent, Slack)')]
        [string]$SoftwareName,
        [Parameter(Mandatory = $false, HelpMessage = 'The version of the application you want to search for ex. (1.1.2)')]
        [string]$SoftwareVersion
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
        # If Parameter is SystemID then return all apps for that system
        if ($SystemId) {
            $OSType = Get-JCSystem -ID $SystemID | Select-Object -ExpandProperty osFamily
            $OSType
            # Regex if $OSType contains Mac

        } elseif ($SystemOS) {
            if ($OsType -eq 'MacOs') {
                $Ostype = 'Darwin'
            }
            $OSType = $SystemOS
        } else {
            Write-Error 'No SystemID or SystemOS passed'
            return
        }

        #TODO: Loop through each endpoint if $SoftwareName is being search across all OS types




        # Switch on OS type and return appropriate apps
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
                }
                Write-Debug $URL
            }
        }

        if ($Parallel) {
            $resultsArray = Get-JCResults -URL $URL -Method "GET" -limit $limit -parallel $true
        } else {
            $resultsArray = Get-JCResults -URL $URL -Method "GET" -limit $limit
        }
    }
    end {
        return $resultsArray
    }
} # End Function

