Describe "Get-JCOrganization 1.6" {

    It "Returns JumpCloud Organizations " {

        $Connect = Connect-JCOnline -JumpCloudAPIKey $MultiTenanntAPIKey -force -JumpCloudOrgID $PesterParams.MultiTenanntOrgID1
        $Connect | Should -be $null
        $Organizations = Get-JCOrganization 
        $OrgVerify = $Organizations | Select-Object OrgID -Unique
        $OrgVerify.Count | Should -BeGreaterThan 1 
       
    }

    It "Returns JumpCloud Organizations connected to two different orgs" {
        
        $Connect = Connect-JCOnline -JumpCloudAPIKey $MultiTenanntAPIKey -force -JumpCloudOrgID $PesterParams.MultiTenanntOrgID1
        $Connect | Should -be $null
        $Organizations = Get-JCOrganization 
        $OrgVerify = $Organizations | Select-Object OrgID -Unique
        $OrgVerify.Count | Should -BeGreaterThan 1 

        $Connect = Connect-JCOnline -JumpCloudAPIKey $MultiTenanntAPIKey -force -JumpCloudOrgID $PesterParams.MultiTenanntOrgID2
        $Connect | Should -be $null
        $Organizations = Get-JCOrganization 
        $OrgVerify = $Organizations | Select-Object OrgID -Unique
        $OrgVerify.Count | Should -BeGreaterThan 1 
        
 
    }
}