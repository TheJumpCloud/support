Connect-JCTestOrg

Describe 'Get-JCGroup 1.0' {

    It 'Gets all groups: System and User' {

        $Groups = Get-JCGroup
        $TwoGroups = $Groups.type | Select-Object -Unique | Measure-Object
        $TwoGroups.Count | Should -Be 2
    }

    It 'Gets all JumpCloud User Groups' {

        $UserGroups = Get-JCGroup -Type User
        $OneGroup = $UserGroups.type | Select-Object -Unique | Measure-Object
        $OneGroup.Count | Should -Be 1

    }

    It 'Gets all JumpCloud System Groups' {

        $SystemGroups = Get-JCGroup -Type System
        $OneGroup = $SystemGroups.type | Select-Object -Unique | Measure-Object
        $OneGroup.Count | Should -Be 1

    }

}

Describe 'Get-JCGroup 1.1.0' {

    It "Gets a JumpCloud UserGroup by Name and Displays Attributes" {
        
        $Posix = Get-JCGroup -Type User -Name $PesterParams.UserGroupName

        $Posix.Attributes | Should -Not -BeNullOrEmpty
    }

}
