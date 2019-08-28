Describe -Tag:('JCUserGroup') 'New-JCUserGroup 1.0' {
    Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force | Out-Null
    It "Creates a new user group" {
        $NewG = New-JCUserGroup -GroupName $(New-RandomString 8)
        $DeletedG = Remove-JCUserGroup -GroupName $NewG.name  -force
        $DeletedG.Result | Should -Be 'Deleted'

    }

}
