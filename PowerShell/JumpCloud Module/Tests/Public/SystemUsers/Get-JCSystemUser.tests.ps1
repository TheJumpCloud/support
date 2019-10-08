Describe -Tag:('JCSystemUser') 'Get-JCSystemUser 1.0' {
    Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force | Out-Null
    It "Gets JumpCloud system users for a system using SystemID" {

        $SystemUsers = Get-JCSystemUser -SystemID  $PesterParams.SystemID
        $SystemUsers.username.Count | Should -BeGreaterThan 1
    }
}
