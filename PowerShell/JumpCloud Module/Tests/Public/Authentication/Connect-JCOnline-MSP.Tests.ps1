Describe -Tag:('MSP') 'Connect-JCOnline Tests' {
    BeforeAll {
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
            $Connect = Connect-JCOnline -JumpCloudApiKey:($env:JCApiKey) -JumpCloudOrgId:($RandomOrgs[0].OrgID) -force
            $env:JCApiKey | Should -Be $env:JCApiKey
            $RandomOrgs[0].OrgID | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $RandomOrgs[0].OrgID
        }
        It ('Should connect using the JumpCloudApiKey parameter.') {
            $Connect = Connect-JCOnline -JumpCloudApiKey:($env:JCApiKey) -force
            $env:JCApiKey | Should -Be $env:JCApiKey
            $RandomOrgs[0].OrgID | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $RandomOrgs[0].OrgID
        }
        It ('Should connect using the JumpCloudOrgId parameter.') {
            $Connect = Connect-JCOnline -JumpCloudOrgId:($RandomOrgs[0].OrgID) -force
            $env:JCApiKey | Should -Be $env:JCApiKey
            $RandomOrgs[0].OrgID | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $RandomOrgs[0].OrgID
        }
        It('Should connect without parameters using the previously set env:jc* parameters.') {
            $Connect = Connect-JCOnline -force
            $env:JCApiKey | Should -Be $env:JCApiKey
            $RandomOrgs[0].OrgID | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $env:JCOrgId
        }
    }
    Context 'MSP OrgId 2 Tests' {
        It ('Should connect using the JumpCloudApiKey and JumpCloudOrgId parameters.') {
            $Connect = Connect-JCOnline -JumpCloudApiKey:($env:JCApiKey) -JumpCloudOrgId:($RandomOrgs[1].OrgID) -force
            $env:JCApiKey | Should -Be $env:JCApiKey
            $RandomOrgs[1].OrgID | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $RandomOrgs[1].OrgID
        }
        It ('Should connect using the JumpCloudApiKey parameter.') {
            $Connect = Connect-JCOnline -JumpCloudApiKey:($env:JCApiKey) -force
            $env:JCApiKey | Should -Be $env:JCApiKey
            $RandomOrgs[1].OrgID | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $RandomOrgs[1].OrgID
        }
        It ('Should connect using the JumpCloudOrgId parameter.') {
            $Connect = Connect-JCOnline -JumpCloudOrgId:($RandomOrgs[1].OrgID) -force
            $env:JCApiKey | Should -Be $env:JCApiKey
            $RandomOrgs[1].OrgID | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $RandomOrgs[1].OrgID
        }
        It('Should connect without parameters using the previously set env:jc* parameters.') {
            $Connect = Connect-JCOnline -force
            $env:JCApiKey | Should -Be $env:JCApiKey
            $RandomOrgs[1].OrgID | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $env:JCOrgId
        }
    }
    # AfterAll {
    #     Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null
    # }
}
