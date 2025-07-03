Function Remove-JCUserGroupMember () {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]

    param
    (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', Position = 0, HelpMessage = 'The name of the JumpCloud User Group that you want to remove the User from.')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ByID', Position = 0, HelpMessage = 'The name of the JumpCloud User Group that you want to remove the User from.')]
        [Alias('name')]
        [String]$GroupName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', Position = 1, HelpMessage = 'The Username of the JumpCloud user you wish to remove from the User Group.')]
        [String]$Username,

        [Parameter(ParameterSetName = 'ByID', HelpMessage = 'Use the -ByID parameter when either the UserID or GroupID is passed over the pipeline to the Add-JCUserGroupMember function. The -ByID SwitchParameter will set the ParameterSet to ''ByID'' which will increase the function speed and performance.')]
        [Switch]$ByID,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ByID', HelpMessage = 'The GroupID is used in the ParameterSet ''ByID''. The GroupID for a User Group can be found by running the command: PS C:\> Get-JCGroup -type ''User''')]
        [string]$GroupID,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ByID', HelpMessage = 'The _id of the User which you want to remove from the User Group. To find a JumpCloud UserID run the command: PS C:\> Get-JCUser | Select username, _id
The UserID will be the 24 character string populated for the _id field. UserID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically using the Get-JCUser function before calling Remove-JCUserGroupMember. This is shown in EXAMPLES 2, 3, and 4.')]
        [Alias('_id', 'id')]
        [string]$UserID
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
            $GroupNameHash = Get-DynamicHash -Object Group -GroupType User -returnProperties name
            Write-Debug 'Populating UserNameHash'
            $UserNameHash = Get-DynamicHash -Object User -returnProperties username
        }

    }

    process {

        if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            if ($GroupNameHash.Values.name -notcontains ($GroupName)) {
                Throw "Group does not exist. Run 'Get-JCGroup -type User' to see a list of all your JumpCloud user groups."
            }

            if ($UserNameHash.Values.username -notcontains ($Username)) {
                Throw "Username does not exist. Run 'Get-JCUser | select username' to see a list of all your JumpCloud users."
            }

            $GroupID = $GroupNameHash.GetEnumerator().Where({ $_.Value.name -contains ($GroupName) }).Name
            $UserID = $UserNameHash.GetEnumerator().Where({ $_.Value.username -contains ($Username) }).Name

            $body = @{
                type = "user"
                op   = "remove"
                id   = $UserID
            }

            $jsonbody = $body | ConvertTo-Json
            Write-Debug $jsonbody

            try {
                $GroupRemove = Set-JcSdkUserGroupMember -GroupId $GroupID -Body $body
                $Status = 'Removed'
            } catch {
                $Status = $_.Exception.Message
            }

            $FormattedResults = [PSCustomObject]@{
                'GroupName' = $GroupName
                'Username'  = $Username
                'UserID'    = $UserID
                'Status'    = $Status
            }

            $resultsArray += $FormattedResults


        } elseif ($PSCmdlet.ParameterSetName -eq 'ByID') {
            if (!$GroupID) {
                Write-Debug 'Populating GroupNameHash'
                $GroupNameHash = Get-DynamicHash -Object Group -GroupType User -returnProperties name
                $GroupID = $GroupNameHash.GetEnumerator().Where({ $_.Value.name -contains ($GroupName) }).Name
            }

            $body = @{
                type = "user"
                op   = "remove"
                id   = $UserID
            }

            $jsonbody = $body | ConvertTo-Json
            Write-Debug $jsonbody

            try {
                $GroupRemove = Set-JcSdkUserGroupMember -GroupId $GroupID -Body $body
                $Status = 'Removed'
            } catch {
                $Status = $_.Exception.Message
            }

            $FormattedResults = [PSCustomObject]@{
                'GroupID' = $GroupID
                'UserID'  = $UserID
                'Status'  = $Status
            }

            $resultsArray += $FormattedResults
        }
    }

    end {
        return $resultsArray
    }

}