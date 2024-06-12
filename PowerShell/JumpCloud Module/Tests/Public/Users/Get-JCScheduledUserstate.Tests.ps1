Describe -Tag:('JCScheduledUserstate') 'Get-JCScheduledUserstate' {
    BeforeAll {
        # Create a few users to test suspension and activation
        $NewStateUser1 = New-RandomUser -domain "delNewUser.$(New-RandomString -NumberOfChars 5)" | New-JCUser
        $NewStateUser2 = New-RandomUser -domain "delNewUser.$(New-RandomString -NumberOfChars 5)" | New-JCUser
        $NewStateUser3 = New-RandomUser -domain "delNewUser.$(New-RandomString -NumberOfChars 5)" | New-JCUser -state "SUSPENDED"

        $ScheduledSuspension = New-JcSdkBulkUserState -UserIds @($($NewStateUser1.Id), $($NewStateUser2.Id)) -State 'SUSPENDED' -StartDate (Get-Date -Hour 12 -Minute 0 -Second 0 -Millisecond 0).AddDays(1)
        $ScheduledActivation = New-JcSdkBulkUserState -UserIds $NewStateUser3.Id -State 'ACTIVATED' -StartDate (Get-Date -Hour 12 -Minute 0 -Second 0 -Millisecond 0).AddDays(1)
    }
    It "Gets scheduled SUSPENDED users" {
        $scheduledUsers = Get-JCScheduledUserstate -State "SUSPENDED"
        $scheduledUsers.count | Should -Be 2

        $scheduledUsers.id | Should -Not -BeNullOrEmpty
        $scheduledUsers.Firstname | Should -Not -BeNullOrEmpty
        $scheduledUsers.Lastname | Should -Not -BeNullOrEmpty
        $scheduledUsers.Email | Should -Not -BeNullOrEmpty
        $scheduledUsers.Username | Should -Not -BeNullOrEmpty
        $scheduledUsers.ScheduledDate | Select-Object -First 1 | Should -Be (Get-Date -Hour 12 -Minute 0 -Second 0 -Millisecond 0).AddDays(1)
    }
    It "Gets scheduled ACTIVATED users" {
        $scheduledUsers = Get-JCScheduledUserstate -State "ACTIVATED"
        $scheduledUsers.count | Should -Be 1

        $scheduledUsers.id | Should -Not -BeNullOrEmpty
        $scheduledUsers.Firstname | Should -Not -BeNullOrEmpty
        $scheduledUsers.Lastname | Should -Not -BeNullOrEmpty
        $scheduledUsers.Email | Should -Not -BeNullOrEmpty
        $scheduledUsers.Username | Should -Not -BeNullOrEmpty
        $scheduledUsers.ScheduledDate | Should -Be (Get-Date -Hour 12 -Minute 0 -Second 0 -Millisecond 0).AddDays(1)
    }
    It "Gets scheduled user by ID" {
        $scheduledUsers = Get-JCScheduledUserstate -UserID $NewStateUser1.Id

        $scheduledUsers.id | Should -Not -BeNullOrEmpty
        $scheduledUsers.Firstname | Should -Not -BeNullOrEmpty
        $scheduledUsers.Lastname | Should -Not -BeNullOrEmpty
        $scheduledUsers.Email | Should -Not -BeNullOrEmpty
        $scheduledUsers.Username | Should -Not -BeNullOrEmpty
        $scheduledUsers.ScheduledDate | Should -Be (Get-Date -Hour 12 -Minute 0 -Second 0 -Millisecond 0).AddDays(1)
    }
    It "Gets scheduled user by ID with 2 userstate changes" {
        $NewScheduledSuspension = New-JcSdkBulkUserState -UserIds $NewStateUser3.Id -State 'SUSPENDED' -StartDate (Get-Date -Hour 12 -Minute 0 -Second 0 -Millisecond 0).AddDays(1)
        $scheduledUsers = Get-JCScheduledUserstate -UserID $NewStateUser3.Id
        $scheduledUsers.count | Should -Be 2

        $scheduledUsers.id | Should -Not -BeNullOrEmpty
        $scheduledUsers.Firstname | Should -Not -BeNullOrEmpty
        $scheduledUsers.Lastname | Should -Not -BeNullOrEmpty
        $scheduledUsers.Email | Should -Not -BeNullOrEmpty
        $scheduledUsers.Username | Should -Not -BeNullOrEmpty
        $scheduledUsers.ScheduledDate | Should -Not -BeNullOrEmpty
    }
    AfterAll {
        Remove-JCUser -UserID $NewStateUser1.Id -ByID -force
        Remove-JCUser -UserID $NewStateUser2.Id -ByID -force
        Remove-JCUser -UserID $NewStateUser3.Id -ByID -force
    }
}