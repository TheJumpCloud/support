Function Get-JCPolicyGroupMember {
    [CmdletBinding()]
    param (
        [Parameter(
            ParameterSetName = 'ById',
            Mandatory = $true,
            HelpMessage = "The ID of the JumpCloud policy group to query and return members of"
        )]
        [Alias('_id', 'id')]
        [System.String]
        $PolicyGroupID,
        [Parameter(
            ParameterSetName = 'ByName',
            Mandatory = $true,
            HelpMessage = "Retrieves a Configured Policy Templates by Name"
        )]
        [System.String]
        $Name
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
                        $PolicyGroupID = $policyGroup.Id
                    } else {
                        throw
                    }
                } catch {
                    throw "Could not find policy group with name: $name"
                }
                "$JCUrlBasePath/api/v2/policygroups/$PolicyGroupID/membership"
            }
            "ById" {
                "$JCUrlBasePath/api/v2/policygroups/$PolicyGroupID/membership"
                # $paginateRequired = $false
            }
        }
        $URL = "$JCUrlBasePath/api/v2/policygroups/$PolicyGroupID/membership"
    }
    process {
        $response = Invoke-JCApi -Method:('GET') -Paginate:($false) -Url:($URL)

        If ('NoContent' -in $response.PSObject.Properties.Name) {
            $policyMemberList = $null
        } else {
            $policyMemberList = New-Object System.Collections.ArrayList
            foreach ($policy in $response) {
                # return the values by getting the policy individually
                $policyResult = Get-JCPolicy -PolicyID $policy.id
                $policyMemberList.Add($policyResult) | Out-Null
            }
        }

    }
    end {
        return $policyMemberList
    }
}