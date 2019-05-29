Connect-JCOnlineTest

Describe "Get-JCPolicyResult 1.10" {

    It "Returns a policy result with the PolicyName" {
        $PolicyResult = Get-JCPolicyResult $SinglePolicy.Name
        $PolicyResult.count | Should -BeGreaterThan 0
    }

    It "Returns a policy result with the PolicyId" {
        $PolicyResult = Get-JCPolicyResult -PolicyId:($SinglePolicy.id)
        $PolicyResult.id.count | Should -BeGreaterThan 0
    }

    It "Returns a policy result with the SystemID" {
        $SingleSystem = Get-JCSystem | Select-Object -Last 1
        $PolicyResult = Get-JCPolicyResult -SystemID:($SystemIDWithPolicyResult._id)
        $PolicyResult.id.count | Should -BeGreaterThan 0
    }

    It "Returns a policy result using the -ByPolicyID switch parameter via the pipeline" {


        $PolicyResultVar = Get-JCPolicyResult -PolicyId:($SinglePolicy.id)

        $PolicyResult = $PolicyResultVar | Get-JCPolicyResult -ByPolicyID

        $PolicyResult.id.count | Should -BeGreaterThan 0

    }

    It "Returns a policy using the -BySystemID switch parameter via the pipeline " {

        $PolicyResultVar = Get-JCPolicyResult -PolicyId:($SinglePolicy.id)

        $PolicyResult = $PolicyResultVar | Get-JCPolicyResult -BySystemID

        $PolicyResult.id.count | Should -BeGreaterThan 0

    }

}