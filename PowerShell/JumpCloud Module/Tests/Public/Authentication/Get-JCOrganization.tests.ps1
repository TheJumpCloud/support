Describe -Tag:('JCOrganization') 'Get-JCOrganization 1.6' {
    It 'Returns JumpCloud Organizations ' {
        Connect-JCOnline -JumpCloudApiKey:($MultiTenantAPIKey) -JumpCloudOrgId:($PesterParams.MultiTernateOrgId1) -force
        $Connect | Should -Be $null
        $Organizations = Get-JCOrganization
        $OrgVerify = $Organizations | Select-Object OrgID -Unique
        $OrgVerify.Count | Should -BeGreaterThan 1
    }
    It 'Returns JumpCloud Organizations connected to two different orgs' {
        Connect-JCOnline -JumpCloudApiKey:($MultiTenantAPIKey) -JumpCloudOrgId:($PesterParams.MultiTernateOrgId1) -force
        $Connect | Should -Be $null
        $Organizations = Get-JCOrganization
        $OrgVerify = $Organizations | Select-Object OrgID -Unique
        $OrgVerify.Count | Should -BeGreaterThan 1

        Connect-JCOnline -JumpCloudApiKey:($MultiTenantAPIKey) -JumpCloudOrgId:($PesterParams.MultiTernateOrgId2) -force
        $Connect | Should -Be $null
        $Organizations = Get-JCOrganization
        $OrgVerify = $Organizations | Select-Object OrgID -Unique
        $OrgVerify.Count | Should -BeGreaterThan 1
    }
}
