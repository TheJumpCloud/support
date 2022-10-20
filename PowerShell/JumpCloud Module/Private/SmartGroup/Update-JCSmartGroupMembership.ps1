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

    }
    process {
        # For the group specified, go fetch system group membership
        switch ($GroupType) {
            'System' {
                $systems = Search-JcSdkSystem -Body:($Search)
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
                $systems = Search-JcSdkUser -Body:($Search)
                $existingMembers = Get-JcSdkuserGroupMembership -GroupId $ID
                $addMembers = $users._id | Where { $existingMembers.Id -notcontains $_ }
                $removeMembers = $existingMembers.Id | Where { $users._id -notcontains $_ }

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


