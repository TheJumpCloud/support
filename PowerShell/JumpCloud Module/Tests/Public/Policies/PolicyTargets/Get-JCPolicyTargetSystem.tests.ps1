Describe -Tag:('JCPolicyTargetSystem') 'Get-JCPolicyTargetSystem 1.10' {
    Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force | Out-Null
    It "Returns all JumpCloud policy system targets using PolicyId" {
        $SystemTarget = Get-JCPolicyTargetSystem -PolicyId:($SinglePolicy.id)
        $SystemTarget.SystemID.count | Should -BeGreaterThan 0
    }

    It "Returns all JumpCloud policy system targets using PolicyName" {
        $SystemTarget = Get-JCPolicyTargetSystem -PolicyName:($SinglePolicy.name)
        $SystemTarget.SystemID.count | Should -BeGreaterThan 0
    }

    It "Returns all JumpCloud policy system targets using the pipeline and group id" {
        $AllPolicy = $MultiplePolicy | ForEach-Object { Get-JCPolicyTargetSystem $_.id }
        $AllPolicy.PolicyId.count | Should -BeGreaterThan 0
    }

    It "Returns all JumpCloud policy system targets using the pipeline and group name" {
        $AllPolicy = $MultiplePolicy | ForEach-Object { Get-JCPolicyTargetSystem -PolicyName:($_.name) }
        $AllPolicy.PolicyId.count | Should -BeGreaterThan 0
    }
}
