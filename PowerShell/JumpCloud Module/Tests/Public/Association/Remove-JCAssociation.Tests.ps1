Describe -Tag:('JCAssociation') 'Remove-JCAssociation dynamic group tests' {
    It 'Skips dynamic group associations when piping Get-JCAssociation into Remove-JCAssociation' {
        $suffix = [guid]::NewGuid().ToString('N').Substring(0, 8)
        $domain = "dynassoc.$suffix"
        $companyValue = "PesterDynCo-$suffix"
        $user = New-RandomUser -domain $domain | New-JCUser -company $companyValue
        $user | Should -Not -BeNullOrEmpty

        $dynamicGroupName = "Pester-DynamicGroup-$suffix"
        $staticGroupName = "Pester-StaticGroup-$suffix"
        $dynamicGroup = New-JCUserGroup -GroupName $dynamicGroupName
        $staticGroup = New-JCUserGroup -GroupName $staticGroupName
        $dynamicGroup.Result | Should -Be 'Created'
        $staticGroup.Result | Should -Be 'Created'

        try {
            $existingGroup = Get-JCUserGroup -Id $dynamicGroup.id
            $headers = @{
                'Content-Type' = 'application/json'
                'Accept'       = 'application/json'
                'X-API-KEY'    = $JCAPIKEY
            }
            if ($JCOrgID) {
                $headers['x-org-id'] = "$($JCOrgID)"
            }

            $groupUpdateBody = [ordered]@{
                id                      = $dynamicGroup.id
                name                    = $dynamicGroupName
                type                    = 'user_group'
                description             = 'Dynamic group for Pester test'
                memberSuggestionsNotify = $false
                membershipMethod        = 'DYNAMIC_AUTOMATED'
                attributes              = @{}
                memberQuery             = [ordered]@{
                    queryType = 'FilterQuery'
                    filters   = @(
                        [ordered]@{
                            field    = 'company'
                            operator = 'eq'
                            value    = $companyValue
                        }
                    )
                }
            }
            if ($existingGroup.email) { $groupUpdateBody.email = $existingGroup.email }
            if ($existingGroup.attributes) {
                $groupUpdateBody.attributes = ($existingGroup.attributes | ConvertTo-Json -Depth 5 | ConvertFrom-Json)
            }

            $uri = "$JCUrlBasePath/api/v2/usergroups/$($dynamicGroup.id)"
            try {
                Invoke-RestMethod -Method PUT -Uri $uri -Headers $headers -Body ($groupUpdateBody | ConvertTo-Json -Depth 6)
            } catch {
                $errorMessage = if ($_.ErrorDetails.Message) { $_.ErrorDetails.Message } else { $_.Exception.Message }
                throw "Failed to configure dynamic user group: $errorMessage"
            }

            Add-JCUserGroupMember -GroupID $staticGroup.id -UserID $user.id

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
                Remove-JCUser -UserID $user.id -force -ErrorAction SilentlyContinue
            }
            if ($dynamicGroup.id) {
                Remove-JCUserGroup -GroupID $dynamicGroup.id -force -ErrorAction SilentlyContinue
            }
            if ($staticGroup.id) {
                Remove-JCUserGroup -GroupID $staticGroup.id -force -ErrorAction SilentlyContinue
            }
        }
    }
}
