Describe -Tag:('JCSystemUser') 'Get-JCSystemUser 1.0' {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null }
    It "Gets JumpCloud system users for a system using SystemID" {

        $SystemUsers = Get-JCSystemUser -SystemID  $PesterParams_SystemLinux._id
        $SystemUsers.username.Count | Should -BeGreaterThan 1
    }

    It "Gets JumpCloud system users for a system using SystemID in parallel" {

        $SystemUsers = Get-JCSystemUser -SystemID  $PesterParams_SystemLinux._id -Parallel $true
        $SystemUsers.username.Count | Should -BeGreaterThan 1
    }

}
