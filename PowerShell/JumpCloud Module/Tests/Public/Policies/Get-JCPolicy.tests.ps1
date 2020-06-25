Describe -Tag:('JCPolicy') 'Get-JCPolicy 1.10' {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null }
    It "Returns a single JumpCloud Policy declaring -PolicyId" {
        $SingleResult = Get-JCPolicy -PolicyId:($PesterParams_SinglePolicy.id)
        $SingleResult.id.Count | Should -Be $PesterParams_SinglePolicyList.Count
    }

    It "Returns a single JumpCloud policy without declaring -PolicyId" {
        $SingleResult = Get-JCPolicy $PesterParams_SinglePolicy.id
        $SingleResult.id.Count | Should -Be $PesterParams_SinglePolicyList.Count
    }

    It "Returns a single JumpCloud policy using -PolicyId passed through the pipeline" {
        $SingleResult = $PesterParams_SinglePolicy | Get-JCPolicy -ByID
        $SingleResult.id.Count | Should -Be $PesterParams_SinglePolicyList.Count
    }

    It "Returns a single JumpCloud policy passed through the pipeline without declaring -ByID" {
        $SingleResult = $PesterParams_SinglePolicy | Get-JCPolicy
        $SingleResult.id.Count | Should -Be $PesterParams_SinglePolicyList.Count
    }

    It "Returns all JumpCloud Policies passed through the pipeline declaring -ByID" {
        $MultiResult = $PesterParams_MultiplePolicy | Get-JCPolicy -ByID
        $MultiResult._id.Count | Should -Be $PesterParams_MultiplePolicyList.Count
    }

    It "Returns a single JumpCloud Policy declaring -Name" {
        $SingleResult = Get-JCPolicy -PolicyId:($PesterParams_SinglePolicy.id)
        $SingleResult.id.Count | Should -Be $PesterParams_SinglePolicyList.Count
    }

    It "Returns a specific single JumpCloud Policy declaring -Name" {
        $SingleResult = Get-JCPolicy -Name:($PesterParams_SinglePolicy.Name)
        $SingleResult.Name | Should -Be $PesterParams_SinglePolicy.Name
    }
}
