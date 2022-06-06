Function Get-JCUserGroupMember ()
{
    [CmdletBinding(DefaultParameterSetName = 'ByGroup')]

    param
    (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ByGroup', Position = 0, HelpMessage = 'The name of the JumpCloud User Group you want to return the members of.')]
        [Alias('name')][String]$GroupName,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ByID', HelpMessage = 'If searching for a User Group using the GroupID populate the GroupID in the -ByID field.')]
        [String]$ByID,
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName, HelpMessage = 'Boolean: $true to run in parallel, $false to run in sequential; Default value: false')]
        [Bool]$Parallel=$false
    )

    begin

    {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        if (($PSVersionTable.PSVersion.Major -ge 7) -and ($parallel -eq $true)) {
            Write-Debug "Parallel set to True, PSVersion greater than 7"
            Write-Debug 'Initilizing resultsArray and results ArraryByID'
            $rawResults = [System.Collections.Concurrent.ConcurrentBag[object]]::new()
            $resultsArray = [System.Collections.Concurrent.ConcurrentBag[object]]::new()

            Write-Debug 'Populating GroupNameHash'
            $GroupNameHash = Get-Hash_UserGroupName_ID
            Write-Debug 'Populating UserIDHash'
            $UserIDHash = Get-Hash_ID_Username -parallel $true
        }
        else {
            Write-Debug 'Initilizing resultsArray and results ArraryByID'
            $rawResults = @()
            $resultsArray = [System.Collections.Generic.List[PSObject]]::new()

            
            Write-Debug 'Populating GroupNameHash'
            $GroupNameHash = Get-Hash_UserGroupName_ID
            Write-Debug 'Populating UserIDHash'
            $UserIDHash = Get-Hash_ID_Username
        }

    }


    process

    {

        if ($PSCmdlet.ParameterSetName -eq 'ByGroup')

        {
            foreach ($Group in $GroupName)

            {
                if ($GroupNameHash.containsKey($Group))

                {
                    $Group_ID = $GroupNameHash.Get_Item($Group)
                    Write-Debug "$Group_ID"

                    $limitURL = "{0}/api/v2/usergroups/{1}/members" -f $JCUrlBasePath, $Group_ID
                    Write-Debug $limitURL

                    if ($Parallel) {
                        $rawResults = Get-JCResults -Url $limitURL -method "GET" -limit 100 -parallel $true
                    }
                    else {
                        $rawResults = Get-JCResults -Url $limitURL -method "GET" -limit 100
                    }
                    

                    foreach ($uid in $rawResults)
                    {
                        $Username = $UserIDHash.Get_Item($uid.to.id)

                        $FomattedResult = [pscustomobject]@{

                            'GroupName' = $GroupName
                            'Username'  = $Username
                            'UserID'    = $uid.to.id
                        }

                        $resultsArray.Add($FomattedResult)
                    }

                    $rawResults = $null

                }

                else { Throw "Group does not exist. Run 'Get-JCGroup -type User' to see a list of all your JumpCloud user groups."}

            }
        }

        elseif ($PSCmdlet.ParameterSetName -eq 'ByID')

        {
            $GroupName = ($GroupNameHash.GetEnumerator() | Where-Object Value -eq $ByID).Name
            Write-Debug "$GroupName"

            $limitURL = "{0}/api/v2/usergroups/{1}/members" -f $JCUrlBasePath, $ByID
            Write-Debug $limitURL

            if ($Parallel) {
                $rawResults = Get-JCResults -Url $limitURL -method "GET" -limit 100 -parallel $true
            }
            else {
                $rawResults = Get-JCResults -Url $limitURL -method "GET" -limit 100
            }
            

            foreach ($uid in $rawResults)
            {
                $Username = $UserIDHash.Get_Item($uid.to.id)

                $FomattedResult = [pscustomobject]@{

                    'GroupName' = $GroupName
                    'Username'  = $Username
                    'UserID'    = $uid.to.id
                }

                $resultsArray.Add($FomattedResult)
            }

            $rawResults = $null

        }
    }
    end
    {
        return $resultsArray
    }
}