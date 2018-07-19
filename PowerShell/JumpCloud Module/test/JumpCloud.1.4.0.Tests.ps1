#Tests for JumpCloud Module Version 1.4.0

#Fill out below varibles to run tests

$PesterUsername = ''
$PesterUserID = ''


$PesterSystemHostName = ""
$PesterSystemID = ''

#Create JumpCloud commands set to run on webhooks and enter their triggers below

$OneTrigger = ''
$TwoTrigger = ''
$ThreeTrigger = ''

Describe "Invoke-JCCommand" {

    It "Triggers a command with one variable" {

        $Trigger = Invoke-JCCommand -trigger $OneTrigger -NumberOfVariables 1 -Variable1_name 'One' -Variable1_value 'One variable' 
        $Trigger.triggered | Should -be 'Invoke - Pester One Variable'

    }

    IT "Triggers a command with two variables" {

        $Trigger = Invoke-JCCommand -trigger $TwoTrigger -NumberOfVariables 2 -Variable1_name 'One' -Variable1_value 'One variable' -Variable2_name 'Two' -Variable2_value 'Two Variable'
        $Trigger.triggered | Should -be  'Invoke - Pester Two Variable'
    }

    IT "Triggers a command with three variables" {
        $Trigger = Invoke-JCCommand -trigger $ThreeTrigger -NumberOfVariables 3 -Variable1_name 'One' -Variable1_value 'One variable' -Variable2_name 'Two' -Variable2_value 'Two Variable' -Variable3_name 'Three' -Variable3_value 'Three variable'
        $Trigger.triggered | Should -be  'Invoke - Pester Three Variable'

    }
 
}

Describe "Get-JCSystem" {

    It "Gets a JumpCloud system by system ID" {

        $PesterSystem = Get-JCSystem -SystemID $PesterSystemID
        $PesterSystem._id | Should Be $PesterSystemID
    }

    It "Returns all JumpCloud systems" {

        $Systems = Get-JCSystem 
        $Systems.count | Should -BeGreaterThan 1

    }

    It "Searches for JumpCloud system by hostname wildcard end" {

        $PesterSystem = Get-JCSystem -hostname "admins*"
        $PesterSystem.hostname | Should -Be $PesterSystemHostName
    }

    It "Searches for JumpCloud system by hostname wildcard beginning" {

        $PesterSystem = Get-JCSystem -hostname "*-Mac.local"
        $PesterSystem.hostname | Should -Be $PesterSystemHostName
    }

    It "Searches for JumpCloud system by hostname wildcard beginning and end" {

        $PesterSystem = Get-JCSystem -hostname "*-Mac*"
        $PesterSystem.hostname | Should -Be $PesterSystemHostName
    }

    
    It "Searches for JumpCloud system by displayname wildcard end" {

        $PesterSystem = Get-JCSystem -displayname "admins*"
        $PesterSystem.displayname | Should -Be $PesterSystemHostName
    }
    
    It "Searches for JumpCloud system by displayname wildcard beginning" {
    
        $PesterSystem = Get-JCSystem -displayname "*-Mac.local"
        $PesterSystem.displayname | Should -Be $PesterSystemHostName
    }
    
    It "Searches for JumpCloud system by displayname wildcard beginning and end" {
    
        $PesterSystem = Get-JCSystem -displayname "*-Mac*"
        $PesterSystem.displayname | Should -Be $PesterSystemHostName
    }

    It "Searches for JumpCloud system by version" {
    
        $PesterSystem = Get-JCSystem -version "10.12"
        $PesterSystem.version | Should -Be '10.12'
    }

    It "Searches for JumpCloud system by templateName and front and end wildcards" {
    
        $PesterSystem = Get-JCSystem -templateName "*mac*"
        $PesterSystem.templateName | Should -Be 'macosx-darwin-x86_64'
    }

    It "Searches for JumpCloud system by os and front and end wildcards" {
    
        $PesterSystem = Get-JCSystem -os "*Mac*"
        $PesterSystem.os | Should -Be 'Mac OS X'
    }

    It "Searches for JumpCloud system by remoteIP and front and end wildcards" {
    
        $PesterSystem = Get-JCSystem -remoteIP "*91.170*"
        $PesterSystem.remoteIP | Should -Be '70.91.170.105'
    }

    It "Searches for JumpCloud system by serialNumber and front and end wildcards" {
    
        $PesterSystem = Get-JCSystem -serialNumber "*AUX*"
        $PesterSystem.serialNumber | Should -Be 'VMaAUXL+fZQf'
    }

    It "Searches for JumpCloud system by serialNumber and front and end wildcards and arch" {
    
        $PesterSystem = Get-JCSystem -serialNumber "*AUX*" -arch "*_64"
        $PesterSystem.serialNumber | Should -Be 'VMaAUXL+fZQf'
    }

    It "Searches for JumpCloud system by agentVersion and front and end wildcards" {
    
        $PesterSystem = Get-JCSystem -agentVersion "*643*"
        $PesterSystem.agentVersion | Should -Be '0.9.643'
    }

    ## Cannot use wildcards on system timezone

    It "Searches for JumpCloud system by systemTimezone" {
    
        $PesterSystem = Get-JCSystem -systemTimezone "-700"
        $PesterSystem.systemTimezone | Should -Be '-700'
    }
    
    ## Boolean searches

    It "Searches for JumpCloud system by active" {
        $PesterSystem = Get-JCSystem -active $False
        $PesterSystem.active | Should -Be $False

    }

    It "Searches for JumpCloud system by hostname and allowMultiFactorAuthentication" {
        $PesterSystem = Get-JCSystem -hostname "*admin*" -allowMultiFactorAuthentication $False
        $PesterSystem.hostname | Should -Be $PesterSystemHostName
    }
    
    It "Searches for JumpCloud system by hostname and allowPublicKeyAuthentication" {
        $PesterSystem = Get-JCSystem -hostname "*admin*" -allowPublicKeyAuthentication $False
        $PesterSystem.hostname | Should -Be $PesterSystemHostName
    }
    
    It "Searches for JumpCloud system by hostname and allowSshPasswordAuthentication" {
        $PesterSystem = Get-JCSystem -hostname "*admin*" -allowSshPasswordAuthentication $False
        $PesterSystem.hostname | Should -Be $PesterSystemHostName
    }
    
    It "Searches for JumpCloud system by hostname and allowSshRootLogin" {
        $PesterSystem = Get-JCSystem -hostname "*admin*" -allowSshRootLogin $False
        $PesterSystem.hostname | Should -Be $PesterSystemHostName
    }

    It "Searches for JumpCloud system by hostname and modifySSHDConfig" {
        $PesterSystem = Get-JCSystem -hostname "*admin*" -modifySSHDConfig $False
        $PesterSystem.hostname | Should -Be $PesterSystemHostName
    }
    
    It "Searches for a JumpCloud system using hostname, filterDateProperty created and before" {

        $PesterSystem = Get-JCSystem -filterDateProperty created -dateFilter before -date '1/10/2018' -hostname "*admin*"
        $PesterSystem.hostname | Should -Be $PesterSystemHostName

    }

    It "Searches for a JumpCloud system using hostname, filterDateProperty created and after" {

        $PesterSystem = Get-JCSystem -filterDateProperty created -dateFilter after -date '1/7/2018' -hostname "*admin*"
        $PesterSystem.hostname | Should -Be $PesterSystemHostName

    }
       
    It "Searches for a JumpCloud system using hostname and returns properties created" {
        $PesterSystem = Get-JCSystem -hostname "*admin*" -returnProperties created
        $PesterSystem.created | Should -Not -Be $null
    } 
    
    It "Searches for a JumpCloud system using hostname and returns properties active" {
        $PesterSystem = Get-JCSystem -hostname "*admin*" -returnProperties active
        $PesterSystem.active | Should -Not -Be $null
    } 
    
    It "Searches for a JumpCloud system using hostname and returns properties agentVersion" {
        $PesterSystem = Get-JCSystem -hostname "*admin*" -returnProperties agentVersion
        $PesterSystem.agentVersion | Should -Not -Be $null
    }  

    It "Searches for a JumpCloud system using hostname and returns properties allowMultiFactorAuthentication" {
        $PesterSystem = Get-JCSystem -hostname "*admin*" -returnProperties allowMultiFactorAuthentication
        $PesterSystem.allowMultiFactorAuthentication | Should -Not -Be $null
    }  
    
    It "Searches for a JumpCloud system using hostname and returns all properties " {
        $PesterSystem = Get-JCSystem -hostname "*admin*" -returnProperties 'created', 'active', 'agentVersion', 'allowMultiFactorAuthentication', 'allowPublicKeyAuthentication', 'allowSshPasswordAuthentication', 'allowSshRootLogin', 'arch', 'created', 'displayName', 'hostname', 'lastContact', 'modifySSHDConfig', 'organization', 'os', 'remoteIP', 'serialNumber', 'systemTimezone', 'templateName', 'version'
        $PesterSystem.created | Should -Not -Be $null
        $PesterSystem.active | Should -Not -Be $null
        $PesterSystem.agentVersion | Should -Not -Be $null
        $PesterSystem.allowMultiFactorAuthentication | Should -Not -Be $null
        $PesterSystem.allowPublicKeyAuthentication | Should -Not -Be $null
        $PesterSystem.allowSshPasswordAuthentication | Should -Not -Be $null
        $PesterSystem.allowSshRootLogin | Should -Not -Be $null
        $PesterSystem.arch | Should -Not -Be $null
        $PesterSystem.created | Should -Not -Be $null
        $PesterSystem.displayName | Should -Not -Be $null
        $PesterSystem.hostname | Should -Not -Be $null
        $PesterSystem.lastContact | Should -Not -Be $null
        $PesterSystem.modifySSHDConfig | Should -Not -Be $null
        $PesterSystem.organization | Should -Not -Be $null
        $PesterSystem.os | Should -Not -Be $null
        $PesterSystem.remoteIP | Should -Not -Be $null
        $PesterSystem.serialNumber | Should -Not -Be $null
        $PesterSystem.systemTimezone | Should -Not -Be $null
        $PesterSystem.templateName | Should -Not -Be $null
        $PesterSystem.version | Should -Not -Be $null
    }  
       
}

Describe "Get-JCUser" {

    It "Returns a JumpCloud user by UserID" {
        $PesterUser = Get-JCUser -userid $PesterUserID
        $PesterUser._id | Should -be $PesterUserID
    }

    It "Returns all JumpCloud users" {
        $AllUsers = Get-JCUser
        $AllUsers.Count | Should -BeGreaterThan 1
    }

    It "Searches for a JumpCloud user by username and wildcard end" {

        $PesterUser = Get-JCUser -username "pester.*"
        $PesterUser.username | Should -be $PesterUsername

    }

    It "Searches for a JumpCloud user by username and wildcard beginning" {
        $PesterUser = Get-JCUser -username "*ester.tester"
        $PesterUser.username | Should -be $PesterUsername
    }

    It "Searches for a JumpCloud user by username and wildcard beginning and wildcard end" {
        $PesterUser = Get-JCUser -username "*ester.teste*"
        $PesterUser.username | Should -be $PesterUsername
    }

    It "Searches for a JumpCloud user by firstname and wildcard end" {
        $PesterUser = Get-JCUser -firstname "Peste*" -username $PesterUsername
        $PesterUser.username | Should -be $PesterUsername
    }
    
    It "Searches for a JumpCloud user by firstname and wildcard beginning" {
        $PesterUser = Get-JCUser -firstname "*ester" -username $PesterUsername
        $PesterUser.username | Should -be $PesterUsername
    }
    
    It "Searches for a JumpCloud user by firstname and wildcard beginning and wildcard end" {
        $PesterUser = Get-JCUser -firstname "*este*" -username $PesterUsername
        $PesterUser.username | Should -be $PesterUsername
    }

    It "Searches for a JumpCloud user by lastname and wildcard end" {
        $PesterUser = Get-JCUser -lastname "Test*" -username $PesterUsername
        $PesterUser.username | Should -be $PesterUsername
    }
    
    It "Searches for a JumpCloud user by lastname and wildcard beginning" {
        $PesterUser = Get-JCUser -lastname "*ester" -username $PesterUsername
        $PesterUser.username | Should -be $PesterUsername
    }
    
    It "Searches for a JumpCloud user by lastname and wildcard beginning and wildcard end" {
        $PesterUser = Get-JCUser -lastname "*este*" -username $PesterUsername
        $PesterUser.username | Should -be $PesterUsername
    }

    It "Searches for a JumpCloud user by email and wildcard beginning" {
        $PesterUser = Get-JCUser -email "*.com" -username $PesterUsername
        $PesterUser.username | Should -be $PesterUsername
    }
    
    It "Searches for a JumpCloud user by email and wildcard beginning and wildcard end" {
        $PesterUser = Get-JCUser -email "*.co*" -username $PesterUsername
        $PesterUser.username | Should -be $PesterUsername
    }

    It "Searches for a JumpCloud user by username and sudo" {
        $PesterUser = Get-JCUser -username $PesterUsername -sudo $false
        $PesterUser.username | Should -be $PesterUsername
    }

    It "Searches for a JumpCloud user by username and enable_managed_uid" {
        $PesterUser = Get-JCUser -username $PesterUsername -enable_managed_uid $false
        $PesterUser.username | Should -be $PesterUsername
    }

    It "Searches for a JumpCloud user by username and activated" {
        $PesterUser = Get-JCUser -username $PesterUsername -activated $true
        $PesterUser.username | Should -be $PesterUsername
    }

    It "Searches for a JumpCloud user by username and password_expired" {
        $PesterUser = Get-JCUser -username $PesterUsername -password_expired $false
        $PesterUser.username | Should -be $PesterUsername
    }

    It "Searches for a JumpCloud user by username and passwordless_sudo" {
        $PesterUser = Get-JCUser -username $PesterUsername -passwordless_sudo $false
        $PesterUser.username | Should -be $PesterUsername
    }

    It "Searches for a JumpCloud user by username and externally_managed" {
        $PesterUser = Get-JCUser -username $PesterUsername -externally_managed $false
        $PesterUser.username | Should -be $PesterUsername
    }

    It "Searches for a JumpCloud user by username and ldap_binding_user" {
        $PesterUser = Get-JCUser -username $PesterUsername -ldap_binding_user $false
        $PesterUser.username | Should -be $PesterUsername
    }

    It "Searches for a JumpCloud user by username and enable_user_portal_multifactor" {
        $PesterUser = Get-JCUser -username $PesterUsername -enable_user_portal_multifactor $false
        $PesterUser.username | Should -be $PesterUsername
    }

    It "Searches for a JumpCloud user by username and totp_enabled" {
        $PesterUser = Get-JCUser -username $PesterUsername -totp_enabled $false
        $PesterUser.username | Should -be $PesterUsername
    }

    It "Searches for a JumpCloud user by username and allow_public_key" {
        $PesterUser = Get-JCUser -username $PesterUsername -allow_public_key $false
        $PesterUser.username | Should -be $PesterUsername
    }

    It "Searches for a JumpCloud user by username and samba_service_user" {
        $PesterUser = Get-JCUser -username $PesterUsername -samba_service_user $false
        $PesterUser.username | Should -be $PesterUsername
    }

    It "Searches for a JumpCloud user by username and password_never_expires" {
        $PesterUser = Get-JCUser -username $PesterUsername -password_never_expires $false
        $PesterUser.username | Should -be $PesterUsername
    }
    
    It "Searches for a JumpCloud user using username, filterDateProperty created and before" {

        $PesterUser = Get-JCUser -username $PesterUsername -filterDateProperty created -dateFilter before -date '1/3/2018'
        $PesterUser.username | Should -be $PesterUsername

    }

    It "Searches for a JumpCloud user using username, filterDateProperty created and after" {

        $PesterUser = Get-JCUser -username $PesterUsername -filterDateProperty created -dateFilter after -date '1/1/2018'
        $PesterUser.username | Should -be $PesterUsername

    } 

    IT "Searches for a JumpCloud user using username and returns on the username property" {
        $PesterUser = Get-JCUser -username $PesterUsername -returnProperties username
        $PesterUser.username | Should -be $PesterUsername
    }

    It "Searches for a JumpCloud user using username and returns all properties " {
        $PesterUser = Get-JCUser -username $PesterUsername  -returnProperties 'created', 'account_locked', 'activated', 'addresses', 'allow_public_key', 'attributes', 'email', 'enable_managed_uid', 'enable_user_portal_multifactor', 'externally_managed', 'firstname', 'lastname', 'ldap_binding_user', 'passwordless_sudo', 'password_expired', 'password_never_expires', 'phoneNumbers', 'samba_service_user', 'ssh_keys', 'sudo', 'totp_enabled', 'unix_guid', 'unix_uid', 'username'
        $PesterUser.created | Should -Not -Be $null
        $PesterUser.account_locked | Should -Not -Be $null
        $PesterUser.activated | Should -Not -Be $null
        $PesterUser.addresses | Should -Not -Be $null
        $PesterUser.allow_public_key | Should -Not -Be $null
        $PesterUser.attributes | Should -Not -Be $null
        $PesterUser.email | Should -Not -Be $null
        $PesterUser.enable_managed_uid | Should -Not -Be $null
        $PesterUser.enable_user_portal_multifactor | Should -Not -Be $null
        $PesterUser.externally_managed | Should -Not -Be $null
        $PesterUser.firstname | Should -Not -Be $null
        $PesterUser.lastname | Should -Not -Be $null
        $PesterUser.ldap_binding_user | Should -Not -Be $null
        $PesterUser.passwordless_sudo | Should -Not -Be $null
        $PesterUser.password_expired | Should -Not -Be $null
        $PesterUser.password_never_expires | Should -Not -Be $null
        $PesterUser.samba_service_user | Should -Not -Be $null
        $PesterUser.sudo | Should -Not -Be $null
        $PesterUser.totp_enabled | Should -Not -Be $null
        $PesterUser.phoneNumbers | Should -Not -Be $null
        $PesterUser.unix_guid | Should -Not -Be $null
        $PesterUser.unix_uid | Should -Not -Be $null
        $PesterUser.username | Should -Not -Be $null

    } 
    

}

