Describe -Tag:('JCUser') 'New-JCUser 1.0' {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null }
    It "Creates a new user" {
        $NewUser = New-RandomUser -domain pleasedelete"PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $NewUser._id.count | Should -Be 1
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User allow_public_key -eq True " {
        $NewUser = New-RandomUser -domain pleasedelete"PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -allow_public_key $true
        $NewUser.allow_public_key | Should -Be True
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User allow_public_key -eq False " {
        $NewUser = New-RandomUser -domain pleasedelete"PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -allow_public_key $false
        $NewUser.allow_public_key | Should -Be False
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User sudo -eq True " {
        $NewUser = New-RandomUser -domain pleasedelete"PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -sudo $true
        $NewUser.sudo | Should -Be True
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User sudo -eq False " {
        $NewUser = New-RandomUser -domain pleasedelete"PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -sudo $false
        $NewUser.sudo | Should -Be False
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User enable_managed_uid -eq True " {
        $NewUser = New-RandomUser -domain pleasedelete"PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -enable_managed_uid $true -unix_uid 1 -unix_guid 1
        $NewUser.enable_managed_uid | Should -Be True
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User enable_managed_uid -eq False " {
        $NewUser = New-RandomUser -domain pleasedelete"PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -enable_managed_uid $false
        $NewUser.enable_managed_uid | Should -Be False
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User passwordless_sudo -eq True " {
        $NewUser = New-RandomUser -domain pleasedelete"PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -passwordless_sudo $true
        $NewUser.passwordless_sudo | Should -Be True
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User passwordless_sudo -eq False " {
        $NewUser = New-RandomUser -domain pleasedelete"PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -passwordless_sudo $false
        $NewUser.passwordless_sudo | Should -Be False
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }


    It "Creates a new User ldap_binding_user -eq True " {
        $NewUser = New-RandomUser -domain pleasedelete"PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -ldap_binding_user $true
        $NewUser.ldap_binding_user | Should -Be True
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User ldap_binding_user -eq False " {
        $NewUser = New-RandomUser -domain pleasedelete"PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -ldap_binding_user $false
        $NewUser.ldap_binding_user | Should -Be False
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User enable_user_portal_multifactor -eq True " {
        $NewUser = New-RandomUser -domain pleasedelete"PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -enable_user_portal_multifactor $true
        $NewUser.enable_user_portal_multifactor | Should -Be True
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User enable_user_portal_multifactor -eq False " {
        $NewUser = New-RandomUser -domain pleasedelete"PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -enable_user_portal_multifactor $false
        $NewUser.enable_user_portal_multifactor | Should -Be False
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User sets unix_uid" {
        $NewUser = New-RandomUser -domain pleasedelete"PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -unix_uid 100
        $NewUser.unix_uid | Should -Be 100
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User sets unix_guid" {
        $NewUser = New-RandomUser -domain pleasedelete"PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -unix_guid 100
        $NewUser.unix_guid | Should -Be 100
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }
    It "Creates a new User sets manager" {
        $managerID = $PesterParams_User1.id
        $NewUser = New-RandomUser -domain pleasedelete"PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser -manager $managerID
        $NewUser.manager | Should -Be $managerID
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }
    It "Creates a new User sets managerUsername" {
        $managerUsername = $PesterParams_User1.username
        $managerID = $PesterParams_User1.id
        $NewUser = New-RandomUser -domain pleasedelete"PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser -manager $managerUsername
        $NewUser.manager | Should -Be $managerID
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }
    It "Creates a new User sets alternateEmail" {
        # TODO: fix function 
        $alternateEmail = "$($RandomString1)1@DeleteMe.com"
        $NewUser = New-RandomUser -domain pleasedelete"PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser -alternateEmail $alternateEmail
        $NewUser.alternateEmail | Should -Be $alternateEmail
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }
    It "Creates a new User sets managedAppleID" {
        $managedAppleID = "$($RandomString1)1@DeleteMe.com"
        $NewUser = New-RandomUser -domain pleasedelete"PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser -managedAppleID $managedAppleID
        $NewUser.managedAppleID | Should -Be $managedAppleID
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


Describe -Tag:('JCUser') 'Add-JCUser 1.3.0' {
    #Linux UID, GUID
    It "Adds a JumpCloud user with a high UID and GUID" {

        $NewUser = New-RandomUser -domain pleasedelete | New-JCUser -unix_uid 1000000 -unix_guid 1000000

        $NewUser.unix_uid | Should -Be '1000000'
        $NewUser.unix_guid | Should -Be '1000000'

        Remove-JCUser -UserID $NewUser._id -ByID -Force

    }

    It "Adds a JumpCloud user with password_never_expires false " {

        $ExpFalse = New-RandomUser -domain pleasedelete | New-JCUser -password_never_expires $false

        $ExpFalse.password_never_expires | Should -Be $false

        Remove-JCUser -userID $ExpFalse._id -force

    }

    It "Adds a JumpCloud user with password_never_expires true " {

        $ExpTrue = New-RandomUser -domain pleasedelete | New-JCUser -password_never_expires $true

        $ExpTrue.password_never_expires | Should -Be $true

        Remove-JCUser -userID $ExpTrue._id -force


    }

}

Describe -Tag:('JCUser') "New-JCUser 1.8.0" {

    It "Creates a user with the extended attributes" {

        $PesterParams_NewUser1.middlename | Should -Be $PesterParams_User1.middlename
        $PesterParams_NewUser1.displayname | Should -Be $PesterParams_User1.displayName
        $PesterParams_NewUser1.jobTitle | Should -Be $PesterParams_User1.jobTitle
        $PesterParams_NewUser1.employeeIdentifier | Should -Match $PesterParams_User1.employeeIdentifier
        $PesterParams_NewUser1.department | Should -Be $PesterParams_User1.department
        $PesterParams_NewUser1.costCenter | Should -Be $PesterParams_User1.costCenter
        $PesterParams_NewUser1.company | Should -Be $PesterParams_User1.Company
        $PesterParams_NewUser1.employeeType | Should -Be $PesterParams_User1.employeeType
        $PesterParams_NewUser1.description | Should -Be $PesterParams_User1.description
        $PesterParams_NewUser1.location | Should -Be $PesterParams_User1.location
        $PesterParams_NewUser1.alternateEmail | Should -Be $PesterParams_User1.alternateEmail
        $PesterParams_NewUser1.managedAppleID | Should -Be $PesterParams_User1.managedAppleID

    }

    It "Creates a user with a work address using work city and state" {

        $PesterParams_NewUser1.addresses.streetAddress | Should -Be $PesterParams_User1.work_streetAddress
        $PesterParams_NewUser1.addresses.poBox | Should -Be $PesterParams_User1.work_poBox
        $PesterParams_NewUser1.addresses.locality | Should -Be $PesterParams_User1.work_city
        $PesterParams_NewUser1.addresses.region | Should -Be $PesterParams_User1.work_state
        $PesterParams_NewUser1.addresses.postalCode | Should -Be $PesterParams_User1.work_postalCode
        $PesterParams_NewUser1.addresses.country | Should -Be $PesterParams_User1.work_country

    }

    It "Creates a user with a work address using work locality and region" {

        $PesterParams_NewUser1.addresses.streetAddress | Should -Be $PesterParams_User1.work_streetAddress
        $PesterParams_NewUser1.addresses.poBox | Should -Be $PesterParams_User1.work_poBox
        $PesterParams_NewUser1.addresses.locality | Should -Be $PesterParams_User1.work_city
        $PesterParams_NewUser1.addresses.region | Should -Be $PesterParams_User1.work_state
        $PesterParams_NewUser1.addresses.postalCode | Should -Be $PesterParams_User1.work_postalCode
        $PesterParams_NewUser1.addresses.country | Should -Be $PesterParams_User1.work_country

    }

    It "Creates a user with a home address using home locality and region" {

        $PesterParams_NewUser1.addresses.streetAddress | Should -Be $PesterParams_User1.home_streetAddress
        $PesterParams_NewUser1.addresses.poBox | Should -Be $PesterParams_User1.home_poBox
        $PesterParams_NewUser1.addresses.locality | Should -Be $PesterParams_User1.home_city
        $PesterParams_NewUser1.addresses.region | Should -Be $PesterParams_User1.home_state
        $PesterParams_NewUser1.addresses.postalCode | Should -Be $PesterParams_User1.home_postalCode
        $PesterParams_NewUser1.addresses.country | Should -Be $PesterParams_User1.home_country

    }

    It "Creates a user with a home address using home city and state" {
        $PesterParams_NewUser1.addresses.streetAddress | Should -Be $PesterParams_User1.home_streetAddress
        $PesterParams_NewUser1.addresses.poBox | Should -Be $PesterParams_User1.home_poBox
        $PesterParams_NewUser1.addresses.locality | Should -Be $PesterParams_User1.home_city
        $PesterParams_NewUser1.addresses.region | Should -Be $PesterParams_User1.home_state
        $PesterParams_NewUser1.addresses.postalCode | Should -Be $PesterParams_User1.home_postalCode
        $PesterParams_NewUser1.addresses.country | Should -Be $PesterParams_User1.home_country
    }

    It "Creates a user with a home address and work address" {

        $PesterParams_NewUser1.addresses | Where-Object type -eq work | Select-Object -ExpandProperty streetAddress | Should -Be $PesterParams_User1.work_streetAddress
        $PesterParams_NewUser1.addresses | Where-Object type -eq work | Select-Object -ExpandProperty poBox | Should -Be $PesterParams_User1.work_poBox
        $PesterParams_NewUser1.addresses | Where-Object type -eq work | Select-Object -ExpandProperty locality | Should -Be $PesterParams_User1.work_city
        $PesterParams_NewUser1.addresses | Where-Object type -eq work | Select-Object -ExpandProperty region | Should -Be $PesterParams_User1.work_state
        $PesterParams_NewUser1.addresses | Where-Object type -eq work | Select-Object -ExpandProperty postalCode | Should -Be $PesterParams_User1.work_postalCode
        $PesterParams_NewUser1.addresses | Where-Object type -eq work | Select-Object -ExpandProperty country | Should -Be $PesterParams_User1.work_country

        $PesterParams_NewUser1.addresses | Where-Object type -eq home | Select-Object -ExpandProperty streetAddress | Should -Be $PesterParams_User1.home_streetAddress
        $PesterParams_NewUser1.addresses | Where-Object type -eq home | Select-Object -ExpandProperty poBox | Should -Be $PesterParams_User1.home_poBox
        $PesterParams_NewUser1.addresses | Where-Object type -eq home | Select-Object -ExpandProperty locality | Should -Be $PesterParams_User1.home_city
        $PesterParams_NewUser1.addresses | Where-Object type -eq home | Select-Object -ExpandProperty region | Should -Be $PesterParams_User1.home_state
        $PesterParams_NewUser1.addresses | Where-Object type -eq home | Select-Object -ExpandProperty postalCode | Should -Be $PesterParams_User1.home_postalCode
        $PesterParams_NewUser1.addresses | Where-Object type -eq home | Select-Object -ExpandProperty country | Should -Be $PesterParams_User1.home_country

    }

    It "Creates a user with a home address and work address and new user attributes" {
        $PesterParams_NewUser1.middlename | Should -Be $PesterParams_User1.middleName
        $PesterParams_NewUser1.displayname | Should -Be $PesterParams_User1.displayName
        $PesterParams_NewUser1.jobTitle | Should -Be $PesterParams_User1.jobTitle
        $PesterParams_NewUser1.employeeIdentifier | Should -Be $PesterParams_User1.employeeIdentifier
        $PesterParams_NewUser1.department | Should -Be $PesterParams_User1.department
        $PesterParams_NewUser1.costCenter | Should -Be $PesterParams_User1.costCenter
        $PesterParams_NewUser1.company | Should -Be $PesterParams_User1.Company
        $PesterParams_NewUser1.employeeType | Should -Be $PesterParams_User1.employeeType
        $PesterParams_NewUser1.description | Should -Be $PesterParams_User1.description
        $PesterParams_NewUser1.location | Should -Be $PesterParams_User1.location

        $PesterParams_NewUser1.addresses | Where-Object type -eq work | Select-Object -ExpandProperty streetAddress | Should -Be $PesterParams_User1.work_streetAddress
        $PesterParams_NewUser1.addresses | Where-Object type -eq work | Select-Object -ExpandProperty poBox | Should -Be $PesterParams_User1.work_poBox
        $PesterParams_NewUser1.addresses | Where-Object type -eq work | Select-Object -ExpandProperty locality | Should -Be $PesterParams_User1.work_city
        $PesterParams_NewUser1.addresses | Where-Object type -eq work | Select-Object -ExpandProperty region | Should -Be $PesterParams_User1.work_state
        $PesterParams_NewUser1.addresses | Where-Object type -eq work | Select-Object -ExpandProperty postalCode | Should -Be $PesterParams_User1.work_postalCode
        $PesterParams_NewUser1.addresses | Where-Object type -eq work | Select-Object -ExpandProperty country | Should -Be $PesterParams_User1.work_country

        $PesterParams_NewUser1.addresses | Where-Object type -eq home | Select-Object -ExpandProperty streetAddress | Should -Be $PesterParams_User1.home_streetAddress
        $PesterParams_NewUser1.addresses | Where-Object type -eq home | Select-Object -ExpandProperty poBox | Should -Be $PesterParams_User1.home_poBox
        $PesterParams_NewUser1.addresses | Where-Object type -eq home | Select-Object -ExpandProperty locality | Should -Be $PesterParams_User1.home_city
        $PesterParams_NewUser1.addresses | Where-Object type -eq home | Select-Object -ExpandProperty region | Should -Be $PesterParams_User1.home_state
        $PesterParams_NewUser1.addresses | Where-Object type -eq home | Select-Object -ExpandProperty postalCode | Should -Be $PesterParams_User1.home_postalCode
        $PesterParams_NewUser1.addresses | Where-Object type -eq home | Select-Object -ExpandProperty country | Should -Be $PesterParams_User1.home_country

    }

    It "Creates a user with mobile number" {
        $PesterParams_NewUser1.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -Be $PesterParams_User1.mobile_number

    }

    It "Creates a user with home number" {
        $PesterParams_NewUser1.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -Be $PesterParams_User1.home_number
    }

    It "Creates a user with work number" {
        $PesterParams_NewUser1.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -Be $PesterParams_User1.work_number
    }

    It "Creates a user with work mobile number" {
        $PesterParams_NewUser1.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -Be $PesterParams_User1.work_mobile
    }


    It "Creates a user with work fax number" {
        $PesterParams_NewUser1.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -Be $PesterParams_User1.work_fax
    }

    It "Creates a user with all numbers" {
        $PesterParams_NewUser1.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -Be $PesterParams_User1.mobile_number
        $PesterParams_NewUser1.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -Be $PesterParams_User1.home_number
        $PesterParams_NewUser1.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -Be $PesterParams_User1.work_number
        $PesterParams_NewUser1.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -Be $PesterParams_User1.work_mobile_number
        $PesterParams_NewUser1.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -Be $PesterParams_User1.work_fax_number
    }

    It "Removes users Where-Object Email -like *pleasedelete* " {
        Get-JCUser | Where-Object Email -like *pleasedelete* | Remove-JCUser -force
    }
}


Describe -Tag:('JCUser') "New-JCUser MFA with enrollment periods 1.10" {

    It "Creates a new user with enable_user_portal_multifactor -eq True" {


        $Newuser = New-RandomUser -domain "deleteme" | New-JCUser -enable_user_portal_multifactor $true

        $Newuser.mfa.exclusion | Should -Be $true

        $Newuser | Remove-JCUser -ByID -force

    }

    It "Creates a new user with enable_user_portal_multifactor -eq True and a 30 days specified for EnrollmentDays" {

        $EnrollmentDays = 30

        $Newuser = New-RandomUser -domain "deleteme" | New-JCUser -enable_user_portal_multifactor $true -EnrollmentDays $EnrollmentDays

        $Newuser.mfa.exclusion | Should -Be $true

        $Newuser | Remove-JCUser -ByID -force

    }

    It "Creates a new user with enable_user_portal_multifactor -eq True and a 365 days specified for EnrollmentDays" {

        $EnrollmentDays = 365

        $Newuser = New-RandomUser -domain "deleteme" | New-JCUser -enable_user_portal_multifactor $true -EnrollmentDays $EnrollmentDays

        $Newuser.mfa.exclusion | Should -Be $true

        $Newuser | Remove-JCUser -ByID -force

    }


    It "Creates a new user with enable_user_portal_multifactor -eq True with Attributes" {

        $NewUser = New-RandomUser -domain "deleteme"-Attributes | New-JCUser -NumberOfCustomAttributes 2 -enable_user_portal_multifactor $True

        $Newuser.mfa.exclusion | Should -Be $true

        $Newuser | Remove-JCUser -ByID -force

    }

    It "Creates a new user with enable_user_portal_multifactor -eq True and a 30 days specified for EnrollmentDays with Attributes" {

        $EnrollmentDays = 30

        $NewUser = New-RandomUser -domain "deleteme"-Attributes | New-JCUser -NumberOfCustomAttributes 2 -enable_user_portal_multifactor $True -EnrollmentDays $EnrollmentDays

        $Newuser.mfa.exclusion | Should -Be $true

        $Newuser | Remove-JCUser -ByID -force

    }

    It "Creates a new user with enable_user_portal_multifactor -eq True and a 30 days via the pipeline" {

        $EnrollmentDays = 30

        $objectProperty = [ordered]@{

            Username                       = "delete.$(Get-Random)"
            Email                          = "delete.$(Get-Random)@deleteme.com"
            Firstname                      = "First"
            Lastname                       = "Last"
            enable_user_portal_multifactor = $true
            EnrollmentDays                 = $EnrollmentDays

        }

        $newUserObj = New-Object -TypeName psobject -Property $objectProperty

        $NewUser = $newUserObj | ForEach-Object { New-JCUser -enable_user_portal_multifactor $_.enable_user_portal_multifactor -EnrollmentDays $_.EnrollmentDays -firstName $_.firstName -lastName $_.Lastname -username $_.username -email $_.email }

        $Newuser.mfa.exclusion | Should -Be $true

        $Newuser | Remove-JCUser -ByID -force

    }

}

Describe -Tag:('JCUser') "New-JCUser with suspend param 1.15" {

    It "Creates a new User suspended -eq True " {
        $NewUser = New-RandomUser -domain pleasedelete"PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -suspended $true
        $NewUser.suspended | Should -Be True
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

}
