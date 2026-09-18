function Test-JCDynamicGroupMembership {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][System.String]$Type
        , [Parameter(Mandatory = $true)][System.String]$Id
        , [Parameter(Mandatory = $false)][System.String]$TargetId
    )
    if ($Type -notin @('user_group', 'system_group')) {
        throw "Invalid target type. Please specify either 'user_group' or 'system_group'."
    }

    $TargetGroup = if ($Type -eq 'user_group') {
        Get-JCUserGroup -Id:($Id)
    } else {
        Get-JCSystemGroup -Id:($Id)
    }

    if (-not $TargetGroup) {
        return $false
    }

    $Exemptions = $TargetGroup.MemberQueryExemptions;

    if ($Exemptions -and $Exemptions.Count -gt 0) {
        $Exemption = $Exemptions | Where-Object { $_.id -eq $TargetId }
        if ($Exemption) {
            return $false
        } else {
            return $true
        }
    } else {
        return $true
    }
    throw "Unable to determine if the target group is a dynamic group. Please check the group and try again."
}