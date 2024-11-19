Function Remove-JCPolicyGroup {
    [CmdletBinding()]
    param (
        [Parameter(
            ParameterSetName = 'ByName',
            Mandatory = $true,
            HelpMessage = 'The Name of the JumpCloud policy group you wish to remove.')]
        [System.String]
        $Name,
        [Parameter(
            ParameterSetName = 'ByID',
            ValueFromPipelineByPropertyName,
            Mandatory = $true,
            HelpMessage = 'The ID of the JumpCloud policy group you wish to remove.')]
        [Alias('_id', 'id')]
        [System.String]
        $PolicyGroupID,
        [Parameter(HelpMessage = 'A SwitchParameter which suppresses the warning message when removing a JumpCloud policy group.')]
        [Switch]
        $Force
    )
    begin {
        Write-Debug 'Verifying JCAPI Key'
        if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
            Connect-JCOnline
        }

        switch ($PSCmdlet.ParameterSetName) {
            'ByName' {
                try {
                    $foundPolicy = Get-JCPolicyGroup -Name $Name
                    $PolicyGroupID = $foundPolicy.ID

                } catch {
                    $PolicyGroupID = $null
                }
                if ($foundPolicy) {
                }
            }
            'ByID' {
                try {
                    $foundPolicy = Get-JCPolicyGroup -PolicyGroupID $PolicyGroupID
                    $PolicyGroupID = $foundPolicy.ID

                } catch {
                    $PolicyGroupID = $null
                }
            }
        }
    }
    process {
        if (-NOT [System.String]::IsNullOrEmpty($PolicyGroupID)) {
            $URL = "https://console.jumpcloud.com/api/v2/policygroups/$PolicyGroupID"
            if (-NOT $Force) {
                Write-Warning "Are you sure you wish to delete policy group: `'$($foundPolicy.Name)`'?" -WarningAction Inquire
            }
            try {
                $Result = Invoke-JCApi -Method:('DELETE') -Url:($URL)
                $Status = "Deleted"
            } catch {
                $Status = $_.ErrorDetails
            }
            # set the return response:
            $FormattedResults = [PSCustomObject]@{
                'Name'   = $foundPolicy.name
                'Result' = $Status
            }
        } else {
            $FormattedResults = [PSCustomObject]@{
                'Name'   = "Not Found"
                'Result' = $null
            }
        }
    }
    end {
        return $FormattedResults
    }
}

