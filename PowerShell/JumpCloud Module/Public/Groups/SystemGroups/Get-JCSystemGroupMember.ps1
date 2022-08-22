Function Get-JCSystemGroupMember () {
    [CmdletBinding(DefaultParameterSetName = 'ByGroup')]

    param
    (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ByGroup', Position = 0, HelpMessage = 'The name of the JumpCloud System Group you want to return the members of.')]
        [Alias('name')][String]$GroupName,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ByID', HelpMessage = 'If searching for a System Group using the GroupID populate the GroupID in the -ByID field.')]
        [Alias('_id', 'id')][String]$ByID
    )

    begin {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {
            Connect-JConline
        }

        $Parallel = $JCConfig.parallel.Calculated

        if ($Parallel) {
            Write-Debug 'Initilizing resultsArray and results ArraryByID'
            $rawResults = [System.Collections.Concurrent.ConcurrentBag[object]]::new()
            $resultsArray = [System.Collections.Concurrent.ConcurrentBag[object]]::new()
        } else {
            Write-Debug 'Initilizing resultsArray and results ArraryByID'
            $rawResults = @()
            $resultsArray = [System.Collections.Generic.List[PSObject]]::new()
        }
        Write-Debug 'Populating GroupNameHash'
        $GroupNameHash = Get-DynamicHash -Object Group -GroupType System -returnProperties name
        Write-Debug 'Populating SystemIDHash'
        $SystemIDHash = Get-DynamicHash -Object System -returnProperties hostname
    }

    process {

        if ($PSCmdlet.ParameterSetName -eq 'ByGroup') {
            foreach ($Group in $GroupName) {
                if ($GroupNameHash.Values.name -contains ($Group)) {
                    $Group_ID = $GroupNameHash.GetEnumerator().Where({ $_.Value.name -contains ($Group) }).Name
                    Write-Debug "$Group_ID"

                    $limitURL = "{0}/api/v2/Systemgroups/{1}/members" -f $JCUrlBasePath, $Group_ID
                    Write-Debug $limitURL

                    if ($Parallel) {
                        $rawResults = Get-JCResults -Url $limitURL -method "GET" -limit 100 -parallel $true
                    } else {
                        $rawResults = Get-JCResults -Url $limitURL -method "GET" -limit 100
                    }

                    foreach ($uid in $rawResults) {
                        $Systemname = $SystemIDHash.Get_Item($uid.to.id).hostname

                        $FomattedResult = [pscustomobject]@{

                            'GroupName' = $GroupName
                            'System'    = $Systemname
                            'SystemID'  = $uid.to.id
                        }

                        $resultsArray.Add($FomattedResult)
                    }

                    $rawResults = $null

                }

                else {
                    Throw "Group does not exist. Run 'Get-JCGroup -type System' to see a list of all your JumpCloud System groups."
                }

            }
        }

        elseif ($PSCmdlet.ParameterSetName -eq 'ByID') {
            $GroupName = $GroupNameHash[$ByID].name
            Write-Debug "$GroupName"

            $limitURL = "{0}/api/v2/Systemgroups/{1}/members" -f $JCUrlBasePath, $ByID
            Write-Debug $limitURL

            if ($Parallel) {
                $rawResults = Get-JCResults -Url $limitURL -method "GET" -limit 100 -parallel $true
            } else {
                $rawResults = Get-JCResults -Url $limitURL -method "GET" -limit 100
            }

            foreach ($uid in $rawResults) {
                $Systemname = $SystemIDHash.Get_Item($uid.to.id).hostname

                $FomattedResult = [pscustomobject]@{

                    'GroupName' = $GroupName
                    'System'    = $Systemname
                    'SystemID'  = $uid.to.id
                }

                $resultsArray.Add($FomattedResult)
            }

            $rawResults = $null

        }
    }
    end {
        return $resultsArray
    }
}