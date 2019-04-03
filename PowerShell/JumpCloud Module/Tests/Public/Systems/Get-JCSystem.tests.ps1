Describe 'Get-JCSystem' {

    It "Gets all JumpCloud systems" {
        $Systems = Get-JCSystem
        $Systems._id.Count | Should -BeGreaterThan 1
    }

    It "Gets a single JumpCloud system" {
        $SingleSystem = Get-JCSystem -SystemID $PesterParams.SystemID
        $SingleSystem.id.Count | Should -be 1
    }

}