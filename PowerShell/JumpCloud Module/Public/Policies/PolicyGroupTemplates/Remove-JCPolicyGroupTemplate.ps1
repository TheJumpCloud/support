Function Remove-JCPolicyGroupTemplate {
    [CmdletBinding()]
    param (
        [Parameter(
            ParameterSetName = 'ByName',
            Mandatory = $true,
            HelpMessage = 'The Name of the JumpCloud policy group template you wish to remove.')]
        [System.String]
        $Name,
        [Parameter(
            ParameterSetName = 'ByID',
            ValueFromPipelineByPropertyName,
            Mandatory = $true,
            HelpMessage = 'The ID of the JumpCloud policy group template you wish to remove.')]
        [Alias('_id', 'id')]
        [System.String]
        $GroupTemplateID,
        [Parameter(HelpMessage = 'A SwitchParameter which suppresses the warning message when removing a JumpCloud policy group template.')]
        [Switch]
        $Force
    )
    begin {
        Write-Debug 'Verifying JCAPI Key'
        if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
            Connect-JCOnline
        }
        Write-Debug 'Verifying JCProviderID Key'
        # validate MTP Org/ ProviderID. Will throw if $env:JCProviderId is missing:
        $ProviderID = Test-JCProviderID -providerID $env:JCProviderId -FunctionName $($MyInvocation.MyCommand)

        switch ($PSCmdlet.ParameterSetName) {
            'ByName' {
                try {
                    $foundPolicy = Get-JCPolicyGroupTemplate -Name $Name
                    $GroupTemplateID = $foundPolicy.ID

                } catch {
                    $GroupTemplateID = $null
                }
                if ($foundPolicy) {
                }
            }
            'ByID' {
                try {
                    $foundPolicy = Get-JCPolicyGroupTemplate -GroupTemplateID $GroupTemplateID
                    $GroupTemplateID = $foundPolicy.ID

                } catch {
                    $GroupTemplateID = $null
                }
            }
        }

    }
    process {
        if (-NOT [System.String]::IsNullOrEmpty($GroupTemplateID)) {
            $URL = "https://console.jumpcloud.com/api/v2/providers/$ProviderID/policygrouptemplates/$GroupTemplateID"
            if (!$Force) {
                Write-Warning "Are you sure you wish to delete policy group template: `'$($foundPolicyGroupTemplate.Name)`'?" -WarningAction Inquire
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
            # set the return response:
            # throw "Not Found"
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

