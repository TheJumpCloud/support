#Tests for JumpCloud Module Version 1.3.0

#Fill out below varibles to run tests

$JC_APIKey = ''

$UserGroupName = 'LDAPTest'  #Create three user groups with LDAP in the name

$UserGroupID = ''  # Paste the corresponding GroupID for the user group named LDAPTest

$SystemGroupName = 'PesterTest_SystemGroup' # Create a sytem group named PesterTest_SystemGroup within your environment

$SystemGroupID = ''  # Paste the corresponding GroupID for the sytem group named PesterTest_SystemGroup

$CommmandID = '' # ID of a test command

$MacCommandID = '' # ID of a Mac Command

$MacSystemID = '' #ID of a Mac System

Function New-RandomUser  ()
{
    [CmdletBinding(DefaultParameterSetName = 'NoAttributes')]
    param
    (
        [Parameter(ParameterSetName = 'Attributes')] ##Test this to see if this can be modified.
        [switch]
        $Attributes

    )

    if (($PSCmdlet.ParameterSetName -eq 'NoAttributes'))
    {
        $username = -join ((65..90) + (97..122) | Get-Random -Count 8 | % {[char]$_})
        $email = $username + "@RamdomUser.com"

        $RandomUser = [ordered]@{
            FirstName = 'Pester'
            LastName  = 'Test'
            Username  = $username
            Email     = $email
            Password  = 'Temp123!'
        }

        $NewRandomUser = New-Object psobject -Property $RandomUser
    }

    if (($PSCmdlet.ParameterSetName -eq 'Attributes'))
    {
        $username = -join ((65..90) + (97..122) | Get-Random -Count 8 | % {[char]$_})
        $email = $username + "@RamdomUser.com"

        $RandomUser = [ordered]@{
            FirstName                = 'Pester'
            LastName                 = 'Test'
            Username                 = $username
            Email                    = $email
            Password                 = 'Temp123!'
            NumberOfCustomAttributes = 3
            Attribute1_name          = 'Department'
            Attribute1_value         = 'Sales'
            Attribute2_name          = 'Office'
            Attribute2_value         = '456789'
            Attribute3_name          = 'Lang'
            Attribute3_value         = 'French'
        }
        $NewRandomUser = New-Object psobject -Property $RandomUser
    }


    return $NewRandomUser
}


Describe 'Connect-JCOnline with force parameter' {

    it "Connects to JumpCloud using the -Force parameter" {

        $Connect = Connect-JCOnline -JumpCloudAPIKey $JC_APIKey -force
        $Connect | Should -be $null
    }

}

#Features
Describe 'Set-JCUserGroupLDAP' {

    it "Enables LDAP for a JumpCloud User Group using GroupName" {

        $DisableLDAP = Set-JCUserGroupLDAP -GroupName $UserGroupName -LDAPEnabled $false

        $EnableLDAP = Set-JCUserGroupLDAP -GroupName $UserGroupName -LDAPEnabled $true

        $EnableLDAP.LDAPEnabled | Should be $true

    }
    
    it "Disables LDAP for a JumpCloud User Group using GroupName" {

        $DisableLDAP = Set-JCUserGroupLDAP -GroupName $UserGroupName -LDAPEnabled $false

        $DisableLDAP.LDAPEnabled | Should be $false

    } 

    it "Enables LDAP for a JumpCloud User Group using GroupID" {

        $DisableLDAP = Set-JCUserGroupLDAP -GroupID $UserGroupID -LDAPEnabled $false

        $EnableLDAP = Set-JCUserGroupLDAP -GroupID $UserGroupID -LDAPEnabled $true

        $EnableLDAP.LDAPEnabled | Should be $true

    }
    
    it "Disables LDAP for a JumpCloud User Group using GroupID" {

        $DisableLDAP = Set-JCUserGroupLDAP -GroupID $UserGroupID -LDAPEnabled $false

        $DisableLDAP.LDAPEnabled | Should be $false

    }
    
    it "Enables LDAP for three JumpCloud User Groups using GroupName and the pipeline" {

        $LDAP_Groups = Get-JCGroup -Type User | Where-Object Name -like "*LDAP*" | Select-Object Name

        $LDAP_Groups_Disable = $LDAP_Groups | Set-JCUserGroupLDAP -LDAPEnabled $false

        $LDAP_Groups_Enable = $LDAP_Groups | Set-JCUserGroupLDAP -LDAPEnabled $true

        $LDAP_Enabled = $LDAP_Groups_Enable  | Select-Object LDAPEnabled -Unique
        
        $LDAP_Enabled | Should be $true

    }

        
    it "Disables LDAP for three JumpCloud User Groups using GroupName and the pipeline" {

        $LDAP_Groups = Get-JCGroup -Type User | Where-Object Name -like "*LDAP*" | Select-Object Name

        $LDAP_Groups_Disable = $LDAP_Groups | Set-JCUserGroupLDAP -LDAPEnabled $false

        $LDAP_Disabled = $LDAP_Groups_Disable  | Select-Object LDAPEnabled -Unique
        
        $LDAP_Disabled.LDAPEnabled | Should be $false

    }

    it "Enables LDAP for three JumpCloud User Groups using GroupID and the pipeline" {

        $LDAP_Groups = Get-JCGroup -Type User | Where-Object Name -like "*LDAP*" | Select-Object id

        $LDAP_Groups_Disable = $LDAP_Groups | % {Set-JCUserGroupLDAP -GroupID $_.id -LDAPEnabled $false}

        $LDAP_Groups_Enable = $LDAP_Groups | % {Set-JCUserGroupLDAP -GroupID $_.id -LDAPEnabled $true}

        $LDAP_Enabled = $LDAP_Groups_Enable  | Select-Object LDAPEnabled -Unique
        
        $LDAP_Enabled | Should be $true

    }
      
    it "Disables LDAP for three JumpCloud User Groups using GroupID and the pipeline" {

        $LDAP_Groups = Get-JCGroup -Type User | Where-Object Name -like "*LDAP*" | Select-Object id

        $LDAP_Groups_Disable = $LDAP_Groups | % {Set-JCUserGroupLDAP -GroupID $_.id -LDAPEnabled $false}

        $LDAP_Disabled = $LDAP_Groups_Disable  | Select-Object LDAPEnabled -Unique
        
        $LDAP_Disabled.LDAPEnabled | Should be $false

    }


}

Describe 'Get-JCCommandTarget' {

    it "Returns a JumpCloud commands system targets" {

        $SystemTarget = Get-JCCommandTarget -CommandID $CommmandID

        $SystemTarget.SystemID.count | Should -BeGreaterThan 0
    }
    
    it "Returns a JumpCloud commands group targets by groupname" {

        $SystemGroupTarget = Get-JCCommandTarget -CommandID $CommmandID -Groups

        $SystemGroupTarget.GroupID.count | Should -BeGreaterThan 0

    }
    
    it "Returns all JumpCloud commands system targets using the pipeline" {
        $AllCommands = Get-JCCommand | Get-JCCommandTarget

        $AllCommands.CommmandID.count | Should -BeGreaterThan 1
    }

    it "Returns all JumpCloud commands system group targets using the pipeline" {

        $AllCommands = Get-JCCommand | Get-JCCommandTarget -Groups

        $AllCommands.CommmandID.count | Should -BeGreaterThan 1
        
    }


}


Describe 'Add-JCCommandTarget' {

    it "Adds a single system to a JupmCloud command" {

        $TargetRemove = Remove-JCCommandTarget -CommandID $MacCommandID -SystemID $MacSystemID

        $TargetAdd = Add-JCCommandTarget -CommandID $MacCommandID -SystemID $MacSystemID

        $TargetAdd.Status | Should -Be 'Added'


    }

    it "Adds a single system group to a JupmCloud command by GroupName" {

        $TargetRemove = Remove-JCCommandTarget -CommandID $MacCommandID -GroupName $SystemGroupName

        $TargetAdd = Add-JCCommandTarget -CommandID $MacCommandID -GroupName $SystemGroupName

        $TargetAdd.Status | Should -Be 'Added'


    }

    it "Removes a single system group to a JupmCloud command by GroupID" {

        $TargetRemove = Remove-JCCommandTarget -CommandID $MacCommandID -GroupName $SystemGroupName

        $TargetAdd = Add-JCCommandTarget -CommandID $MacCommandID -GroupID $SystemGroupID

        $TargetAdd.Status | Should -Be 'Added'


    }

   


}

Describe 'Remove-JCCommandTarget' {

    it "Removes a single system from a JumpCloud command" {

        $TargetRemove = Remove-JCCommandTarget -CommandID $MacCommandID -SystemID $MacSystemID

        $TargetRemove.Status | Should -be  'Removed'

    }
    
    it "Removes a single system group from a JumpCloud command by GroupID" {

        $TargetAdd = Add-JCCommandTarget -CommandID $MacCommandID -GroupName $SystemGroupName

        $TargetRemove = Remove-JCCommandTarget -CommandID $MacCommandID -GroupID $SystemGroupID

        $TargetRemove.Status | Should -be  'Removed'

    }  

    it "Removes a single system group from a JumpCloud command by GroupName" {

        $TargetAdd = Add-JCCommandTarget -CommandID $MacCommandID -GroupName $SystemGroupName

        $TargetRemove = Remove-JCCommandTarget -CommandID $MacCommandID -GroupName $SystemGroupName

        $TargetRemove.Status | Should -be  'Removed'

    }  


}

#Bug fixes

Describe 'Get-JCSystemGroupMember' {
    #ByID
    it "Gets the members of a JumpCloud system group by Group Name" {

        $SystemGroupMembers = Get-JCSystemGroupMember -GroupName $SystemGroupName 

        $SystemGroupMembers.SystemID.Count | Should -BeGreaterThan 0

    }
    
    it "Gets the members of a JumpCloud system group by Goup ID" {

        $SystemGroupMembers = Get-JCSystemGroupMember -ByID $SystemGroupID

        $SystemGroupMembers.SystemID.Count | Should -BeGreaterThan 0

    }    


}

Describe 'Add-JCUser' {
    #Linux UID, GUID
    it "Adds a JumpCloud user with a high UID and GUID" {

        $NewUser = New-RandomUser | New-JCUser -unix_uid 1000000 -unix_guid 1000000

        $NewUser.unix_uid | Should -be '1000000'
        $NewUser.unix_guid | Should -be '1000000'

    }    

    it "Adds a JumpCloud user with password_never_expires false " {
        
        $ExpFalse = New-RandomUser | New-JCUser -password_never_expires $false

        $ExpFalse.password_never_expires | Should Be $false

    }

    it "Adds a JumpCloud user with password_never_expires true " {

        $ExpTrue = New-RandomUser | New-JCUser -password_never_expires $true

        $ExpTrue.password_never_expires | Should Be $true
        
    }

}

Describe 'Set-JCUser' {
    # Linux UID, GUID
    it "Updates the UID and GUID to 2000000" {

        $RandomUser = New-RandomUser | New-JCUser

        $SetUser = Set-JCUser -Username $RandomUser.username -unix_uid 2000000 -unix_guid 2000000

        $SetUser.unix_guid | Should be 2000000

        $SetUser.unix_uid | Should be 2000000

    } 
    
    it "Updates a JumpCloud user to password_never_expires false " {

        $ExpTrue = New-RandomUser | New-JCUser -password_never_expires $true

        $SetFalse = $ExpTrue | Set-JCUser -password_never_expires $false

        $SetFalse.password_never_expires | Should Be $false

    }

    it "Updates a JumpCloud user to password_never_expires true " {

        $ExpFalse = New-RandomUser | New-JCUser -password_never_expires $false

        $SetTrue = $ExpFalse | Set-JCUser -password_never_expires $True

        $SetTrue.password_never_expires | Should be $true
        
    }


}

