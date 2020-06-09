Describe -Tag:('JCPolicyTargetGroup') 'Get-JCPolicyTargetGroup 1.10' {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null }
    It "Returns all JumpCloud policy group targets by GroupName using PolicyId" {
        $SystemGroupTarget = Get-JCPolicyTargetGroup -PolicyId:($PesterParams_SinglePolicy.id)
        $SystemGroupTarget.GroupName.count | Should -BeGreaterThan 0
    }

    It "Returns all JumpCloud policy group targets by GroupName using PolicyName" {
        $SystemGroupTarget = Get-JCPolicyTargetGroup -PolicyName:($PesterParams_SinglePolicy.name)
        $SystemGroupTarget.GroupName.count | Should -BeGreaterThan 0
    }

    It "Returns all JumpCloud policy system group targets using the pipeline and group id" {
        $AllPolicy = $PesterParams_MultiplePolicy | Get-JCPolicyTargetGroup
        $AllPolicy.PolicyId.count | Should -BeGreaterThan 0
    }

    It "Returns all JumpCloud policy system group targets using the pipeline and group name" {
        $AllPolicy = $PesterParams_MultiplePolicy | Get-JCPolicyTargetGroup -ByName
        $AllPolicy.PolicyId.count | Should -BeGreaterThan 0
    }
}
