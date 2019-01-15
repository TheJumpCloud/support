$SingleAdminAPIKey = ''
Describe "Connect-JCOnline" {

    It "Connects to JumpCloud with a single admin API Key using force" {
        $Connect = Connect-JCOnline -JumpCloudAPIKey "$SingleAdminAPIKey" -force
        $Connect | Should -be $null
    }
}
#region policy test data validation
$Policies = Get-JCPolicy
$SinglePolicy = $Policies | Select-Object -Last 1
$MultiplePolicy = $Policies | Select-Object -Last 5
If ($($Policies._id.Count) -le 1) {Write-Error 'You must have at least 2 JumpCloud policies to run the Pester tests'; break}
Write-Host "There are $($Policies.Count) policies"
#endregion policy test data validation
Describe 'Get-JCPolicy' {

    It "Returns all JumpCloud Policies" {
        $Policies.id.Count | Should -BeGreaterThan 1
    }

    It "Returns a single JumpCloud Policy declaring -PolicyId" {
        $SingleResult = Get-JCPolicy -PolicyId:($SinglePolicy.id)
        $SingleResult.id.Count | Should Be 1
    }

    It "Returns a single JumpCloud policy without declaring -PolicyId" {
        $SingleResult = Get-JCPolicy $SinglePolicy.id
        $SingleResult.id.Count | Should Be 1
    }

    It "Returns a single JumpCloud policy using -PolicyId passed through the pipeline" {
        $SingleResult = $SinglePolicy | Get-JCPolicy -ByID
        $SingleResult.id.Count | Should Be 1
    }

    It "Returns a single JumpCloud policy passed through the pipeline without declaring -ByID" {
        $SingleResult = $SinglePolicy | Get-JCPolicy
        $SingleResult.id.Count | Should Be 1
    }

    It "Returns all JumpCloud Policies passed through the pipeline declaring -ByID" {
        $MultiResult = Get-JCPolicy | Get-JCPolicy -ByID
        $MultiResult._id.Count | Should -BeGreaterThan 1
    }

    It "Returns a single JumpCloud Policy declaring -Name" {
        $SingleResult = Get-JCPolicy -PolicyId:($SinglePolicy.id)
        $SingleResult.id.Count | Should Be 1
    }

    It "Returns a specific single JumpCloud Policy declaring -Name" {
        $SingleResult = Get-JCPolicy -Name:($SinglePolicy.Name)
        $SingleResult.Name | Should Be $SinglePolicy.Name
    }
}
Describe 'Get-JCPolicyTargetGroup' {

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
        $AllPolicy.PolicyId.count | Should -BeGreaterThan 1
    }

    It "Returns all JumpCloud policy system group targets using the pipeline and group name" {
        $AllPolicy = $MultiplePolicy | Get-JCPolicyTargetGroup -ByName
        $AllPolicy.PolicyId.count | Should -BeGreaterThan 1
    }
}

Describe 'Get-JCPolicyTargetSystem' {

    It "Returns all JumpCloud policy system targets using PolicyId" {
        $SystemTarget = Get-JCPolicyTargetSystem -PolicyId:($SinglePolicy.id)
        $SystemTarget.SystemID.count | Should -BeGreaterThan 0
    }

    It "Returns all JumpCloud policy system targets using PolicyName" {
        $SystemTarget = Get-JCPolicyTargetSystem -PolicyName:($SinglePolicy.name)
        $SystemTarget.SystemID.count | Should -BeGreaterThan 0
    }

    It "Returns all JumpCloud policy system targets using the pipeline and group id" {
        $AllPolicy = $MultiplePolicy  | ForEach-Object { Get-JCPolicyTargetSystem $_.id}
        $AllPolicy.PolicyId.count | Should -BeGreaterThan 1
    }

    It "Returns all JumpCloud policy system targets using the pipeline and group name" {
        $AllPolicy = $MultiplePolicy | ForEach-Object { Get-JCPolicyTargetSystem -PolicyName:($_.name)}
        $AllPolicy.PolicyId.count | Should -BeGreaterThan 1
    }
}

Describe "Get-JCPolicyResult" {

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
        $PolicyResult = Get-JCPolicyResult -SystemID:($SingleSystem._id)
        $PolicyResult.id.count | Should -BeGreaterThan 0
    }
}
