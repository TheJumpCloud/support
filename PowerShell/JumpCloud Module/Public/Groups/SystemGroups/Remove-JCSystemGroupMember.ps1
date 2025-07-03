Function Remove-JCSystemGroupMember () {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param
    (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', Position = 0, HelpMessage = 'The name of the JumpCloud System Group that you want to remove the System from.')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ByID', Position = 0, HelpMessage = 'The name of the JumpCloud System Group that you want to remove the System from.')]
        [Alias('name')]
        [String]$GroupName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', HelpMessage = 'The _id of the System which you want to remove from the System Group. To find a JumpCloud SystemID run the command: PS C:\> Get-JCSystem | Select hostname, _id
The SystemID will be the 24 character string populated for the _id field. SystemID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically using the Get-JCSystem function before calling Remove-JCSystemGroupMember. This is shown in EXAMPLES 2 and 3.')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ByID', HelpMessage = 'The _id of the System which you want to remove from the System Group. To find a JumpCloud SystemID run the command: PS C:\> Get-JCSystem | Select hostname, _id
The SystemID will be the 24 character string populated for the _id field. SystemID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically using the Get-JCSystem function before calling Remove-JCSystemGroupMember. This is shown in EXAMPLES 2 and 3.')]
        [Alias('id', '_id')]
        [string]$SystemID,

        [Parameter(ParameterSetName = 'ByID', HelpMessage = 'Use the -ByID parameter when the SystemID is passed over the pipeline to the Remove-JCSystemGroupMember function. The -ByID SwitchParameter will set the ParameterSet to ''ByID'' which will increase the function speed and performance.')]
        [Switch]$ByID,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ByID', HelpMessage = 'The GroupID is used in the ParameterSet ''ByID''. The GroupID for a System Group can be found by running the command: PS C:\> Get-JCGroup -type ''System''')]
        [string]$GroupID
    )
    begin {
        Write-Debug 'Verifying JCAPI Key'
        if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
            Connect-JCOnline
        }

        Write-Debug 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        if ($JCOrgID) {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }

        Write-Debug 'Initilizing resultsArray'
        $resultsArray = @()

        if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            Write-Debug 'Populating GroupNameHash'
            $GroupNameHash = Get-DynamicHash -Object Group -GroupType System -returnProperties name
            Write-Debug 'Populating SystemIDHash'
            $SystemHostNameHash = Get-DynamicHash -Object System -returnProperties hostname
        }
    }
    process {

        if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            if ($GroupNameHash.Values.name -notcontains ($GroupName)) {
                Throw "Group does not exist. Run 'Get-JCGroup -type System' to see a list of all your JumpCloud user groups."
            }

            $GroupID = $GroupNameHash.GetEnumerator().Where({ $_.Value.name -contains ($GroupName) }).Name
            $HostName = $SystemHostNameHash.Get_Item($SystemID).hostname

            $body = @{

                type = "system"
                op   = "remove"
                id   = $SystemID

            }

            $jsonbody = $body | ConvertTo-Json
            Write-Debug $jsonbody

            try {
                $GroupRemove = Set-JcSdkSystemGroupMember -GroupId $GroupID -Body $body
                $Status = 'Removed'
            } catch {
                $Status = $_.Exception.Message
            }

            $FormattedResults = [PSCustomObject]@{

                'Groupname' = $GroupName
                'System'    = $HostName
                'SystemID'  = $SystemID
                'Status'    = $Status

            }

            $resultsArray += $FormattedResults


        }

        elseif ($PSCmdlet.ParameterSetName -eq 'ByID') {
            if (!$GroupID) {
                Write-Debug 'Populating GroupNameHash'
                $GroupNameHash = Get-DynamicHash -Object Group -GroupType System -returnProperties name
                $GroupID = $GroupNameHash.GetEnumerator().Where({ $_.Value.name -contains ($GroupName) }).Name
            }

            $body = @{

                type = "system"
                op   = "remove"
                id   = $SystemID

            }

            $jsonbody = $body | ConvertTo-Json
            Write-Debug $jsonbody


            try {
                $GroupRemove = Set-JcSdkSystemGroupMember -GroupId $GroupID -Body $body
                $Status = 'Removed'
            } catch {
                $Status = $_.Exception.Message
            }

            $FormattedResults = [PSCustomObject]@{

                'Group'    = $GroupID
                'SystemID' = $SystemID
                'Status'   = $Status
            }

            $resultsArray += $FormattedResults
        }
    }

    end {
        return $resultsArray
    }

}