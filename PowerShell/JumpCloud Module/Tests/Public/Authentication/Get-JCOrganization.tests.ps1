Describe -Tag:('JCOrganization') 'Get-JCOrganization 1.6' {
    It 'Returns JumpCloud Organizations ' {
        Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKeyMsp) -JumpCloudOrgId:($PesterParams_Org.OrgIDMsp1) -force
        $Connect | Should -Be $null
        $Organizations = Get-JCOrganization
        $OrgVerify = $Organizations | Select-Object OrgID -Unique
        $OrgVerify.Count | Should -BeGreaterThan 1
    }
    It 'Returns JumpCloud Organizations connected to two different orgs' {
        Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKeyMsp) -JumpCloudOrgId:($PesterParams_Org.OrgIDMsp1) -force
        $Connect | Should -Be $null
        $Organizations = Get-JCOrganization
        $OrgVerify = $Organizations | Select-Object OrgID -Unique
        $OrgVerify.Count | Should -BeGreaterThan 1

        Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKeyMsp) -JumpCloudOrgId:($PesterParams_Org.OrgIDMsp2) -force
        $Connect | Should -Be $null
        $Organizations = Get-JCOrganization
        $OrgVerify = $Organizations | Select-Object OrgID -Unique
        $OrgVerify.Count | Should -BeGreaterThan 1
    }
}
