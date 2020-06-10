Describe -Tag:('JCUser') 'Set-JCUser 1.0' {
    BeforeAll {
        Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null
        $RandomString = ( -join (( 0x41..0x5A) + ( 0x61..0x7A) | Get-Random -Count 8 | ForEach-Object { [char]$_ }))
        $RandomEmail = '{0}@{1}.com' -f $RandomString, $RandomString
    }
    It "Updates the FirstName using -ByID and -UserID" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $NewFirstName = Set-JCUser -ByID -UserID $NewUser._id -firstname 'NewFirstName'
        $NewFirstName.firstname | Should -Be 'NewFirstName'
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates the FirstName using -Username" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $NewFirstName = Set-JCUser -Username $NewUser.Username -firstname 'NewFirstName'
        $NewFirstName.firstname | Should -Be 'NewFirstName'
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates the LastName using -ByID and -UserID" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Newlastname = Set-JCUser -ByID -UserID $NewUser._id -lastname 'NewLastName'
        $Newlastname.lastname | Should -Be 'NewLastName'
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates the LastName using -Username" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Newlastname = Set-JCUser -Username $NewUser.Username -lastname 'NewLastName'
        $Newlastname.lastname | Should -Be 'NewLastName'
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates the email using -ByID and -UserID" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Newemail = Set-JCUser -ByID -UserID $NewUser._id -email $RandomEmail
        $Newemail.email | Should -Be $RandomEmail
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates the email using -Username" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Newemail = Set-JCUser -Username $NewUser.Username -email $RandomEmail
        $Newemail.email | Should -Be $RandomEmail
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates the password using -ByID and -UserID" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        { Set-JCUser -ByID -UserID $NewUser._id -password 'Temp123!' } | Should -Not -Throw
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates the password using -Username" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        { Set-JCUser -Username $NewUser.Username -password 'Temp123!' } | Should -Not -Throw
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates a User allow_public_key -eq True using -ByID and -UserID" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Update = Set-JCUser -ByID -UserID $NewUser._id -allow_public_key $true
        $Update.allow_public_key | Should -Be True
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates a User allow_public_key -eq False using -ByID and -UserID" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Update = Set-JCUser -ByID -UserID $NewUser._id -allow_public_key $false
        $Update.allow_public_key | Should -Be False
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates a User allow_public_key -eq True using -Username" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Update = Set-JCUser -Username $NewUser.Username -allow_public_key $true
        $Update.allow_public_key | Should -Be True
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates a User allow_public_key -eq False using -Username" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Update = Set-JCUser -Username $NewUser.Username -allow_public_key $false
        $Update.allow_public_key | Should -Be False
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates a User sudo -eq True using -ByID and -UserID" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Update = Set-JCUser -ByID -UserID $NewUser._id -sudo $true
        $Update.sudo | Should -Be True
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates a User sudo -eq False using -ByID and -UserID" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Update = Set-JCUser -ByID -UserID $NewUser._id -sudo $false
        $Update.sudo | Should -Be False
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates a User sudo -eq True using -Username" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Update = Set-JCUser -Username $NewUser.Username -sudo $true
        $Update.sudo | Should -Be True
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates a User sudo -eq False using -Username" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Update = Set-JCUser -Username $NewUser.Username -sudo $false
        $Update.sudo | Should -Be False
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates a User enable_managed_uid -eq True using -ByID and -UserID" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Update = Set-JCUser -ByID -UserID $NewUser._id -enable_managed_uid $true
        $Update.enable_managed_uid | Should -Be True
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates a User enable_managed_uid -eq False using -ByID and -UserID" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Update = Set-JCUser -ByID -UserID $NewUser._id -enable_managed_uid $false
        $Update.enable_managed_uid | Should -Be False
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates a User enable_managed_uid -eq True using -Username" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Update = Set-JCUser -Username $NewUser.Username -enable_managed_uid $true
        $Update.enable_managed_uid | Should -Be True
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates a User enable_managed_uid -eq False using -Username" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Update = Set-JCUser -Username $NewUser.Username -enable_managed_uid $false
        $Update.enable_managed_uid | Should -Be False
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates a User account_locked -eq True using -ByID and -UserID" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Update = Set-JCUser -ByID -UserID $NewUser._id -account_locked $true
        $Update.account_locked | Should -Be True
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates a User account_locked -eq False using -ByID and -UserID" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Update = Set-JCUser -ByID -UserID $NewUser._id -account_locked $false
        $Update.account_locked | Should -Be False
    }
    It "Updates a User account_locked -eq True using -Username" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Update = Set-JCUser -Username $NewUser.Username -account_locked $true
        $Update.account_locked | Should -Be True
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates a User account_locked -eq False using -Username" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Update = Set-JCUser -Username $NewUser.Username -account_locked $false
        $Update.account_locked | Should -Be False
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates a User passwordless_sudo -eq True using -ByID and -UserID" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Update = Set-JCUser -ByID -UserID $NewUser._id -passwordless_sudo $true
        $Update.passwordless_sudo | Should -Be True
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates a User passwordless_sudo -eq False using -ByID and -UserID" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Update = Set-JCUser -ByID -UserID $NewUser._id -passwordless_sudo $false
        $Update.passwordless_sudo | Should -Be False
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates a User passwordless_sudo -eq True using -Username" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Update = Set-JCUser -Username $NewUser.Username -passwordless_sudo $true
        $Update.passwordless_sudo | Should -Be True
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates a User passwordless_sudo -eq False using -Username" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Update = Set-JCUser -Username $NewUser.Username -passwordless_sudo $false
        $Update.passwordless_sudo | Should -Be False
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates a User externally_managed -eq True using -ByID and -UserID" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Update = Set-JCUser -ByID -UserID $NewUser._id -externally_managed $true
        $Update.externally_managed | Should -Be True
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates a User externally_managed -eq False using -ByID and -UserID" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Update = Set-JCUser -ByID -UserID $NewUser._id -externally_managed $false
        $Update.externally_managed | Should -Be False
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates a User externally_managed -eq True using -Username" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Update = Set-JCUser -Username $NewUser.Username -externally_managed $true
        $Update.externally_managed | Should -Be True
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates a User externally_managed -eq False using -Username" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Update = Set-JCUser -Username $NewUser.Username -externally_managed $false
        $Update.externally_managed | Should -Be False
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates a User ldap_binding_user -eq True using -ByID and -UserID" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Update = Set-JCUser -ByID -UserID $NewUser._id -ldap_binding_user $true
        $Update.ldap_binding_user | Should -Be True
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates a User ldap_binding_user -eq False using -ByID and -UserID" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Update = Set-JCUser -ByID -UserID $NewUser._id -ldap_binding_user $false
        $Update.ldap_binding_user | Should -Be False
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates a User ldap_binding_user -eq True using -Username" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Update = Set-JCUser -Username $NewUser.Username -ldap_binding_user $true
        $Update.ldap_binding_user | Should -Be True
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates a User ldap_binding_user -eq False using -Username" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Update = Set-JCUser -Username $NewUser.Username -ldap_binding_user $false
        $Update.ldap_binding_user | Should -Be False
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates a User enable_user_portal_multifactor -eq True using -ByID and -UserID" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Update = Set-JCUser -ByID -UserID $NewUser._id -enable_user_portal_multifactor $true
        $Update.enable_user_portal_multifactor | Should -Be True
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates a User enable_user_portal_multifactor -eq False using -ByID and -UserID" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Update = Set-JCUser -ByID -UserID $NewUser._id -enable_user_portal_multifactor $false
        $Update.enable_user_portal_multifactor | Should -Be False
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates a User enable_user_portal_multifactor -eq True using -Username" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Update = Set-JCUser -Username $NewUser.Username -enable_user_portal_multifactor $true
        $Update.enable_user_portal_multifactor | Should -Be True
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates a User enable_user_portal_multifactor -eq False using -Username" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $Update = Set-JCUser -Username $NewUser.Username -enable_user_portal_multifactor $false
        $Update.enable_user_portal_multifactor | Should -Be False
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates the unix_uid using -ByID and -UserID" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $100 = Set-JCUser -ByID -UserID $NewUser._id -unix_uid '100'
        $100.unix_uid | Should -Be '100'
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates the unix_uid using -Username" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $100 = Set-JCUser -Username $NewUser.Username -unix_uid '100'
        $100.unix_uid | Should -Be '100'
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates the unix_guid using -ByID and -UserID" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $100 = Set-JCUser -ByID -UserID $NewUser._id -unix_guid '100'
        $100.unix_guid | Should -Be '100'
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Updates the unix_guid using -Username" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $100 = Set-JCUser -Username $NewUser.Username -unix_guid '100'
        $100.unix_guid | Should -Be '100'
        Remove-JCUser -UserID $NewUser._id -force
    }
}
Describe -Tag:('JCUser') "Set-JCUser - CustomAttributes 1.0" {
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
        $match | Should -Be $true
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
        $match | Should -Be $true
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
        $match | Should -Be $true
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }
}
Describe -Tag:('JCUser') 'Set-JCUser 1.3.0' {
    # Linux UID, GUID
    It "Updates the UID and GUID to 2000000" {
        $RandomUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $SetUser = Set-JCUser -Username $RandomUser.username -unix_uid 2000000 -unix_guid 2000000
        $SetUser.unix_guid | Should -Be 2000000
        $SetUser.unix_uid | Should -Be 2000000
        Remove-JCUser -UserID $RandomUser._id -ByID -Force
    }
    It "Updates a JumpCloud user to password_never_expires false " {
        $ExpTrue = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser -password_never_expires $true
        $SetFalse = $ExpTrue | Set-JCUser -password_never_expires $false
        $SetFalse.password_never_expires | Should -Be $false
        Remove-JCUser -UserID $ExpTrue._id -ByID -Force
    }
    It "Updates a JumpCloud user to password_never_expires true " {
        $ExpFalse = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser -password_never_expires $false
        $SetTrue = $ExpFalse | Set-JCUser -password_never_expires $True
        $SetTrue.password_never_expires | Should -Be $true
        Remove-JCUser -UserID $SetTrue._id -ByID -Force
    }
}
Describe -Tag:('JCUser') "Set-JCUser 1.8.0" {
    It "Updates a users middle name" {
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
        };
        $NewUser = New-JCUser @UserWithAttributes
        $SetUser = Set-JCUser -Username $NewUser.username -middlename "new_middle_name"
        $SetUser.middlename | Should -Be "new_middle_name"
    }
    It "Updates a users displayName" {
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
        $SetUser = Set-JCUser -Username $NewUser.username -displayname "new_displayName"
        $SetUser.displayname | Should -Be "new_displayName"
    }
    It "Updates a users jobTitle" {
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
        $SetUser = Set-JCUser -Username $NewUser.username -jobTitle "new_jobTitle"
        $SetUser.jobTitle | Should -Be "new_jobTitle"
    }
    It "Updates a users employeeIdentifier" {
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
        $SetUser = Set-JCUser -Username $NewUser.username -employeeIdentifier "new_employeeIdentifier_$(New-RandomString -NumberOfChars 8)"
        $SetUser.employeeIdentifier | Should -Match "new_employeeIdentifier"
    }
    It "Updates a users department" {
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
        $SetUser = Set-JCUser -Username $NewUser.username -department "new_department"
        $SetUser.department | Should -Be "new_department"
    }
    It "Updates a users costCenter" {
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
        $SetUser = Set-JCUser -Username $NewUser.username -costCenter "new_costCenter"
        $SetUser.costCenter | Should -Be "new_costCenter"
    }
    It "Updates a users company" {
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
        $SetUser = Set-JCUser -Username $NewUser.username -company "new_company"
        $SetUser.company | Should -Be "new_company"
    }
    It "Updates a users employeeType" {
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
        $SetUser = Set-JCUser -Username $NewUser.username -employeeType "new_employeeType"
        $SetUser.employeeType | Should -Be "new_employeeType"
    }
    It "Updates a users description" {
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
        $SetUser = Set-JCUser -Username $NewUser.username -description "new_description"
        $SetUser.description | Should -Be "new_description"
    }
    It "Updates a users location" {
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
        $SetUser = Set-JCUser -Username $NewUser.username -location "new_location"
        $SetUser.location | Should -Be "new_location"
    }
    It "Updates a users middle name using userID" {
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
        $SetUser = Set-JCUser -UserID $NewUser._id -middlename "new_middle_name"
        $SetUser.middlename | Should -Be "new_middle_name"
    }
    It "Updates a users displayName using userID" {
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
        $SetUser = Set-JCUser -UserID $NewUser._id -displayname "new_displayName"
        $SetUser.displayname | Should -Be "new_displayName"
    }
    It "Updates a users jobTitle using userID" {
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
        $SetUser = Set-JCUser -UserID $NewUser._id -jobTitle "new_jobTitle"
        $SetUser.jobTitle | Should -Be "new_jobTitle"
    }
    It "Updates a users employeeIdentifier using userID" {
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
        $SetUser = Set-JCUser -UserID $NewUser._id -employeeIdentifier "new_employeeIdentifier_$(New-RandomString -NumberOfChars 8)"
        $SetUser.employeeIdentifier | Should -Match "new_employeeIdentifier"
    }
    It "Updates a users department using userID" {
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
        $SetUser = Set-JCUser -UserID $NewUser._id -department "new_department"
        $SetUser.department | Should -Be "new_department"
    }
    It "Updates a users costCenter using userID" {
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
        $SetUser = Set-JCUser -UserID $NewUser._id -costCenter "new_costCenter"
        $SetUser.costCenter | Should -Be "new_costCenter"
    }
    It "Updates a users company using userID" {
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
        $SetUser = Set-JCUser -UserID $NewUser._id -company "new_company"
        $SetUser.company | Should -Be "new_company"
    }
    It "Updates a users employeeType using userID" {
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
        $SetUser = Set-JCUser -UserID $NewUser._id -employeeType "new_employeeType"
        $SetUser.employeeType | Should -Be "new_employeeType"
    }
    It "Updates a users description using userID" {
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
        $SetUser = Set-JCUser -UserID $NewUser._id -description "new_description"
        $SetUser.description | Should -Be "new_description"
    }
    It "Updates a users location using userID" {
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
        $SetUser = Set-JCUser -UserID $NewUser._id -location "new_location"
        $SetUser.location | Should -Be "new_location"
    }
    It "Removes users Where-Object Email -like *pleasedelete* " {
        Get-JCUser | Where-Object Email -like *pleasedelete* | Remove-JCUser -force
    }
}
Describe -Tag:('JCUser') "Set-JCUser addresses 1.8.0" {
    It "Updates a users work address" {
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
        $SetUser = Set-JCUser -Username $NewUser.username -work_streetAddress "new_workStreetAddress"
        $SetUser.addresses | Where-Object type -EQ work | Select-Object -ExpandProperty streetAddress | Should -Be "new_workStreetAddress"
        $SetUser = Set-JCUser -Username $NewUser.username -work_poBox "new_work_poBox"
        $SetUser.addresses | Where-Object type -EQ work | Select-Object -ExpandProperty poBox | Should -Be "new_work_poBox"
        $SetUser = Set-JCUser -Username $NewUser.username -work_city "new_work_city"
        $SetUser.addresses | Where-Object type -EQ work | Select-Object -ExpandProperty locality | Should -Be "new_work_city"
        $SetUser = Set-JCUser -Username $NewUser.username -work_state "new_work_state"
        $SetUser.addresses | Where-Object type -EQ work | Select-Object -ExpandProperty region | Should -Be "new_work_state"
        $SetUser = Set-JCUser -Username $NewUser.username -work_postalCode "new_work_postalCode"
        $SetUser.addresses | Where-Object type -EQ work | Select-Object -ExpandProperty postalCode | Should -Be "new_work_postalCode"
        $SetUser = Set-JCUser -Username $NewUser.username -work_country "new_work_country"
        $SetUser.addresses | Where-Object type -EQ work | Select-Object -ExpandProperty country | Should -Be "new_work_country"
    }
    It "Updates a users home address" {
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
        $SetUser = Set-JCUser -Username $NewUser.username -home_streetAddress "new_homeStreetAddress"
        $SetUser.addresses | Where-Object type -EQ home | Select-Object -ExpandProperty streetAddress | Should -Be "new_homeStreetAddress"
        $SetUser = Set-JCUser -Username $NewUser.username -home_poBox "new_home_poBox"
        $SetUser.addresses | Where-Object type -EQ home | Select-Object -ExpandProperty poBox | Should -Be "new_home_poBox"
        $SetUser = Set-JCUser -Username $NewUser.username -home_city "new_home_city"
        $SetUser.addresses | Where-Object type -EQ home | Select-Object -ExpandProperty locality | Should -Be "new_home_city"
        $SetUser = Set-JCUser -Username $NewUser.username -home_state "new_home_state"
        $SetUser.addresses | Where-Object type -EQ home | Select-Object -ExpandProperty region | Should -Be "new_home_state"
        $SetUser = Set-JCUser -Username $NewUser.username -home_postalCode "new_home_postalCode"
        $SetUser.addresses | Where-Object type -EQ home | Select-Object -ExpandProperty postalCode | Should -Be "new_home_postalCode"
        $SetUser = Set-JCUser -Username $NewUser.username -home_country "new_home_country"
        $SetUser.addresses | Where-Object type -EQ home | Select-Object -ExpandProperty country | Should -Be "new_home_country"
    }
    It "Removes users Where-Object Email -like *pleasedelete* " {
        Get-JCUser | Where-Object Email -like *pleasedelete* | Remove-JCUser -force
    }
}
Describe -Tag:('JCUser') "Set-JCUser phoneNumbers 1.8.0" {
    It "Updates a users mobile number" {
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
        $NewUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -Be "mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -Be "home_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -Be "work_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -Be "work_mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -Be "work_fax_number"
        $UpdatedUser = Set-JCUser -Username $NewUser.username -mobile_number "new_mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -Be "new_mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -Be "home_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -Be "work_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -Be "work_mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -Be "work_fax_number"
    }
    It "Updates a users home number" {
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
        $NewUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -Be "mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -Be "home_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -Be "work_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -Be "work_mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -Be "work_fax_number"
        $UpdatedUser = Set-JCUser -Username $NewUser.username -home_number "new_home_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -Be "mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -Be "new_home_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -Be "work_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -Be "work_mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -Be "work_fax_number"
    }
    It "Updates a users work number" {
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
        $NewUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -Be "mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -Be "home_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -Be "work_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -Be "work_mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -Be "work_fax_number"
        $UpdatedUser = Set-JCUser -Username $NewUser.username -work_number "new_work_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -Be "mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -Be "home_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -Be "new_work_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -Be "work_mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -Be "work_fax_number"
    }
    It "Updates a users work_mobile_number" {
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
        $NewUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -Be "mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -Be "home_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -Be "work_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -Be "work_mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -Be "work_fax_number"
        $UpdatedUser = Set-JCUser -Username $NewUser.username -work_mobile_number "new_work_mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -Be "mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -Be "home_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -Be "work_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -Be "new_work_mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -Be "work_fax_number"
    }
    It "Updates a users work_fax_number" {
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
        $NewUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -Be "mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -Be "home_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -Be "work_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -Be "work_mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -Be "work_fax_number"
        $UpdatedUser = Set-JCUser -Username $NewUser.username -work_fax_number "new_work_fax_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -Be "mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -Be "home_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -Be "work_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -Be "work_mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -Be "new_work_fax_number"
    }
    It "Updates two numbers on a user" {
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
        $NewUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -Be "mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -Be "home_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -Be "work_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -Be "work_mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -Be "work_fax_number"
        $UpdatedUser = Set-JCUser -Username $NewUser.username -work_fax_number "new_work_fax_number" -work_number "new_work_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -Be "mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -Be "home_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -Be "new_work_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -Be "work_mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -Be "new_work_fax_number"
    }
    It "Updates all numbers on a user" {
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
        $NewUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -Be "mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -Be "home_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -Be "work_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -Be "work_mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -Be "work_fax_number"
        $UpdatedUser = Set-JCUser -Username $NewUser.username -work_fax_number "new_work_fax_number" -work_number "new_work_number" -home_number "new_home_number" -mobile_number "new_mobile_number" -work_mobile_number "new_work_mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -Be "new_mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -Be "new_home_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -Be "new_work_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -Be "new_work_mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -Be "new_work_fax_number"
    }
    It "Removes users Where-Object Email -like *pleasedelete* " {
        Get-JCUser | Where-Object Email -like *pleasedelete* | Remove-JCUser -force
    }
}
Describe -Tag:('JCUser') "Set-JCuser users phoneNumbers and attributes 1.8.0" {
    It "Updates a number and adds an attribute" {
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
        $NewUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -Be "mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -Be "home_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -Be "work_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -Be "work_mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -Be "work_fax_number"
        $UpdatedUser = Set-JCUser -Username $NewUser.username -NumberOfCustomAttributes 1 -Attribute1_name 'attr1' -Attribute1_value 'one' -work_fax_number "new_work_fax_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -Be "mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -Be "home_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -Be "work_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -Be "work_mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -Be "new_work_fax_number"
        $UpdatedUser.attributes | Where-Object name -EQ "attr1" | Select-Object -ExpandProperty value | Should -Be "one"
    }
    It "Updates a number and adds two attribute" {
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
        $NewUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -Be "mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -Be "home_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -Be "work_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -Be "work_mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -Be "work_fax_number"
        $UpdatedUser = Set-JCUser -Username $NewUser.username -NumberOfCustomAttributes 2 -Attribute1_name 'attr1' -Attribute1_value 'one' -work_fax_number "new_work_fax_number" -Attribute2_name 'attr2' -Attribute2_value 'two'
        $UpdatedUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -Be "mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -Be "home_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -Be "work_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -Be "work_mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -Be "new_work_fax_number"
        $UpdatedUser.attributes | Where-Object name -EQ "attr1" | Select-Object -ExpandProperty value | Should -Be "one"
        $UpdatedUser.attributes | Where-Object name -EQ "attr2" | Select-Object -ExpandProperty value | Should -Be "two"
    }
    It "Updates a number and updates an attribute" {
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
        $NewUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -Be "mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -Be "home_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -Be "work_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -Be "work_mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -Be "work_fax_number"
        $UpdatedUser = Set-JCUser -Username $NewUser.username -NumberOfCustomAttributes 1 -Attribute1_name 'attr1' -Attribute1_value 'one'
        $UpdatedUser = Set-JCUser -Username $NewUser.username -NumberOfCustomAttributes 1 -Attribute1_name 'attr1' -Attribute1_value 'updated_one' -work_fax_number "new_work_fax_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -Be "mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -Be "home_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -Be "work_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -Be "work_mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -Be "new_work_fax_number"
        $UpdatedUser.attributes | Where-Object name -EQ "attr1" | Select-Object -ExpandProperty value | Should -Be "updated_one"
    }
    It "Updates a number and updates two attribute" {
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
        $NewUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -Be "mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -Be "home_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -Be "work_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -Be "work_mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -Be "work_fax_number"
        $UpdatedUser = Set-JCUser -Username $NewUser.username -NumberOfCustomAttributes 2 -Attribute1_name 'attr1' -Attribute1_value 'one' -Attribute2_name 'attr2' -Attribute2_value 'two'
        $UpdatedUser = Set-JCUser -Username $NewUser.username -NumberOfCustomAttributes 2 -Attribute1_name 'attr1' -Attribute1_value 'updated_one' -work_fax_number "new_work_fax_number" -Attribute2_name 'attr2' -Attribute2_value 'updated_two'
        $UpdatedUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -Be "mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -Be "home_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -Be "work_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -Be "work_mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -Be "new_work_fax_number"
        $UpdatedUser.attributes | Where-Object name -EQ "attr1" | Select-Object -ExpandProperty value | Should -Be "updated_one"
        $UpdatedUser.attributes | Where-Object name -EQ "attr2" | Select-Object -ExpandProperty value | Should -Be "updated_two"
    }
    It "Updates a number and removes an attribute" {
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
        $NewUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -Be "mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -Be "home_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -Be "work_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -Be "work_mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -Be "work_fax_number"
        $UpdatedUser = Set-JCUser -Username $NewUser.username -NumberOfCustomAttributes 1 -Attribute1_name 'attr1' -Attribute1_value 'one'
        $UpdatedUser = Set-JCUser -Username $NewUser.username -RemoveAttribute 'attr1' -work_fax_number "new_work_fax_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -Be "mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -Be "home_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -Be "work_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -Be "work_mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -Be "new_work_fax_number"
        $UpdatedUser.attributes | Where-Object name -EQ "attr1" | Select-Object -ExpandProperty value | Should -Be $Null
    }
    It "Removes users Where-Object Email -like *pleasedelete* " {
        Get-JCUser | Where-Object Email -like *pleasedelete* | Remove-JCUser -force
    }
}
Describe -Tag:('JCUser') "Set-JCUser MFA Enrollment periods 1.10" {
    It "Updates an existing user with enable_user_portal_multifactor -eq False to enable_user_portal_multifactor -eq True " {
        $CreateUser = New-RandomUser -domain "deleteme" | New-JCUser -enable_user_portal_multifactor $false
        $NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $true
        $Newuser.mfa.exclusion | Should -Be $true
        $Newuser | Remove-JCUser -ByID -force
    }
    It "Updates an existing user with enable_user_portal_multifactor -eq False to enable_user_portal_multifactor -eq True and a 30 days specified for EnrollmentDays" {
        $CreateUser = New-RandomUser -domain "deleteme" | New-JCUser -enable_user_portal_multifactor $false
        $EnrollmentDays = 30
        $NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $true -EnrollmentDays $EnrollmentDays
        $Newuser.mfa.exclusion | Should -Be $true
        $Newuser | Remove-JCUser -ByID -force
    }
    It "Updates an existing user with enable_user_portal_multifactor -eq True and a 365 days specified for EnrollmentDays" {
        $CreateUser = New-RandomUser -domain "deleteme" | New-JCUser -enable_user_portal_multifactor $false
        $EnrollmentDays = 365
        $NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $true -EnrollmentDays $EnrollmentDays
        $Newuser.mfa.exclusion | Should -Be $true
        $Newuser | Remove-JCUser -ByID -force
    }
    It "Updates an existing user with enable_user_portal_multifactor -eq False to enable_user_portal_multifactor -eq True -ByID" {
        $CreateUser = New-RandomUser -domain "deleteme" | New-JCUser -enable_user_portal_multifactor $false
        $NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $true -ByID
        $Newuser.mfa.exclusion | Should -Be $true
        $Newuser | Remove-JCUser -ByID -force
    }
    It "Updates an existing user with enable_user_portal_multifactor -eq False to enable_user_portal_multifactor -eq True and a 30 days specified for EnrollmentDays -ByID" {
        $CreateUser = New-RandomUser -domain "deleteme" | New-JCUser -enable_user_portal_multifactor $false
        $EnrollmentDays = 30
        $NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $true -EnrollmentDays $EnrollmentDays -ByID
        $Newuser.mfa.exclusion | Should -Be $true
        $Newuser | Remove-JCUser -ByID -force
    }
    It "Updates an existing user with enable_user_portal_multifactor -eq True and a 365 days specified for EnrollmentDays -ByID" {
        $CreateUser = New-RandomUser -domain "deleteme" | New-JCUser -enable_user_portal_multifactor $false
        $EnrollmentDays = 365
        $NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $true -EnrollmentDays $EnrollmentDays -ByID
        $Newuser.mfa.exclusion | Should -Be $true
        $Newuser | Remove-JCUser -ByID -force
    }
    It "Updates an existing user with enable_user_portal_multifactor -eq True with Attributes" {
        $CreateUser = New-RandomUser -domain "deleteme" -Attributes | New-JCUser -NumberOfCustomAttributes 2 -enable_user_portal_multifactor $True
        $NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $true -NumberOfCustomAttributes 1 -Attribute1_name 'attr1' -Attribute1_value 'attr1v'
        $Newuser.mfa.exclusion | Should -Be $true
        $Newuser | Remove-JCUser -ByID -force
    }
    It "Updates an existing user with enable_user_portal_multifactor -eq True and a 30 days specified for EnrollmentDays with Attributes" {
        $EnrollmentDays = 30
        $CreateUser = New-RandomUser -domain "deleteme" -Attributes | New-JCUser -NumberOfCustomAttributes 2 -enable_user_portal_multifactor $True
        $NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $true -EnrollmentDays $EnrollmentDays -NumberOfCustomAttributes 1 -Attribute1_name 'attr1' -Attribute1_value 'attr1v'
        $Newuser.mfa.exclusion | Should -Be $true
        $Newuser | Remove-JCUser -ByID -force
    }
    It "Updates an existing user with enable_user_portal_multifactor -eq True with removeAttributes" {
        $CreateUser = New-RandomUser -domain "deleteme" -Attributes | New-JCUser -NumberOfCustomAttributes 2
        $NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $true -RemoveAttribute 'Department', 'Lang'
        $Newuser.mfa.exclusion | Should -Be $true
        $Newuser | Remove-JCUser -ByID -force
    }
    It "Updates an existing user with enable_user_portal_multifactor -eq True and a 30 days specified for EnrollmentDays with removeAttributes" {
        $CreateUser = New-RandomUser -domain "deleteme" | New-JCUser -enable_user_portal_multifactor $true
        $EnrollmentDays = 30
        $NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $true -EnrollmentDays $EnrollmentDays
        $Newuser.mfa.exclusion | Should -Be $true
        $Newuser | Remove-JCUser -ByID -force
    }
    It "Disabled MFA enrollment by setting enable_user_portal_multifactor to False" {
        $CreateUser = New-RandomUser -domain "deleteme" | New-JCUser -enable_user_portal_multifactor $true
        $NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $false
        $Newuser.mfa.exclusion | Should -Be $false
        $Newuser.mfa.exclusionUntil | Should -BeNullOrEmpty
    }
}
Describe -Tag:('JCUser') "Set-JCUser bug fix 1.10.2" {
    It "Updates a users home poBox" {
        $CreateUser = New-RandomUser -domain "deleteme" | New-JCUser -home_poBox "myhome"
        $NewUser = $CreateUser | Set-JCUser -home_poBox "yourHome"
        $NewUser.addresses | Where-Object type -EQ home | Select-Object -ExpandProperty poBox | Should -Be "yourHome"
        #$NullCheck = Get-JCUser $CreateUser.username | ConvertTo-Json -Depth 5 | Select-String null
        #$NullCheck | Should -BeNullOrEmpty
        $Newuser | Remove-JCUser -ByID -force
    }
    It "Updates a users work poBox" {
        $CreateUser = New-RandomUser -domain "deleteme" | New-JCUser -work_poBox "mywork"
        $NewUser = $CreateUser | Set-JCUser -work_poBox "yourwork"
        $NewUser.addresses | Where-Object type -EQ work | Select-Object -ExpandProperty poBox | Should -Be "yourwork"
        #$NullCheck = Get-JCUser $CreateUser.username | ConvertTo-Json -Depth 5 | Select-String null
        #$NullCheck | Should -BeNullOrEmpty
        $Newuser | Remove-JCUser -ByID -force
    }
    It "Updates a mobile_number" {
        $CreateUser = New-RandomUser -domain "deleteme" | New-JCUser -mobile_number "mobile1"
        $NewUser = $CreateUser | Set-JCUser -mobile_number "mobile2"
        $NewUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -Be "mobile2"
        #$NullCheck = Get-JCUser $CreateUser.username | ConvertTo-Json -Depth 5 | Select-String null
        #$NullCheck | Should -BeNullOrEmpty
        $Newuser | Remove-JCUser -ByID -force
    }
    It "Updates a users home poBox and work poBox" {
        $CreateUser = New-RandomUser -domain "deleteme" | New-JCUser -home_poBox "myhome"
        $NewUser = $CreateUser | Set-JCUser -home_poBox "yourHome"
        $NewUser.addresses | Where-Object type -EQ home | Select-Object -ExpandProperty poBox | Should -Be "yourHome"
        $NewUser = $CreateUser | Set-JCUser -work_poBox "yourwork"
        $NewUser.addresses | Where-Object type -EQ work | Select-Object -ExpandProperty poBox | Should -Be "yourwork"
        #$NullCheck = Get-JCUser $CreateUser.username | ConvertTo-Json -Depth 5 | Select-String null
        #$NullCheck | Should -BeNullOrEmpty
        $Newuser | Remove-JCUser -ByID -force
    }
    It "Updates a mobile_number and work_number" {
        $CreateUser = New-RandomUser -domain "deleteme" | New-JCUser -mobile_number "mobile1"
        $NewUser = $CreateUser | Set-JCUser -mobile_number "mobile2"
        $NewUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -Be "mobile2"
        $NewUser = $CreateUser | Set-JCUser -work_number "work2"
        $NewUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -Be "work2"
        #$NullCheck = Get-JCUser $CreateUser.username | ConvertTo-Json -Depth 5 | Select-String null
        #$NullCheck | Should -BeNullOrEmpty
        $Newuser | Remove-JCUser -ByID -force
    }
}
Describe -Tag:('JCUser') "Set-JCUser 1.12" {
    It "Sets a users external_source_type" {
        $Newuser = New-RandomUser -domain "deleteme" | New-JCUser
        $Random1 = $(Get-Random)
        $Random2 = $(Get-Random)
        $SetUser = Set-JCUser -Username $Newuser.username -external_source_type "$Random1" -external_dn "$Random2"
        $SearchUser = Get-JCUser -external_source_type $Random1
        Remove-JCUser -UserID $Newuser._id -force
        $SearchUser.external_source_type | Should -Be $SetUser.external_source_type
    }
    It "Sets a users external_dn" {
        $Newuser = New-RandomUser -domain "deleteme" | New-JCUser
        $Random1 = $(Get-Random)
        $Random2 = $(Get-Random)
        $SetUser = Set-JCUser -Username $Newuser.username -external_source_type "$Random1" -external_dn "$Random2"
        $SearchUser = Get-JCUser -external_source_type $Random1
        Remove-JCUser -UserID $Newuser._id -force
        $SearchUser.external_dn | Should -Be $SetUser.external_dn
    }
    It "Sets a users external_dn and external_source_type" {
        $Newuser = New-RandomUser -domain "deleteme" | New-JCUser
        $Random1 = $(Get-Random)
        $Random2 = $(Get-Random)
        $SetUser = Set-JCUser -Username $Newuser.username -external_source_type "$Random1" -external_dn "$Random2"
        $SearchUser = Get-JCUser -external_source_type "$Random1" -external_dn "$Random2"
        Remove-JCUser -UserID $Newuser._id -force
        $SearchUser.external_dn | Should -Be $SetUser.external_dn
        $SearchUser.external_source_type | Should -Be $SetUser.external_source_type
    }
}
Describe -Tag:('JCUser') "Set-JCUser with Suspend param 1.15" {
    It "Updates a user suspended -eq True " {
        $NewUser = New-RandomUser -domain pleasedelete"PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $UpdatedUser = $NewUser | Set-JCUser -suspended $True
        $UpdatedUser.suspended | Should -Be True
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }
    It "Updates a user suspended -eq false " {
        $NewUser = New-RandomUser -domain pleasedelete"PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser -suspended $true
        $UpdatedUser = $NewUser | Set-JCUser -suspended $false
        $UpdatedUser.suspended | Should -Be False
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }
}
