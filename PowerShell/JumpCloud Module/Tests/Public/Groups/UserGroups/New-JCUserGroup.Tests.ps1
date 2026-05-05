Describe -Tag:('JCUserGroup') 'New-JCUserGroup 1.0' {
    BeforeAll {  }
    It "Creates a new user group" {
        $NewG = New-JCUserGroup -GroupName ("Group-" + [guid]::NewGuid().ToString('N').Substring(0,8))
        $NewG.Result | Should -Be 'Created'
        $DeletedG = Remove-JCUserGroup -GroupName $NewG.name -Force
    }
}
