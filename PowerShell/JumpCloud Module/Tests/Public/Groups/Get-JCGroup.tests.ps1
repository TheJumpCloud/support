Describe -Tag:('JCGroup') 'Get-JCGroup 1.0' {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null }
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

Describe -Tag:('JCGroup') 'Get-JCGroup 1.1.0' {

    It "Gets a JumpCloud UserGroup by Name and Displays Attributes" {

        $Posix = Get-JCGroup -Type User -Name $PesterParams_UserGroup.Name

        $Posix.Attributes | Should -Not -BeNullOrEmpty
    }

}

Describe -Tag:('JCGroup') 'Get-JCGroup 1.12.0' {

    It "Searches for a User group that does not exist and errors" {

        $Random = $(Get-Random)

        Get-JCGroup -Type User -Name $Random -ErrorVariable err -ErrorAction SilentlyContinue

        $err.Count | Should -Not -Be 0

        $err[0].Exception.Message | Should -Be "There is no User group named $Random. NOTE: Group names are case sensitive."
    }

    It "Searches for a System group that does not exist and errors" {

        $Random = $(Get-Random)

        Get-JCGroup -Type System -Name $Random -ErrorVariable err -ErrorAction SilentlyContinue

        $err.Count | Should -Not -Be 0

        $err[0].Exception.Message | Should -Be "There is no System group named $Random. NOTE: Group names are case sensitive."
    }
}
