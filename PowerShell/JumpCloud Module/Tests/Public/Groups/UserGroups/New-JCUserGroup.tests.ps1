Connect-JCOnlineTest

Describe -Tag:('JCUserGroup') 'New-JCUserGroup 1.0' {

    It "Creates a new user group" {
        $NewG = New-JCUserGroup -GroupName $(New-RandomString 8)
        $NewG.Result | Should -Be 'Created'
        $DeletedG = Remove-JCUserGroup -GroupName $NewG.name  -force
    }

}
