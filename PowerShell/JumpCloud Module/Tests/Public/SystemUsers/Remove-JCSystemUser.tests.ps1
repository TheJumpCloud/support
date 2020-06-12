Describe -Tag:('JCSystemUser') 'Remove-JCSystemUser 1.0' {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null }
    It "Adds a single user to a single system by Username and SystemID" {
        $UserRemove = Remove-JCSystemUser -Username $PesterParams_User1.Username -SystemID $PesterParams_SystemLinux._id -force
        $UserAdd = Add-JCSystemUser -Username $PesterParams_User1.Username -SystemID $PesterParams_SystemLinux._id
        $UserAdd.Status | Should -Be 'Added'
    }

    It "Removes a single user froma single system by Username and SystemID with default warning" {
        $UserRemove = Remove-JCSystemUser -Username $PesterParams_User1.Username -SystemID $PesterParams_SystemLinux._id -force
        $UserRemove.Status | Should -Be 'Removed'
    }

    It "Adds a single user to a single system by UserID and SystemID" {
        $UserAdd = Add-JCSystemUser -UserID $PesterParams_User1.Id -SystemID $PesterParams_SystemLinux._id
        $UserAdd.Status | Should -Be 'Added'
    }

    It "Removes a single user froma single system with -force parameter" {
        $UserRemove = Remove-JCSystemUser -Username $PesterParams_User1.Username -SystemID $PesterParams_SystemLinux._id -force
        $UserRemove.Status | Should -Be 'Removed'
    }

    It "Adds two users to a single system using the pipeline and system ID" {
        $MultiUserAdd = Get-JCUser | Select-Object -Last 2 | Add-JCSystemUser -SystemID $PesterParams_SystemLinux._id
        $MultiUserAdd.Status.Count | Should -Be 2
    }

    It "Removes two users from a single system using the pipeline and system ID using the -force parameter" {
        $MultiUserRemove = Get-JCUser | Select-Object -Last 2 | Remove-JCSystemUser -SystemID $PesterParams_SystemLinux._id -force
        $MultiUserRemove.Status.Count | Should -Be 2
    }

    It "Adds back two users to a single system using the pipeline and system ID" {
        $MultiUserAdd = Get-JCUser | Select-Object -Last 2 | Add-JCSystemUser -SystemID $PesterParams_SystemLinux._id
        $MultiUserAdd.Status.Count | Should -Be 2
    }
}
