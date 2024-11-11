Function Get-JCPolicyGroupTemplate {
    [CmdletBinding(DefaultParameterSetName = 'ReturnAll')]
    param (
        [Parameter(
            ParameterSetName = 'ByID',
            HelpMessage = 'Use the -GroupTemplateID parameter when you want to query a specific group template.'
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
        $URL = switch ($PSCmdlet.ParameterSetName) {
            "ReturnAll" {
                "$JCUrlBasePath/api/v2/providers/$ProviderID/policygrouptemplates/"
                $paginateRequired = $true
            }
            "ByID" {
                "$JCUrlBasePath/api/v2/providers/$ProviderID/policygrouptemplates/$GroupTemplateID"
                $paginateRequired = $false

            }
        }
        $response = Invoke-JCApi -Method:('Get') -Paginate:($paginateRequired) -Url:($URL)

    }
    end {
        if ($response.records) {
            return $response.records

        } else {
            return $response
        }
    }
}