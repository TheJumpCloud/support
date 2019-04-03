#Tests for JumpCloud Module Version 1.0.0

# To run all the Pester Tests you will need to have a tenant that matches the below criteria.

# For Command Results Tests - Have at least 5 command results present in your Org (These results will be deleted)
# For Commands Tests - Have at least 2 JumpCloud commands that are set to run via the 'Run on Trigger' event
# For Groups Tests - Have at least 2 JumpCloud User Groups and 2 JumpCloud System Groups
# For Systems Tests - Have at least 2 JumpCloud Systems present in your Org.
# For Users Tests - Have at least 2 JumpCloud Users present in your Org.

#Additionally you must populate the below variables to run successful tests using the -ByID parameter


#Test Functions





#region CommandResult Pester tests

#region CommandResults test data validation

#endregion CommandResults test data validation




#endregion CommandResult Pester tests

#region Commands Pester test


#region Commands test data validation

#endregion Commands test data validation





#endregion Commands Pester test

#region Groups pester test

#region Groups test data validation



Get-JCGroup -Type System | Get-JCSystemGroupMember | Remove-JCSystemGroupMember | Out-Null #Remove all system group members
#endregion Groups test data validation










#endregion Groups pester test

#region Systems Pester test

#region Systems data validation

$Systems = Get-JCSystem

if ($($Systems._id.Count) -le 1)
{ Write-Error 'You must have at least 2 JumpCloud systems to run the Pester tests'; break }

#endregion Systems data validation










#Purposefully left off Remove-JCSystem -force (I don't have enough systems to test with)

#endregion Systems Pester test

#region Users Pester test

#region Users data validation

$Users = Get-JCUser

if ($($Users._id.Count) -le 1)
{ Write-Error 'You must have at least 2 JumpCloud users to run the Pester tests'; break }

#endregion Users data validation


Describe 'Get-JCUser' {

    It "Gets all JumpCloud users using Get-JCuser" { $Users = Get-JCUser
        $Users._id.count | Should -BeGreaterThan 1 }

    It 'Get a single JumpCloud user by Username' {
        $User = Get-JCUser -Username $Username
        $User._id.count | Should -Be 1
    }

    It 'Get a single JumpCloud user by UserID' {
        $User = Get-JCUser -UserID $UserID
        $User._id.count | Should -Be 1
    }

    It 'Get multiple JumpCloud users via the pipeline using User ID' {
        $Users = Get-JCUser | Select-Object -Last 2 | ForEach-Object { Get-JCUser -UserID $_._id }
        $Users._id.count | Should -Be 2
    }
}


Describe 'New-JCUser and Remove-JCuser' {

    It "Creates a new user" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $NewUser._id.count | Should -Be 1
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new user and then deletes them" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $DeleteUser = Remove-JCUser -UserID $NewUser._id -ByID -Force
        $DeleteUser.results | Should -be 'Deleted'
    }

    It "Creates a new User allow_public_key -eq True " {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -allow_public_key $true
        $NewUser.allow_public_key | Should -Be True
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User allow_public_key -eq False " {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -allow_public_key $false
        $NewUser.allow_public_key | Should -Be False
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User sudo -eq True " {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -sudo $true
        $NewUser.sudo | Should -Be True
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User sudo -eq False " {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -sudo $false
        $NewUser.sudo | Should -Be False
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User enable_managed_uid -eq True " {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -enable_managed_uid $true
        $NewUser.enable_managed_uid | Should -Be True
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User enable_managed_uid -eq False " {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -enable_managed_uid $false
        $NewUser.enable_managed_uid | Should -Be False
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User passwordless_sudo -eq True " {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -passwordless_sudo $true
        $NewUser.passwordless_sudo | Should -Be True
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User passwordless_sudo -eq False " {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -passwordless_sudo $false
        $NewUser.passwordless_sudo | Should -Be False
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }


    It "Creates a new User ldap_binding_user -eq True " {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -ldap_binding_user $true
        $NewUser.ldap_binding_user | Should -Be True
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User ldap_binding_user -eq False " {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -ldap_binding_user $false
        $NewUser.ldap_binding_user | Should -Be False
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User enable_user_portal_multifactor -eq True " {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -enable_user_portal_multifactor $true
        $NewUser.enable_user_portal_multifactor | Should -Be True
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User enable_user_portal_multifactor -eq False " {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -enable_user_portal_multifactor $false
        $NewUser.enable_user_portal_multifactor | Should -Be False
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User sets unix_uid" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -unix_uid 100
        $NewUser.unix_uid | Should -Be 100
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User sets unix_guid" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -unix_guid 100
        $NewUser.unix_guid | Should -Be 100
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User with 1 custom attributes" {
        $NewUser = New-RandomUser -Attributes -Domain DeleteMe | New-JCUser -NumberOfCustomAttributes 1
        $NewUser.attributes._id.Count | Should -Be 1
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User with 3 custom attributes" {
        $NewUser = New-RandomUser -Attributes -Domain DeleteMe | New-JCUser -NumberOfCustomAttributes 3
        $NewUser.attributes._id.Count | Should -Be 3
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }
}

Describe 'Set-JCUser' {

    It "Updates the firstname and then sets it back using -ByID and -UserID" {
        $CurrentFirstName = Get-JCUser -UserID $UserID | Select-Object firstname
        $NewFirstName = Set-JCUser -ByID -UserID $UserID -firstname 'NewFirstName'
        $NewFirstName.firstname | Should -be 'NewFirstName'
        Set-JCUser -ByID -UserID $UserID -firstname $CurrentFirstName.firstname | Out-Null

    }

    It "Updates the firstname and then sets it back using -Username" {
        $CurrentFirstName = Get-JCUser -UserID $UserID | Select-Object firstname
        $NewFirstName = Set-JCUser -Username $Username -firstname 'NewFirstName'
        $NewFirstName.firstname | Should -be 'NewFirstName'
        Set-JCUser -ByID -UserID $UserID -firstname $CurrentFirstName.firstname | Out-Null

    }

    It "Updates the lastname and then sets it back using -ByID and -UserID" {
        $Currentlastname = Get-JCUser -UserID $UserID | Select-Object lastname
        $Newlastname = Set-JCUser -ByID -UserID $UserID -lastname 'NewLastName'
        $Newlastname.lastname | Should -be 'NewLastName'
        Set-JCUser -ByID -UserID $UserID -lastname $Currentlastname.lastname | Out-Null

    }

    It "Updates the lastname and then sets it back using -Username" {
        $Currentlastname = Get-JCUser -UserID $UserID | Select-Object lastname
        $Newlastname = Set-JCUser -Username $Username -lastname 'NewLastName'
        $Newlastname.lastname | Should -be 'NewLastName'
        Set-JCUser -ByID -UserID $UserID -lastname $Currentlastname.lastname | Out-Null

    }

    It "Updates the email and then sets it back using -ByID and -UserID" {
        $Currentemail = Get-JCUser -UserID $UserID | Select-Object email
        $Newemail = Set-JCUser -ByID -UserID $UserID -email $RandomEmail
        $Newemail.email | Should -be $RandomEmail
        Set-JCUser -ByID -UserID $UserID -email $Currentemail.email | Out-Null

    }

    It "Updates the email and then sets it back using -Username" {
        $Currentemail = Get-JCUser -UserID $UserID | Select-Object email
        $Newemail = Set-JCUser -Username $Username -email $RandomEmail
        $Newemail.email | Should -be $RandomEmail
        Set-JCUser -ByID -UserID $UserID -email $Currentemail.email | Out-Null

    }

    It "Updates the password using -ByID and -UserID" {

        { Set-JCUser -ByID -UserID $UserID -password 'Temp123!' } | Should -Not -Throw

    }

    It "Updates the password using -Username" {

        { Set-JCUser -Username $username -password 'Temp123!' } | Should -Not -Throw

    }

    It "Updates a User allow_public_key -eq True using -ByID and -UserID" {
        $Update = Set-JCUser -ByID -UserID $UserID -allow_public_key $true
        $Update.allow_public_key | Should -Be True
    }

    It "Updates a User allow_public_key -eq False using -ByID and -UserID" {
        $Update = Set-JCUser -ByID -UserID $UserID -allow_public_key $false
        $Update.allow_public_key | Should -Be False
    }

    It "Updates a User allow_public_key -eq True using -Username" {
        $Update = Set-JCUser -Username $Username -allow_public_key $true
        $Update.allow_public_key | Should -Be True
    }

    It "Updates a User allow_public_key -eq False using -Username" {
        $Update = Set-JCUser -Username $Username -allow_public_key $false
        $Update.allow_public_key | Should -Be False
    }

    It "Updates a User sudo -eq True using -ByID and -UserID" {
        $Update = Set-JCUser -ByID -UserID $UserID -sudo $true
        $Update.sudo | Should -Be True
    }

    It "Updates a User sudo -eq False using -ByID and -UserID" {
        $Update = Set-JCUser -ByID -UserID $UserID -sudo $false
        $Update.sudo | Should -Be False
    }

    It "Updates a User sudo -eq True using -Username" {
        $Update = Set-JCUser -Username $Username -sudo $true
        $Update.sudo | Should -Be True
    }

    It "Updates a User sudo -eq False using -Username" {
        $Update = Set-JCUser -Username $Username -sudo $false
        $Update.sudo | Should -Be False
    }

    It "Updates a User enable_managed_uid -eq True using -ByID and -UserID" {
        $Update = Set-JCUser -ByID -UserID $UserID -enable_managed_uid $true
        $Update.enable_managed_uid | Should -Be True
    }

    It "Updates a User enable_managed_uid -eq False using -ByID and -UserID" {
        $Update = Set-JCUser -ByID -UserID $UserID -enable_managed_uid $false
        $Update.enable_managed_uid | Should -Be False
    }

    It "Updates a User enable_managed_uid -eq True using -Username" {
        $Update = Set-JCUser -Username $Username -enable_managed_uid $true
        $Update.enable_managed_uid | Should -Be True
    }

    It "Updates a User enable_managed_uid -eq False using -Username" {
        $Update = Set-JCUser -Username $Username -enable_managed_uid $false
        $Update.enable_managed_uid | Should -Be False
    }

    It "Updates a User account_locked -eq True using -ByID and -UserID" {
        $Update = Set-JCUser -ByID -UserID $UserID -account_locked $true
        $Update.account_locked | Should -Be True
    }

    It "Updates a User account_locked -eq False using -ByID and -UserID" {
        $Update = Set-JCUser -ByID -UserID $UserID -account_locked $false
        $Update.account_locked | Should -Be False
    }

    It "Updates a User account_locked -eq True using -Username" {
        $Update = Set-JCUser -Username $Username -account_locked $true
        $Update.account_locked | Should -Be True
    }

    It "Updates a User account_locked -eq False using -Username" {
        $Update = Set-JCUser -Username $Username -account_locked $false
        $Update.account_locked | Should -Be False
    }
    It "Updates a User passwordless_sudo -eq True using -ByID and -UserID" {
        $Update = Set-JCUser -ByID -UserID $UserID -passwordless_sudo $true
        $Update.passwordless_sudo | Should -Be True
    }

    It "Updates a User passwordless_sudo -eq False using -ByID and -UserID" {
        $Update = Set-JCUser -ByID -UserID $UserID -passwordless_sudo $false
        $Update.passwordless_sudo | Should -Be False
    }

    It "Updates a User passwordless_sudo -eq True using -Username" {
        $Update = Set-JCUser -Username $Username -passwordless_sudo $true
        $Update.passwordless_sudo | Should -Be True
    }

    It "Updates a User passwordless_sudo -eq False using -Username" {
        $Update = Set-JCUser -Username $Username -passwordless_sudo $false
        $Update.passwordless_sudo | Should -Be False
    }

    It "Updates a User externally_managed -eq True using -ByID and -UserID" {
        $Update = Set-JCUser -ByID -UserID $UserID -externally_managed $true
        $Update.externally_managed | Should -Be True
    }

    It "Updates a User externally_managed -eq False using -ByID and -UserID" {
        $Update = Set-JCUser -ByID -UserID $UserID -externally_managed $false
        $Update.externally_managed | Should -Be False
    }

    It "Updates a User externally_managed -eq True using -Username" {
        $Update = Set-JCUser -Username $Username -externally_managed $true
        $Update.externally_managed | Should -Be True
    }

    It "Updates a User externally_managed -eq False using -Username" {
        $Update = Set-JCUser -Username $Username -externally_managed $false
        $Update.externally_managed | Should -Be False
    }

    It "Updates a User ldap_binding_user -eq True using -ByID and -UserID" {
        $Update = Set-JCUser -ByID -UserID $UserID -ldap_binding_user $true
        $Update.ldap_binding_user | Should -Be True
    }

    It "Updates a User ldap_binding_user -eq False using -ByID and -UserID" {
        $Update = Set-JCUser -ByID -UserID $UserID -ldap_binding_user $false
        $Update.ldap_binding_user | Should -Be False
    }

    It "Updates a User ldap_binding_user -eq True using -Username" {
        $Update = Set-JCUser -Username $Username -ldap_binding_user $true
        $Update.ldap_binding_user | Should -Be True
    }

    It "Updates a User ldap_binding_user -eq False using -Username" {
        $Update = Set-JCUser -Username $Username -ldap_binding_user $false
        $Update.ldap_binding_user | Should -Be False
    }
    It "Updates a User enable_user_portal_multifactor -eq True using -ByID and -UserID" {
        $Update = Set-JCUser -ByID -UserID $UserID -enable_user_portal_multifactor $true
        $Update.enable_user_portal_multifactor | Should -Be True
    }

    It "Updates a User enable_user_portal_multifactor -eq False using -ByID and -UserID" {
        $Update = Set-JCUser -ByID -UserID $UserID -enable_user_portal_multifactor $false
        $Update.enable_user_portal_multifactor | Should -Be False
    }

    It "Updates a User enable_user_portal_multifactor -eq True using -Username" {
        $Update = Set-JCUser -Username $Username -enable_user_portal_multifactor $true
        $Update.enable_user_portal_multifactor | Should -Be True
    }

    It "Updates a User enable_user_portal_multifactor -eq False using -Username" {
        $Update = Set-JCUser -Username $Username -enable_user_portal_multifactor $false
        $Update.enable_user_portal_multifactor | Should -Be False
    }


    It "Updates the unix_uid and then sets it back using -ByID and -UserID" {
        $Currentunix_uid = Get-JCUser -UserID $UserID | Select-Object unix_uid
        $100 = Set-JCUser -ByID -UserID $UserID -unix_uid '100'
        $100.unix_uid | Should -be '100'
        Set-JCUser -ByID -UserID $UserID -unix_uid $Currentunix_uid.unix_uid | Out-Null

    }

    It "Updates the unix_uid and then sets it back using -Username" {
        $Currentunix_uid = Get-JCUser -UserID $UserID | Select-Object unix_uid
        $100 = Set-JCUser -Username $Username -unix_uid '100'
        $100.unix_uid | Should -be '100'
        Set-JCUser -ByID -UserID $UserID -unix_uid $Currentunix_uid.unix_uid | Out-Null

    }

    It "Updates the unix_guid and then sets it back using -ByID and -UserID" {
        $Currentunix_guid = Get-JCUser -UserID $UserID | Select-Object unix_guid
        $100 = Set-JCUser -ByID -UserID $UserID -unix_guid '100'
        $100.unix_guid | Should -be '100'
        Set-JCUser -ByID -UserID $UserID -unix_guid $Currentunix_guid.unix_guid | Out-Null

    }

    It "Updates the unix_guid and then sets it back using -Username" {
        $Currentunix_guid = Get-JCUser -UserID $UserID | Select-Object unix_guid
        $100 = Set-JCUser -Username $Username -unix_guid '100'
        $100.unix_guid | Should -be '100'
        Set-JCUser -ByID -UserID $UserID -unix_guid $Currentunix_guid.unix_guid | Out-Null

    }
}

Describe "Set-JCUser - CustomAttributes" {

    It "Updates a custom attribute on a User" {
        $NewUser = New-RandomUserCustom -Attributes -Domain DeleteMe | New-JCUser -NumberOfCustomAttributes 3
        $UpdatedUser = Set-JCUser $NewUser.username -NumberOfCustomAttributes 1 -Attribute1_name 'Department' -Attribute1_value 'IT'

        [string]$NewUserAttr = $NewUser.attributes.name | Sort-Object
        [string]$UpdatedUserAttr = $UpdatedUser.attributes.name | Sort-Object

        $match = if ($NewUserAttr -eq $UpdatedUserAttr) { $true }
        else
        {
            $false
        }

        $match | Should -be $true

        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Adds a custom attribute to a User" {
        $NewUser = New-RandomUserCustom -Attributes -Domain DeleteMe | New-JCUser -NumberOfCustomAttributes 3
        $UpdatedUser = Set-JCUser $NewUser.username -NumberOfCustomAttributes 1 -Attribute1_name 'NewAttribute' -Attribute1_value 'IT'

        [int]$NewUserAttr = $NewUser.attributes.name.count
        [int]$UpdatedUserAttr = $UpdatedUser.attributes.name.count

        $NewUserAttr ++

        $match = if ($NewUserAttr -eq $UpdatedUserAttr) { $true }
        else
        {
            $false
        }

        $match | Should -be $true

        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Removes a custom attribute from a User" {
        $NewUser = New-RandomUserCustom -Attributes -Domain DeleteMe | New-JCUser -NumberOfCustomAttributes 3
        $UpdatedUser = Set-JCUser $NewUser.username -RemoveAttribute 'Department'

        [int]$NewUserAttr = $NewUser.attributes.name.count
        [int]$UpdatedUserAttr = $UpdatedUser.attributes.name.count

        $UpdatedUserAttr++

        $match = if ($NewUserAttr -eq $UpdatedUserAttr) { $true }
        else
        {
            $false
        }

        $match | Should -be $true

        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }


}



#endregion Users Pester test