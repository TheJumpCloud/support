$SingleAdminAPIKey = ''
Describe "Connect-JCOnline" {

    It "Connects to JumpCloud with a single admin API Key using force" {
        
        $Connect = Connect-JCOnline -JumpCloudAPIKey $SingleAdminAPIKey -force
        $Connect | Should -be $null

    }
}

Describe "New-JCUser MFA with enrollment periods" {

    It "Creates a new user with enable_user_portal_multifactor -eq True" {


        $Newuser = New-RandomUser | New-JCUser -enable_user_portal_multifactor $true

        $DateCheck = (Get-Date).AddDays(7).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfa.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfa.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 2

        $Newuser  | Remove-JCUser -ByID -force

    }

    It "Creates a new user with enable_user_portal_multifactor -eq True and a 30 days specified for EnrollmentDays" {

        $EnrollmentDays = 30

        $Newuser = New-RandomUser | New-JCUser -enable_user_portal_multifactor $true -EnrollmentDays $EnrollmentDays

        $DateCheck = (Get-Date).AddDays($EnrollmentDays).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfa.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfa.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 2

        $Newuser  | Remove-JCUser -ByID -force

    }

    It "Creates a new user with enable_user_portal_multifactor -eq True and a 365 days specified for EnrollmentDays" {

        $EnrollmentDays = 365

        $Newuser = New-RandomUser | New-JCUser -enable_user_portal_multifactor $true -EnrollmentDays $EnrollmentDays

        $DateCheck = (Get-Date).AddDays($EnrollmentDays).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfa.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfa.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 2

        $Newuser  | Remove-JCUser -ByID -force

    }

    It "Creates a new user with enable_user_portal_multifactor -eq True and a 366 days specified for EnrollmentDays (invalid)" {

        $EnrollmentDays = 366

        {$Newuser = New-RandomUser | New-JCUser -enable_user_portal_multifactor $true -EnrollmentDays $EnrollmentDays} | Should Throw "Cannot validate argument on parameter 'EnrollmentDays'. The 366 argument is greater than the maximum allowed range of 365. Supply an argument that is less than or equal to 365 and then try the command again."


    }

    It "Creates a new user with enable_user_portal_multifactor -eq True with Attributes" {

        $NewUser = New-RandomUser -Attributes | New-JCUser -NumberOfCustomAttributes 2 -enable_user_portal_multifactor $True

        $DateCheck = (Get-Date).AddDays(7).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfa.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfa.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 2

        $Newuser  | Remove-JCUser -ByID -force

    }

    It "Creates a new user with enable_user_portal_multifactor -eq True and a 30 days specified for EnrollmentDays with Attributes" {

        $EnrollmentDays = 30

        $NewUser = New-RandomUser -Attributes | New-JCUser -NumberOfCustomAttributes 2 -enable_user_portal_multifactor $True -EnrollmentDays $EnrollmentDays

        $DateCheck = (Get-Date).AddDays($EnrollmentDays).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfa.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfa.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 2

        $Newuser  | Remove-JCUser -ByID -force

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

        $NewUser = $newUserObj | % {New-JCUser -enable_user_portal_multifactor $_.enable_user_portal_multifactor -EnrollmentDays $_.EnrollmentDays -firstName $_.firstName -lastName $_.Lastname -username $_.username -email $_.email}

        $DateCheck = (Get-Date).AddDays($EnrollmentDays).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfa.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfa.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 2

        $Newuser  | Remove-JCUser -ByID -force

    }

}

Describe "Set-JCUser MFA Enrollment periods" {

    It "Updates an existing user with enable_user_portal_multifactor -eq False to enable_user_portal_multifactor -eq True " {
        $CreateUser = New-RandomUser | New-JCUser -enable_user_portal_multifactor $false

        $NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $true

        $DateCheck = (Get-Date).AddDays(7).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfa.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfa.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 2

        $Newuser  | Remove-JCUser -ByID -force

    }

    It "Updates an existing user with enable_user_portal_multifactor -eq False to enable_user_portal_multifactor -eq True and a 30 days specified for EnrollmentDays" {

        $CreateUser = New-RandomUser | New-JCUser -enable_user_portal_multifactor $false

        $EnrollmentDays = 30

        $NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $true -EnrollmentDays $EnrollmentDays

        $DateCheck = (Get-Date).AddDays($EnrollmentDays).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfa.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfa.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 2

        $Newuser  | Remove-JCUser -ByID -force


    }

    It "Updates an existing user with enable_user_portal_multifactor -eq True and a 365 days specified for EnrollmentDays" {

        $CreateUser = New-RandomUser | New-JCUser -enable_user_portal_multifactor $false

        $EnrollmentDays = 365

        $NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $true -EnrollmentDays $EnrollmentDays

        $DateCheck = (Get-Date).AddDays($EnrollmentDays).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfa.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfa.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 2

        $Newuser  | Remove-JCUser -ByID -force
    }

    It "Updates an existing user with enable_user_portal_multifactor -eq False to enable_user_portal_multifactor -eq True -ByID" {
        $CreateUser = New-RandomUser | New-JCUser -enable_user_portal_multifactor $false

        $NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $true -ByID

        $DateCheck = (Get-Date).AddDays(7).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfa.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfa.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 2

        $Newuser  | Remove-JCUser -ByID -force

    }

    It "Updates an existing user with enable_user_portal_multifactor -eq False to enable_user_portal_multifactor -eq True and a 30 days specified for EnrollmentDays -ByID" {

        $CreateUser = New-RandomUser | New-JCUser -enable_user_portal_multifactor $false

        $EnrollmentDays = 30

        $NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $true -EnrollmentDays $EnrollmentDays -ByID

        $DateCheck = (Get-Date).AddDays($EnrollmentDays).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfa.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfa.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 2

        $Newuser  | Remove-JCUser -ByID -force


    }

    It "Updates an existing user with enable_user_portal_multifactor -eq True and a 365 days specified for EnrollmentDays -ByID" {

        $CreateUser = New-RandomUser | New-JCUser -enable_user_portal_multifactor $false

        $EnrollmentDays = 365

        $NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $true -EnrollmentDays $EnrollmentDays -ByID

        $DateCheck = (Get-Date).AddDays($EnrollmentDays).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfa.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfa.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 2

        $Newuser  | Remove-JCUser -ByID -force
    }

    It "Updates an existing user with enable_user_portal_multifactor -eq True and a 366 days specified for EnrollmentDays (invalid)" {

        $CreateUser = New-RandomUser | New-JCUser -enable_user_portal_multifactor $false

        $EnrollmentDays = 366

        {$NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $true -EnrollmentDays $EnrollmentDays} | Should Throw "Cannot validate argument on parameter 'EnrollmentDays'. The 366 argument is greater than the maximum allowed range of 365. Supply an argument that is less than or equal to 365 and then try the command again."
    }

    It "Updates an existing user with enable_user_portal_multifactor -eq True with Attributes" {

        $CreateUser = New-RandomUser -Attributes | New-JCUser -NumberOfCustomAttributes 2 -enable_user_portal_multifactor $True

        $NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $true -NumberOfCustomAttributes 1 -Attribute1_name 'attr1' -Attribute1_value 'attr1v'

        $DateCheck = (Get-Date).AddDays(7).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfa.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfa.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 2

        $Newuser  | Remove-JCUser -ByID -force

    }

    It "Updates an existing user with enable_user_portal_multifactor -eq True and a 30 days specified for EnrollmentDays with Attributes" {

        $EnrollmentDays = 30

        $CreateUser = New-RandomUser -Attributes | New-JCUser -NumberOfCustomAttributes 2 -enable_user_portal_multifactor $True

        $NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $true -EnrollmentDays $EnrollmentDays -NumberOfCustomAttributes 1 -Attribute1_name 'attr1' -Attribute1_value 'attr1v'

        $DateCheck = (Get-Date).AddDays($EnrollmentDays).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfa.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfa.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 2

        $Newuser  | Remove-JCUser -ByID -force



    }

    It "Updates an existing user with enable_user_portal_multifactor -eq True with removeAttributes" {
        $CreateUser = New-RandomUser -Attributes | New-JCUser -NumberOfCustomAttributes 2

        $NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $true -RemoveAttribute 'Department', 'Lang'

        $DateCheck = (Get-Date).AddDays(7).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfa.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfa.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 2

        $Newuser  | Remove-JCUser -ByID -force
    }

    It "Updates an existing user with enable_user_portal_multifactor -eq True and a 30 days specified for EnrollmentDays with removeAttributes" {

        $CreateUser = New-RandomUser | New-JCUser -enable_user_portal_multifactor $true

        $EnrollmentDays = 30

        $NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $true -EnrollmentDays $EnrollmentDays

        $DateCheck = (Get-Date).AddDays($EnrollmentDays).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfa.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfa.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 2

        $Newuser  | Remove-JCUser -ByID -force



    }

    It "Disabled MFA enrollment by setting  enable_user_portal_multifactor to False" {

        $CreateUser = New-RandomUser | New-JCUser -enable_user_portal_multifactor $true

        $EnrollmentDays = 30

        $NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $false

        $Newuser.mfa.exclusion | Should -Be $false

        $Newuser.mfa.exclusionUntil | Should -BeNullOrEmpty

    }

}