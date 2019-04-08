Connect-JCTestOrg

Describe 'Get-JCPolicyTargetGroup 1.10' {

    It "Returns all JumpCloud policy group targets by GroupName using PolicyId" {
        $SystemGroupTarget = Get-JCPolicyTargetGroup -PolicyId:($SinglePolicy.id)
        $SystemGroupTarget.GroupName.count | Should -BeGreaterThan 0
    }

    It "Returns all JumpCloud policy group targets by GroupName using PolicyName" {
        $SystemGroupTarget = Get-JCPolicyTargetGroup -PolicyName:($SinglePolicy.name)
        $SystemGroupTarget.GroupName.count | Should -BeGreaterThan 0
    }

    It "Returns all JumpCloud policy system group targets using the pipeline and group id" {
        $AllPolicy = $MultiplePolicy | Get-JCPolicyTargetGroup
        $AllPolicy.PolicyId.count | Should -BeGreaterThan 0
    }

    It "Returns all JumpCloud policy system group targets using the pipeline and group name" {
        $AllPolicy = $MultiplePolicy | Get-JCPolicyTargetGroup -ByName
        $AllPolicy.PolicyId.count | Should -BeGreaterThan 0
    }
}