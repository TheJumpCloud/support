Describe -Tag:('JCUser') 'Get-JCUser 1.0' {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force | Out-Null }
    It "Gets all JumpCloud users using Get-JCuser" { $Users = Get-JCUser
        $Users._id.count | Should -BeGreaterThan 1 }

    It 'Get a single JumpCloud user by Username' {
        $User = Get-JCUser -Username $PesterParams_Username
        $User._id.count | Should -Be 1
    }

    It 'Get a single JumpCloud user by UserID' {
        $User = Get-JCUser -UserID $PesterParams_UserID
        $User._id.count | Should -Be 1
    }

    It 'Get multiple JumpCloud users via the pipeline using User ID' {
        $Users = Get-JCUser | Select-Object -Last 2 | ForEach-Object { Get-JCUser -UserID $_._id }
        $Users._id.count | Should -Be 2
    }
}

Describe -Tag:('JCUser') 'Get-JCUser 1.1' {

    It "Searches a JumpCloud user by username" {

        $Username = New-RandomString -NumberOfChars 8
        $NewUser = New-RandomUser -Domain DeleteMe | New-JCUser -username $Username
        $NewUser = Get-JCUser -Username $Username
        $NewUser.username | Should -Be $Username
        Remove-JCUser -UserID $NewUser._id -force
    }

    It "Searches a JumpCloud user by lastname" {

        $lastname = New-RandomString -NumberOfChars 8
        $NewUser = New-RandomUser -Domain DeleteMe | New-JCUser -lastname $lastname
        $NewUser = Get-JCUser -lastname $lastname
        $NewUser.lastname | Should -Be $lastname
        Remove-JCUser -UserID $NewUser._id -force
    }

    It "Searches a JumpCloud user by firstname" {

        $firstname = New-RandomString -NumberOfChars 8
        $NewUser = New-RandomUser -Domain DeleteMe | New-JCUser -firstname $firstname
        $NewUser = Get-JCUser -firstname $firstname
        $NewUser.firstname | Should -Be $firstname
        Remove-JCUser -UserID $NewUser._id -force

    }

    It "Searches a JumpCloud user by email" {

        $email = "deleteme@$(New-RandomString -NumberOfChars 8).com"
        $NewUser = New-RandomUser -Domain DeleteMe | New-JCUser -email $email
        $NewUser = Get-JCUser -email $email
        $NewUser.email | Should -Be $email
        Remove-JCUser -UserID $NewUser._id -force

    }

}

Describe -Tag:('JCUser') "Get-JCUser 1.4" {

    It "Returns a JumpCloud user by UserID" {
        $PesterUser = Get-JCUser -userid $PesterParams_UserID
        $PesterUser._id | Should -Be $PesterParams_UserID
    }

    It "Returns all JumpCloud users" {
        $AllUsers = Get-JCUser
        $AllUsers.Count | Should -BeGreaterThan 1
    }

    It "Searches for a JumpCloud user by username and wildcard end" {

        $PesterUser = Get-JCUser -username "pester.*"
        $PesterUser.username | Should -BeGreaterThan 0

    }

    It "Searches for a JumpCloud user by username and wildcard beginning" {
        $PesterUser = Get-JCUser -username "*ester.tester"
        $PesterUser.username | Should -BeGreaterThan 0

    }

    It "Searches for a JumpCloud user by username and wildcard beginning and wildcard end" {
        $PesterUser = Get-JCUser -username "*ester.teste*"
        $PesterUser.username | Should -BeGreaterThan 0
    }

    It "Searches for a JumpCloud user by firstname and wildcard end" {
        $PesterUser = Get-JCUser -firstname "Peste*" -username $PesterParams_Username
        $PesterUser.username | Should -BeGreaterThan 0
    }

    It "Searches for a JumpCloud user by firstname and wildcard beginning" {
        $PesterUser = Get-JCUser -firstname "*ester" -username $PesterParams_Username
        $PesterUser.username | Should -BeGreaterThan 0
    }

    It "Searches for a JumpCloud user by firstname and wildcard beginning and wildcard end" {
        $PesterUser = Get-JCUser -firstname "*este*" -username $PesterParams_Username
        $PesterUser.username | Should -BeGreaterThan 0
    }

    It "Searches for a JumpCloud user by lastname and wildcard end" {
        $PesterUser = Get-JCUser -lastname "Test*" -username $PesterParams_Username
        $PesterUser.username | Should -BeGreaterThan 0
    }

    It "Searches for a JumpCloud user by lastname and wildcard beginning" {
        $PesterUser = Get-JCUser -lastname "*ester" -username $PesterParams_Username
        $PesterUser.username | Should -BeGreaterThan 0
    }

    It "Searches for a JumpCloud user by lastname and wildcard beginning and wildcard end" {
        $PesterUser = Get-JCUser -lastname "*este*" -username $PesterParams_Username
        $PesterUser.username | Should -BeGreaterThan 0
    }

    It "Searches for a JumpCloud user by email and wildcard beginning" {
        $PesterUser = Get-JCUser -email "*.com" -username $PesterParams_Username
        $PesterUser.username | Should -BeGreaterThan 0
    }

    It "Searches for a JumpCloud user by email and wildcard beginning and wildcard end" {
        $PesterUser = Get-JCUser -email "*.co*" -username $PesterParams_Username
        $PesterUser.username | Should -BeGreaterThan 0
    }

    It "Searches for a JumpCloud user by username and sudo" {
        $PesterUser = Get-JCUser -username $PesterParams_Username -sudo $false
        $PesterUser.username | Should -Be $PesterParams_Username
    }

    It "Searches for a JumpCloud user by username and enable_managed_uid" {
        $PesterUser = Get-JCUser -username $PesterParams_Username -enable_managed_uid $false
        $PesterUser.username | Should -Be $PesterParams_Username
    }

    It "Searches for a JumpCloud user by username and activated" {
        $PesterUser = Get-JCUser -username $PesterParams_Username -activated $true
        $PesterUser.username | Should -Be $PesterParams_Username
    }

    It "Searches for a JumpCloud user by username and password_expired" {
        $PesterUser = Get-JCUser -username $PesterParams_Username -password_expired $false
        $PesterUser.username | Should -Be $PesterParams_Username
    }

    It "Searches for a JumpCloud user by username and passwordless_sudo" {
        $PesterUser = Get-JCUser -username $PesterParams_Username -passwordless_sudo $false
        $PesterUser.username | Should -Be $PesterParams_Username
    }

    It "Searches for a JumpCloud user by username and externally_managed" {
        $PesterUser = Get-JCUser -username $PesterParams_Username -externally_managed $false
        $PesterUser.username | Should -Be $PesterParams_Username
    }

    It "Searches for a JumpCloud user by username and ldap_binding_user" {
        $PesterUser = Get-JCUser -username $PesterParams_Username -ldap_binding_user $false
        $PesterUser.username | Should -Be $PesterParams_Username
    }

    It "Searches for a JumpCloud user by username and enable_user_portal_multifactor" {
        $PesterUser = Get-JCUser -username $PesterParams_Username -enable_user_portal_multifactor $false
        $PesterUser.username | Should -Be $PesterParams_Username
    }

    It "Searches for a JumpCloud user by username and totp_enabled" {
        $PesterUser = Get-JCUser -username $PesterParams_Username -totp_enabled $false
        $PesterUser.username | Should -Be $PesterParams_Username
    }

    It "Searches for a JumpCloud user by username and allow_public_key" {
        $PesterUser = Get-JCUser -username $PesterParams_Username -allow_public_key $false
        $PesterUser.username | Should -Be $PesterParams_Username
    }


    It "Searches for a JumpCloud user by username and samba_service_user" {
        $PesterUser = Get-JCUser -username $PesterParams_Username -samba_service_user $false
        $PesterUser.username | Should -Be $PesterParams_Username
    }

    It "Searches for a JumpCloud user by username and password_never_expires" {
        $PesterUser = Get-JCUser -username $PesterParams_Username -password_never_expires $true
        $PesterUser.username | Should -Be $PesterParams_Username
    }

    It "Searches for a JumpCloud user using username, filterDateProperty created and before" {

        $PesterUser = Get-JCUser -username $PesterParams_Username -filterDateProperty created -dateFilter before -date '6/3/2020'
        $PesterUser.username | Should -Be $PesterParams_Username

    }

    It "Searches for a JumpCloud user using username, filterDateProperty created and after" {

        $PesterUser = Get-JCUser -username $PesterParams_Username -filterDateProperty created -dateFilter after -date '1/1/2018'
        $PesterUser.username | Should -Be $PesterParams_Username

    }

    It "Searches for a JumpCloud user using username and returns on the username property" {
        $PesterUser = Get-JCUser -username $PesterParams_Username -returnProperties username
        $PesterUser.username | Should -Be $PesterParams_Username
    }

    It "Searches for a JumpCloud user using username and returns all properties " {
        $PesterUser = Get-JCUser -username $PesterParams_Username  -returnProperties 'created', 'account_locked', 'activated', 'addresses', 'allow_public_key', 'attributes', 'email', 'enable_managed_uid', 'enable_user_portal_multifactor', 'externally_managed', 'firstname', 'lastname', 'ldap_binding_user', 'passwordless_sudo', 'password_expired', 'password_never_expires', 'phoneNumbers', 'samba_service_user', 'ssh_keys', 'sudo', 'totp_enabled', 'unix_guid', 'unix_uid', 'username'
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

Describe -Tag:('JCUser') "Get-JCUser with new attributes 1.8.0" {

    $RandomString = (New-RandomString -NumberOfChars 8 ).ToLower()

    $UserWithAttributes = @{
        Username           = "$(New-RandomString -NumberOfChars 8)"
        FirstName          = "Delete"
        LastName           = "Me"
        Email              = "$(New-RandomString -NumberOfChars 8)@pleasedelete.me"
        MiddleName         = "middlename_$RandomString"
        displayName        = "displayname_$RandomString"
        jobTitle           = "jobTitle_$RandomString"
        employeeIdentifier = "employeeIdentifier_$RandomString"
        department         = "department_$RandomString"
        costCenter         = "costCenter_$RandomString"
        company            = "company_$RandomString"
        employeeType       = "employeeType_$RandomString"
        description        = "description_$RandomString"
        location           = "location_$RandomString"
    }

    New-JCUser @UserWithAttributes

    It "Searches for a user by middlename" {

        $Search = Get-JCUser -middlename "middlename_$RandomString" -returnProperties middlename
        $Search.middlename | Should -Be "middlename_$RandomString"

    }
    It "Searches for a user by displayname" {
        $Search = Get-JCUser -displayname "displayname_$RandomString" -returnProperties displayname
        $Search.displayname | Should -Be "displayname_$RandomString"
    }
    It "Searches for a user by jobTitle" {
        $Search = Get-JCUser -jobTitle "jobTitle_$RandomString" -returnProperties jobTitle
        $Search.jobTitle | Should -Be "jobTitle_$RandomString"
    }
    It "Searches for a user by employeeIdentifier" {
        $Search = Get-JCUser -employeeIdentifier "employeeIdentifier_$RandomString" -returnProperties employeeIdentifier
        $Search.employeeIdentifier | Should -Be "employeeIdentifier_$RandomString"
    }
    It "Searches for a user by department" {
        $Search = Get-JCUser -department "department_$RandomString" -returnProperties department
        $Search.department | Should -Be "department_$RandomString"
    }
    It "Searches for a user by costCenter" {
        $Search = Get-JCUser -costCenter "costCenter_$RandomString" -returnProperties costCenter
        $Search.costCenter | Should -Be "costCenter_$RandomString"
    }
    It "Searches for a user by company" {
        $Search = Get-JCUser -company "company_$RandomString" -returnProperties company
        $Search.company | Should -Be "company_$RandomString"
    }
    It "Searches for a user by employeeType" {
        $Search = Get-JCUser -employeeType "employeeType_$RandomString" -returnProperties employeeType
        $Search.employeeType | Should -Be "employeeType_$RandomString"
    }
    It "Searches for a user by description" {
        $Search = Get-JCUser -description "description_$RandomString" -returnProperties description
        $Search.description | Should -Be "description_$RandomString"
    }
    It "Searches for a user by location" {
        $Search = Get-JCUser -location "location_$RandomString" -returnProperties location
        $Search.location | Should -Be "location_$RandomString"
    }
}


Describe -Tag:('JCUser') "Get-JCUser 1.12" {


    It "Searches for a user by external_source_type" {

        $Newuser = New-RandomUser -domain "deleteme" | New-JCUser
        $Random1 = $(Get-Random)
        $Random2 = $(Get-Random)
        $SetUser = Set-JCUser -Username $Newuser.username -external_source_type "$Random1" -external_dn "$Random2"
        $SearchUser = Get-JCUser -external_source_type $Random1
        $RemoveUser = Remove-JCUser -UserID  $Newuser._id -force
        $SearchUser._id | Should -Be $Newuser._id

    }


    It "Searches for a user by external_dn" {

        $Newuser = New-RandomUser -domain "deleteme" | New-JCUser
        $Random1 = $(Get-Random)
        $Random2 = $(Get-Random)
        $SetUser = Set-JCUser -Username $Newuser.username -external_source_type "$Random1" -external_dn "$Random2"
        $SearchUser = Get-JCUser -external_source_type $Random1
        $RemoveUser = Remove-JCUser -UserID  $Newuser._id -force
        $SearchUser._id | Should -Be $Newuser._id

    }

    It "Searches for a user by external_dn and external_source_type" {

        $Newuser = New-RandomUser -domain "deleteme" | New-JCUser
        $Random1 = $(Get-Random)
        $Random2 = $(Get-Random)
        $SetUser = Set-JCUser -Username $Newuser.username -external_source_type "$Random1" -external_dn "$Random2"
        $SearchUser = Get-JCUser -external_source_type "$Random1" -external_dn "$Random2"
        $RemoveUser = Remove-JCUser -UserID  $Newuser._id -force
        $SearchUser._id | Should -Be $Newuser._id

    }

}
