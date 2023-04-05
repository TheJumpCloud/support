BeforeAll {
}
Describe -tag 'Get config fields tests' 'JCPolicy' {

    Context 'Test Config Fields for all possible types' {
        # . "/Users/jworkman/Documents/GitHub/support/PowerShell/JumpCloud Module/Private/Policies/Enumerate-JCPolicyConfigMapping.ps1"
        # . "/Users/jworkman/Documents/GitHub/support/PowerShell/JumpCloud Module/Private/Policies/Get-JCPolicyTemplateConfigField.ps1"
        $configMappint = Enumerate-JCPolicyConfigMapping
        It 'Get-JCPolicyConfigField should return all types of available policy types' {
            foreach ($configType in $configMappint) {
                $object = Get-JCPolicyTemplateConfigField -templateID $configType.value
                $object | Should -Not -BeNullOrEmpty
                foreach ($objectField in $object) {
                    $objectField.configFieldID | Should -Not -BeNullOrEmpty
                    $objectField.label | Should -Not -BeNullOrEmpty
                    $objectField.configFieldName | Should -Not -BeNullOrEmpty
                    $objectField.position | Should -Not -BeNullOrEmpty
                    $objectField.type | Should -Not -BeNullOrEmpty
                }
            }
        }
    }
}
