$SingleAdminAPIKey = ''
Describe "Connect-JCOnline" {

    It "Connects to JumpCloud with a single admin API Key using force" {
        
        $Connect = Connect-JCOnline -JumpCloudAPIKey "$SingleAdminAPIKey" -force
        $Connect | Should -be $null

    }
}

#region policy test data validation
$Policies = Get-JCPolicy

if ($($Policies._id.Count) -le 1)
{Write-Error 'You must have at least 2 JumpCloud policies to run the Pester tests'; break}

Write-Host "There are $($Policies.Count) policies"

#endregion policy test data validation

Describe 'Get-JCPolicy' {

    It "Returns all JumpCloud Policies" {
        $AllPolicies = Get-JCPolicy
        $AllPolicies.id.Count | Should -BeGreaterThan 1
    }

    It "Returns a single JumpCloud Policy declaring -PolicyID" {
        $SinglePolicy = Get-JCPolicy | Select-Object -Last 1
        $SingleResult = Get-JCPolicy -PolicyID $SinglePolicy.id
        $SingleResult.id.Count | Should Be 1
    }

    It "Returns a single JumpCloud policy without declaring -PolicyID" {
        $SinglePolicy = Get-JCPolicy | Select-Object -Last 1
        $SingleResult = Get-JCPOlicy $SinglePolicy.id
        $SingleResult.id.Count | Should Be 1
    }

    It "Returns a single JumpCloud policy using -PolicyID passed through the pipeline" {
        $SingleResult = Get-JCPolicy | Select-Object -last 1 id | Get-JCPolicy -ByID
        $SingleResult.id.Count | Should Be 1
    }

    It "Returns a single JumpCloud policy passed through the pipeline without declaring -ByID" {
        $SingleResult = Get-JCPolicy | Select-Object -Last 1 | Get-JCPolicy
        $SingleResult.id.Count | Should Be 1
    }

    It "Returns all JumpCloud Policies passed through the pipeline declaring -ByID" {
        $MultiResult = Get-JCPolicy | Get-JCPolicy -ByID
        $MultiResult._id.Count | Should -BeGreaterThan 1
    }

    It "Returns a single JumpCloud Policy declaring -Name" {
        $SinglePolicy = Get-JCPolicy | Select-Object -Last 1
        $SingleResult = Get-JCPolicy -PolicyID $SinglePolicy.id
        $SingleResult.id.Count | Should Be 1
    }

    It "Returns a specific single JumpCloud Policy declaring -Name" {
        $SinglePolicy = Get-JCPolicy | Select-Object -Last 1
        $SingleResult = Get-JCPolicy -Name $SinglePolicy.Name
        $SingleResult.Name | Should Be $SinglePolicy.Name
    }
}
Describe 'Get-JCPolicyTargetGroup' {

    it "Returns all JumpCloud policy group targets by groupname using policyid" {
        $SinglePolicy = Get-JCPolicy | Select-Object -Last 1 
        $SystemGroupTarget = Get-JCPolicyTargetGroup -PolicyID $SinglePolicy.id
        $SystemGroupTarget.Groupname.count | Should -BeGreaterThan 0
    }

    it "Returns all JumpCloud policy group targets by groupname using policyname" {
        $SinglePolicy = Get-JCPolicy | Select-Object -Last 1 
        $SystemGroupTarget = Get-JCPolicyTargetGroup -PolicyName $SinglePolicy.name
        $SystemGroupTarget.Groupname.count | Should -BeGreaterThan 0
    }

    it "Returns all JumpCloud policy system group targets using the pipeline and group id" {
        $Allpolicy = Get-JCPolicy | Get-JCPolicyTargetGroup
        $Allpolicy.PolicyID.count | Should -BeGreaterThan 1
    }

    it "Returns all JumpCloud policy system group targets using the pipeline and group name" {
        $Allpolicy = Get-JCPolicy | Get-JCPolicyTargetGroup -ByName
        $Allpolicy.PolicyID.count | Should -BeGreaterThan 1
    }
}

Describe 'Get-JCPolicyTargetSystem' {

    it "Returns all JumpCloud policy system targets using policyid" {
        $SinglePolicy = Get-JCPolicy | Select-Object -Last 1
        $SystemTarget = Get-JCPolicyTargetSystem -PolicyID $SinglePolicy.id
        $SystemTarget.SystemID.count | Should -BeGreaterThan 0
    }

    it "Returns all JumpCloud policy system targets using policyname" {
        $SinglePolicy = Get-JCPolicy | Select-Object -Last 1
        $SystemTarget = Get-JCPolicyTargetSystem -PolicyName $SinglePolicy.name
        $SystemTarget.SystemID.count | Should -BeGreaterThan 0
    }

    it "Returns all JumpCloud policy system targets using the pipeline and group id" {

        $Allpolicy = (Get-JCPolicy) | %{ Get-JCPolicyTargetSystem $_.id}
        $Allpolicy.PolicyID.count | Should -BeGreaterThan 1
    }

    it "Returns all JumpCloud policy system targets using the pipeline and group name" {

        $Allpolicy = (Get-JCPolicy) | %{ Get-JCPolicyTargetSystem -policyname:($_.name)}
        $Allpolicy.PolicyID.count | Should -BeGreaterThan 1
    }
}

Describe "Get-JCPolicyResult" {

    It "Returns a policy result with the policyname" {
        $SinglePolicy = Get-JCPolicy | Select-Object -Last 1
        $PolicyResult = Get-JCPolicyResult $SinglePolicy.Name
        $PolicyResult.count | Should -BeGreaterThan 0
    }

    It "Returns a policy result with the PolicyID" {
        $SinglePolicy = Get-JCPolicy | Select-Object -Last 1
        $PolicyResult = Get-JCPolicyResult -PolicyID $SinglePolicy.id
        $PolicyResult.id.count | Should -BeGreaterThan 0
    }

    It "Returns a policy result with the SystemID" {
        $SingleSystem = Get-JCSystem | Select-Object -Last 1
        $PolicyResult = Get-JCPolicyResult -SystemID $SingleSystem._id
        $PolicyResult.id.count | Should -BeGreaterThan 0
    }

}
