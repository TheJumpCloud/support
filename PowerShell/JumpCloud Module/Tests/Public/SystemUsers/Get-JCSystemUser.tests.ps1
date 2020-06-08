Describe -Tag:('JCSystemUser') 'Get-JCSystemUser 1.0' {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force | Out-Null }
    It "Gets JumpCloud system users for a system using SystemID" {

        $SystemUsers = Get-JCSystemUser -SystemID  $PesterParams_SystemID
        $SystemUsers.username.Count | Should -BeGreaterThan 1
    }

}
