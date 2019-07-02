Describe -Tag:('JCUser') 'New-JCUser 1.0' {
Connect-JCOnlineTest
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

        $NewUser.unix_uid | Should -be '1000000'
        $NewUser.unix_guid | Should -be '1000000'

        Remove-JCUser -UserID $NewUser._id -ByID -Force

    }

    It "Adds a JumpCloud user with password_never_expires false " {

        $ExpFalse = New-RandomUser -domain pleasedelete | New-JCUser -password_never_expires $false

        $ExpFalse.password_never_expires | Should Be $false

        Remove-JCUser -userID $ExpFalse._id -force

    }

    It "Adds a JumpCloud user with password_never_expires true " {

        $ExpTrue = New-RandomUser -domain pleasedelete | New-JCUser -password_never_expires $true

        $ExpTrue.password_never_expires | Should Be $true

        Remove-JCUser -userID $ExpTrue._id -force


    }

}

Describe -Tag:('JCUser') "New-JCUser 1.8.0" {

    It "Creates a user with the extended attributes" {

        $UserWithAttributes = @{
            Username           = "$(New-RandomString -NumberOfChars 8)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString -NumberOfChars 8)@pleasedelete.me"
            MiddleName         = 'middlename'
            displayName        = 'displayName'
            jobTitle           = 'jobTitle'
            employeeIdentifier = "employeeIdentifier_$(New-RandomString -NumberOfChars 8)"
            department         = 'department'
            costCenter         = 'costCenter'
            company            = 'company'
            employeeType       = 'employeeType'
            description        = 'description'
            location           = 'location'
        }

        $NewUser = New-JCUser @UserWithAttributes

        $NewUser.middlename | Should -Be "middleName"
        $NewUser.displayname | Should -Be "displayName"
        $NewUser.jobTitle | Should -Be "jobTitle"
        $NewUser.employeeIdentifier | Should -Match "employeeIdentifier"
        $NewUser.department | Should -Be "department"
        $NewUser.costCenter | Should -Be "costCenter"
        $NewUser.company | Should -be "Company"
        $NewUser.employeeType | Should -be "employeeType"
        $NewUser.description | Should -be "description"
        $NewUser.location | Should -be "location"

    }

    It "Creates a user with a work address using work city and state" {

        $UserWithWorkAddress = @{
            Username           = "$(New-RandomString -NumberOfChars 8)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString -NumberOfChars 8)@pleasedelete.me"
            work_streetAddress = "work_streetAddress"
            work_poBox         = "work_poBox"
            work_city          = "work_city"
            work_state         = "work_state"
            work_postalCode    = "work_postalCode"
            work_country       = "work_country"


        }

        $NewUser = New-JCUser @UserWithWorkAddress

        $NewUser.addresses.streetAddress | Should -Be "work_streetAddress"
        $NewUser.addresses.poBox | Should -Be "work_poBox"
        $NewUser.addresses.locality | Should -Be "work_city"
        $NewUser.addresses.region | Should -Be "work_state"
        $NewUser.addresses.postalCode | Should -Be "work_postalCode"
        $NewUser.addresses.country | Should -Be "work_country"

    }

    It "Creates a user with a work address using work locality and region" {

        $UserWithWorkAddress = @{
            Username           = "$(New-RandomString -NumberOfChars 8)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString -NumberOfChars 8)@pleasedelete.me"
            work_streetAddress = "work_streetAddress"
            work_poBox         = "work_poBox"
            work_locality      = "work_city"
            work_region        = "work_state"
            work_postalCode    = "work_postalCode"
            work_country       = "work_country"


        }

        $NewUser = New-JCUser @UserWithWorkAddress

        $NewUser.addresses.streetAddress | Should -Be "work_streetAddress"
        $NewUser.addresses.poBox | Should -Be "work_poBox"
        $NewUser.addresses.locality | Should -Be "work_city"
        $NewUser.addresses.region | Should -Be "work_state"
        $NewUser.addresses.postalCode | Should -Be "work_postalCode"
        $NewUser.addresses.country | Should -Be "work_country"

    }

    It "Creates a user with a home address using home locality and region" {

        $UserWithWorkAddress = @{
            Username           = "$(New-RandomString -NumberOfChars 8)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString -NumberOfChars 8)@pleasedelete.me"
            home_streetAddress = "home_streetAddress"
            home_poBox         = "home_poBox"
            home_locality      = "home_city"
            home_region        = "home_state"
            home_postalCode    = "home_postalCode"
            home_country       = "home_country"


        }

        $NewUser = New-JCUser @UserWithWorkAddress

        $NewUser.addresses.streetAddress | Should -Be "home_streetAddress"
        $NewUser.addresses.poBox | Should -Be "home_poBox"
        $NewUser.addresses.locality | Should -Be "home_city"
        $NewUser.addresses.region | Should -Be "home_state"
        $NewUser.addresses.postalCode | Should -Be "home_postalCode"
        $NewUser.addresses.country | Should -Be "home_country"

    }

    It "Creates a user with a home address using home city and state" {

        $UserWithWorkAddress = @{
            Username           = "$(New-RandomString -NumberOfChars 8)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString -NumberOfChars 8)@pleasedelete.me"
            home_streetAddress = "home_streetAddress"
            home_poBox         = "home_poBox"
            home_city          = "home_city"
            home_state         = "home_state"
            home_postalCode    = "home_postalCode"
            home_country       = "home_country"
        }

        $NewUser = New-JCUser @UserWithWorkAddress

        $NewUser.addresses.streetAddress | Should -Be "home_streetAddress"
        $NewUser.addresses.poBox | Should -Be "home_poBox"
        $NewUser.addresses.locality | Should -Be "home_city"
        $NewUser.addresses.region | Should -Be "home_state"
        $NewUser.addresses.postalCode | Should -Be "home_postalCode"
        $NewUser.addresses.country | Should -Be "home_country"
    }

    It "Creates a user with a home address and work address" {

        $UserWithHomeAndWorkAddress = @{
            Username           = "$(New-RandomString -NumberOfChars 8)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString -NumberOfChars 8)@pleasedelete.me"
            home_streetAddress = "home_streetAddress"
            home_poBox         = "home_poBox"
            home_city          = "home_city"
            home_state         = "home_state"
            home_postalCode    = "home_postalCode"
            home_country       = "home_country"
            work_streetAddress = "work_streetAddress"
            work_poBox         = "work_poBox"
            work_locality      = "work_city"
            work_region        = "work_state"
            work_postalCode    = "work_postalCode"
            work_country       = "work_country"
        }

        $NewUser = New-JCUser @UserWithHomeAndWorkAddress

        $NewUser.addresses | Where-Object type -eq work | Select-Object -ExpandProperty streetAddress | Should -Be "work_streetAddress"
        $NewUser.addresses | Where-Object type -eq work | Select-Object -ExpandProperty poBox | Should -Be "work_poBox"
        $NewUser.addresses | Where-Object type -eq work | Select-Object -ExpandProperty locality | Should -Be "work_city"
        $NewUser.addresses | Where-Object type -eq work | Select-Object -ExpandProperty region | Should -Be "work_state"
        $NewUser.addresses | Where-Object type -eq work | Select-Object -ExpandProperty postalCode | Should -Be "work_postalCode"
        $NewUser.addresses | Where-Object type -eq work | Select-Object -ExpandProperty country | Should -Be "work_country"

        $NewUser.addresses | Where-Object type -eq home | Select-Object -ExpandProperty streetAddress | Should -Be "home_streetAddress"
        $NewUser.addresses | Where-Object type -eq home | Select-Object -ExpandProperty poBox | Should -Be "home_poBox"
        $NewUser.addresses | Where-Object type -eq home | Select-Object -ExpandProperty locality | Should -Be "home_city"
        $NewUser.addresses | Where-Object type -eq home | Select-Object -ExpandProperty region | Should -Be "home_state"
        $NewUser.addresses | Where-Object type -eq home | Select-Object -ExpandProperty postalCode | Should -Be "home_postalCode"
        $NewUser.addresses | Where-Object type -eq home | Select-Object -ExpandProperty country | Should -Be "home_country"

    }

    It "Creates a user with a home address and work address and new user attributes" {

        $UserWithHomeAndWorkAddressAndAttributes = @{
            Username           = "$(New-RandomString -NumberOfChars 8)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString -NumberOfChars 8)@pleasedelete.me"
            MiddleName         = 'middlename'
            displayName        = 'displayName'
            jobTitle           = 'jobTitle'
            employeeIdentifier = "employeeIdentifier_$(New-RandomString -NumberOfChars 8)"
            department         = 'department'
            costCenter         = 'costCenter'
            company            = 'company'
            employeeType       = 'employeeType'
            description        = 'description'
            location           = 'location'
            home_streetAddress = "home_streetAddress"
            home_poBox         = "home_poBox"
            home_city          = "home_city"
            home_state         = "home_state"
            home_postalCode    = "home_postalCode"
            home_country       = "home_country"
            work_streetAddress = "work_streetAddress"
            work_poBox         = "work_poBox"
            work_locality      = "work_city"
            work_region        = "work_state"
            work_postalCode    = "work_postalCode"
            work_country       = "work_country"
        }

        $NewUser = New-JCUser @UserWithHomeAndWorkAddressAndAttributes

        $NewUser.middlename | Should -Be "middleName"
        $NewUser.displayname | Should -Be "displayName"
        $NewUser.jobTitle | Should -Be "jobTitle"
        $NewUser.employeeIdentifier | Should -Match "employeeIdentifier"
        $NewUser.department | Should -Be "department"
        $NewUser.costCenter | Should -Be "costCenter"
        $NewUser.company | Should -be "Company"
        $NewUser.employeeType | Should -be "employeeType"
        $NewUser.description | Should -be "description"
        $NewUser.location | Should -be "location"

        $NewUser.addresses | Where-Object type -eq work | Select-Object -ExpandProperty streetAddress | Should -Be "work_streetAddress"
        $NewUser.addresses | Where-Object type -eq work | Select-Object -ExpandProperty poBox | Should -Be "work_poBox"
        $NewUser.addresses | Where-Object type -eq work | Select-Object -ExpandProperty locality | Should -Be "work_city"
        $NewUser.addresses | Where-Object type -eq work | Select-Object -ExpandProperty region | Should -Be "work_state"
        $NewUser.addresses | Where-Object type -eq work | Select-Object -ExpandProperty postalCode | Should -Be "work_postalCode"
        $NewUser.addresses | Where-Object type -eq work | Select-Object -ExpandProperty country | Should -Be "work_country"

        $NewUser.addresses | Where-Object type -eq home | Select-Object -ExpandProperty streetAddress | Should -Be "home_streetAddress"
        $NewUser.addresses | Where-Object type -eq home | Select-Object -ExpandProperty poBox | Should -Be "home_poBox"
        $NewUser.addresses | Where-Object type -eq home | Select-Object -ExpandProperty locality | Should -Be "home_city"
        $NewUser.addresses | Where-Object type -eq home | Select-Object -ExpandProperty region | Should -Be "home_state"
        $NewUser.addresses | Where-Object type -eq home | Select-Object -ExpandProperty postalCode | Should -Be "home_postalCode"
        $NewUser.addresses | Where-Object type -eq home | Select-Object -ExpandProperty country | Should -Be "home_country"

    }

    It "Creates a user with mobile number" {

        $UserWithNumber = @{
            Username      = "$(New-RandomString -NumberOfChars 8)"
            FirstName     = "Delete"
            LastName      = "Me"
            Email         = "$(New-RandomString -NumberOfChars 8)@pleasedelete.me"
            mobile_number = "1234"
        }

        $NewUser = New-JCUser @UserWithNumber

        $NewUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -be "1234"

    }

    It "Creates a user with home number" {
        $UserWithNumber = @{
            Username    = "$(New-RandomString -NumberOfChars 8)"
            FirstName   = "Delete"
            LastName    = "Me"
            Email       = "$(New-RandomString -NumberOfChars 8)@pleasedelete.me"
            home_number = "1234"
        }

        $NewUser = New-JCUser @UserWithNumber

        $NewUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -be "1234"
    }

    It "Creates a user with work number" {
        $UserWithNumber = @{
            Username    = "$(New-RandomString -NumberOfChars 8)"
            FirstName   = "Delete"
            LastName    = "Me"
            Email       = "$(New-RandomString -NumberOfChars 8)@pleasedelete.me"
            work_number = "1234"
        }

        $NewUser = New-JCUser @UserWithNumber

        $NewUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -be "1234"
    }

    It "Creates a user with work mobile number" {
        $UserWithNumber = @{
            Username           = "$(New-RandomString -NumberOfChars 8)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString -NumberOfChars 8)@pleasedelete.me"
            work_mobile_number = "1234"
        }

        $NewUser = New-JCUser @UserWithNumber

        $NewUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -be "1234"
    }


    It "Creates a user with work fax number" {
        $UserWithNumber = @{
            Username        = "$(New-RandomString -NumberOfChars 8)"
            FirstName       = "Delete"
            LastName        = "Me"
            Email           = "$(New-RandomString -NumberOfChars 8)@pleasedelete.me"
            work_fax_number = "1234"
        }

        $NewUser = New-JCUser @UserWithNumber

        $NewUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -be "1234"
    }

    It "Creates a user with all numbers" {
        $UserWithNumbers = @{
            Username           = "$(New-RandomString -NumberOfChars 8)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString -NumberOfChars 8)@pleasedelete.me"
            mobile_number      = "mobile_number"
            home_number        = "home_number"
            work_number        = "work_number"
            work_mobile_number = "work_mobile_number"
            work_fax_number    = "work_fax_number"
        }

        $NewUser = New-JCUser @UserWithNumbers

        $NewUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -be "mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -be "home_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -be "work_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -be "work_mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -be "work_fax_number"
    }

    Get-JCUser | Where-Object Email -like *pleasedelete* | Remove-JCUser -force

}


Describe -Tag:('JCUser') "New-JCUser MFA with enrollment periods 1.10" {

    It "Creates a new user with enable_user_portal_multifactor -eq True" {


        $Newuser = New-RandomUser -domain "deleteme" | New-JCUser -enable_user_portal_multifactor $true

        $DateCheck = (Get-Date).AddDays(7).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfa.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfa.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 2

        $Newuser | Remove-JCUser -ByID -force

    }

    It "Creates a new user with enable_user_portal_multifactor -eq True and a 30 days specified for EnrollmentDays" {

        $EnrollmentDays = 30

        $Newuser = New-RandomUser -domain "deleteme" | New-JCUser -enable_user_portal_multifactor $true -EnrollmentDays $EnrollmentDays

        $DateCheck = (Get-Date).AddDays($EnrollmentDays).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfa.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfa.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 2

        $Newuser | Remove-JCUser -ByID -force

    }

    It "Creates a new user with enable_user_portal_multifactor -eq True and a 365 days specified for EnrollmentDays" {

        $EnrollmentDays = 365

        $Newuser = New-RandomUser -domain "deleteme" | New-JCUser -enable_user_portal_multifactor $true -EnrollmentDays $EnrollmentDays

        $DateCheck = (Get-Date).AddDays($EnrollmentDays).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfa.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfa.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 2

        $Newuser | Remove-JCUser -ByID -force

    }


    It "Creates a new user with enable_user_portal_multifactor -eq True with Attributes" {

        $NewUser = New-RandomUser -domain "deleteme"-Attributes | New-JCUser -NumberOfCustomAttributes 2 -enable_user_portal_multifactor $True

        $DateCheck = (Get-Date).AddDays(7).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfa.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfa.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 2

        $Newuser | Remove-JCUser -ByID -force

    }

    It "Creates a new user with enable_user_portal_multifactor -eq True and a 30 days specified for EnrollmentDays with Attributes" {

        $EnrollmentDays = 30

        $NewUser = New-RandomUser -domain "deleteme"-Attributes | New-JCUser -NumberOfCustomAttributes 2 -enable_user_portal_multifactor $True -EnrollmentDays $EnrollmentDays

        $DateCheck = (Get-Date).AddDays($EnrollmentDays).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfa.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfa.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 2

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

        $NewUser = $newUserObj | % { New-JCUser -enable_user_portal_multifactor $_.enable_user_portal_multifactor -EnrollmentDays $_.EnrollmentDays -firstName $_.firstName -lastName $_.Lastname -username $_.username -email $_.email }

        $DateCheck = (Get-Date).AddDays($EnrollmentDays).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfa.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfa.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 2

        $Newuser | Remove-JCUser -ByID -force

    }

}
