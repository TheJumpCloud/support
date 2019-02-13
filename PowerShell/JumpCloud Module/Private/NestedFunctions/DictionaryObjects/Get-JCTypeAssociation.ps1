Function Get-JCTypeAssociation
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param(
        # Any other parameters can go here
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, Position = 0)][ValidateNotNullOrEmpty()]$Source
    )
    $TypeAssociation = @()
    $TypeAssociation += [PSCustomObject]@{'Source' = 'activedirectories'; 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group'); }
    $TypeAssociation += [PSCustomObject]@{'Source' = 'applications'; 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group'); }
    $TypeAssociation += [PSCustomObject]@{'Source' = 'commands'; 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group'); }
    $TypeAssociation += [PSCustomObject]@{'Source' = 'gsuites'; 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group'); }
    $TypeAssociation += [PSCustomObject]@{'Source' = 'ldapservers'; 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group'); }
    $TypeAssociation += [PSCustomObject]@{'Source' = 'office365s'; 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group'); }
    $TypeAssociation += [PSCustomObject]@{'Source' = 'policies'; 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group'); }
    $TypeAssociation += [PSCustomObject]@{'Source' = 'radiusservers'; 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group'); }
    $TypeAssociation += [PSCustomObject]@{'Source' = 'systemgroups'; 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'user', 'user_group'); }
    $TypeAssociation += [PSCustomObject]@{'Source' = 'systems'; 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'user', 'user_group'); }
    $TypeAssociation += [PSCustomObject]@{'Source' = 'usergroups'; 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group'); }
    $TypeAssociation += [PSCustomObject]@{'Source' = 'users'; 'Targets' = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group'); }
    $SpecifiedType = $TypeAssociation | Where-Object {$_.Source -eq $Source}
    If($SpecifiedType)
    {
        Return $SpecifiedType
    }
    Else
    {
        Write-Error ('The type "' + $Source + '" does not exist. Available types are ' + ($TypeAssociation.Source -join ', '))
    }
}