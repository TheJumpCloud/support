function Update-JCSmartGroupMembership {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory)]
        [ValidateSet('System', 'User')]
        [System.String]
        ${GroupType},
        [Parameter(Mandatory)]
        [System.String]
        $ID
    )
    begin {
        $SmartGroupDetails = Get-JCSmartGroup -GroupType $GroupType -ByID $ID

        # Build Attribute string:
        if ($SmartGroupDetails.Attributes.Custom.software) {
            $customFlow = $true
            Write-Warning "custom"
            if ($SmartGroupDetails.Attributes.Custom.software.version) {
                $windowsFilter = @(
                    "name:eq:$($SmartGroupDetails.Attributes.Custom.software.windowsProgram)"
                )
                $macFilter = @(
                    "name:eq:$(($SmartGroupDetails.Attributes.Custom.software.macApp))"
                )
                $windowsSystems = Get-JcSdkSystemInsightProgram -Filter $windowsFilter | Where-Object { $_.Version -eq $SmartGroupDetails.Attributes.Custom.software.version }
                $macSystems = Get-JcSdkSystemInsightApp -Filter $macFilter | Where-Object { $_.BundleShortVersion -eq $SmartGroupDetails.Attributes.Custom.software.version }
            } else {
                $windowsFilter = @(
                    "name:eq:$($SmartGroupDetails.Attributes.Custom.software.windowsProgram)"
                )
                $macFilter = @(
                    "name:eq:$(($SmartGroupDetails.Attributes.Custom.software.macApp))"
                )
                $windowsSystems = Get-JcSdkSystemInsightProgram -Filter $windowsFilter
                $macSystems = Get-JcSdkSystemInsightApp -Filter $macFilter
            }

            $systems = [pscustomobject]@{
                Id = @()
            }
            foreach ($sys in $windowsSystems) {
                $systems.Id += ($sys.SystemId)
            }
            foreach ($sys in $macSystems) {
                $systems.Id += ($sys.SystemId)
            }
        } else {

            $andFilters = @()
            $orFilters = @()
            $ands = $SmartGroupDetails.Attributes.And.PSobject.Properties.Name
            $ors = $SmartGroupDetails.Attributes.Or.PSobject.Properties.Name

            foreach ($And in $ands) {
                $andFilters += "$($and):" + $SmartGroupDetails.Attributes.And."$and"
            }
            foreach ($Or in $ors) {
                $orFilters += "$($Or):" + $SmartGroupDetails.Attributes.Or."$or"
            }
            if ($orFilters -And $andFilters) {
                $Search = @{
                    filter = @{
                        and = $andFilters
                        or  = $orFilters
                    }
                }
            } elseif ($orFilters -And !$andFilters) {
                $Search = @{
                    filter = @{
                        or = $orFilters
                    }
                }
            } elseif (!$orFilters -And $andFilters) {
                $Search = @{
                    filter = @{
                        and = $andFilters
                    }
                }
            }
            # $searchJson = $search | ConvertTo-Json
            # Write-Warning $searchJson
        }

    }
    process {
        # For the group specified, go fetch system group membership
        switch ($GroupType) {
            'System' {
                if (!$customFlow) {
                    # Write-Warning "gettin systems"
                    $systems = Search-JcSdkSystem -Body:($Search)
                }
                $existingMembers = Get-JcSdkSystemGroupMembership -GroupId $ID
                $addMembers = $systems.id | Where { $existingMembers.Id -notcontains $_ }
                $removeMembers = $existingMembers.Id | Where { $systems.id -notcontains $_ }

                if ($addMembers.count -ne 0) {
                    $addMembers | ForEach-Object { Set-JcSdkSystemGroupMember -GroupId $ID -Op add -Id $_ }
                }
                if ($removeMembers.count -ne 0) {
                    $removeMembers | ForEach-Object { Set-JcSdkSystemGroupMember -GroupId $ID -Op remove -Id $_ }
                }
            }
            'User' {
                $users = Search-JcSdkUser -Body:($Search)
                $existingMembers = Get-JcSdkUserGroupMembership -GroupId $ID
                $addMembers = $users.id | Where { $existingMembers.Id -notcontains $_ }
                $removeMembers = $existingMembers.Id | Where { $users.id -notcontains $_ }

                if ($addMembers.count -ne 0) {
                    $addMembers | ForEach-Object { Set-JcSdkUserGroupMember -GroupId $ID -Op add -Id $_ }
                }
                if ($removeMembers.count -ne 0) {
                    $removeMembers | ForEach-Object { Set-JcSdkUserGroupMember -GroupId $ID -Op remove -Id $_ }
                }
            }
        }
    }
    end {
        Write-Host "$($SmartGroupDetails.Name) Updated ✅"
    }
}


