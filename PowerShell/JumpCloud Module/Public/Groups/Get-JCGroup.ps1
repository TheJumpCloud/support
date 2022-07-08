Function Get-JCGroup () {
    [CmdletBinding(DefaultParameterSetName = 'ReturnAll')]
    param
    (
        [Parameter(ParameterSetName = 'Type', Position = 0, HelpMessage = 'The type of JumpCloud group you want to return. Note there are only two options - User and System.')]
        [ValidateSet('User', 'System')]
        [string]$Type
    )
    DynamicParam {
        If ((Get-PSCallStack).Command -like '*MarkdownHelp') {
            $Type = 'User'
        }
        If ($Type) {
            $attr = New-Object System.Management.Automation.ParameterAttribute
            $attr.HelpMessage = "Enter the group name"
            $attr.Mandatory = $false
            $attr.ValueFromPipelineByPropertyName = $true
            $attrColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attrColl.Add($attr)
            $param = New-Object System.Management.Automation.RuntimeDefinedParameter('Name', [string], $attrColl)
            $dict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $dict.Add('Name', $param)
            return $dict
        }
    }
    begin {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {
            Connect-JConline
        }

        [int]$limit = '100'
        Write-Debug "Setting limit to $limit"

        $Parallel = $JCParallel

        Write-Debug 'Initilizing resultsArray'
        $resultsArray = @()

        if ($param.IsSet) {
            if ($Type -eq 'System') {
                Write-Verbose 'Populating SystemGroupHash'
                $SystemGroupHash = Get-DynamicHash -Object Group -GroupType System -returnProperties name
            } elseif ($Type -eq 'User') {
                Write-Verbose 'Populating UserGroupHash'
                $UserGroupHash = Get-DynamicHash -Object Group -GroupType User -returnProperties name
            }
        }
    }
    process {
        if ($PSCmdlet.ParameterSetName -eq 'ReturnAll') {
            $limitURL = "$JCUrlBasePath/api/v2/groups"
            Write-Debug $limitURL

            if ($Parallel) {
                $resultsArray = Get-JCResults -URL $limitURL -Method "GET" -limit $limit -parallel $true
            } else {
                $resultsArray = Get-JCResults -URL $limitURL -Method "GET" -limit $limit
            }

            $resultsArray = $resultsArray | Sort-Object type, name

            $count = ($resultsArray.results).Count
            Write-Debug "Results count equals $count"
        } elseif (($PSCmdlet.ParameterSetName -eq 'Type') -and !($param.IsSet)) {
            if ($type -eq 'User') {
                $limitURL = "$JCUrlBasePath/api/v2/groups?filter=type:eq:user_group"
                if ($Parallel) {
                    $resultsArray = Get-JCResults -URL $limitURL -Method "GET" -limit $limit -parallel $true
                } else {
                    $resultsArray = Get-JCResults -URL $limitURL -Method "GET" -limit $limit
                }
                $resultsArray = $resultsArray | Sort-Object name
            } elseif ($type -eq 'System') {
                $limitURL = "$JCUrlBasePath/api/v2/groups?filter=type:eq:system_group"
                if ($Parallel) {
                    $resultsArray = Get-JCResults -URL $limitURL -Method "GET" -limit $limit -parallel $true
                } else {
                    $resultsArray = Get-JCResults -URL $limitURL -Method "GET" -limit $limit
                }
                $resultsArray = $resultsArray | Sort-Object name
            }
        } elseif (($PSCmdlet.ParameterSetName -eq 'Type') -and ($param.IsSet)) {
            if ($Type -eq 'System') {
                $GID = $SystemGroupHash.GetEnumerator().Where({ $_.Value.name -contains ($param.Value) }).Name
                if ($GID) {
                    $GURL = "$JCUrlBasePath/api/v2/systemgroups/$GID"
                    $resultsArray = Get-JCResults -URL $GURL -Method "GET" -limit $limit
                } else {
                    Write-Error "There is no $Type group named $($param.Value). NOTE: Group names are case sensitive."
                }
            } elseif ($Type -eq 'User') {
                $GID = $UserGroupHash.GetEnumerator().Where({ $_.Value.name -contains ($param.Value) }).Name
                if ($GID) {
                    $GURL = "$JCUrlBasePath/api/v2/usergroups/$GID"
                    $resultsArray = Get-JCResults -URL $GURL -Method "GET" -limit $limit
                } else {
                    Write-Error "There is no $Type group named $($param.Value). NOTE: Group names are case sensitive."
                }
            }
        }
    }
    end {
        return $resultsArray
    }
}