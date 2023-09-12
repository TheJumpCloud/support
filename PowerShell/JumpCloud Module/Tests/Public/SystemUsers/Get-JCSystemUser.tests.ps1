Describe -Tag:('JCSystemUser') 'Get-JCSystemUser 1.0' {

    BeforeEach {
        $RandomString1 = ( -join (( 0x41..0x5A) + ( 0x61..0x7A) | Get-Random -Count 8 | ForEach-Object { [char]$_ }))

        $NewUser1 = @{
            email     = "$($RandomString1)su@DeleteMe.com"
            firstname = 'pester_sysUser1'
            lastname  = 'pester_sysLastName'
            username  = "pester.sU_$($RandomString1)"
        };
        $testUser = New-JCUser @NewUser1
        New-JCAssociation -Type system -TargetType user -Id $PesterParams_SystemLinux._id -TargetId $testUser.id -Force
    }
    It "Gets JumpCloud system users for a system using SystemID" {

        $SystemUsers = Get-JCSystemUser -SystemID  $PesterParams_SystemLinux._id
        $SystemUsers.username.Count | Should -BeGreaterThan 1
    }
    AfterEach {
        Remove-JCAssociation -Type system -TargetType user -Id $PesterParams_SystemLinux._id -TargetId $testUser.id -Force
    }
}
