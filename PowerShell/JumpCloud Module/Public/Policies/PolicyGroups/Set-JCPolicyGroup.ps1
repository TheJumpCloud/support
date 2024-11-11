Function Set-JCPolicyGroup {
    [CmdletBinding()]
    param (
        [Parameter(
            ValueFromPipelineByPropertyName,
            Mandatory = $true,
            HelpMessage = 'The Name of the JumpCloud policy group you wish to set.')]
        [System.String]$Name,
        [Parameter(
            ValueFromPipelineByPropertyName,
            Mandatory = $true,
            HelpMessage = 'The Id of the JumpCloud policy group you wish to set.')]
        [Alias('_id', 'id')]
        [System.String]$PolicyGroupID,
        [Parameter(
            ValueFromPipelineByPropertyName,
            Mandatory = $true,
            HelpMessage = 'The Description of the JumpCloud policy group you wish to set.')]
        [System.String]$Description
    )
    begin {
        if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
            Connect-JCOnline
        }
        if ($PSCmdlet.ParameterSetName -eq "ByName") {

            $foundPolicy = Get-JCPolicyGroup -Name $Name
            if ($foundPolicy) {
                $PolicyGroupID = $foundPolicy.ID
            }
        }
    }
    process {
        $URL = "https://console.jumpcloud.com/api/v2/policygroups/$PolicyGroupID"
        $BODY = @{
            name        = "$Name"
            description = "$Description"
        } | ConvertTo-Json
        $Result = Invoke-JCApi -Method:('PUT') -Url:($URL) -Body:($BODY)
    }
    end {
        return $Result
    }
}

