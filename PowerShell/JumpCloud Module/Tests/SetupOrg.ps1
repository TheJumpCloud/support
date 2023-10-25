Param(
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][System.String]$JumpCloudApiKey
    , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][System.String]$JumpCloudApiKeyMsp
    , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][System.String]$JumpCloudMspOrg
)
Try {
    Write-Host "[Status] Begin SetupOrg"
    $stopwatch = [system.diagnostics.stopwatch]::StartNew()
    # Import JC Module
    Import-Module "$PSScriptRoot/../JumpCloud.psd1"
    # Authenticate to JumpCloud
    if (-not [string]::IsNullOrEmpty($JumpCloudMspOrg)) {
        Connect-JCOnline -JumpCloudApiKey:($JumpCloudApiKey) -JumpCloudOrgId:($JumpCloudMspOrg) -force | Out-Null
    } else {
        Connect-JCOnline -JumpCloudApiKey:($JumpCloudApiKey) -force | Out-Null
    }
    # Define variable names
    $PesterParamsHash_VariableName = @{
        VariableNamePrefix     = 'PesterParams_';
        VariableNamePrefixHash = 'PesterParamsHash_';
    }
    Write-Host "[Status] Setup Variables: $($stopwatch.Elapsed)"
    # Tear down org
    Function Remove-Org {
        Param(
            [switch]$Users
            , [switch]$Systems
            , [switch]$Policies
            , [switch]$Groups
            # , [switch]$Applications
            # , [switch]$Directories
            , [switch]$Commands
            , [switch]$RadiusServers
        )
        # Remove all users from an org
        If ($Users) {
            $NonExternallyManagedUsersToRemove = Get-JCUser | Where-Object { ($_.Email -like '*delete*' -or $_.Email -like '*pester*') -and -not $_.externally_managed }
            $RemoveNonExternallyManagedUsers = $NonExternallyManagedUsersToRemove | Remove-JCUser -force
            $ExternallyManagedUsersToRemove = Get-JCUser | Where-Object { ($_.Email -like '*delete*' -or $_.Email -like '*pester*') -and $_.externally_managed }
            $UpdateExternallyManagedUsersToRemove = $ExternallyManagedUsersToRemove | Set-JCUser -externally_managed $false
            $RemoveExternallyManagedUsers = $ExternallyManagedUsersToRemove | Remove-JCUser -force
            Write-Host "[status] Removed users: $($stopwatch.Elapsed)"
        }
        # Remove all systems from an org
        If ($Systems) {
            $null = Get-JCSystem | Remove-JCSystem -force
            Write-Host "[status] Removed systems: $($stopwatch.Elapsed)"
        }
        # Remove all groups from an org
        If ($Groups) {
            # TODO: if system group is assigned to MDM this will throw an error
            $null = Get-JCGroup | ForEach-Object {
                If ($_.Type -eq 'system_group') {
                    # write-host $_.Name
                    Remove-JcSdkSystemGroup -Id $_.id -ErrorAction Ignore
                } elseif ($_.Type -eq 'user_group') {
                    # write-host $_.Name
                    Remove-JcSdkUserGroup -Id $_.id -ErrorAction Ignore
                }
            }
            Write-Host "[status] Removed groups: $($stopwatch.Elapsed)"
        }
        # Remove all Commands from an org
        If ($Commands) {
            $null = Get-JCCommand | Remove-JCCommand -force
            $null = Get-JCCommandResult | Remove-JCCommandResult -force
            Write-Host "[status] Removed commands: $($stopwatch.Elapsed)"
        }
        # Remove all RadiusServers from an org
        If ($RadiusServers) {
            $null = Get-JCRadiusServer | Remove-JCRadiusServer -Force
            Write-Host "[status] Removed Radius Servers: $($stopwatch.Elapsed)"
        }
        if ($Policies) {
            $allPolicies = Get-JCPolicy
            foreach ($policy in $allPolicies.id) {
                $null = Remove-JcSdkPolicy -Id $policy
            }
            Write-Host "[status] Removed Policies: $($stopwatch.Elapsed)"
        }
    }
    Remove-Org -Users -Groups -Commands -RadiusServers -Policies
    Write-Host "[Status] Finished Cleaning Up Org: $($stopwatch.Elapsed)"

    # Generate required policies
    foreach ( $policyName in $PesterParamsHash_Common.MultiplePolicyList ) {
        If (-not (Get-JCPolicy -Name $policyName)) {
            New-JCPolicy -TemplateName linux_Disable_USB_Storage -Name $policyName
        }
    }
    Write-Host "[Status] Finished Generating Policies: $($stopwatch.Elapsed)"
    # Setup org
    $PesterParamsHash_BuildOrg = @{
        # Newly created objects
        User1             = New-JCUser @PesterParams_NewUser1
        User2             = New-JCUser @PesterParams_NewUser2
        UserGroup         = New-JCUserGroup @PesterParams_NewUserGroup
        SystemGroup       = New-JCSystemGroup @PesterParams_NewSystemGroup
        RadiusServer      = New-JCRadiusServer @PesterParams_NewRadiusServer
        RadiusAzureServer = New-JCRadiusServer @PesterParams_NewAzureRadiusServer
        Command1          = New-JCCommand @PesterParams_NewCommand1
        Command2          = New-JCCommand @PesterParams_NewCommand2
        Command3          = New-JCCommand @PesterParams_NewCommand3
        Command4          = New-JCCommand @PesterParams_NewCommand4
        Command5          = New-JCCommand @PesterParams_NewCommand5
        Command6          = New-JCCommand @PesterParams_NewCommand6
        # Get info for things that have already been setup within the org. TODO dynamically create these
        # Add systems: Windows, Mac, and Linux
        # Create 2 new policies and assign policy to system
        Org               = Get-JCOrganization
        SinglePolicy      = Get-JCPolicy -Name:($PesterParams_SinglePolicyList)
        MultiplePolicy    = Get-JCPolicy -Name:($PesterParams_MultiplePolicyList)
        SystemLinux       = Get-JCSystem -displayName:($PesterParams_SystemNameLinux)
        SystemMac         = Get-JCSystem -displayName:($PesterParams_SystemNameMac)
        SystemWindows     = Get-JCSystem -displayName:($PesterParams_SystemNameWindows)
        CommandResults    = Get-JCCommandResult
    }

    $PesterParamsHash_Associations = @{
        PolicySystemGroupMembership   = $PesterParamsHash_BuildOrg.MultiplePolicy | ForEach-Object {
            If (-not (Get-JcSdkPolicyAssociation -PolicyId:($_.id) -Targets:('system_group') | Where-Object { $_.id -eq $PesterParamsHash_BuildOrg.SystemGroup.id })) {
                Set-JcSdkPolicyAssociation -Op:("add") -PolicyId:($_.id) -Type:('system_group') -Id:($PesterParamsHash_BuildOrg.SystemGroup.id);
            };
        };
        UserGroupMembership           = If (-not (Get-JcSdkUserGroupMember -GroupId:($PesterParamsHash_BuildOrg.UserGroup.id) | Where-Object { $_.id -eq $PesterParamsHash_BuildOrg.User1.id })) {
            Set-JcSdkUserGroupMember -Op:("add") -GroupId:($PesterParamsHash_BuildOrg.UserGroup.id) -Id:($PesterParamsHash_BuildOrg.User1.id);
        };
        SystemUserMembership          = If (-not (Get-JcSdkSystemAssociation -SystemId:($PesterParamsHash_BuildOrg.SystemLinux._id) -Targets:('user') | Where-Object { $_.id -eq $PesterParamsHash_BuildOrg.User1.id })) {
            Set-JcSdkSystemAssociation -Op:("add") -SystemId:($PesterParamsHash_BuildOrg.SystemLinux._id) -Type:('user') -Id:($PesterParamsHash_BuildOrg.User1.id);
        };
        SystemPolicyMembership        = If (-not (Get-JcSdkSystemAssociation -SystemId:($PesterParamsHash_BuildOrg.SystemLinux._id) -Targets:('policy') | Where-Object { $_.id -eq $PesterParamsHash_BuildOrg.SinglePolicy.id })) {
            Set-JcSdkSystemAssociation -Op:("add") -SystemId:($PesterParamsHash_BuildOrg.SystemLinux._id) -Type:('policy') -Id:($PesterParamsHash_BuildOrg.SinglePolicy.id);
        };
        Command1SystemGroupMembership = If (-not (Get-JcSdkCommandAssociation -CommandId:($PesterParamsHash_BuildOrg.Command1._id) -Targets:('system_group') | Where-Object { $_.id -eq $PesterParamsHash_BuildOrg.SystemGroup.id })) {
            Set-JcSdkCommandAssociation -Op:("add") -CommandId:($PesterParamsHash_BuildOrg.Command1._id) -Type:('system_group') -Id:($PesterParamsHash_BuildOrg.SystemGroup.id);
        };
        Command2SystemGroupMembership = If (-not (Get-JcSdkCommandAssociation -CommandId:($PesterParamsHash_BuildOrg.Command2._id) -Targets:('system_group') | Where-Object { $_.id -eq $PesterParamsHash_BuildOrg.SystemGroup.id })) {
            Set-JcSdkCommandAssociation -Op:("add") -CommandId:($PesterParamsHash_BuildOrg.Command2._id) -Type:('system_group') -Id:($PesterParamsHash_BuildOrg.SystemGroup.id);
        };
        Command3SystemGroupMembership = If (-not (Get-JcSdkCommandAssociation -CommandId:($PesterParamsHash_BuildOrg.Command3._id) -Targets:('system_group') | Where-Object { $_.id -eq $PesterParamsHash_BuildOrg.SystemGroup.id })) {
            Set-JcSdkCommandAssociation -Op:("add") -CommandId:($PesterParamsHash_BuildOrg.Command3._id) -Type:('system_group') -Id:($PesterParamsHash_BuildOrg.SystemGroup.id);
        };
    }
    Write-Host "[Status] Finished Generating Associations: $($stopwatch.Elapsed)"

    # Generate command results if they dont exist
    If ([System.String]::IsNullOrEmpty($PesterParamsHash_BuildOrg.CommandResults) -or $PesterParamsHash_BuildOrg.CommandResults.Count -lt $PesterParams_CommandResultCount) {
        If (-not (Get-JcSdkCommandAssociation -CommandId:($PesterParamsHash_BuildOrg.Command1._id) -Targets:('system') | Where-Object { $_.targetId -eq $PesterParamsHash_BuildOrg.SystemLinux._id })) {
            Set-JcSdkCommandAssociation -Op:("add") -CommandId:($PesterParamsHash_BuildOrg.Command1._id) -Type:('system') -Id:($PesterParamsHash_BuildOrg.SystemLinux._id)
        };
        For ($i = 1; $i -le $PesterParams_CommandResultCount; $i++) {
            Invoke-JCCommand -trigger:($PesterParamsHash_BuildOrg.Command1.trigger)
        }
        While ((Get-JCCommandResult | Where-Object { $_.Name -eq $PesterParamsHash_BuildOrg.Command1.name }).Count -ge $PesterParams_CommandResultCount) {
            Start-Sleep -Milliseconds:(200)
        }
        If ((Get-JcSdkCommandAssociation -CommandId:($PesterParamsHash_BuildOrg.Command1._id) -Targets:('system') | Where-Object { $_.targetId -eq $PesterParamsHash_BuildOrg.SystemLinux._id })) {
            Set-JcSdkCommandAssociation -Op:("remove") -CommandId:($PesterParamsHash_BuildOrg.Command1._id) -Type:('system') -Id:($PesterParamsHash_BuildOrg.SystemLinux._id)

        };
    }
    Write-Host "[Status] Finished Generating Command Results: $($stopwatch.Elapsed)"

    # Combine all hash tables into one list and foreach of their values create a new global parameter
    (Get-Variable -Scope:('Script') -Name:("$($PesterParamsHash_VariableName.VariableNamePrefixHash)*")).Value | ForEach-Object {
        $_.GetEnumerator() | ForEach-Object {
            Set-Variable -Name:("$($PesterParamsHash_VariableName.VariableNamePrefix)$($_.Name)") -Value:($_.Value) -Scope:('Global')
            $variableObject = [PSCustomObject]@{
                Name  = "$($PesterParamsHash_VariableName.VariableNamePrefix)$($_.Name)"
                Value = $_.Value
            }
            $variableArray.Add($variableObject)
        }
    }
    $stopwatch.Stop()
    Write-Host "[Status] SetupOrg took $($stopwatch.Elapsed) to complete!"
} Catch {
    Write-Error ($_.Exception)
    Write-Error ($_.FullyQualifiedErrorId)
    Write-Error ($_.ScriptStackTrace)
    Write-Error ($_.TargetObject)
    Write-Error ($_.PSMessageDetails)
}
