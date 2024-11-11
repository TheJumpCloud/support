Function Get-JCPolicyGroup {
    [CmdletBinding(DefaultParameterSetName = 'ReturnAll')]
    param (
        [Parameter(
            ParameterSetName = 'Name',
            Mandatory = $true,
            HelpMessage = 'The Name of the JumpCloud policy group you wish to query. This value is case sensitive')]
        [System.String]$Name
    )
    begin {
        if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
            Connect-JCOnline
        }
        $URL = switch ($PSCmdlet.ParameterSetName) {
            "ReturnAll" {
                "$JCUrlBasePath/api/v2/policygroups"
            }
            "Name" {
                # TODO: decide on search vs exact match
                "$JCUrlBasePath/api/v2/policygroups?sort=name&filter=name%3Aeq%3A$Name"
                # "$JCUrlBasePath/api/v2/policygroups?sort=name&filter=type%3Aeq%3Apolicy_group%2Cname%3Asearch%3A$Name"
            }
        }
    }
    process {
        $Result = Invoke-JCApi -Method:('GET') -Paginate:($true) -Url:($URL)
    }
    end {

        return $Result
    }
}

