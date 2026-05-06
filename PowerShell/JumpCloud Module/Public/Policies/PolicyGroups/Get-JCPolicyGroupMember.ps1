Function Get-JCPolicyGroupMember {
    [CmdletBinding()]
    param (
        [Parameter(
            ParameterSetName = 'ById',
            Mandatory = $true,
            HelpMessage = "The ID of the JumpCloud policy group to query and return members of"
        )]
        [Alias('id', '_id')]
        # Changed to $GroupId to maintain consistency across the module
        [System.String]$GroupId,

        [Parameter(
            ParameterSetName = 'ByName',
            Mandatory = $true,
            HelpMessage = "The name of the JumpCloud policy group to query and return members of"
        )]
        [System.String]$Name
    )
    begin {
        if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
            Connect-JCOnline
        }

        $URL = switch ($PSCmdlet.ParameterSetName) {
            "ByName" {
                try {
                    $policyGroup = Get-JCPolicyGroup -Name $Name
                    if ($policyGroup) {
                        $GroupId = $policyGroup.Id
                    } else {
                        throw
                    }
                } catch {
                    throw "Could not find policy group with name: $name"
                }
                "$JCUrlBasePath/api/v2/policygroups/$GroupId/membership"
            }
            "ById" {
                "$JCUrlBasePath/api/v2/policygroups/$GroupId/membership"
            }
        }
    }
    process {
        $response = Invoke-JCApi -Method:('GET') -Paginate:($true) -Url:($URL)

        If ('NoContent' -in $response.PSObject.Properties.Name) {
            $policyMemberList = $null
        } else {
            $policyMemberList = New-Object System.Collections.ArrayList
            foreach ($policy in $response) {
                # Return the values by getting the policy individually
                $policyResult = Get-JCPolicy -PolicyID $policy.id
                $policyMemberList.Add($policyResult) | Out-Null
            }
        }
    }
    end {
        return $policyMemberList
    }
}