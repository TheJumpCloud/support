function Test-JCDynamicGroupMembership {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][System.String]$Type
        , [Parameter(Mandatory = $true)][System.String]$Id
        , [Parameter(Mandatory = $false)][System.String]$TargetId
    )

    $groupId = '';
    $itemId = '';

    switch ($Type) {
        'user_group' {
            $groupId = $Id
            $itemId = $TargetId
        }
        'system_group' {
            $groupId = $Id
            $itemId = $TargetId
        }
        'user' {
            $groupId = $TargetId
            $itemId = $Id
        }
        default {
            throw 'object type not in the valid list'
        }
    }

    $TargetGroup = if (($Type -eq 'user_group') -or ($Type -eq 'user')) {
        Get-JCUserGroup -Id:($groupId)
    } else {
        Get-JCSystemGroup -Id:($groupId)
    }

    if (-not $TargetGroup) {
        return $false
    }

    $Exemptions = $TargetGroup.MemberQueryExemptions;
    $dynamicMembershipFound = $TargetGroup.MembershipMethod -match 'DYNAMIC'

    if ( $dynamicMembershipFound ) {
        if ($Exemptions -and $Exemptions.Count -gt 0 -and ($Exemptions | Where-Object { $_.id -eq $itemId })) {
            return $false
        }

        return $true
    } else {
        return $false
    }
    throw "Unable to determine if the target group is a dynamic group. Please check the group and try again."
}