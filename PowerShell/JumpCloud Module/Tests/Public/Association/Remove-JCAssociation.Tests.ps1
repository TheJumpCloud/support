Describe -Tag:('JCAssociation') 'Remove-JCAssociation dynamic group tests' {
    It 'Skips dynamic group associations when piping Get-JCAssociation into Remove-JCAssociation' {
        $suffix = [guid]::NewGuid().ToString('N').Substring(0, 8)
        $domain = "dynassoc.$suffix"
        $user = New-RandomUser -domain $domain | New-JCUser
        $user | Should -Not -BeNullOrEmpty

        $dynamicGroupName = "Pester-DynamicGroup-$suffix"
        $staticGroupName = "Pester-StaticGroup-$suffix"
        $dynamicGroup = New-JCUserGroup -GroupName $dynamicGroupName
        $staticGroup = New-JCUserGroup -GroupName $staticGroupName
        $dynamicGroup.Result | Should -Be 'Created'
        $staticGroup.Result | Should -Be 'Created'

        $escapedDomain = [regex]::Escape($domain)
        $memberQueryFilter = '[{"email":{"$regex": ".*@' + $escapedDomain + '$"}}]'

        try {
            $null = Set-JCUserGroup -Id $dynamicGroup.id `
                -MembershipMethod 'DYNAMIC_AUTOMATED' `
                -MemberQueryType 'Filter' `
                -Name $dynamicGroupName `
                -MemberQueryFilters @($memberQueryFilter)

            $null = Add-JCUserGroupMember -GroupID $staticGroup.id -UserID $user.id

            $dynamicMembershipFound = $false
            for ($attempt = 0; $attempt -lt 12 -and -not $dynamicMembershipFound; $attempt++) {
                $groupAssociations = Get-JCAssociation -Type user -Id $user.id -TargetType user_group -Force
                $dynamicMembershipFound = $groupAssociations.targetId -contains $dynamicGroup.id
                if (-not $dynamicMembershipFound) {
                    Start-Sleep -Seconds 5
                }
            }
            $dynamicMembershipFound | Should -BeTrue -Because 'the user should match the dynamic group filter'

            $associations = Get-JCAssociation -Type user -Id $user.id -Force
            $associations | Should -Not -BeNullOrEmpty
            $associations.targetId | Should -Contain $dynamicGroup.id
            $associations.targetId | Should -Contain $staticGroup.id

            $null = $associations | Remove-JCAssociation -Force

            $remainingAssociations = Get-JCAssociation -Type user -Id $user.id -TargetType user_group -Force
            $remainingAssociations.targetId | Should -Contain $dynamicGroup.id
            $remainingAssociations.targetId | Should -Not -Contain $staticGroup.id
        } finally {
            if ($user.id) {
                Remove-JCUser -UserID $user.id -Force -ErrorAction SilentlyContinue
            }
            if ($dynamicGroup.id) {
                Remove-JCUserGroup -GroupID $dynamicGroup.id -Force -ErrorAction SilentlyContinue
            }
            if ($staticGroup.id) {
                Remove-JCUserGroup -GroupID $staticGroup.id -Force -ErrorAction SilentlyContinue
            }
        }
    }
}
