Describe -Tag:('JCOrganization') 'Set-JCOrganization Tests' {
    BeforeAll {
        # Prevent the Update-JCModule from running
        $env:JcUpdateModule = $false
        $StartingApiKey = If (-not [System.String]::IsNullOrEmpty($env:JCApiKey)) {
            $env:JCApiKey
        }
        $StartingOrgId = If (-not [System.String]::IsNullOrEmpty($env:JCOrgId)) {
            $env:JCOrgId
        }
    }
    Context 'Single Org Tests' {
        It ('Should connect using the JumpCloudApiKey and JumpCloudOrgId parameters.') {
            $Connect = Set-JCOrganization -JumpCloudApiKey:($PesterParams_ApiKey) -JumpCloudOrgId:($PesterParams_Org.OrgID)
            $PesterParams_ApiKey | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $PesterParams_Org.OrgID
        }
        It ('Should connect using the JumpCloudApiKey parameter.') {
            $Connect = Set-JCOrganization -JumpCloudApiKey:($PesterParams_ApiKey)
            $PesterParams_ApiKey | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $PesterParams_Org.OrgID
        }
        It ('Should connect using the JumpCloudOrgId parameter.') {
            $Connect = Set-JCOrganization -JumpCloudOrgId:($PesterParams_ApiKey)
            $PesterParams_ApiKey | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $PesterParams_Org.OrgID
        }
        It('Should connect without parameters using the previously set env:jc* parameters.') {
            $Connect = Set-JCOrganization
            $PesterParams_ApiKey | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $PesterParams_Org.OrgID
        }
    }
}
