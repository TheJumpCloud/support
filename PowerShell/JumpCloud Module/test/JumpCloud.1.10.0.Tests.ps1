#region policy test data validation
$Policies = Get-JCPolicy

if ($($Policies._id.Count) -le 1)
{Write-Error 'You must have at least 2 JumpCloud policies to run the Pester tests';break}

Write-Host "There are $($Policies.Count) policies"

#endregion policy test data validation

Describe 'Get-JCPolicy'{

    It "Gets all JumpCloud Policies"{
        $AllPolicies = Get-JCPolicy
        $AllPolicies.id.Count | Should -BeGreaterThan 1
    }

    It "Gets a single JumpCloud Policy declaring -PolicyID"{
        $SinglePolicy = Get-JCPolicy | Select-Object -Last 1
        $SingleResult = Get-JCPolicy -PolicyID $SinglePolicy.id
        $SingleResult.id.Count | Should Be 1

    }

    It "Gets a single JumpCloud policy without declaring -PolicyID"{
        $SinglePolicy = Get-JCPolicy | Select-Object -Last 1
        $SingleResult = Get-JCPOlicy $SinglePolicy.id
        $SingleResult.id.Count | Should Be 1

    }

    It "Gets a single JumpCloud policy using -PolicyID passed through the pipeline"{
        $SingleResult = Get-JCPolicy | Select-Object -last 1 id | Get-JCPolicy -ByID
        $SingleResult.id.Count | Should Be 1
    }

    It "Gets a single JumpCloud policy passed through the pipeline without declaring -ByID"{
        $SingleResult = Get-JCPolicy | Select-Object -Last 1 | Get-JCPolicy
        $SingleResult.id.Count | Should Be 1
    }

    It "Gets all JumpCloud command passed through the pipeline declaring -ByID"{
        $MultiResult = Get-JCCommand | Get-JCCommand -ByID
        $MultiResult._id.Count | Should -BeGreaterThan 1
    }

    It "Gets a single JumpCloud Policy declaring -Name"{
        $SinglePolicy = Get-JCPolicy | Select-Object -Last 1
        $SingleResult = Get-JCPolicy -PolicyID $SinglePolicy.id
        $SingleResult.id.Count | Should Be 1

    }

    It "Gets a specific single JumpCloud Policy declaring -Name"{
        $SinglePolicy = Get-JCPolicy | Select-Object -Last 1
        $SingleResult = Get-JCPolicy -Name $SinglePolicy.Name
        $SingleResult.Name | Should Be $SinglePolicy.Name

    }

    Describe 'Get-JCPolicyTarget' {

        it "Returns a JumpCloud policy system targets" {
            $SinglePolicy = Get-JCPolicy | Select-Object -Last 1
            $SystemTarget = Get-JCPolicyTarget -PolicyID $SinglePolicy.id
            $SystemTarget.SystemID.count | Should -BeGreaterThan 0
        }
        
        it "Returns a JumpCloud policy group targets by groupname" {
            $SinglePolicy = Get-JCPolicy | Select-Object -Last 1 | select id
            $SystemGroupTarget = Get-JCPolicyTarget -PolicyID $SinglePolicy.id -Groups
            $SystemGroupTarget.Groupname.count | Should -BeGreaterThan 0
    
        }
        
        it "Returns all JumpCloud policy system targets using the pipeline" {
            $Allpolicy = Get-JCPolicy | Select-Object id -Last 1 | Get-JCPolicyTarget 
            $Allpolicy.PolicyID.count | Should -BeGreaterThan 1

        }
    
        it "Returns all JumpCloud policy system group targets using the pipeline" {
    
            $Allpolicy = Get-JCPolicy | Select-Object id -Last 1 | Get-JCPolicyTarget -Groups
            $Allpolicy.PolicyID.count | Should -BeGreaterThan 1

        }
    
    
    }
    Describe "Get-JCPolicyResult" {

        It "Returns a policy result with the policyname" {
            $SinglePolicy = Get-JCPolicy | Select-Object -Last 1
            $PolicyResult = Get-JCPolicyResult $SinglePolicy.Name
            $PolicyResult.id.count | Should -Be GreaterThan 1
    
        }

        It "Returns a policy result with the PolicyID" {
            $SinglePolicy = Get-JCPolicy | Select-Object -Last 1
            $PolicyResult = Get-JCPolicyResult -PolicyID $SinglePolicy.id
            $PolicyResult.id.count | Should -Be GreaterThan 1
    
        }
    
        It "Returns a policy result with the SystemID" {
            $SingleSystem = Get-JCSystem | Select-Object -Last 1
            $PolicyResult = Get-JCPolicyResult -SystemID $SingleSystem._id
            $PolicyResult.id.count | Should -Be GreaterThan 1
    
        }
    
        It "Returns a policy result with the PolicyResultID" {
            $SinglePolicyResult = Get-JCPolicy | Select-Object -Last 1
            $PolicyResult = Get-JCPolicyResult -PolicyID $SinglePolicy.id
            $PolicyResult.id.count | Should -Be GreaterThan 1
    
        }
     
    }


}

#endregion JCPolicies Pester test