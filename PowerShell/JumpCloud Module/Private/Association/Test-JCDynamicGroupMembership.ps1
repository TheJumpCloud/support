Function Test-JCDynamicGroupMembership {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false)][System.String]$TargetType
        , [Parameter(Mandatory = $false)][System.String]$TargetId
        , [Parameter(Mandatory = $false)][System.String]$TargetName
    )
    If ($TargetType -notin @('user_group', 'system_group')) {
        Return $false
    }
    $TargetGroup = If ($TargetId) {
        Get-JCObject -Type:($TargetType) -Id:($TargetId)
    } ElseIf ($TargetName) {
        Get-JCObject -Type:($TargetType) -Name:($TargetName)
    }
    If (-not $TargetGroup) {
        Return $false
    }
    $MembershipMethod = $TargetGroup.MembershipMethod
    Return ($MembershipMethod -match '^DYNAMIC_')
}