Describe -Tag:('JCOnline') 'Connect-JCOnline Single Org Tests' {
    It ('Should connect using the JumpCloudApiKey and JumpCloudOrgId parameters.') {
        $Connect = Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -JumpCloudOrgId:($PesterParams.SingleTernateOrgId) -force
        $TestOrgAPIKey | Should -Be $env:JCApiKey
        $Connect.JCOrgId | Should -Be $env:JCOrgId
        $Connect.JCOrgId | Should -Be $PesterParams.SingleTernateOrgId
    }
    It ('Should connect using the JumpCloudApiKey parameter.') {
        $Connect = Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force
        $TestOrgAPIKey | Should -Be $env:JCApiKey
        $Connect.JCOrgId | Should -Be $env:JCOrgId
        $Connect.JCOrgId | Should -Be $PesterParams.SingleTernateOrgId
    }
    It ('Should connect using the JumpCloudOrgId parameter.') {
        $Connect = Connect-JCOnline -JumpCloudOrgId:($TestOrgAPIKey) -force
        $TestOrgAPIKey | Should -Be $env:JCApiKey
        $Connect.JCOrgId | Should -Be $env:JCOrgId
        $Connect.JCOrgId | Should -Be $PesterParams.SingleTernateOrgId
    }
    It('Should connect without parameters using the previously set env:jc* parameters.') {
        $Connect = Connect-JCOnline -force
        $TestOrgAPIKey | Should -Be $env:JCApiKey
        $Connect.JCOrgId | Should -Be $env:JCOrgId
        $Connect.JCOrgId | Should -Be $PesterParams.SingleTernateOrgId
    }
}
Describe -Tag:('JCOnline') 'Connect-JCOnline MSP OrgId 1 Tests' {

    It ('Should connect using the JumpCloudApiKey and JumpCloudOrgId parameters.') {
        $Connect = Connect-JCOnline -JumpCloudApiKey:($MultiTenantAPIKey) -JumpCloudOrgId:($PesterParams.MultiTernateOrgId1) -force
        $MultiTenantAPIKey | Should -Be $env:JCApiKey
        $Connect.JCOrgId | Should -Be $env:JCOrgId
        $Connect.JCOrgId | Should -Be $PesterParams.MultiTernateOrgId1
    }
    It ('Should connect using the JumpCloudApiKey parameter.') {
        $Connect = Connect-JCOnline -JumpCloudApiKey:($MultiTenantAPIKey) -force
        $MultiTenantAPIKey | Should -Be $env:JCApiKey
        $Connect.JCOrgId | Should -Be $env:JCOrgId
        $Connect.JCOrgId | Should -Be $PesterParams.MultiTernateOrgId1
    }
    It ('Should connect using the JumpCloudOrgId parameter.') {
        $Connect = Connect-JCOnline -JumpCloudOrgId:($PesterParams.MultiTernateOrgId1) -force
        $MultiTenantAPIKey | Should -Be $env:JCApiKey
        $Connect.JCOrgId | Should -Be $env:JCOrgId
        $Connect.JCOrgId | Should -Be $PesterParams.MultiTernateOrgId1
    }
    It('Should connect without parameters using the previously set env:jc* parameters.') {
        $Connect = Connect-JCOnline -force
        $MultiTenantAPIKey | Should -Be $env:JCApiKey
        $Connect.JCOrgId | Should -Be $env:JCOrgId
    }
}
Describe -Tag:('JCOnline') 'Connect-JCOnline MSP OrgId 2 Tests' {

    It ('Should connect using the JumpCloudApiKey and JumpCloudOrgId parameters.') {
        $Connect = Connect-JCOnline -JumpCloudApiKey:($MultiTenantAPIKey) -JumpCloudOrgId:($PesterParams.MultiTernateOrgId2) -force
        $MultiTenantAPIKey | Should -Be $env:JCApiKey
        $Connect.JCOrgId | Should -Be $env:JCOrgId
        $Connect.JCOrgId | Should -Be $PesterParams.MultiTernateOrgId2
    }
    It ('Should connect using the JumpCloudApiKey parameter.') {
        $Connect = Connect-JCOnline -JumpCloudApiKey:($MultiTenantAPIKey) -force
        $MultiTenantAPIKey | Should -Be $env:JCApiKey
        $Connect.JCOrgId | Should -Be $env:JCOrgId
        $Connect.JCOrgId | Should -Be $PesterParams.MultiTernateOrgId2
    }
    It ('Should connect using the JumpCloudOrgId parameter.') {
        $Connect = Connect-JCOnline -JumpCloudOrgId:($PesterParams.MultiTernateOrgId2) -force
        $MultiTenantAPIKey | Should -Be $env:JCApiKey
        $Connect.JCOrgId | Should -Be $env:JCOrgId
        $Connect.JCOrgId | Should -Be $PesterParams.MultiTernateOrgId2
    }
    It('Should connect without parameters using the previously set env:jc* parameters.') {
        $Connect = Connect-JCOnline -force
        $MultiTenantAPIKey | Should -Be $env:JCApiKey
        $Connect.JCOrgId | Should -Be $env:JCOrgId
    }
}