Function Get-JCSystemGroupMember ()
{
    [CmdletBinding(DefaultParameterSetName = 'ByGroup')]

    param
    (

        [Parameter(Mandatory, ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByGroup',
            Position = 0,
            HelpMessage = 'The name of the JumpCloud System Group you want to return the members of.')]
        [Alias('name')]
        [String]$GroupName,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID',
            HelpMessage = 'If searching for a System Group using the GroupID populate the GroupID in the -ByID field.')]
        [Alias('_id', 'id')]
        [String]$ByID
    )

    begin

    {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Debug 'Initilizing resultsArray and results ArraryByID'
        $rawResults = @()
        $resultsArray = @()

        if ($PSCmdlet.ParameterSetName -eq 'ByGroup')
        {
            Write-Debug 'Populating GroupNameHash'
            $GroupNameHash = Get-Hash_SystemGroupName_ID
            Write-Debug 'Populating SystemIDHash'
            $SystemIDHash = Get-Hash_SystemID_HostName
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

                    $limitURL = "{0}/api/v2/Systemgroups/{1}/members" -f $JCUrlBasePath, $Group_ID
                    $rawResults = Get-JCResults -Url $limitURL

                    foreach ($uid in $rawResults)
                    {
                        $Systemname = $SystemIDHash.Get_Item($uid.to.id)

                        $FomattedResult = [pscustomobject]@{

                            'GroupName' = $GroupName
                            'System'    = $Systemname
                            'SystemID'  = $uid.to.id
                        }

                        $resultsArray += $FomattedResult
                    }

                    $rawResults = $null

                }

                else { Throw "Group does not exist. Run 'Get-JCGroup -type System' to see a list of all your JumpCloud System groups." }

            }
        }

        elseif ($PSCmdlet.ParameterSetName -eq 'ByID')

        {
            $limitURL = "{0}/api/v2/Systemgroups/{1}/members" -f $JCUrlBasePath, $ByID
            $resultsArray = Get-JCResults -Url $limitURL

        }
    }
    end
    {
        return $resultsArray
    }
}