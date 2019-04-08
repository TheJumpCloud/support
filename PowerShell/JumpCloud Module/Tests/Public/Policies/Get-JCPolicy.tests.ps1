Connect-JCTestOrg

Describe 'Get-JCPolicy 1.10' {

    It "Returns a single JumpCloud Policy declaring -PolicyId" {
        $SingleResult = Get-JCPolicy -PolicyId:($SinglePolicy.id)
        $SingleResult.id.Count | Should Be $SinglePolicyList.Count
    }

    It "Returns a single JumpCloud policy without declaring -PolicyId" {
        $SingleResult = Get-JCPolicy $SinglePolicy.id
        $SingleResult.id.Count | Should Be $SinglePolicyList.Count
    }

    It "Returns a single JumpCloud policy using -PolicyId passed through the pipeline" {
        $SingleResult = $SinglePolicy | Get-JCPolicy -ByID
        $SingleResult.id.Count | Should Be $SinglePolicyList.Count
    }

    It "Returns a single JumpCloud policy passed through the pipeline without declaring -ByID" {
        $SingleResult = $SinglePolicy | Get-JCPolicy
        $SingleResult.id.Count | Should Be $SinglePolicyList.Count
    }

    It "Returns all JumpCloud Policies passed through the pipeline declaring -ByID" {
        $MultiResult = $MultiplePolicy | Get-JCPolicy -ByID
        $MultiResult._id.Count | Should Be $MultiplePolicyList.Count
    }

    It "Returns a single JumpCloud Policy declaring -Name" {
        $SingleResult = Get-JCPolicy -PolicyId:($SinglePolicy.id)
        $SingleResult.id.Count | Should Be $SinglePolicyList.Count
    }

    It "Returns a specific single JumpCloud Policy declaring -Name" {
        $SingleResult = Get-JCPolicy -Name:($SinglePolicy.Name)
        $SingleResult.Name | Should Be $SinglePolicy.Name
    }
}