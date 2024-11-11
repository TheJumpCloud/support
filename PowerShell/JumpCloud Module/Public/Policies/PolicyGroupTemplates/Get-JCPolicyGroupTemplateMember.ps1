Function Get-JCPolicyGroupTemplateMember {
    [CmdletBinding()]
    param (
        [Parameter(
            HelpMessage = 'Use the -GroupTemplateID parameter when you want to query a specific group template members.'
        )]
        [System.String]
        $GroupTemplateID
    )
    begin {
        Write-Debug 'Verifying JCAPI Key'
        if (($JCAPIKEY)::isNullorEmpty) {
            Connect-JCOnline
        }
        Write-Debug 'Verifying JCProviderID Key'
        # validate MTP Org/ ProviderID. Will throw if $env:JCProviderId is missing:
        $ProviderID = Test-JCProviderID -providerID $env:JCProviderId -FunctionName $($MyInvocation.MyCommand)
    }
    process {
        # TODO: CUT-4439 set to Invoke-JCApi when that supports dynamic support for endpoints that do not require
        $URL = "https://console.jumpcloud.com/api/v2/providers/$ProviderID/policygrouptemplates/$GroupTemplateID/members"
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