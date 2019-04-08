Describe "Connect-JCOnline 1.6" {

    It "Connects to JumpCloud with a single admin API Key using force" {
        
        $Connect = Connect-JCOnline -JumpCloudAPIKey $TestOrgAPIKey -force
        $Connect | Should -be $null

    }

    It "Connects to JumpCloud with a MSP API key and OrgID using force" {
        
        $Connect = Connect-JCOnline -JumpCloudAPIKey $MultiTenanntAPIKey -force -JumpCloudOrgID $PesterParams.MultiTenanntOrgID1
        $Connect | Should -be $null
        $ConnectedOrgID = Get-JCCommand | Select-Object -Last 1 | Select-Object -ExpandProperty organization
        $ConnectedOrgID | Should -Be $PesterParams.MultiTenanntOrgID1
    }

    It "Connects to JumpCloud with a MSP API key and OrgID using force then connects with a single admin org" {
        
        $Connect = Connect-JCOnline -JumpCloudAPIKey $MultiTenanntAPIKey -force -JumpCloudOrgID $PesterParams.MultiTenanntOrgID1
        $Connect | Should -be $null
        $ConnectedOrgID = Get-JCCommand | Select-Object -Last 1 | Select-Object -ExpandProperty organization
        $ConnectedOrgID | Should -Be $PesterParams.MultiTenanntOrgID1
        $Connect = Connect-JCOnline -JumpCloudAPIKey $TestOrgAPIKey -force
        $Connect | Should -be $null
        $ConnectedOrgID = Get-JCCommand | Select-Object -Last 1 | Select-Object -ExpandProperty organization
        $ConnectedOrgID | Should -Not -be $PesterParams.MultiTenanntOrgID1

    }

    It "Connects to JumpCloud with a MSP API key and OrgID using force then connects with a single admin org then back to a MSP org" {
        
        $Connect = Connect-JCOnline -JumpCloudAPIKey $MultiTenanntAPIKey -force -JumpCloudOrgID $PesterParams.MultiTenanntOrgID1
        $Connect | Should -be $null
        $ConnectedOrgID = Get-JCCommand | Select-Object -Last 1 | Select-Object -ExpandProperty organization
        $ConnectedOrgID | Should -Be $PesterParams.MultiTenanntOrgID1
        $Connect = Connect-JCOnline -JumpCloudAPIKey $TestOrgAPIKey -force
        $Connect | Should -be $null
        $ConnectedOrgID = Get-JCCommand | Select-Object -Last 1 | Select-Object -ExpandProperty organization
        $ConnectedOrgID | Should -Not -be $PesterParams.MultiTenanntOrgID1
        $Connect = Connect-JCOnline -JumpCloudAPIKey $MultiTenanntAPIKey -force -JumpCloudOrgID $PesterParams.MultiTenanntOrgID1
        $Connect | Should -be $null
        $ConnectedOrgID = Get-JCCommand | Select-Object -Last 1 | Select-Object -ExpandProperty organization
        $ConnectedOrgID | Should -Be $PesterParams.MultiTenanntOrgID1

    }

    It "Connects to JumpCloud with an MSP API key and OrgID then connects to a seperate JumpCloud org with MSP API key and OrgID" {

        $Connect = Connect-JCOnline -JumpCloudAPIKey $MultiTenanntAPIKey -force -JumpCloudOrgID $PesterParams.MultiTenanntOrgID1
        $Connect | Should -be $null
        $ConnectedOrgID = Get-JCCommand | Select-Object -Last 1 | Select-Object -ExpandProperty organization
        $ConnectedOrgID | Should -Be $PesterParams.MultiTenanntOrgID1

        $Connect = Connect-JCOnline -JumpCloudAPIKey $MultiTenanntAPIKey -force -JumpCloudOrgID $PesterParams.MultiTenanntOrgID2
        $Connect | Should -be $null
        $ConnectedOrgID = Get-JCCommand | Select-Object -Last 1 | Select-Object -ExpandProperty organization
        $ConnectedOrgID | Should -Be $PesterParams.MultiTenanntOrgID2
    }
}
