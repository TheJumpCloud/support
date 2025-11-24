function Get-JCPolicyGroupTemplateMember {
    [CmdletBinding()]
    param (
        [Parameter(
            ParameterSetName = 'ById',
            Mandatory = $true,
            HelpMessage = "The ID of the JumpCloud policy group template to query and return members of"
        )]
        [Alias('_id', 'id')]
        [System.String]
        $GroupTemplateID,
        [Parameter(
            ParameterSetName = 'ByName',
            Mandatory = $true,
            HelpMessage = "The name of the JumpCloud policy group template to query and return members of"
        )]
        [System.String]
        $Name
    )
    begin {
        Write-Debug 'Verifying JCAPI Key'
        if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
            Connect-JCOnline
        }
        Write-Debug 'Verifying JCProviderID Key'
        # validate MTP Org/ ProviderID. Will throw if $env:JCProviderId is missing:
        $ProviderID = Test-JCProviderID -providerID $env:JCProviderId -FunctionName $($MyInvocation.MyCommand)

    }
    process {
        $URL = switch ($PSCmdlet.ParameterSetName) {
            "ByName" {
                try {
                    $policyGroupTemplate = Get-JCPolicyGroupTemplate -Name $Name
                    if ($policyGroupTemplate) {
                        $GroupTemplateID = $policyGroupTemplate.Id
                    } else {
                        throw
                    }
                } catch {
                    throw "Could not find policy group template with name: $name"
                }
                "$global:JCUrlBasePath/api/v2/providers/$ProviderID/policygrouptemplates/$GroupTemplateID/members"
            }
            "ById" {
                "$global:JCUrlBasePath/api/v2/providers/$ProviderID/policygrouptemplates/$GroupTemplateID/members"
            }
        }
        $response = Invoke-JCApi -Method:('Get') -Paginate:($true) -Url:($URL)
    }
    end {
        if ($response.records) {
            return $response.records

        } else {
            return $response
        }

    }
}