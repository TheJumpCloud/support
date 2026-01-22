function Get-JCConfiguredTemplatePolicy {
    [CmdletBinding(DefaultParameterSetName = 'ReturnAll')]
    param (
        [Parameter(
            ParameterSetName = 'ById',
            Mandatory = $true,
            HelpMessage = "Retrieves a Configured Policy Templates by Id"
        )]
        [Alias('_id', 'id')]
        [System.String]
        $ConfiguredTemplatePolicyID,
        [Parameter(
            ParameterSetName = 'ByName',
            Mandatory = $true,
            HelpMessage = "Retrieves a Configured Policy Templates by Name"
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

        $URL = switch ($PSCmdlet.ParameterSetName) {
            "ReturnAll" {
                "$JCUrlBasePath/api/v2/providers/$ProviderID/configuredpolicytemplates"
                $paginateRequired = $true
            }
            "ByName" {
                # TODO: decide on search vs exact match
                "$JCUrlBasePath/api/v2/providers/$ProviderID/configuredpolicytemplates?sort=name&filter=name%3Aeq%3A$Name"
                $paginateRequired = $true
                # "$JCUrlBasePath/api/v2/policygroups?sort=name&filter=type%3Aeq%3Apolicy_group%2Cname%3Asearch%3A$Name"
            }
            "ById" {
                "$JCUrlBasePath/api/v2/providers/$ProviderID/configuredpolicytemplates/$ConfiguredTemplatePolicyID"
                $paginateRequired = $false
            }
        }
    }
    process {
        $response = Invoke-JCApi -URL:("$URL") -Method:("GET") -Paginate:($paginateRequired)
        if ($response.totalCount -eq 0) {
            $response = $null
        }
    }
    end {
        if ($response.results) {
            return $response.results

        } else {
            return $response
        }
    }
}