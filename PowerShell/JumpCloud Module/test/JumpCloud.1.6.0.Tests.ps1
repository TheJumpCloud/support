$Username = "pester.emailone"
$UserID = ""
$EmailGroupName = "PesterEmail"

$MultiTenanntAPIKey = ""
$MultiTenanntOrgID1 = ""
$MultiTenanntOrgID2 = ""
$SingleAdminAPIKey = ""

## You must have at least one command for the connect tests to work. JumpCloud command objects contain the organization ID on them. This is used to verify connection to the correct orgID.

Describe "Sent-JCPasswordReset" {

    It "Sends a single password reset email by username" {

        $SingleResetEmail = Send-JCPasswordReset -username $Username
        $SingleResetEmail.ResetEmail | Should -be "Sent"
       

    }

    It "Sends a single password reset email by UserID" {
        
        $SingleResetEmail = Send-JCPasswordReset -UserID $UserID
        $SingleResetEmail.ResetEmail | Should -be "Sent"

    }

    It "Sends password resets to all members of a group" {
        
        $MultiResetEmail = Get-JCUserGroupMember -GroupName $EmailGroupName | Send-JCPasswordReset
        $ResetEmails = $MultiResetEmail | Select-Object ResetEmail -Unique 
        $ResetEmails.ResetEmail | Should -Be "Sent"
 
    }
}

Describe "Connect-JCOnline" {

    It "Connects to JumpCloud with a single admin API Key using force" {
        
        $Connect = Connect-JCOnline -JumpCloudAPIKey $SingleAdminAPIKey -force
        $Connect | Should -be $null

    }

    It "Connects to JumpCloud with a MSP API key and OrgID using force" {
        
        $Connect = Connect-JCOnline -JumpCloudAPIKey $MultiTenanntAPIKey -force -JumpCloudOrgID $MultiTenanntOrgID1
        $Connect | Should -be $null
        $ConnectedOrgID = Get-JCCommand | Select-Object -Last 1 |  Select-Object -ExpandProperty organization
        $ConnectedOrgID | Should -Be $MultiTenanntOrgID1
    }

    It "Connects to JumpCloud with a MSP API key and OrgID using force then connects with a single admin org" {
        
        $Connect = Connect-JCOnline -JumpCloudAPIKey $MultiTenanntAPIKey -force -JumpCloudOrgID $MultiTenanntOrgID1
        $Connect | Should -be $null
        $ConnectedOrgID = Get-JCCommand | Select-Object -Last 1 |  Select-Object -ExpandProperty organization
        $ConnectedOrgID | Should -Be $MultiTenanntOrgID1
        $Connect = Connect-JCOnline -JumpCloudAPIKey $SingleAdminAPIKey -force
        $Connect | Should -be $null
        $ConnectedOrgID = Get-JCCommand | Select-Object -Last 1 |  Select-Object -ExpandProperty organization
        $ConnectedOrgID | Should -Not -be $MultiTenanntOrgID1

    }

    It "Connects to JumpCloud with a MSP API key and OrgID using force then connects with a single admin org then back to a MSP org" {
        
        $Connect = Connect-JCOnline -JumpCloudAPIKey $MultiTenanntAPIKey -force -JumpCloudOrgID $MultiTenanntOrgID1
        $Connect | Should -be $null
        $ConnectedOrgID = Get-JCCommand | Select-Object -Last 1 |  Select-Object -ExpandProperty organization
        $ConnectedOrgID | Should -Be $MultiTenanntOrgID1
        $Connect = Connect-JCOnline -JumpCloudAPIKey $SingleAdminAPIKey -force
        $Connect | Should -be $null
        $ConnectedOrgID = Get-JCCommand | Select-Object -Last 1 |  Select-Object -ExpandProperty organization
        $ConnectedOrgID | Should -Not -be $MultiTenanntOrgID1
        $Connect = Connect-JCOnline -JumpCloudAPIKey $MultiTenanntAPIKey -force -JumpCloudOrgID $MultiTenanntOrgID1
        $Connect | Should -be $null
        $ConnectedOrgID = Get-JCCommand | Select-Object -Last 1 |  Select-Object -ExpandProperty organization
        $ConnectedOrgID | Should -Be $MultiTenanntOrgID1

    }

    It "Connects to JumpCloud with an MSP API key and OrgID then connects to a seperate JumpCloud org with MSP API key and OrgID" {

        $Connect = Connect-JCOnline -JumpCloudAPIKey $MultiTenanntAPIKey -force -JumpCloudOrgID $MultiTenanntOrgID1
        $Connect | Should -be $null
        $ConnectedOrgID = Get-JCCommand | Select-Object -Last 1 |  Select-Object -ExpandProperty organization
        $ConnectedOrgID | Should -Be $MultiTenanntOrgID1

        $Connect = Connect-JCOnline -JumpCloudAPIKey $MultiTenanntAPIKey -force -JumpCloudOrgID $MultiTenanntOrgID2
        $Connect | Should -be $null
        $ConnectedOrgID = Get-JCCommand | Select-Object -Last 1 |  Select-Object -ExpandProperty organization
        $ConnectedOrgID | Should -Be $MultiTenanntOrgID2
    }
}

Describe "Get-JCOrganization" {

    It "Returns JumpCloud Organizations " {

        $Connect = Connect-JCOnline -JumpCloudAPIKey $MultiTenanntAPIKey -force -JumpCloudOrgID $MultiTenanntOrgID1
        $Connect | Should -be $null
        $Organizations = Get-JCOrganization 
        $OrgVerify = $Organizations | Select-Object OrgID -Unique
        $OrgVerify.Count | Should -BeGreaterThan 1 
       
    }

    It "Returns JumpCloud Organizations connected to two different orgs" {
        
        $Connect = Connect-JCOnline -JumpCloudAPIKey $MultiTenanntAPIKey -force -JumpCloudOrgID $MultiTenanntOrgID1
        $Connect | Should -be $null
        $Organizations = Get-JCOrganization 
        $OrgVerify = $Organizations | Select-Object OrgID -Unique
        $OrgVerify.Count | Should -BeGreaterThan 1 

        $Connect = Connect-JCOnline -JumpCloudAPIKey $MultiTenanntAPIKey -force -JumpCloudOrgID $MultiTenanntOrgID2
        $Connect | Should -be $null
        $Organizations = Get-JCOrganization 
        $OrgVerify = $Organizations | Select-Object OrgID -Unique
        $OrgVerify.Count | Should -BeGreaterThan 1 
        
 
    }
}

Describe "Set-JCOrganization" {

    It "Switches connection between two JumpCloud orgs for an admin with a multi tenant API connection" {
        
        $Connect = Connect-JCOnline -JumpCloudAPIKey $MultiTenanntAPIKey -force -JumpCloudOrgID $MultiTenanntOrgID1
        $ConnectedOrgID = Get-JCCommand | Select-Object -Last 1 |  Select-Object -ExpandProperty organization
        $ConnectedOrgID | Should -Be $MultiTenanntOrgID1

        Set-JCOrganization -OrgID $MultiTenanntOrgID2

        $ConnectedOrgID = Get-JCCommand | Select-Object -Last 1 |  Select-Object -ExpandProperty organization
        $ConnectedOrgID | Should -Be $MultiTenanntOrgID2

       

    }

    It "Switches connection back and forth between two JumpCloud orgs for an admin with a multi tenant API connection" {
        
        $Connect = Connect-JCOnline -JumpCloudAPIKey $MultiTenanntAPIKey -force -JumpCloudOrgID $MultiTenanntOrgID1
        $ConnectedOrgID = Get-JCCommand | Select-Object -Last 1 |  Select-Object -ExpandProperty organization
        $ConnectedOrgID | Should -Be $MultiTenanntOrgID1

        Set-JCOrganization -OrgID $MultiTenanntOrgID2

        $ConnectedOrgID = Get-JCCommand | Select-Object -Last 1 |  Select-Object -ExpandProperty organization
        $ConnectedOrgID | Should -Be $MultiTenanntOrgID2

        Set-JCOrganization -OrgID $MultiTenanntOrgID1

        $ConnectedOrgID = Get-JCCommand | Select-Object -Last 1 |  Select-Object -ExpandProperty organization
        $ConnectedOrgID | Should -Be $MultiTenanntOrgID1
 
 
    }
}