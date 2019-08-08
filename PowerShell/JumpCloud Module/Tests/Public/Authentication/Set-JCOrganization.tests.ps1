Describe -Tag:('JCOrganization') 'Set-JCOrganization Single Org Tests' {
    It ('Should connect using the JumpCloudApiKey and JumpCloudOrgId parameters.') {
        $Connect = Set-JCOrganization -JumpCloudApiKey:($TestOrgAPIKey) -JumpCloudOrgId:($PesterParams.SingleTernateOrgId)
        $TestOrgAPIKey | Should -Be $env:JCApiKey
        $Connect.JCOrgId | Should -Be $env:JCOrgId
        $Connect.JCOrgId | Should -Be $PesterParams.SingleTernateOrgId
    }
    It ('Should connect using the JumpCloudApiKey parameter.') {
        $Connect = Set-JCOrganization -JumpCloudApiKey:($TestOrgAPIKey)
        $TestOrgAPIKey | Should -Be $env:JCApiKey
        $Connect.JCOrgId | Should -Be $env:JCOrgId
        $Connect.JCOrgId | Should -Be $PesterParams.SingleTernateOrgId
    }
    It ('Should connect using the JumpCloudOrgId parameter.') {
        $Connect = Set-JCOrganization -JumpCloudOrgId:($TestOrgAPIKey)
        $TestOrgAPIKey | Should -Be $env:JCApiKey
        $Connect.JCOrgId | Should -Be $env:JCOrgId
        $Connect.JCOrgId | Should -Be $PesterParams.SingleTernateOrgId
    }
    It('Should connect without parameters using the previously set env:jc* parameters.') {
        $Connect = Set-JCOrganization
        $TestOrgAPIKey | Should -Be $env:JCApiKey
        $Connect.JCOrgId | Should -Be $env:JCOrgId
        $Connect.JCOrgId | Should -Be $PesterParams.SingleTernateOrgId
    }
}
Describe -Tag:('JCOrganization') 'Set-JCOrganization MSP OrgId 1 Tests' {
    It ('Should connect using the JumpCloudApiKey and JumpCloudOrgId parameters.') {
        $Connect = Set-JCOrganization -JumpCloudApiKey:($MultiTenantAPIKey) -JumpCloudOrgId:($PesterParams.MultiTernateOrgId1)
        $MultiTenantAPIKey | Should -Be $env:JCApiKey
        $Connect.JCOrgId | Should -Be $env:JCOrgId
        $Connect.JCOrgId | Should -Be $PesterParams.MultiTernateOrgId1
    }
    It ('Should connect using the JumpCloudOrgId parameter.') {
        $Connect = Set-JCOrganization -JumpCloudOrgId:($PesterParams.MultiTernateOrgId1)
        $MultiTenantAPIKey | Should -Be $env:JCApiKey
        $Connect.JCOrgId | Should -Be $env:JCOrgId
        $Connect.JCOrgId | Should -Be $PesterParams.MultiTernateOrgId1
    }
}
Describe -Tag:('JCOrganization') 'Set-JCOrganization MSP OrgId 2 Tests' {
    It ('Should connect using the JumpCloudApiKey and JumpCloudOrgId parameters.') {
        $Connect = Set-JCOrganization -JumpCloudApiKey:($MultiTenantAPIKey) -JumpCloudOrgId:($PesterParams.MultiTernateOrgId2)
        $MultiTenantAPIKey | Should -Be $env:JCApiKey
        $Connect.JCOrgId | Should -Be $env:JCOrgId
        $Connect.JCOrgId | Should -Be $PesterParams.MultiTernateOrgId2
    }
    It ('Should connect using the JumpCloudOrgId parameter.') {
        $Connect = Set-JCOrganization -JumpCloudOrgId:($PesterParams.MultiTernateOrgId2)
        $MultiTenantAPIKey | Should -Be $env:JCApiKey
        $Connect.JCOrgId | Should -Be $env:JCOrgId
        $Connect.JCOrgId | Should -Be $PesterParams.MultiTernateOrgId2
    }
}