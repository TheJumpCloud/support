Describe -Tag:('JCOnline') 'Connect-JCOnline Tests' {
    BeforeAll {
        $StartingApiKey = if (-not [System.String]::IsNullOrEmpty($env:JCApiKey)) {
            $env:JCApiKey
        }
        $StartingOrgId = if (-not [System.String]::IsNullOrEmpty($env:JCOrgId)) {
            $env:JCOrgId
        }
    }
    Context 'EU Org Tests' {
        It ('Should connect using the EU JumpCloudApiKey and JumpCloudOrgId parameters.') {
            $Connect = Connect-JCOnline -JumpCloudApiKey:($PesterParams_EU_ApiKey) -JumpCloudOrgId:($PesterParams_EU_OrgID) -force
            $PesterParams_EU_ApiKey | Should -Be $env:JCApiKey
            $PesterParams_EU_OrgID | Should -Be $env:JCOrgId

            $env:JCEnvironment | Should -Be 'EU'

            $global:PSDefaultParameterValues['*-JcSdk*:ApiHost'] | Should -Be "api.eu"
            $global:PSDefaultParameterValues['*-JcSdk*:ConsoleHost'] | Should -Be "console.eu"
            # $Connect.JCOrgId | Should -Be $env:JCOrgId
            # $Connect.JCOrgId | Should -Be $PesterParams_EU_Org.OrgID
        }
    }
    Context 'Single Org Tests' {
        It ('Should connect using the JumpCloudApiKey and JumpCloudOrgId parameters.') {
            $Connect = Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -JumpCloudOrgId:($PesterParams_Org.OrgID) -force
            $PesterParams_ApiKey | Should -Be $env:JCApiKey
            $PesterParams_Org.OrgID | Should -Be $env:JCOrgId
            # $Connect.JCOrgId | Should -Be $env:JCOrgId
            # $Connect.JCOrgId | Should -Be $PesterParams_Org.OrgID
        }
        It ('Should connect using the JumpCloudApiKey parameter.') {
            $Connect = Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force
            $PesterParams_ApiKey | Should -Be $env:JCApiKey
            $PesterParams_Org.OrgID | Should -Be $env:JCOrgId
            # $Connect.JCOrgId | Should -Be $env:JCOrgId
            # $Connect.JCOrgId | Should -Be $PesterParams_Org.OrgID
        }
        It ('Should connect using the JumpCloudOrgId parameter.') {
            $Connect = Connect-JCOnline -JumpCloudOrgId:($PesterParams_ApiKey) -force
            $PesterParams_ApiKey | Should -Be $env:JCApiKey
            $PesterParams_Org.OrgID | Should -Be $env:JCOrgId
            # $Connect.JCOrgId | Should -Be $env:JCOrgId
            # $Connect.JCOrgId | Should -Be $PesterParams_Org.OrgID
        }
        It('Should connect without parameters using the previously set env:jc* parameters.') {
            $Connect = Connect-JCOnline -force
            $PesterParams_ApiKey | Should -Be $env:JCApiKey
            $PesterParams_Org.OrgID | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $PesterParams_Org.OrgID
        }
    }
    Context 'ProviderID Tests for non-MTP Orgs' {
        It ('Should not have a ProviderID set') {
            $Connect = Connect-JCOnline -JumpCloudOrgId:($PesterParams_ApiKey) -force
            $env:JCProviderId | Should -BeNullOrEmpty
        }
    }
    AfterAll {
        if (-not [System.String]::IsNullOrEmpty($StartingApiKey) -and -not [System.String]::IsNullOrEmpty($StartingOrgId)) {
            Connect-JCOnline -JumpCloudApiKey:($StartingApiKey) -JumpCloudOrgId:($StartingOrgId) -force | Out-Null
        } elseif (-not [System.String]::IsNullOrEmpty($StartingApiKey) -and [System.String]::IsNullOrEmpty($StartingOrgId)) {
            Connect-JCOnline -JumpCloudApiKey:($StartingApiKey) -force | Out-Null
        } elseif ([System.String]::IsNullOrEmpty($StartingApiKey) -and -not [System.String]::IsNullOrEmpty($StartingOrgId)) {
            Connect-JCOnline -JumpCloudOrgId:($StartingOrgId) -force | Out-Null
        } else {
            Write-Error ('Unknown scenario encountered')
        }
    }
}
