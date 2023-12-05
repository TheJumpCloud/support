Describe -Tag:('JCCloudDirectory') 'Set-JCCloudDirectory' {
    BeforeAll {
        $Office365DirectoryList = Get-JCCloudDirectory -Type 'office_365' | Select -First 1
        $Office365Directory = Get-JCCloudDirectory -id $Office365DirectoryList.id
        $GsuiteDirectoryList = Get-JCCloudDirectory -Type 'g_suite' | Select -First 1
        $GsuiteDirectory = Get-JCCloudDirectory -id $GsuiteDirectoryList.id
    }
    It 'Sets GroupsEnabled field by Id' {
        $GroupsEnabledTest = Set-JCCloudDirectory -Id $Office365Directory.Id -GroupsEnabled $true
        $GroupsEnabledTest.GroupsEnabled | Should -Be $true
    }
    It 'Sets GroupsEnabled field by Name' {
        $GroupsEnabledTest = Set-JCCloudDirectory -Name $Office365Directory.Name -GroupsEnabled $true
        $GroupsEnabledTest.GroupsEnabled | Should -Be $true
    }
    It 'Sets NewName field by Id' {
        $NewNameTest = Set-JCCloudDirectory -Id $Office365Directory.Id -NewName "$($Office365Directory.Name)-1"
        $NewNameTest.Name | Should -Be "$($Office365Directory.Name)-1"
        Set-JCCloudDirectory -Id $Office365Directory.Id -NewName "$($Office365Directory.Name)"
    }
    It 'Sets NewName field by Name' {
        $NewNameTest = Set-JCCloudDirectory -Name $Office365Directory.Name -NewName "$($Office365Directory.Name)-2"
        $NewNameTest.Name | Should -Be "$($Office365Directory.Name)-2"
        Set-JCCloudDirectory -Id $Office365Directory.Id -NewName "$($Office365Directory.Name)"
    }
    It 'Sets UserLockoutAction by Id' {
        $LockoutActionTest = Set-JCCloudDirectory -Id $Office365Directory.Id -UserLockoutAction 'suspend'
        $LockoutActionTest.UserLockoutAction | Should -Be 'suspend'
    }
    It 'Sets UserLockoutAction by Name' {
        $LockoutActionTest = Set-JCCloudDirectory -Name $Office365Directory.Name -UserLockoutAction 'suspend'
        $LockoutActionTest.UserLockoutAction | Should -Be 'suspend'
    }
    It 'Sets UserPasswordExpirationAction by Id' {
        $PasswordExpAction = Set-JCCloudDirectory -Id $Office365Directory.Id -UserPasswordExpirationAction 'suspend'
        $PasswordExpAction.UserLockoutAction | Should -Be 'suspend'
    }
    It 'Sets UserPasswordExpirationAction by Name' {
        $PasswordExpAction = Set-JCCloudDirectory -Name $Office365Directory.Name -UserPasswordExpirationAction 'suspend'
        $PasswordExpAction.UserPasswordExpirationAction | Should -Be 'suspend'
    }
    It 'Set UserPasswordExpirationAction to remove_access for Office365 directory' {
        { $PasswordExpAction = Set-JCCloudDirectory -Name $Office365Directory.Name -UserPasswordExpirationAction 'remove_access' } | Should -Throw
    }
    It 'Set UserPasswordExpirationAction to remove_access for Gsuite directory' {
        { Set-JCCloudDirectory -Name $GsuiteDirectory.Name -UserPasswordExpirationAction 'remove_access' } | Should -Not -Throw
        $PasswordExpAction = Get-JCCloudDirectory -Name $GsuiteDirectory.Name
        $PasswordExpAction.UserPasswordExpirationAction | Should -Be 'remove_access'
        Set-JCCloudDirectory -Name $GsuiteDirectory.Name -UserPasswordExpirationAction $GsuiteDirectory.UserPasswordExpirationAction
    }
    AfterAll {
        # Set values back to default
        Set-JCCloudDirectory -Id $Office365Directory.Id -NewName $Office365Directory.Name -UserLockoutAction $Office365Directory.UserLockoutAction -UserPasswordExpirationAction $Office365Directory.UserPasswordExpirationAction -GroupsEnabled $Office365Directory.GroupsEnabled
    }
}