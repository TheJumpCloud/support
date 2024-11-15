Function Get-JCPolicyGroupTemplate {
    [CmdletBinding(DefaultParameterSetName = 'ReturnAll')]
    param (
        [Parameter(
            ParameterSetName = 'ByName',
            Mandatory = $true,
            HelpMessage = 'The Name of the JumpCloud policy group you wish to query. This value is case sensitive')]
        [System.String]
        $Name,
        [Parameter(
            ParameterSetName = 'ByID',
            Mandatory = $true,
            HelpMessage = 'Use the -GroupTemplateID parameter when you want to query a specific group template.'
        )]
        [Alias('_id', 'id')]
        [System.String]
        $GroupTemplateID
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
            "ReturnAll" {
                "$JCUrlBasePath/api/v2/providers/$ProviderID/policygrouptemplates/"
                $paginateRequired = $true
            }
            "ByName" {
                "$JCUrlBasePath/api/v2/providers/$ProviderID/policygrouptemplates/?sort=name&filter=name%3Aeq%3A$Name"
                $paginateRequired = $true
            }
            "ByID" {
                "$JCUrlBasePath/api/v2/providers/$ProviderID/policygrouptemplates/$GroupTemplateID"
                $paginateRequired = $false

            }
        }
        $response = Invoke-JCApi -Method:('Get') -Paginate:($paginateRequired) -Url:($URL)
        if ($response.totalCount -eq 0) {
            $response = $null
        }

    }
    end {
        if ($response.records) {
            return $response.records

        } else {
            return $response
        }
    }
}