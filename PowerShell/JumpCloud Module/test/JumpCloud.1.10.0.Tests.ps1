## Generic Test
$SingleAdminAPIKey = ''
Describe "Connect-JCOnline" {

    It "Connects to JumpCloud with a single admin API Key using force" {
        $Connect = Connect-JCOnline -JumpCloudAPIKey "$SingleAdminAPIKey" -force
        $Connect | Should -be $null
    }
}
#region policy test data validation
$MultiplePolicyList = @('','','') #Populate with multiple policy names.
$SinglePolicyList = @('') #Populate with single policy name.
$Policies = Get-JCPolicy
$SystemIDWithPolicyResult = Get-JCSystem -SystemID ''
$SinglePolicy = $Policies | Where {$_.Name -eq $SinglePolicyList}
$MultiplePolicy = $Policies | Where {$_.Name -in $MultiplePolicyList}
If ($($Policies._id.Count) -le 1) {Write-Error 'You must have at least 2 JumpCloud policies to run the Pester tests'; break}
Write-Host "There are $($Policies.Count) policies"
#endregion policy test data validation
Describe 'Get-JCPolicy' {

    It "Returns a single JumpCloud Policy declaring -PolicyId" {
        $SingleResult = Get-JCPolicy -PolicyId:($SinglePolicy.id)
        $SingleResult.id.Count | Should Be $SinglePolicyList.Count
    }

    It "Returns a single JumpCloud policy without declaring -PolicyId" {
        $SingleResult = Get-JCPolicy $SinglePolicy.id
        $SingleResult.id.Count | Should Be $SinglePolicyList.Count
    }

    It "Returns a single JumpCloud policy using -PolicyId passed through the pipeline" {
        $SingleResult = $SinglePolicy | Get-JCPolicy -ByID
        $SingleResult.id.Count | Should Be $SinglePolicyList.Count
    }

    It "Returns a single JumpCloud policy passed through the pipeline without declaring -ByID" {
        $SingleResult = $SinglePolicy | Get-JCPolicy
        $SingleResult.id.Count | Should Be $SinglePolicyList.Count
    }

    It "Returns all JumpCloud Policies passed through the pipeline declaring -ByID" {
        $MultiResult = $MultiplePolicy | Get-JCPolicy -ByID
        $MultiResult._id.Count | Should Be $MultiplePolicyList.Count
    }

    It "Returns a single JumpCloud Policy declaring -Name" {
        $SingleResult = Get-JCPolicy -PolicyId:($SinglePolicy.id)
        $SingleResult.id.Count | Should Be $SinglePolicyList.Count
    }

    It "Returns a specific single JumpCloud Policy declaring -Name" {
        $SingleResult = Get-JCPolicy -Name:($SinglePolicy.Name)
        $SingleResult.Name | Should Be $SinglePolicy.Name
    }
}
Describe 'Get-JCPolicyTargetGroup' {

    It "Returns all JumpCloud policy group targets by GroupName using PolicyId" {
        $SystemGroupTarget = Get-JCPolicyTargetGroup -PolicyId:($SinglePolicy.id)
        $SystemGroupTarget.GroupName.count | Should -BeGreaterThan 0
    }

    It "Returns all JumpCloud policy group targets by GroupName using PolicyName" {
        $SystemGroupTarget = Get-JCPolicyTargetGroup -PolicyName:($SinglePolicy.name)
        $SystemGroupTarget.GroupName.count | Should -BeGreaterThan 0
    }

    It "Returns all JumpCloud policy system group targets using the pipeline and group id" {
        $AllPolicy = $MultiplePolicy | Get-JCPolicyTargetGroup
        $AllPolicy.PolicyId.count | Should -BeGreaterThan 0
    }

    It "Returns all JumpCloud policy system group targets using the pipeline and group name" {
        $AllPolicy = $MultiplePolicy | Get-JCPolicyTargetGroup -ByName
        $AllPolicy.PolicyId.count | Should -BeGreaterThan 0
    }
}

Describe 'Get-JCPolicyTargetSystem' {

    It "Returns all JumpCloud policy system targets using PolicyId" {
        $SystemTarget = Get-JCPolicyTargetSystem -PolicyId:($SinglePolicy.id)
        $SystemTarget.SystemID.count | Should -BeGreaterThan 0
    }

    It "Returns all JumpCloud policy system targets using PolicyName" {
        $SystemTarget = Get-JCPolicyTargetSystem -PolicyName:($SinglePolicy.name)
        $SystemTarget.SystemID.count | Should -BeGreaterThan 0
    }

    It "Returns all JumpCloud policy system targets using the pipeline and group id" {
        $AllPolicy = $MultiplePolicy  | ForEach-Object { Get-JCPolicyTargetSystem $_.id}
        $AllPolicy.PolicyId.count | Should -BeGreaterThan 0
    }

    It "Returns all JumpCloud policy system targets using the pipeline and group name" {
        $AllPolicy = $MultiplePolicy | ForEach-Object { Get-JCPolicyTargetSystem -PolicyName:($_.name)}
        $AllPolicy.PolicyId.count | Should -BeGreaterThan 0
    }
}

Describe "Get-JCPolicyResult" {

    It "Returns a policy result with the PolicyName" {
        $PolicyResult = Get-JCPolicyResult $SinglePolicy.Name
        $PolicyResult.count | Should -BeGreaterThan 0
    }

    It "Returns a policy result with the PolicyId" {
        $PolicyResult = Get-JCPolicyResult -PolicyId:($SinglePolicy.id)
        $PolicyResult.id.count | Should -BeGreaterThan 0
    }

    It "Returns a policy result with the SystemID" {
        $SingleSystem = Get-JCSystem | Select-Object -Last 1
        $PolicyResult = Get-JCPolicyResult -SystemID:($SystemIDWithPolicyResult._id)
        $PolicyResult.id.count | Should -BeGreaterThan 0
    }

    It "Returns a policy result using the -ByPolicyID switch parameter via the pipeline" {


        $PolicyResultVar = Get-JCPolicyResult -PolicyId:($SinglePolicy.id)

        $PolicyResult = $PolicyResultVar | Get-JCPolicyResult -ByPolicyID

        $PolicyResult.id.count | Should -BeGreaterThan 0
    
    }
    
    It "Returns a policy using the -BySystemID switch parameter via the pipeline " {

        $PolicyResultVar = Get-JCPolicyResult -PolicyId:($SinglePolicy.id)

        $PolicyResult = $PolicyResultVar | Get-JCPolicyResult -BySystemID

        $PolicyResult.id.count | Should -BeGreaterThan 0

    }
}


Describe "New-JCUser MFA with enrollment periods" {

    It "Creates a new user with enable_user_portal_multifactor -eq True" {


        $Newuser = New-RandomUser | New-JCUser -enable_user_portal_multifactor $true

        $DateCheck = (Get-Date).AddDays(7).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfaData.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfaData.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 1

        $Newuser  | Remove-JCUser -ByID -force

    }

    It "Creates a new user with enable_user_portal_multifactor -eq True and a 30 days specified for EnrollmentDays" {

        $EnrollmentDays = 30

        $Newuser = New-RandomUser | New-JCUser -enable_user_portal_multifactor $true -EnrollmentDays $EnrollmentDays

        $DateCheck = (Get-Date).AddDays($EnrollmentDays).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfaData.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfaData.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 1

        $Newuser  | Remove-JCUser -ByID -force

    }

    It "Creates a new user with enable_user_portal_multifactor -eq True and a 365 days specified for EnrollmentDays" {

        $EnrollmentDays = 365

        $Newuser = New-RandomUser | New-JCUser -enable_user_portal_multifactor $true -EnrollmentDays $EnrollmentDays

        $DateCheck = (Get-Date).AddDays($EnrollmentDays).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfaData.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfaData.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 1

        $Newuser  | Remove-JCUser -ByID -force

    }

    It "Creates a new user with enable_user_portal_multifactor -eq True and a 366 days specified for EnrollmentDays (invalid)" {

        $EnrollmentDays = 366

        {$Newuser = New-RandomUser | New-JCUser -enable_user_portal_multifactor $true -EnrollmentDays $EnrollmentDays} | Should Throw "Cannot validate argument on parameter 'EnrollmentDays'. The 366 argument is greater than the maximum allowed range of 365. Supply an argument that is less than or equal to 365 and then try the command again."


    }

    It "Creates a new user with enable_user_portal_multifactor -eq True with Attributes" {

        $NewUser = New-RandomUser -Attributes | New-JCUser -NumberOfCustomAttributes 2 -enable_user_portal_multifactor $True

        $DateCheck = (Get-Date).AddDays(7).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfaData.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfaData.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 1

        $Newuser  | Remove-JCUser -ByID -force

    }

    It "Creates a new user with enable_user_portal_multifactor -eq True and a 30 days specified for EnrollmentDays with Attributes" {

        $EnrollmentDays = 30

        $NewUser = New-RandomUser -Attributes | New-JCUser -NumberOfCustomAttributes 2 -enable_user_portal_multifactor $True -EnrollmentDays $EnrollmentDays

        $DateCheck = (Get-Date).AddDays($EnrollmentDays).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfaData.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfaData.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 1

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

        $Newuser.mfaData.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfaData.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 1

        $Newuser  | Remove-JCUser -ByID -force

    }

}

Describe "Set-JCUser MFA Enrollment periods" {

    It "Updates an existing user with enable_user_portal_multifactor -eq False to enable_user_portal_multifactor -eq True " {
        $CreateUser = New-RandomUser | New-JCUser -enable_user_portal_multifactor $false

        $NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $true

        $DateCheck = (Get-Date).AddDays(7).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfaData.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfaData.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 1

        $Newuser  | Remove-JCUser -ByID -force

    }

    It "Updates an existing user with enable_user_portal_multifactor -eq False to enable_user_portal_multifactor -eq True and a 30 days specified for EnrollmentDays" {

        $CreateUser = New-RandomUser | New-JCUser -enable_user_portal_multifactor $false

        $EnrollmentDays = 30

        $NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $true -EnrollmentDays $EnrollmentDays

        $DateCheck = (Get-Date).AddDays($EnrollmentDays).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfaData.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfaData.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 1

        $Newuser  | Remove-JCUser -ByID -force


    }

    It "Updates an existing user with enable_user_portal_multifactor -eq True and a 365 days specified for EnrollmentDays" {

        $CreateUser = New-RandomUser | New-JCUser -enable_user_portal_multifactor $false

        $EnrollmentDays = 365

        $NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $true -EnrollmentDays $EnrollmentDays

        $DateCheck = (Get-Date).AddDays($EnrollmentDays).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfaData.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfaData.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 1

        $Newuser  | Remove-JCUser -ByID -force
    }

    It "Updates an existing user with enable_user_portal_multifactor -eq False to enable_user_portal_multifactor -eq True -ByID" {
        $CreateUser = New-RandomUser | New-JCUser -enable_user_portal_multifactor $false

        $NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $true -ByID

        $DateCheck = (Get-Date).AddDays(7).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfaData.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfaData.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 1

        $Newuser  | Remove-JCUser -ByID -force

    }

    It "Updates an existing user with enable_user_portal_multifactor -eq False to enable_user_portal_multifactor -eq True and a 30 days specified for EnrollmentDays -ByID" {

        $CreateUser = New-RandomUser | New-JCUser -enable_user_portal_multifactor $false

        $EnrollmentDays = 30

        $NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $true -EnrollmentDays $EnrollmentDays -ByID

        $DateCheck = (Get-Date).AddDays($EnrollmentDays).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfaData.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfaData.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 1

        $Newuser  | Remove-JCUser -ByID -force


    }

    It "Updates an existing user with enable_user_portal_multifactor -eq True and a 365 days specified for EnrollmentDays -ByID" {

        $CreateUser = New-RandomUser | New-JCUser -enable_user_portal_multifactor $false

        $EnrollmentDays = 365

        $NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $true -EnrollmentDays $EnrollmentDays -ByID

        $DateCheck = (Get-Date).AddDays($EnrollmentDays).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfaData.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfaData.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 1

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

        $Newuser.mfaData.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfaData.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 1

        $Newuser  | Remove-JCUser -ByID -force

    }

    It "Updates an existing user with enable_user_portal_multifactor -eq True and a 30 days specified for EnrollmentDays with Attributes" {

        $EnrollmentDays = 30

        $CreateUser = New-RandomUser -Attributes | New-JCUser -NumberOfCustomAttributes 2 -enable_user_portal_multifactor $True

        $NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $true -EnrollmentDays $EnrollmentDays -NumberOfCustomAttributes 1 -Attribute1_name 'attr1' -Attribute1_value 'attr1v'

        $DateCheck = (Get-Date).AddDays($EnrollmentDays).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfaData.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfaData.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 1

        $Newuser  | Remove-JCUser -ByID -force



    }

    It "Updates an existing user with enable_user_portal_multifactor -eq True with removeAttributes" {
        $CreateUser = New-RandomUser -Attributes | New-JCUser -NumberOfCustomAttributes 2

        $NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $true -RemoveAttribute 'Department', 'Lang'

        $DateCheck = (Get-Date).AddDays(7).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfaData.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfaData.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 1

        $Newuser  | Remove-JCUser -ByID -force
    }

    It "Updates an existing user with enable_user_portal_multifactor -eq True and a 30 days specified for EnrollmentDays with removeAttributes" {

        $CreateUser = New-RandomUser | New-JCUser -enable_user_portal_multifactor $true

        $EnrollmentDays = 30

        $NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $true -EnrollmentDays $EnrollmentDays

        $DateCheck = (Get-Date).AddDays($EnrollmentDays).AddHours(7) # +7 hours for UTC offset

        $Newuser.mfaData.exclusion | Should -Be $true

        $DateConfirm = New-TimeSpan -Start $Newuser.mfaData.exclusionUntil -End $DateCheck

        $DateConfirm.Seconds | Should -BeLessThan 1

        $Newuser  | Remove-JCUser -ByID -force



    }

    It "Disabled MFA enrollment by setting  enable_user_portal_multifactor to False" {

        $CreateUser = New-RandomUser | New-JCUser -enable_user_portal_multifactor $true

        $EnrollmentDays = 30

        $NewUser = $CreateUser | Set-JCUser -enable_user_portal_multifactor $false

        $Newuser.mfaData.exclusion | Should -Be $false

        $Newuser.mfaData.exclusionUntil | Should -BeNullOrEmpty

    }

}
