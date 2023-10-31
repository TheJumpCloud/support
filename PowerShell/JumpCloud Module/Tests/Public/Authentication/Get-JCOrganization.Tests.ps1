Describe -Tag:('MSP') 'Get-JCOrganization 1.6' {
    BeforeAll {
        $orgs = Get-JCOrganization
        $RandomOrgs = $orgs | get-Random -count 2
    }
    It 'Returns JumpCloud Organizations ' {
        Connect-JCOnline -JumpCloudApiKey:($env:JCApiKey) -JumpCloudOrgId:($RandomOrgs[0].OrgID) -force
        $Connect | Should -Be $null
        $Organizations = Get-JCOrganization
        $OrgVerify = $Organizations | Select-Object OrgID -Unique
        $OrgVerify.Count | Should -BeGreaterThan 1
    }
    It 'Returns JumpCloud Organizations connected to two different orgs' {
        Connect-JCOnline -JumpCloudApiKey:($env:JCApiKey) -JumpCloudOrgId:($RandomOrgs[0].OrgID) -force
        $Connect | Should -Be $null
        $Organizations = Get-JCOrganization
        $OrgVerify = $Organizations | Select-Object OrgID -Unique
        $OrgVerify.Count | Should -BeGreaterThan 1

        Connect-JCOnline -JumpCloudApiKey:($env:JCApiKey) -JumpCloudOrgId:($RandomOrgs[1].OrgID) -force
        $Connect | Should -Be $null
        $Organizations = Get-JCOrganization
        $OrgVerify = $Organizations | Select-Object OrgID -Unique
        $OrgVerify.Count | Should -BeGreaterThan 1
    }
    # AfterAll {
    #     Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null
    # }
}
