function Get-JCSystemKB () {
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The System Id(s) of the system(s) you want to search for KBs. Accepts comma separated strings. Ex: 618972a694380d17e4145626, 63210fc54861961ac387f0ac, ...',
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'SearchFilter'
        )]
        [Alias("system_id", "id", "_id")]
        [ValidateNotNullorEmpty()]
        [string[]]$SystemID,
        [Parameter(
            Mandatory = $false ,
            ParameterSetName = 'SearchFilter',
            HelpMessage = 'The KB(s) you wish to search for. Accepts comma separated strings. Ex: KB5006670, KB5005699, KB5000736, ...')]

        [Alias("hotfix_id")]
        [string[]]$KB
    )
    begin {
        Write-Verbose 'Verifying JCAPI Key'
        if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
            Connect-JCOnline
        }
        $Parallel = $JCConfig.parallel.Calculated
    }
    process {
        [int]$limit = '10000'
        Write-Verbose "Setting limit to $limit"

        [int]$skip = '0'
        Write-Verbose "Setting skip to $skip"

        $SystemInsightsURL = "$JCUrlBasePath/api/v2/systeminsights/patches"

        switch ($PSCmdlet.ParameterSetName) {
            All {
                if ($Parallel) {
                    $systemInsightsPatches = Get-JCResults -URL $SystemInsightsURL -method "GET" -limit $limit -Parallel $true
                } else {
                    $systemInsightsPatches = Get-JCResults -URL $SystemInsightsURL -method "GET" -limit $limit
                }
            }
            SearchFilter {
                $filter = @()
                foreach ($param in $PSBoundParameters.GetEnumerator()) {
                    switch ($param.Key) {
                        SystemID {
                            if ($param.Value.Count -gt 1) {
                                $filter += "system_id:in:$($param.Value -join '|')"
                            } else {
                                $filter += "system_id:eq:$($param.Value)"
                            }
                        }
                        KB {
                            if ($param.Value.Count -gt 1) {
                                $filter += "hotfix_id:in:$($param.Value -join '|')"
                            } else {
                                $filter += "hotfix_id:eq:$($param.Value)"
                            }
                        }
                        Default {
                            continue
                        }
                    }
                }

                if ($filter.Count -gt 1) {
                    $URL = "$($SystemInsightsURL)?filter[0]=$($filter[0])&filter[1]=$($filter[1])"
                } else {
                    $URL = "$($SystemInsightsURL)?filter=$($filter)"
                }


                if ($Parallel) {
                    $systemInsightsPatches = Get-JCResults -URL $URL -method "GET" -limit $limit -Parallel $true
                } else {
                    $systemInsightsPatches = Get-JCResults -URL $URL -method "GET" -limit $limit
                }
            }
        }
    }
    end {
        return $systemInsightsPatches
    }
}