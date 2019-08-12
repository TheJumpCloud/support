Function Remove-JCSystemGroupMember ()
{
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param
    (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', Position = 0, HelpMessage = 'The name of the JumpCloud System Group that you want to remove the System from.')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ByID', Position = 0, HelpMessage = 'The name of the JumpCloud System Group that you want to remove the System from.')]
        [Alias('name')]
        [String]$GroupName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', HelpMessage = 'The _id of the System which you want to remove from the System Group. To find a JumpCloud SystemID run the command: `PS C:\> Get-JCSystem | Select hostname, _id`. The SystemID will be the 24 character string populated for the _id field. SystemID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically using the Get-JCSystem function before calling Remove-JCSystemGroupMember. This is shown in EXAMPLES 2 and 3.')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ByID', HelpMessage = 'The _id of the System which you want to remove from the System Group. To find a JumpCloud SystemID run the command: `PS C:\> Get-JCSystem | Select hostname, _id`. The SystemID will be the 24 character string populated for the _id field. SystemID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically using the Get-JCSystem function before calling Remove-JCSystemGroupMember. This is shown in EXAMPLES 2 and 3.')]
        [Alias('id', '_id')]
        [string]$SystemID,

        [Parameter(ParameterSetName = 'ByID', HelpMessage = 'Use the -ByID parameter when the SystemID is passed over the pipeline to the Remove-JCSystemGroupMember function. The -ByID SwitchParameter will set the ParameterSet to ''ByID'' which will increase the function speed and performance.')]
        [Switch]$ByID,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ByID', HelpMessage = 'The GroupID is used in the ParameterSet ''ByID''. The GroupID for a System Group can be found by running the command: `PS C:\> Get-JCGroup -type ''System''`')]
        [string]$GroupID
    )
    begin

    {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Debug 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        if ($JCOrgID)
        {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }

        Write-Debug 'Initilizing resultsArray'
        $resultsArray = @()

        if ($PSCmdlet.ParameterSetName -eq 'ByName')
        {
            Write-Debug 'Populating GroupNameHash'
            $GroupNameHash = Get-Hash_SystemGroupName_ID
            Write-Debug 'Populating SystemHostNameHash'
            $SystemHostNameHash = Get-Hash_SystemID_HostName
        }
    }
    process

    {

        if ($PSCmdlet.ParameterSetName -eq 'ByName')
        {
            if ($GroupNameHash.containsKey($GroupName)) {}

            else { Throw "Group does not exist. Run 'Get-JCGroup -type System' to see a list of all your JumpCloud user groups."}

            $GroupID = $GroupNameHash.Get_Item($GroupName)
            $HostName = $SystemHostNameHash.Get_Item($SystemID)

            $body = @{

                type = "system"
                op   = "remove"
                id   = $SystemID

            }

            $jsonbody = $body | ConvertTo-Json
            Write-Debug $jsonbody


            $GroupsURL = "$JCUrlBasePath/api/v2/systemgroups/$GroupID/members"
            Write-Debug $GroupsURL

            try
            {
                $GroupRemove = Invoke-RestMethod -Method POST -Body $jsonbody -Uri $GroupsURL -Headers $hdrs -UserAgent:(Get-JCUserAgent)
                $Status = 'Removed'
            }
            catch
            {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{

                'Groupname' = $GroupName
                'System'    = $HostName
                'SystemID'  = $SystemID
                'Status'    = $Status

            }

            $resultsArray += $FormattedResults


        }

        elseif ($PSCmdlet.ParameterSetName -eq 'ByID')

        {
            if (!$GroupID)
            {
                Write-Debug 'Populating GroupNameHash'
                $GroupNameHash = Get-Hash_SystemGroupName_ID
                $GroupID = $GroupNameHash.Get_Item($GroupName)
            }

            $body = @{

                type = "system"
                op   = "remove"
                id   = $SystemID

            }

            $jsonbody = $body | ConvertTo-Json
            Write-Debug $jsonbody


            $GroupsURL = "$JCUrlBasePath/api/v2/systemgroups/$GroupID/members"
            Write-Debug $GroupsURL

            try
            {
                $GroupRemove = Invoke-RestMethod -Method POST -Body $jsonbody -Uri $GroupsURL -Headers $hdrs -UserAgent:(Get-JCUserAgent)
                $Status = 'Removed'
            }
            catch
            {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{

                'Group'    = $GroupID
                'SystemID' = $SystemID
                'Status'   = $Status
            }

            $resultsArray += $FormattedResults
        }
    }

    end

    {
        return $resultsArray
    }

}