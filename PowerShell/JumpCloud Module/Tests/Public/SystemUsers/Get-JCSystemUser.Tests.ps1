Describe -Tag:('JCSystemUser') 'Get-JCSystemUser 1.0' {
    BeforeAll {
        $SystemUsers = Get-JCSystemUser -SystemID $PesterParams_SystemLinux._id
        if (-Not $SystemUsers) {
            Add-JCSystemUser -Username $PesterParams_User1.username -SystemID $PesterParams_SystemLinux._id
        }
    }
    It "Gets JumpCloud system users for a system using SystemID" {
        $SystemUsers = Get-JCSystemUser -SystemID $PesterParams_SystemLinux._id
        $SystemUsers.username.Count | Should -BeGreaterOrEqual 1
    }
}
