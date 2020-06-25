Describe -Tag:('JCPolicyTargetGroup') 'Get-JCPolicyTargetGroup 1.10' {
    BeforeAll {
        Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null
        $SystemGroup = Get-JCGroup -Type:('System') | Where-Object { $_.name -eq $PesterParams_SystemGroup.Name }
        $PesterParams_MultiplePolicy | ForEach-Object {
            If (-not (Get-JCAssociation -Type:('policy') -Id:($_.id) -TargetType:('system_group') | Where-Object { $_.targetId -eq $SystemGroup.id }))
            {
                New-JCAssociation -Type:('policy') -Id:($_.id) -TargetType:('system_group') -TargetId:($SystemGroup.id) -force
            }
        }
    }
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
