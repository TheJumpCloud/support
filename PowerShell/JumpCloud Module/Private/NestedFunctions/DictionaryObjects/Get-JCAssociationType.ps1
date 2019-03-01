Function Get-JCAssociationType
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param(
        # Any other parameters can go here
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, Position = 0)][ValidateNotNullOrEmpty()]$InputObject
    )
    $AssociationTypes = @()
    $AssociationTypes += [PSCustomObject]@{'InputObject' = @('activedirectories'); 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group'); }
    $AssociationTypes += [PSCustomObject]@{'InputObject' = @('applications'); 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group'); }
    $AssociationTypes += [PSCustomObject]@{'InputObject' = @('commands'); 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group'); }
    $AssociationTypes += [PSCustomObject]@{'InputObject' = @('gsuites'); 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group'); }
    $AssociationTypes += [PSCustomObject]@{'InputObject' = @('ldapservers'); 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group'); }
    $AssociationTypes += [PSCustomObject]@{'InputObject' = @('office365s'); 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group'); }
    $AssociationTypes += [PSCustomObject]@{'InputObject' = @('policies'); 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group'); }
    $AssociationTypes += [PSCustomObject]@{'InputObject' = @('radiusservers'); 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group'); }
    $AssociationTypes += [PSCustomObject]@{'InputObject' = @('systemgroups'); 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'user', 'user_group'); }
    $AssociationTypes += [PSCustomObject]@{'InputObject' = @('systems'); 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'user', 'user_group'); }
    $AssociationTypes += [PSCustomObject]@{'InputObject' = @('usergroups'); 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group'); }
    $AssociationTypes += [PSCustomObject]@{'InputObject' = @('users'); 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group'); }
    $AssociationType = $AssociationTypes | Where-Object {$InputObject -in $_.InputObject}
    If ($AssociationType)
    {
        Return $AssociationType
    }
    Else
    {
        Write-Error ('The type "' + $InputObject + '" does not exist. Available types are (' + ($AssociationTypes.InputObject -join ', ') + ')')
    }
}