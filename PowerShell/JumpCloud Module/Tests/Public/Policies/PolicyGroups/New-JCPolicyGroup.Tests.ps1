Describe -Tag:('JCPolicyGroup') 'JCPolicyGroup' {
    # remove pester policy groups before starting these tests
    $policyGroups = Get-JCPolicyGroup
    foreach ($policyGroup in $policyGroups) {
        if ($policyGroup.name -match "Pester") {
            Remove-JCPolicyGroup -PolicyGroupID $policyGroup.id -Force
        }
    }
    It ('Creates a Policy Group with the name parameter') {
        $randomName = $(Get-Random)
        $newGroup = New-JCPolicyGroup -Name "$randomName"
        $newGroup | Should -Not -BeNullOrEmpty
    }
    It ('Throws if the Policy Group already exists') {
        $policyGroups = Get-JCPolicyGroup
        $randomPolicyGroup = $policyGroups | Where-Object { $_.name -match "pester" } | Select-Object -First 1
        { New-JCPolicyGroup -Name "$($randomPolicyGroup.name)" } | Should -Throw
    }
}