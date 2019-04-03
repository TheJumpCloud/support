Describe 'Get-JCGroup' {

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