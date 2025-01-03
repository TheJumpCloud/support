Describe -Tag:('JCPolicyResult') "Get-JCPolicyResult 1.10" {
    BeforeAll {
        $allSystems = Get-JCSystem
        # get an active linux system
        $activeLinuxSystem = $allSystems | Where-Object { ($_.active -eq $true) -And ($_.osFamily -eq 'linux') }
        # create a policy to test the
        $policyName = "Pester-$(new-randomString -numberOfChars 6)"
        $linuxHardeningPolicy = New-JCPolicy -TemplateName linux_Additional_Process_Hardening -core_dumps_restricted $true -aslr_enabled $false -prelink_disabled $false -XD_NX_support_enabled $false -Name $policyName
        Set-JcSdkPolicyAssociation -PolicyId $linuxHardeningPolicy.id -Id $activeLinuxSystem.id -Op "add" -Type 'system'

        # loop with timeout to check for policy result:
        $policyResult = Get-JCPolicyResult $policyName
        if (-Not $policyResult.Id) {
            $wait = 10
            $i = 0
            $timeout = $false
            do {
                $policyResult = Get-JCPolicyResult $policyName
                if ($i -ne 10) {
                    Write-Output "waiting $wait seconds| i: $i to: $timeout $($policyResult.id)"
                    Start-Sleep -Seconds $wait
                } else {
                    break
                }
                $i++
            } until (
                (-Not [System.String]::IsNullOrEmpty($($policyResult.id)))
            )
        }
    }
    It "Returns a policy result with the PolicyName" {
        $PolicyResult = Get-JCPolicyResult $linuxHardeningPolicy.Name
        $PolicyResult.count | Should -BeGreaterThan 0
    }

    It "Returns a policy result with the PolicyId" {
        $PolicyResult = Get-JCPolicyResult -PolicyId:($linuxHardeningPolicy.id)
        $PolicyResult.id.count | Should -BeGreaterThan 0
    }

    It "Returns a policy result with the SystemID" {
        $PolicyResult = Get-JCPolicyResult -SystemID:($activeLinuxSystem._id)
        $PolicyResult.id.count | Should -BeGreaterThan 0
    }

    It "Returns a policy result using the -ByPolicyID switch parameter via the pipeline" {


        $PolicyResultVar = Get-JCPolicyResult -PolicyId:($linuxHardeningPolicy.id)

        $PolicyResult = $PolicyResultVar | Get-JCPolicyResult -ByPolicyID

        $PolicyResult.id.count | Should -BeGreaterThan 0

    }

    It "Returns a policy using the -BySystemID switch parameter via the pipeline " {

        $PolicyResultVar = Get-JCPolicyResult -PolicyId:($linuxHardeningPolicy.id)

        $PolicyResult = $PolicyResultVar | Get-JCPolicyResult -BySystemID

        $PolicyResult.id.count | Should -BeGreaterThan 0

    }

}
