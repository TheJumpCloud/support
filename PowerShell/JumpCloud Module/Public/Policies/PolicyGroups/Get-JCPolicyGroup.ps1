Function Get-JCPolicyGroup {
    [CmdletBinding(DefaultParameterSetName = 'ReturnAll')]
    param (
        [Parameter(
            ParameterSetName = 'Name',
            HelpMessage = 'The Name of the JumpCloud policy group you wish to query.')]
        [System.String]$Name
    )
    begin {
        $URL = switch ($PSCmdlet.ParameterSetName) {
            "ReturnAll" {
                "$JCUrlBasePath/api/v2/policygroups"
            }
            "Name" {
                "$JCUrlBasePath/api/v2/policygroups?sort=name&filter=name%3Aeq%3A$Name"
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

