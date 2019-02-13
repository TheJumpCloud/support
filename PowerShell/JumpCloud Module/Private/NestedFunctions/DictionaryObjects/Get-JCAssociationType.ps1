Function Get-JCAssociationType
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param(
        # Any other parameters can go here
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, Position = 0)][ValidateNotNullOrEmpty()]$Source
    )
    $AssociationTypes = @()
    $AssociationTypes += [PSCustomObject]@{'Source' = 'activedirectories'; 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group'); }
    $AssociationTypes += [PSCustomObject]@{'Source' = 'applications'; 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group'); }
    $AssociationTypes += [PSCustomObject]@{'Source' = 'commands'; 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group'); }
    $AssociationTypes += [PSCustomObject]@{'Source' = 'gsuites'; 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group'); }
    $AssociationTypes += [PSCustomObject]@{'Source' = 'ldapservers'; 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group'); }
    $AssociationTypes += [PSCustomObject]@{'Source' = 'office365s'; 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group'); }
    $AssociationTypes += [PSCustomObject]@{'Source' = 'policies'; 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group'); }
    $AssociationTypes += [PSCustomObject]@{'Source' = 'radiusservers'; 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group'); }
    $AssociationTypes += [PSCustomObject]@{'Source' = 'systemgroups'; 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'user', 'user_group'); }
    $AssociationTypes += [PSCustomObject]@{'Source' = 'systems'; 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'user', 'user_group'); }
    $AssociationTypes += [PSCustomObject]@{'Source' = 'usergroups'; 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group'); }
    $AssociationTypes += [PSCustomObject]@{'Source' = 'users'; 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group'); }
    $AssociationType = $AssociationTypes | Where-Object {$_.Source -eq $Source}
    If ($AssociationType)
    {
        Return $AssociationType
    }
    Else
    {
        Write-Error ('The type "' + $Source + '" does not exist. Available types are ' + ($AssociationTypes.Source -join ', '))
    }
}