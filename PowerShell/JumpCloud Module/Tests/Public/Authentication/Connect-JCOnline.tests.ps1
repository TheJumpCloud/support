Describe -Tag:('JCOnline') "Connect-JCOnline 1.6" {
    It "Connects to JumpCloud with a single admin API Key using force" {
        $Connect = Connect-JCOnline -JumpCloudAPIKey $TestOrgAPIKey -force
        $Connect | Should -Not -Be $null
        $ConnectedOrgID | Should -Not -be $PesterParams.MultiTenanntOrgID1
    }

    It "Connects to JumpCloud with a MSP API key and OrgID using force" {
        $Connect = Connect-JCOnline -JumpCloudAPIKey $MultiTenantAPIKey -JumpCloudOrgId $PesterParams.MultiTenanntOrgId1 -force
        $Connect | Should -Not -Be $null
        $Connect.JCOrgId | Should -Be $PesterParams.MultiTenanntOrgID1
    }

    It "Connects to JumpCloud with a MSP API key and OrgID using force then connects with a single admin org" {
        $Connect = Connect-JCOnline -JumpCloudAPIKey $MultiTenantAPIKey -JumpCloudOrgId $PesterParams.MultiTenanntOrgId1 -force
        $Connect | Should -Not -Be $null
        $Connect.JCOrgId | Should -Be $PesterParams.MultiTenanntOrgID1

        $Connect = Connect-JCOnline -JumpCloudAPIKey $TestOrgAPIKey -force
        $Connect | Should -Not -Be $null
        $ConnectedOrgID | Should -Not -be $PesterParams.MultiTenanntOrgID1
    }

    It "Connects to JumpCloud with a MSP API key and OrgID using force then connects with a single admin org then back to a MSP org" {
        $Connect = Connect-JCOnline -JumpCloudAPIKey $MultiTenantAPIKey -JumpCloudOrgId $PesterParams.MultiTenanntOrgId1 -force
        $Connect | Should -Not -Be $null
        $Connect.JCOrgId | Should -Be $PesterParams.MultiTenanntOrgID1

        $Connect = Connect-JCOnline -JumpCloudAPIKey $TestOrgAPIKey -force
        $Connect | Should -Not -Be $null
        $Connect.JCOrgId | Should -Not -Be $PesterParams.MultiTenanntOrgID1

        $Connect = Connect-JCOnline -JumpCloudAPIKey $MultiTenantAPIKey -JumpCloudOrgId $PesterParams.MultiTenanntOrgId1 -force
        $Connect | Should -Not -Be $null
        $Connect.JCOrgId | Should -Be $PesterParams.MultiTenanntOrgID1
    }
    It "Connects to JumpCloud with an MSP API key and OrgID then connects to a separate JumpCloud org with MSP API key and OrgID" {
        $Connect = Connect-JCOnline -JumpCloudAPIKey $MultiTenantAPIKey -JumpCloudOrgId $PesterParams.MultiTenanntOrgId1 -force
        $Connect | Should -Not -Be $null
        $Connect.JCOrgId | Should -Be $PesterParams.MultiTenanntOrgID1

        $Connect = Connect-JCOnline  -JumpCloudAPIKey $MultiTenantAPIKey -JumpCloudOrgId $PesterParams.MultiTenanntOrgID2 -force
        $Connect | Should -Not -Be $null
        $Connect.JCOrgId | Should -Be $PesterParams.MultiTenanntOrgID2
    }
}
