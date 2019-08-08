Describe -Tag:('JCOrganization') "Set-JCOrganization" {

    It "Switches connection between two JumpCloud orgs for an admin with a multi tenant API connection" {

        Connect-JCOnlineMultiTenant -JumpCloudOrgID $PesterParams.MultiTernateOrgId1
        $ConnectedOrgID = Get-JCCommand | Select-Object -Last 1 | Select-Object -ExpandProperty organization
        $ConnectedOrgID | Should -Be $PesterParams.MultiTernateOrgId1

        Connect-JCOnlineMultiTenant -JumpCloudOrgID $PesterParams.MultiTernateOrgId2
        $ConnectedOrgID = Get-JCCommand | Select-Object -Last 1 | Select-Object -ExpandProperty organization
        $ConnectedOrgID | Should -Be $PesterParams.MultiTernateOrgId2



    }

    It "Switches connection back and forth between two JumpCloud orgs for an admin with a multi tenant API connection" {

        Connect-JCOnlineMultiTenant -JumpCloudOrgID $PesterParams.MultiTernateOrgId1
        $ConnectedOrgID = Get-JCCommand | Select-Object -Last 1 | Select-Object -ExpandProperty organization
        $ConnectedOrgID | Should -Be $PesterParams.MultiTernateOrgId1

        Connect-JCOnlineMultiTenant -JumpCloudOrgID $PesterParams.MultiTernateOrgId2
        $ConnectedOrgID = Get-JCCommand | Select-Object -Last 1 | Select-Object -ExpandProperty organization
        $ConnectedOrgID | Should -Be $PesterParams.MultiTernateOrgId2

        Connect-JCOnlineMultiTenant -JumpCloudOrgID $PesterParams.MultiTernateOrgId1
        $ConnectedOrgID = Get-JCCommand | Select-Object -Last 1 | Select-Object -ExpandProperty organization
        $ConnectedOrgID | Should -Be $PesterParams.MultiTernateOrgId1

    }
}
