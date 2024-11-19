Function Get-JCPolicyGroup {
    [CmdletBinding(DefaultParameterSetName = 'ReturnAll')]
    param (
        [Parameter(
            ParameterSetName = 'ByName',
            Mandatory = $true,
            HelpMessage = 'The Name of the JumpCloud policy group you wish to query. This value is case sensitive')]
        [System.String]
        $Name,
        [Parameter(
            ParameterSetName = 'ById',
            Mandatory = $true,
            HelpMessage = 'The ID of the JumpCloud policy group you wish to query')]
        [Alias('_id', 'id')]
        [System.String]
        $PolicyGroupID
    )
    begin {
        if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
            Connect-JCOnline
        }
        $URL = switch ($PSCmdlet.ParameterSetName) {
            "ReturnAll" {
                "$JCUrlBasePath/api/v2/policygroups"
                $paginateRequired = $true
            }
            "ByName" {
                # TODO: decide on search vs exact match
                "$JCUrlBasePath/api/v2/policygroups?sort=name&filter=name%3Aeq%3A$Name"
                $paginateRequired = $true
                # "$JCUrlBasePath/api/v2/policygroups?sort=name&filter=type%3Aeq%3Apolicy_group%2Cname%3Asearch%3A$Name"
            }
            "ById" {
                "$JCUrlBasePath/api/v2/policygroups/$PolicyGroupID"
                $paginateRequired = $false
            }
        }
    }
    process {
        $Result = Invoke-JCApi -Method:('GET') -Paginate:($paginateRequired) -Url:($URL)
    }
    end {
        return $Result
    }
}

