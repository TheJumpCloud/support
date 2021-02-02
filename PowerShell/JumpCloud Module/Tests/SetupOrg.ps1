Param(
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][System.String]$JumpCloudApiKey
    , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][System.String]$JumpCloudApiKeyMsp
)
Try
{
    # Authenticate to JumpCloud
    Connect-JCOnline -JumpCloudApiKey:($JumpCloudApiKey) -force | Out-Null
    # Define variable names
    $PesterParamsHash_VariableName = @{
        VariableNamePrefix     = 'PesterParams_';
        VariableNamePrefixHash = 'PesterParamsHash_';
    }
    # Tear down org
    Function Remove-Org
    {
        Param(
            [switch]$Users
            , [switch]$Systems
            # , [switch]$Policies
            , [switch]$Groups
            # , [switch]$Applications
            # , [switch]$Directories
            , [switch]$Commands
            , [switch]$RadiusServers
        )
        # Remove all users from an org
        If ($Users)
        {
            $NonExternallyManagedUsersToRemove = Get-JCUser | Where-Object { ($_.Email -like '*delete*' -or $_.Email -like '*pester*') -and -not $_.externally_managed }
            $RemoveNonExternallyManagedUsers = $NonExternallyManagedUsersToRemove | Remove-JCUser -force
            $ExternallyManagedUsersToRemove = Get-JCUser | Where-Object { ($_.Email -like '*delete*' -or $_.Email -like '*pester*') -and $_.externally_managed }
            $UpdateExternallyManagedUsersToRemove = $ExternallyManagedUsersToRemove | Set-JCUser -externally_managed $false
            $RemoveExternallyManagedUsers = $ExternallyManagedUsersToRemove | Remove-JCUser -force
        }
        # Remove all systems from an org
        If ($Systems)
        {
            $null = Get-JCSystem | Remove-JCSystem -force
        }
        # Remove all groups from an org
        If ($Groups)
        {
            $null = Get-JCGroup | ForEach-Object { If ($_.Type -eq 'system_group') { Remove-JCSystemGroup -GroupName:($_.Name) -force }ElseIf ($_.Type -eq 'user_group') { Remove-JCUserGroup -GroupName:($_.Name) -force }Else { Write-Error('Unknown') } }
        }
        # Remove all Commands from an org
        If ($Commands)
        {
            $null = Get-JCCommand | Remove-JCCommand -force
        }
        # Remove all RadiusServers from an org
        If ($RadiusServers)
        {
            $null = Get-JCRadiusServer | Remove-JCRadiusServer -Force
        }
    }
    Remove-Org -Users -Groups -Commands -RadiusServers

    # Setup org
    $PesterParamsHash_BuildOrg = @{
        # Newly created objects
        User1          = New-JCUser @PesterParams_NewUser1
        User2          = New-JCUser @PesterParams_NewUser2
        UserGroup      = New-JCUserGroup @PesterParams_NewUserGroup
        SystemGroup    = New-JCSystemGroup @PesterParams_NewSystemGroup
        RadiusServer   = New-JCRadiusServer @PesterParams_NewRadiusServer
        Command1       = New-JCCommand @PesterParams_NewCommand1
        Command2       = New-JCCommand @PesterParams_NewCommand2
        Command3       = New-JCCommand @PesterParams_NewCommand3
        Command4       = New-JCCommand @PesterParams_NewCommand4
        Command5       = New-JCCommand @PesterParams_NewCommand5
        Command6       = New-JCCommand @PesterParams_NewCommand6
        # Get info for things that have already been setup within the org. TODO dynamically create these
        # Add systems: Windows, Mac, and Linux
        # Create 2 new policies and assign policy to system
        Org            = Get-JCOrganization
        SinglePolicy   = Get-JCPolicy -Name:($PesterParams_SinglePolicyList)
        MultiplePolicy = Get-JCPolicy -Name:($PesterParams_MultiplePolicyList)
        SystemLinux    = Get-JCSystem -displayName:($PesterParams_SystemNameLinux)
        SystemMac      = Get-JCSystem -displayName:($PesterParams_SystemNameMac)
        SystemWindows  = Get-JCSystem -displayName:($PesterParams_SystemNameWindows)
        # CommandResults = Get-JCCommandResult
    }
    $PesterParamsHash_Associations = @{
        PolicySystemGroupMembership   = $PesterParamsHash_BuildOrg.MultiplePolicy | ForEach-Object {
            If (-not (Get-JCAssociation -Type:('policy') -Id:($_.id) -TargetType:('system_group') | Where-Object { $_.targetId -eq $PesterParamsHash_BuildOrg.SystemGroup.id })) { New-JCAssociation -Type:('policy') -Id:($_.id) -TargetType:('system_group') -TargetId:($PesterParamsHash_BuildOrg.SystemGroup.id) -force; };
        };
        UserGroupMembership           = If (-not (Get-JCAssociation -Type:('user_group') -Id:($PesterParamsHash_BuildOrg.UserGroup.id) -TargetType:('user') | Where-Object { $_.targetId -eq $PesterParamsHash_BuildOrg.User1.id })) { New-JCAssociation -Type:('user_group') -Id:($PesterParamsHash_BuildOrg.UserGroup.id) -TargetType:('user') -TargetId:($PesterParamsHash_BuildOrg.User1.id) -force; };
        SystemUserMembership          = If (-not (Get-JCAssociation -Type:('system') -Id:($PesterParamsHash_BuildOrg.SystemLinux._id) -TargetType:('user') | Where-Object { $_.targetId -eq $PesterParamsHash_BuildOrg.User1.id })) { New-JCAssociation -Type:('system') -Id:($PesterParamsHash_BuildOrg.SystemLinux._id) -TargetType:('user') -TargetId:($PesterParamsHash_BuildOrg.User1.id) -force; };
        SystemPolicyMembership        = If (-not (Get-JCAssociation -Type:('system') -Id:($PesterParamsHash_BuildOrg.SystemLinux._id) -TargetType:('policy') | Where-Object { $_.targetId -eq $PesterParamsHash_BuildOrg.SinglePolicy.id })) { New-JCAssociation -Type:('system') -Id:($PesterParamsHash_BuildOrg.SystemLinux._id) -TargetType:('policy') -TargetId:($PesterParamsHash_BuildOrg.SinglePolicy.id) -force; };
        Command1SystemGroupMembership = If (-not (Get-JCAssociation -Type:('command') -Id:($PesterParamsHash_BuildOrg.Command1._id) -TargetType:('system_group') | Where-Object { $_.targetId -eq $PesterParamsHash_BuildOrg.SystemGroup.id })) { New-JCAssociation -Type:('command') -Id:($PesterParamsHash_BuildOrg.Command1._id) -TargetType:('system_group') -TargetId:($PesterParamsHash_BuildOrg.SystemGroup.id) -force; };
        Command2SystemGroupMembership = If (-not (Get-JCAssociation -Type:('command') -Id:($PesterParamsHash_BuildOrg.Command2._id) -TargetType:('system_group') | Where-Object { $_.targetId -eq $PesterParamsHash_BuildOrg.SystemGroup.id })) { New-JCAssociation -Type:('command') -Id:($PesterParamsHash_BuildOrg.Command2._id) -TargetType:('system_group') -TargetId:($PesterParamsHash_BuildOrg.SystemGroup.id) -force; };
        Command3SystemGroupMembership = If (-not (Get-JCAssociation -Type:('command') -Id:($PesterParamsHash_BuildOrg.Command3._id) -TargetType:('system_group') | Where-Object { $_.targetId -eq $PesterParamsHash_BuildOrg.SystemGroup.id })) { New-JCAssociation -Type:('command') -Id:($PesterParamsHash_BuildOrg.Command3._id) -TargetType:('system_group') -TargetId:($PesterParamsHash_BuildOrg.SystemGroup.id) -force; };
    }
    # Generate command results of they dont exist
    # If ([System.String]::IsNullOrEmpty($PesterParamsHash_BuildOrg.CommandResults) -or $PesterParamsHash_BuildOrg.CommandResults.Count -lt $PesterParams_CommandResultCount)
    # {
    If (-not (Get-JCAssociation -Type:('command') -Id:($PesterParamsHash_BuildOrg.Command1._id) -TargetType:('system') | Where-Object { $_.targetId -eq $PesterParamsHash_BuildOrg.SystemLinux._id }))
    {
        New-JCAssociation -Type:('command') -Id:($PesterParamsHash_BuildOrg.Command1._id) -TargetType:('system') -TargetId:($PesterParamsHash_BuildOrg.SystemLinux._id) -force
    };
    For ($i = 1; $i -le $PesterParams_CommandResultCount; $i++)
    {
        Invoke-JCCommand -trigger:($PesterParamsHash_BuildOrg.Command1.trigger)
    }
    While ((Get-JCCommandResult | Where-Object { $_.Name -eq $PesterParamsHash_BuildOrg.Command1.name }).Count -ge $PesterParams_CommandResultCount)
    {
        Start-Sleep -Seconds:(1)
    }
    If ((Get-JCAssociation -Type:('command') -Id:($PesterParamsHash_BuildOrg.Command1._id) -TargetType:('system') | Where-Object { $_.targetId -eq $PesterParamsHash_BuildOrg.SystemLinux._id }))
    {
        Remove-JCAssociation -Type:('command') -Id:($PesterParamsHash_BuildOrg.Command1._id) -TargetType:('system') -TargetId:($PesterParamsHash_BuildOrg.SystemLinux._id) -force
    };
    # }
    # Combine all hash tables into one list and foreach of their values create a new global parameter
    (Get-Variable -Scope:('Script') -Name:("$($PesterParamsHash_VariableName.VariableNamePrefixHash)*")).Value | ForEach-Object {
        $_.GetEnumerator() | ForEach-Object {
            Set-Variable -Name:("$($PesterParamsHash_VariableName.VariableNamePrefix)$($_.Name)") -Value:($_.Value) -Scope:('Global')
        }
    }
}
Catch
{
    Write-Error ($_)
}
