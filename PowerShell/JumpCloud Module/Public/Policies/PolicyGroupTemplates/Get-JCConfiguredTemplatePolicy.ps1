Function Get-JCConfiguredTemplatePolicy {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.String]
        $ConfiguredTemplatePolicyID
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
        # set headers
        $headers = @{
            "x-api-key" = $JCAPIKEY
        }
        $response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/v2/providers/$ProviderID/configuredpolicytemplates/$ConfiguredTemplatePolicyID" -Method GET -Headers $headers
    }
    end {
        return $response
    }
}