Describe -tag:('JCPolicy') 'Get config fields tests' {

    Context 'Test Config Fields for all possible types' {
        $configMapping = Get-JCPolicyConfigMapping
        It 'Get-JCPolicyConfigField should return all types of available policy types' {
            foreach ($configType in $configMapping) {
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
