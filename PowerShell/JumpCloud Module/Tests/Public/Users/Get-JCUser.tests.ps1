Describe -Tag:('JCUser') 'Get-JCUser 1.0' {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null }
    It "Gets all JumpCloud users using Get-JCuser" {
        $Users = Get-JCUser
        $Users._id.count | Should -BeGreaterThan 1
    }

    It 'Get a single JumpCloud user by Username' {
        $User = Get-JCUser -Username $PesterParams_User1.Username
        $User._id.count | Should -Be 1
    }

    It 'Get a single JumpCloud user by UserID' {
        $User = Get-JCUser -UserID $PesterParams_User1.id
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
    It "Searches a JumpCloud user by alternateEmail" -Skip {
        $alternateEmail = "deleteme@$(New-RandomString -NumberOfChars 8).com"
        $NewUser = New-RandomUser -Domain DeleteMe | New-JCUser -alternateEmail $alternateEmail
        $NewUser = Get-JCUser -alternateEmail $alternateEmail
        $NewUser.alternateEmail | Should -Be $alternateEmail
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Searches a JumpCloud user by recoveryEmail" {
        $recoveryEmail = "deleteme@$(New-RandomString -NumberOfChars 8).com"
        $NewUser = New-RandomUser -Domain DeleteMe | New-JCUser -recoveryEmail $recoveryEmail
        $NewUser = Get-JCUser -recoveryEmail $recoveryEmail
        $NewUser.recoveryEmail.address | Should -Be $recoveryEmail
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Searches a JumpCloud user by managedAppleID" {
        $managedAppleID = "deleteme@$(New-RandomString -NumberOfChars 8).com"
        $NewUser = New-RandomUser -Domain DeleteMe | New-JCUser -managedAppleID $managedAppleID
        $NewUser = Get-JCUser -managedAppleID $managedAppleID
        $NewUser.managedAppleID | Should -Be $managedAppleID
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Searches a JumpCloud user by managerID" {
        $manager = $PesterParams_User1.id
        $NewUser = New-RandomUser -Domain DeleteMe | New-JCUser -manager $manager
        $NewUser = Get-JCUser -manager $manager
        $NewUser.manager | Should -Be $manager
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Searches a JumpCloud user by managerUsername" {
        $managerUsername = $PesterParams_User1.username
        $managerId = $PesterParams_User1.id
        $NewUser = New-RandomUser -Domain DeleteMe | New-JCUser -manager $managerUsername
        $NewUser = Get-JCUser -manager $managerUsername
        $NewUser.manager | Should -Be $managerId
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Searches a JumpCloud user by managerEmail" {
        $managerEmail = $PesterParams_User1.email
        $managerId = $PesterParams_User1.id
        $NewUser = New-RandomUser -Domain DeleteMe | New-JCUser -manager $managerEmail
        $NewUser = Get-JCUser -manager $managerEmail
        $NewUser.manager | Should -Be $managerId
        Remove-JCUser -UserID $NewUser._id -force
    }
    It "Searches a JumpCloud user by state SUSPENDED" {
        $NewUser = New-RandomUser -Domain DeleteMe | New-JcUser -state "SUSPENDED"
        $SearchUser = Get-JCUser -state "SUSPENDED" | Select-Object -First 1
        $SearchUser.state | Should -Be "SUSPENDED"
        Remove-JCUser -UserId $NewUser._id -force
    }
    It "Searches a JumpCloud user by state STAGED" {
        $NewUser = New-RandomUser -Domain DeleteMe | New-JcUser -state "STAGED"
        $SearchUser = Get-JCUser -state "STAGED" | Select-Object -First 1
        $SearchUser.state | Should -Be "STAGED"
        Remove-JCUser -UserId $NewUser._id -force
    }
    It "Searches a JumpCloud user by state ACTIVATED" {
        $NewUser = New-RandomUser -Domain DeleteMe | New-JcUser -state "ACTIVATED"
        $SearchUser = Get-JCUser -state "ACTIVATED" | Select-Object -First 1
        $SearchUser.state | Should -Be "ACTIVATED"
        Remove-JCUser -UserId $NewUser._id -force
    }

}

Describe -Tag:('JCUser') "Get-JCUser 1.4" {

    It "Returns a JumpCloud user by UserID" {
        $PesterUser = Get-JCUser -userid $PesterParams_User1.id
        $PesterUser._id | Should -Be $PesterParams_User1.id
    }

    It "Returns all JumpCloud users" {
        $AllUsers = Get-JCUser
        $AllUsers.Count | Should -BeGreaterThan 1
    }

    It "Searches for a JumpCloud user by username and wildcard end" {

        $PesterUser = Get-JCUser -username "$($PesterParams_User1.Username.Substring(0, $PesterParams_User1.Username.Length - ($PesterParams_User1.Username.Length/2)))*"
        $PesterUser.username | Should -BeGreaterThan 0

    }

    It "Searches for a JumpCloud user by username and wildcard beginning" {
        $PesterUser = Get-JCUser -username "*$($PesterParams_User1.Username.Substring(1))"
        $PesterUser.username | Should -BeGreaterThan 0


    }

    It "Searches for a JumpCloud user by username and wildcard beginning and wildcard end" {
        $PesterUser = Get-JCUser -username "*$($PesterParams_User1.Username.Substring(1, $PesterParams_User1.Username.Length - ($PesterParams_User1.Username.Length/2)))*"
        $PesterUser.username | Should -BeGreaterThan 0
    }

    It "Searches for a JumpCloud user by firstname and wildcard end" {
        $PesterUser = Get-JCUser -firstname "$($PesterParams_User1.FirstName.Substring(0, $PesterParams_User1.FirstName.Length - ($PesterParams_User1.FirstName.Length/2)))*" -username $PesterParams_User1.Username
        $PesterUser.username | Should -BeGreaterThan 0
    }

    It "Searches for a JumpCloud user by firstname and wildcard beginning" {
        $PesterUser = Get-JCUser -firstname "*$($PesterParams_User1.FirstName.Substring(1))" -username $PesterParams_User1.Username
        $PesterUser.username | Should -BeGreaterThan 0
    }

    It "Searches for a JumpCloud user by firstname and wildcard beginning and wildcard end" {
        $PesterUser = Get-JCUser -firstname "*$($PesterParams_User1.FirstName.Substring(1, $PesterParams_User1.FirstName.Length - ($PesterParams_User1.FirstName.Length/2)))*" -username $PesterParams_User1.Username
        $PesterUser.username | Should -BeGreaterThan 0
    }

    It "Searches for a JumpCloud user by lastname and wildcard end" {
        $PesterUser = Get-JCUser -lastname "$($PesterParams_User1.lastname.Substring(0, $PesterParams_User1.lastname.Length - ($PesterParams_User1.lastname.Length/2)))*" -username $PesterParams_User1.Username
        $PesterUser.username | Should -BeGreaterThan 0
    }

    It "Searches for a JumpCloud user by lastname and wildcard beginning" {
        $PesterUser = Get-JCUser -lastname "*$($PesterParams_User1.lastname.Substring(1))" -username $PesterParams_User1.Username
        $PesterUser.username | Should -BeGreaterThan 0
    }

    It "Searches for a JumpCloud user by lastname and wildcard beginning and wildcard end" {
        $PesterUser = Get-JCUser -lastname "*$($PesterParams_User1.lastname.Substring(1, $PesterParams_User1.lastname.Length - ($PesterParams_User1.lastname.Length/2)))*" -username $PesterParams_User1.Username
        $PesterUser.username | Should -BeGreaterThan 0
    }

    It "Searches for a JumpCloud user by email and wildcard beginning" {
        $PesterUser = Get-JCUser -email "*$($PesterParams_User1.email.Substring(1))" -username $PesterParams_User1.Username
        $PesterUser.username | Should -BeGreaterThan 0
    }

    It "Searches for a JumpCloud user by email and wildcard beginning and wildcard end" {
        $PesterUser = Get-JCUser -email "*$($PesterParams_User1.email.Substring(1, $PesterParams_User1.email.Length - ($PesterParams_User1.email.Length/2)))*" -username $PesterParams_User1.Username
        $PesterUser.username | Should -BeGreaterThan 0
    }

    It "Searches for a JumpCloud user by username and sudo" {
        $PesterUser = Get-JCUser -username $PesterParams_User1.Username -sudo $false
        $PesterUser.username | Should -Be $PesterParams_User1.Username
    }

    It "Searches for a JumpCloud user by username and enable_managed_uid" {
        $PesterUser = Get-JCUser -username $PesterParams_User1.Username -enable_managed_uid $false
        $PesterUser.username | Should -Be $PesterParams_User1.Username
    }

    It "Searches for a JumpCloud user by username and activated" -Skip {
        $PesterUser = Get-JCUser -username $PesterParams_User1.Username -activated $true
        $PesterUser.username | Should -Be $PesterParams_User1.Username
    }

    It "Searches for a JumpCloud user by username and password_expired" {
        $PesterUser = Get-JCUser -username $PesterParams_User1.Username -password_expired $false
        $PesterUser.username | Should -Be $PesterParams_User1.Username
    }

    It "Searches for a JumpCloud user by username and passwordless_sudo" {
        $PesterUser = Get-JCUser -username $PesterParams_User1.Username -passwordless_sudo $false
        $PesterUser.username | Should -Be $PesterParams_User1.Username
    }

    It "Searches for a JumpCloud user by username and externally_managed" {
        $PesterUser = Get-JCUser -username $PesterParams_User1.Username -externally_managed $false
        $PesterUser.username | Should -Be $PesterParams_User1.Username
    }

    It "Searches for a JumpCloud user by username and ldap_binding_user" {
        $PesterUser = Get-JCUser -username $PesterParams_User1.Username -ldap_binding_user $false
        $PesterUser.username | Should -Be $PesterParams_User1.Username
    }

    It "Searches for a JumpCloud user by username and enable_user_portal_multifactor" {
        $PesterUser = Get-JCUser -username $PesterParams_User1.Username -enable_user_portal_multifactor $false
        $PesterUser.username | Should -Be $PesterParams_User1.Username
    }

    It "Searches for a JumpCloud user by username and totp_enabled" {
        $PesterUser = Get-JCUser -username $PesterParams_User1.Username -totp_enabled $false
        $PesterUser.username | Should -Be $PesterParams_User1.Username
    }

    It "Searches for a JumpCloud user by username and allow_public_key" {
        $PesterUser = Get-JCUser -username $PesterParams_User1.Username -allow_public_key $false
        $PesterUser.username | Should -Be $PesterParams_User1.Username
    }


    It "Searches for a JumpCloud user by username and samba_service_user" {
        $PesterUser = Get-JCUser -username $PesterParams_User1.Username -samba_service_user $false
        $PesterUser.username | Should -Be $PesterParams_User1.Username
    }

    It "Searches for a JumpCloud user by username and password_never_expires" {
        $PesterUser = Get-JCUser -username $PesterParams_User1.Username -password_never_expires $true
        $PesterUser.username | Should -Be $PesterParams_User1.Username
    }

    It "Searches for a JumpCloud user using username, filterDateProperty created and before" {

        $PesterUser = Get-JCUser -username $PesterParams_User1.Username -filterDateProperty created -dateFilter before -date (Get-Date).AddDays(1).ToString('MM/dd/yyyy')
        $PesterUser.username | Should -Be $PesterParams_User1.Username

    }

    It "Searches for a JumpCloud user using username, filterDateProperty created and after" {

        $PesterUser = Get-JCUser -username $PesterParams_User1.Username -filterDateProperty created -dateFilter after -date (Get-Date).AddDays(-30).ToString('MM/dd/yyyy')
        $PesterUser.username | Should -Be $PesterParams_User1.Username

    }

    It "Searches for a JumpCloud user using username and returns on the username property" {
        $PesterUser = Get-JCUser -username $PesterParams_User1.Username -returnProperties username
        $PesterUser.username | Should -Be $PesterParams_User1.Username
    }

    It "Searches for a JumpCloud user using username and returns all properties" {
        $PesterUser = Get-JCUser -username $PesterParams_User1.Username  -returnProperties 'created', 'account_locked', 'activated', 'addresses', 'allow_public_key', 'attributes', 'email', 'enable_managed_uid', 'enable_user_portal_multifactor', 'externally_managed', 'firstname', 'lastname', 'ldap_binding_user', 'passwordless_sudo', 'password_expired', 'password_never_expires', 'phoneNumbers', 'samba_service_user', 'ssh_keys', 'sudo', 'suspended', 'totp_enabled', 'unix_guid', 'unix_uid', 'username', 'alternateEmail', 'managedAppleId', 'recoveryEmail'
        $PesterUser.account_locked | Should -Not -Be $null
        $PesterUser.activated | Should -Not -Be $null
        $PesterUser.addresses | Should -Not -Be $null
        $PesterUser.allow_public_key | Should -Not -Be $null
        $PesterUser.alternateEmail | Should -Not -Be $null
        $PesterUser.attributes | Should -Not -Be $null
        $PesterUser.created | Should -Not -Be $null
        $PesterUser.email | Should -Not -Be $null
        $PesterUser.recoveryEmail | Should -Not -Be $null
        $PesterUser.enable_managed_uid | Should -Not -Be $null
        $PesterUser.enable_user_portal_multifactor | Should -Not -Be $null
        $PesterUser.externally_managed | Should -Not -Be $null
        $PesterUser.firstname | Should -Not -Be $null
        $PesterUser.lastname | Should -Not -Be $null
        $PesterUser.ldap_binding_user | Should -Not -Be $null
        $PesterUser.managedAppleID | Should -Not -Be $null
        $PesterUser.password_expired | Should -Not -Be $null
        $PesterUser.password_never_expires | Should -Not -Be $null
        $PesterUser.passwordless_sudo | Should -Not -Be $null
        $PesterUser.phoneNumbers | Should -Not -Be $null
        $PesterUser.samba_service_user | Should -Not -Be $null
        $PesterUser.sudo | Should -Not -Be $null
        $PesterUser.suspended | Should -Not -Be $null
        $PesterUser.totp_enabled | Should -Not -Be $null
        $PesterUser.unix_guid | Should -Not -Be $null
        $PesterUser.unix_uid | Should -Not -Be $null
        $PesterUser.username | Should -Not -Be $null
    }


}

Describe -Tag:('JCUser') "Get-JCUser with new attributes 1.8.0" {
    It "Searches for a user by middlename" {
        $Search = Get-JCUser -middlename $PesterParams_User1.middlename -returnProperties middlename
        $Search.middlename | Should -Be $PesterParams_User1.middlename
    }
    It "Searches for a user by displayname" {
        $Search = Get-JCUser -displayname $PesterParams_User1.displayname -returnProperties displayname
        $Search.displayname | Should -Be $PesterParams_User1.displayname
    }
    It "Searches for a user by jobTitle" {
        $Search = Get-JCUser -jobTitle $PesterParams_User1.jobTitle -returnProperties jobTitle
        $Search.jobTitle | Should -Be $PesterParams_User1.jobTitle
    }
    It "Searches for a user by employeeIdentifier" {
        $Search = Get-JCUser -employeeIdentifier $PesterParams_User1.employeeIdentifier -returnProperties employeeIdentifier
        $Search.employeeIdentifier | Should -Be $PesterParams_User1.employeeIdentifier
    }
    It "Searches for a user by department" {
        $Search = Get-JCUser -department $PesterParams_User1.department -returnProperties department
        $Search.department | Should -Be $PesterParams_User1.department
    }
    It "Searches for a user by costCenter" {
        $Search = Get-JCUser -costCenter $PesterParams_User1.costCenter -returnProperties costCenter
        $Search.costCenter | Should -Be $PesterParams_User1.costCenter
    }
    It "Searches for a user by company" {
        $Search = Get-JCUser -company $PesterParams_User1.company -returnProperties company
        $Search.company | Should -Be $PesterParams_User1.company
    }
    It "Searches for a user by employeeType" {
        $Search = Get-JCUser -employeeType $PesterParams_User1.employeeType -returnProperties employeeType
        $Search.employeeType | Should -Be $PesterParams_User1.employeeType
    }
    It "Searches for a user by description" {
        $Search = Get-JCUser -description $PesterParams_User1.description -returnProperties description
        $Search.description | Should -Be $PesterParams_User1.description
    }
    It "Searches for a user by location" {
        $Search = Get-JCUser -location $PesterParams_User1.location -returnProperties location
        $Search.location | Should -Be $PesterParams_User1.location
    }
    It "Searches for a user by alternateEmail" -Skip {
        $Search = Get-JCUser -alternateEmail $PesterParams_User1.alternateEmail -returnProperties alternateEmail
        $Search.alternateEmail | Should -Be $PesterParams_User1.alternateEmail
    }
    It "Searches for a user by managedAppleID" {
        $Search = Get-JCUser -managedAppleId $PesterParams_User1.managedAppleID -returnProperties managedAppleId
        $Search.managedAppleID | Should -Be $PesterParams_User1.managedAppleID
    }
    It "Searches for a user by recoveryEmail" {
        $Search = Get-JCUser -recoveryEmail $PesterParams_User1.recoveryEmail.address -returnProperties recoveryEmail
        $Search.recoveryEmail.address | Should -Be $PesterParams_User1.recoveryEmail.address
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

Describe -Tag:('JCUser') "Case Insensitivity Tests" {
    It "Searches for usernames byLower" {
        # 'username' should return same user as 'Username'
        $userSearch = Get-JCUser -Username $PesterParams_User1.Username.toLower()
        $userSearchDefault = Get-JCUser -Username $PesterParams_User1.Username
        $userSearch._id | Should -Be $userSearchDefault._id
    }
    It "Searches for usernames, firstnames, lastnames with mixed capitalaztion" {
        # search by username, firstname, lastname
        # Get-JCuser -username uSeRnAmE should return same user as Get-JCuser -username Username
        # Get-JCuser -firstname fIrStNaMe should return same user as Get-JCuser -firstname Firstname
        # Get-JCuser -lastname lAsTnAmE should return same user as Get-JCuser -lastname Lastname
        $params = ('username', 'firstname', 'lastname')
        foreach ($param in $params) {
            $string = $PesterParams_User1.$param.toLower()
            $string.length
            $stringList = @()
            $stringFinal = ""
            # for i in usernmae length, get the letters and capatlize ever other letter
            for ($i = 0; $i -lt $string.length; $i++) {
                <# Action that will repeat until the condition is met #>
                $letter = $string.Substring($i, 1)
                if ($i % 2 -eq 1) {
                    $letter = $letter.TOUpper()
                }
                $stringList += ($letter)
            }
            foreach ($letter in $stringList) {
                <# $currentItemName is the current item #>
                $stringFinal += $letter
            }
            $Command_Associations_POST = "Get-JCUser -$($param) $stringFinal"
            # $userSearch = Get-JCUser -$($param) $stringFinal
            $userSearch = Invoke-Expression -Command:($Command_Associations_POST)
            $Command_Associations_POST_DEFAULT = "Get-JCUser -$($param) $($PesterParams_User1.$param)"
            # $userSearchDefault = $userSearchDefault = Get-JCUser -$($param) $PesterParams_User1.$param
            $userSearchDefault = Invoke-Expression -Command:($Command_Associations_POST_DEFAULT)
            Write-Host " $($userSearch.$param) should be $($userSearchDefault.$param)"
            # Ids returned here should return the same restuls
            $userSearch._id | Should -Be $userSearchDefault._id
        }
    }
}