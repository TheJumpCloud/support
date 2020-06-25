Describe -Tag:('JCPolicyTargetSystem') 'Get-JCPolicyTargetSystem 1.10' {
    BeforeAll {
        Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null
        $PesterParams_MultiplePolicy | ForEach-Object {
            If (-not (Get-JCAssociation -Type:('policy') -Id:($_.Id) -TargetType:('system') -IncludeNames | Where-Object { $_.TargetName -eq $PesterParams_SystemLinux.displayName }))
            {
                Add-JCAssociation -Type:('policy') -Id:($_.Id) -TargetType:('system') -TargetName:($PesterParams_SystemLinux.displayName) -Force
            }
        }
    }
    It "Returns all JumpCloud policy system targets using PolicyId" {
        $SystemTarget = Get-JCPolicyTargetSystem -PolicyId:($PesterParams_SinglePolicy.id)
        $SystemTarget.SystemID.count | Should -BeGreaterThan 0
    }

    It "Returns all JumpCloud policy system targets using PolicyName" {
        $SystemTarget = Get-JCPolicyTargetSystem -PolicyName:($PesterParams_SinglePolicy.name)
        $SystemTarget.SystemID.count | Should -BeGreaterThan 0
    }

    It "Returns all JumpCloud policy system targets using the pipeline and group id" {
        $AllPolicy = $PesterParams_MultiplePolicy | ForEach-Object { Get-JCPolicyTargetSystem $_.id }
        $AllPolicy.PolicyId.count | Should -BeGreaterThan 0
    }

    It "Returns all JumpCloud policy system targets using the pipeline and group name" {
        $AllPolicy = $PesterParams_MultiplePolicy | ForEach-Object { Get-JCPolicyTargetSystem -PolicyName:($_.name) }
        $AllPolicy.PolicyId.count | Should -BeGreaterThan 0
    }
}