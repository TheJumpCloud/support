Describe -Tag:('MSP') 'Get-JCConfiguredTemplatePolicy' {
    # Note for these tests, there's not a public endpoint to delete these objects
    # tests in this file will assume that configuredTemplatePolicy objects exist
    It "Lists all configured template policies" {
        $configuredPolicyTemplates = Get-JCConfiguredTemplatePolicy
        $configuredPolicyTemplates | Should -Not -BeNullOrEmpty
    }
    It "Lists one configured template policies by ID" {
        $configuredPolicyTemplates = Get-JCConfiguredTemplatePolicy
        $testPolicyTemplate = $configuredPolicyTemplates | Select-Object -First 1
        # get a single item:
        $singleConfiguredTemplatePolicy = Get-JCConfiguredTemplatePolicy -ConfiguredTemplatePolicyID $testPolicyTemplate.id
        $singleConfiguredTemplatePolicy | Should -Not -BeNullOrEmpty
        $singleConfiguredTemplatePolicy.id | Should -Be $testPolicyTemplate.id
        $singleConfiguredTemplatePolicy.name | Should -Be $testPolicyTemplate.name
        $singleConfiguredTemplatePolicy.policyTemplateId | Should -Be $testPolicyTemplate.policyTemplateId
        $singleConfiguredTemplatePolicy.values | Should -Not -BeNullOrEmpty
    }
    It "Lists one configured template policies by Name" {
        $configuredPolicyTemplates = Get-JCConfiguredTemplatePolicy
        $testPolicyTemplate = $configuredPolicyTemplates | Select-Object -First 1
        # get a single item:
        $singleConfiguredTemplatePolicy = Get-JCConfiguredTemplatePolicy -Name $testPolicyTemplate.name
        $singleConfiguredTemplatePolicy | Should -Not -BeNullOrEmpty
        $singleConfiguredTemplatePolicy.id | Should -Be $testPolicyTemplate.id
        $singleConfiguredTemplatePolicy.name | Should -Be $testPolicyTemplate.name
        $singleConfiguredTemplatePolicy.policyTemplateId | Should -Be $testPolicyTemplate.policyTemplateId
        # if you get an item by name it will not contain values:
        $singleConfiguredTemplatePolicy.values | Should -BeNullOrEmpty
    }
    It "Should throw if an there is not an object found byID" {
        { Get-JCConfiguredTemplatePolicy -ConfiguredTemplatePolicyID "111111111111111111111111" } | Should -Throw
    }
    It "Should return nothing if there is not an object found byName" {
        $search = Get-JCConfiguredTemplatePolicy -Name "111111111111111111111111"
        $search | Should -BeNullOrEmpty
    }
}