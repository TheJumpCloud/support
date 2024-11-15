Function Set-JCPolicyGroup {
    [CmdletBinding()]
    param (
        [Parameter(
            ParameterSetName = 'ByName',
            ValueFromPipelineByPropertyName,
            Mandatory = $true,
            HelpMessage = 'The Name of the JumpCloud policy group you wish to set.')]
        [System.String]$Name,
        [Parameter(
            ParameterSetName = 'ByID',
            ValueFromPipelineByPropertyName,
            Mandatory = $true,
            HelpMessage = 'The Id of the JumpCloud policy group you wish to set.')]
        [Alias('_id', 'id')]
        [System.String]$PolicyGroupID,
        [Parameter(Mandatory = $false,
            HelpMessage = 'The new name to set on the existing JumpCloud policy group. If left unspecified, the cmdlet will not rename the existing policy group.')]
        [System.String]
        $NewName,
        [Parameter(
            ValueFromPipelineByPropertyName,
            Mandatory = $false,
            HelpMessage = 'The Description of the JumpCloud policy group you wish to set.')]
        [System.String]$Description
    )
    begin {
        if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
            Connect-JCOnline
        }
        if ($PSBoundParameters["PolicyGroupID"]) {
            # Get the policy by ID
            $foundPolicyGroup = Get-JCPolicyGroup -PolicyGroupID $PolicyGroupID
            if ([string]::IsNullOrEmpty($foundPolicyGroup.ID)) {
                throw "Could not find policy group by ID"
            }

        } elseif ($PSBoundParameters["Name"]) {
            # Get the policy by Name
            $foundPolicyGroup = Get-JCPolicyGroup -Name $Name
            if ([string]::IsNullOrEmpty($foundPolicyGroup.ID)) {
                throw "Could not find policy group by specified Name"
            }
        }
    }
    process {
        # First set the name from PSParamSet if set; else set from policy
        $NameFromProcess = if ($PSBoundParameters["NewName"]) {
            $NewName
        } else {
            $foundPolicyGroup.name
        }
        $DescriptionFromProcess = if ($PSBoundParameters["Description"]) {
            $Description
        } else {
            $foundPolicyGroup.Description
        }

        $URL = "https://console.jumpcloud.com/api/v2/policygroups/$($foundPolicyGroup.id)"
        $BODY = @{
            name        = "$NameFromProcess"
            description = "$DescriptionFromProcess"
        } | ConvertTo-Json
        $Result = Invoke-JCApi -Method:('PUT') -Url:($URL) -Body:($BODY)
    }
    end {
        return $Result
    }
}

