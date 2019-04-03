Describe 'Get-JCSystemUser' {

    It "Gets JumpCloud system users for a system using SystemID" {

        $SystemUsers = Get-JCSystemUser -SystemID  $PesterParams.SystemID
        $SystemUsers.username.Count | Should -BeGreaterThan 1
    }

    It "Gets all JumpCloud system user associations using Get-JCsystem and the pipeline" {

        $AllSystemUsers = Get-JCSystem | Get-JCSystemUser
        $Systems = $AllSystemUsers.SystemID | Select-Object -Unique | Measure-Object
        $Systems.Count | Should -BeGreaterThan 1
    }
}