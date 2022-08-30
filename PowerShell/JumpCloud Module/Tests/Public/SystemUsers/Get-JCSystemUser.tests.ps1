Describe -Tag:('JCSystemUser') 'Get-JCSystemUser 1.0' {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null }
    It "Gets JumpCloud system users for a system using SystemID" {

        $SystemUsers = Get-JCSystemUser -SystemID  $PesterParams_SystemLinux._id
        $SystemUsers.username.Count | Should -BeGreaterThan 1
    }
}
