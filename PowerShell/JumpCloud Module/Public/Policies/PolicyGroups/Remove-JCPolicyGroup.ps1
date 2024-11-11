Function Remove-JCPolicyGroup {
    [CmdletBinding()]
    param (
        [Parameter(
            ParameterSetName = 'ByName',
            Mandatory = $true,
            HelpMessage = 'The Name of the JumpCloud policy group you wish to remove.')]
        [System.String]$Name,
        [Parameter(
            ParameterSetName = 'ByID',
            ValueFromPipelineByPropertyName,
            Mandatory = $true,
            HelpMessage = 'The ID of the JumpCloud policy group you wish to remove.')]
        [Alias('_id', 'id')]
        [System.String]$PolicyGroupID,
        [Parameter(HelpMessage = 'A SwitchParameter which suppresses the warning message when removing a JumpCloud Policy.')]
        [Switch]
        $Force
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
        if (!$Force) {
            Write-Warning "Are you sure you wish to delete policy group: `'$PolicyGroupID`'?" -WarningAction Inquire
        }
        $Result = Invoke-JCApi -Method:('DELETE') -Url:($URL)
    }
    end {
        return $Result
    }
}

