Describe -Tag:('MSP') 'Set-JCOrganization Tests' {
    BeforeAll {
        # Prevent the Update-JCModule from running
        $env:JcUpdateModule = $false
        $StartingApiKey = If (-not [System.String]::IsNullOrEmpty($env:JCApiKey)) {
            $env:JCApiKey
        }
        $StartingOrgId = If (-not [System.String]::IsNullOrEmpty($env:JCOrgId)) {
            $env:JCOrgId
        }
        $orgs = Get-JCOrganization
        $RandomOrgs = $orgs | get-Random -count 2
    }
    Context 'MSP OrgId 1 Tests' {
        It ('Should connect using the JumpCloudApiKey and JumpCloudOrgId parameters.') {
            $Connect = Set-JCOrganization -JumpCloudApiKey:($env:JCApiKey) -JumpCloudOrgId:($RandomOrgs[0].OrgID)
            $env:JCApiKey | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $RandomOrgs[0].OrgID
        }
        It ('Should connect using the JumpCloudOrgId parameter.') {
            $Connect = Set-JCOrganization -JumpCloudOrgId:($RandomOrgs[0].OrgID)
            $env:JCApiKey | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $RandomOrgs[0].OrgID
        }
    }
    Context 'MSP OrgId 2 Tests' {
        It ('Should connect using the JumpCloudApiKey and JumpCloudOrgId parameters.') {
            $Connect = Set-JCOrganization -JumpCloudApiKey:($env:JCApiKey) -JumpCloudOrgId:($RandomOrgs[1].OrgID)
            $env:JCApiKey | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $RandomOrgs[1].OrgID
        }
        It ('Should connect using the JumpCloudOrgId parameter.') {
            $Connect = Set-JCOrganization -JumpCloudOrgId:($RandomOrgs[1].OrgID)
            $env:JCApiKey | Should -Be $env:JCApiKey
            $Connect.JCOrgId | Should -Be $env:JCOrgId
            $Connect.JCOrgId | Should -Be $RandomOrgs[1].OrgID
        }
    }
    # AfterAll {
    #     Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null
    # }
}
