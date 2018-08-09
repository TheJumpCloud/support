Function Remove-JCUserGroupMember ()
{
    [CmdletBinding(DefaultParameterSetName = 'ByName')]

    param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByName',
            Position = 0)]

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID',
            Position = 0)]

        [Alias('name')]
        [String]$GroupName,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByName',
            Position = 1)]
        [String]$Username,

        [Parameter(
            ParameterSetName = 'ByID')]
        [Switch]
        $ByID,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID')]
        [string]$GroupID,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID')]
        [Alias('_id', 'id')]
        [string]$UserID

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
            $GroupNameHash = Get-Hash_UserGroupName_ID
            Write-Debug 'Populating UserNameHash'
            $UserNameHash = Get-Hash_UserName_ID
        }

    }

    process

    {

        if ($PSCmdlet.ParameterSetName -eq 'ByName')
        {
            if ($GroupNameHash.containsKey($GroupName)) {}

            else { Throw "Group does not exist. Run 'Get-JCGroup -type User' to see a list of all your JumpCloud user groups."}

            Write-Debug 'Populating UserNameHash'

            if ($UserNameHash.containsKey($Username)) {}

            else { Throw "Username does not exist. Run 'Get-JCUser | select username' to see a list of all your JumpCloud users."}

            $GroupID = $GroupNameHash.Get_Item($GroupName)
            $UserID = $UserNameHash.Get_Item($Username)

            $body = @{

                type = "user"
                op   = "remove"
                id   = $UserID

            }

            $jsonbody = $body | ConvertTo-Json
            Write-Debug $jsonbody


            $GroupsURL = "https://console.jumpcloud.com/api/v2/usergroups/$GroupID/members"
            Write-Debug $GroupsURL

            try
            {
                $GroupAdd = Invoke-RestMethod -Method POST -Body $jsonbody -Uri $GroupsURL -Headers $hdrs -UserAgent 'Pwsh_1.7.0'
                $Status = 'Removed'
            }
            catch
            {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{

                'GroupName' = $GroupName
                'Username'  = $Username
                'UserID'    = $UserID
                'Status'    = $Status

            }

            $resultsArray += $FormattedResults


        }
        elseif ($PSCmdlet.ParameterSetName -eq 'ByID')

        {
            if (!$GroupID)
            {
                Write-Debug 'Populating GroupNameHash'
                $GroupNameHash = Get-Hash_UserGroupName_ID
                $GroupID = $GroupNameHash.Get_Item($GroupName)
            }

            $body = @{

                type = "user"
                op   = "remove"
                id   = $UserID

            }

            $jsonbody = $body | ConvertTo-Json
            Write-Debug $jsonbody


            $GroupsURL = "https://console.jumpcloud.com/api/v2/usergroups/$GroupID/members"
            Write-Debug $GroupsURL

            try
            {
                $GroupRemove = $GroupAdd = Invoke-RestMethod -Method POST -Body $jsonbody -Uri $GroupsURL -Headers $hdrs -UserAgent 'Pwsh_1.7.0'
                $Status = 'Removed'
            }
            catch
            {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{

                'GroupID' = $GroupID
                'UserID'  = $UserID
                'Status'  = $Status
            }

            $resultsArray += $FormattedResults
        }
    }

    end

    {
        return $resultsArray
    }

}