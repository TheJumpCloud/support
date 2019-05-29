Describe -Tag:('JCOrganization') "Get-JCOrganization 1.6" {

    It "Returns JumpCloud Organizations " {

        Connect-JCOnlineMultiTenant -JumpCloudOrgID $PesterParams.MultiTenanntOrgID1
        $Connect | Should -be $null
        $Organizations = Get-JCOrganization
        $OrgVerify = $Organizations | Select-Object OrgID -Unique
        $OrgVerify.Count | Should -BeGreaterThan 1

    }

    It "Returns JumpCloud Organizations connected to two different orgs" {

        Connect-JCOnlineMultiTenant -JumpCloudOrgID $PesterParams.MultiTenanntOrgID1
        $Connect | Should -be $null
        $Organizations = Get-JCOrganization
        $OrgVerify = $Organizations | Select-Object OrgID -Unique
        $OrgVerify.Count | Should -BeGreaterThan 1

        Connect-JCOnlineMultiTenant -JumpCloudOrgID $PesterParams.MultiTenanntOrgID2
        $Connect | Should -be $null
        $Organizations = Get-JCOrganization
        $OrgVerify = $Organizations | Select-Object OrgID -Unique
        $OrgVerify.Count | Should -BeGreaterThan 1


    }
}
