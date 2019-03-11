Function Get-JCAssociationType
{
    [CmdletBinding()]
    Param()
    DynamicParam
    {
        $InputObjectNames = @()
        $InputObjectNames += [PSCustomObject]@{'Plural' = 'activedirectories'; 'Singular' = 'active_directory'; }
        $InputObjectNames += [PSCustomObject]@{'Plural' = 'commands'; 'Singular' = 'command'; }
        $InputObjectNames += [PSCustomObject]@{'Plural' = 'ldapservers'; 'Singular' = 'ldap_server'; }
        $InputObjectNames += [PSCustomObject]@{'Plural' = 'policies'; 'Singular' = 'policy'; }
        $InputObjectNames += [PSCustomObject]@{'Plural' = 'applications'; 'Singular' = 'application'; }
        $InputObjectNames += [PSCustomObject]@{'Plural' = 'radiusservers'; 'Singular' = 'radius_server'; }
        $InputObjectNames += [PSCustomObject]@{'Plural' = 'systemgroups'; 'Singular' = 'system_group'; }
        $InputObjectNames += [PSCustomObject]@{'Plural' = 'systems'; 'Singular' = 'system'; }
        $InputObjectNames += [PSCustomObject]@{'Plural' = 'usergroups'; 'Singular' = 'user_group'; }
        $InputObjectNames += [PSCustomObject]@{'Plural' = 'users'; 'Singular' = 'user'; }
        $InputObjectNames += [PSCustomObject]@{'Plural' = 'gsuites'; 'Singular' = 'g_suite'; }
        $InputObjectNames += [PSCustomObject]@{'Plural' = 'office365s'; 'Singular' = 'office_365'; }
        $InputObjectNames = $InputObjectNames | Select-Object *, @{Name = 'Lookup'; Expression = {@($_.Plural, $_.Singular)}}
        # Build parameter array
        $RuntimeParameterDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
        New-DynamicParameter -Name:('InputObject') -Type:([System.String]) -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -ParameterSets:('ByName') -ValidateSet:($InputObjectNames.Lookup) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        Return $RuntimeParameterDictionary
    }
    Begin
    {
        # Create new variables for script
        $PsBoundParameters.GetEnumerator() | ForEach-Object {New-Variable -Name:($_.Key) -Value:($_.Value) -Force}
        # Debug message for parameter call
        # Write-Debug ('[CallFunction]' + $MyInvocation.MyCommand.Name + ' ' + ($PsBoundParameters.GetEnumerator() | Sort-Object Key | ForEach-Object { '-' + $_.Key + ":('" + ($_.Value -join "','") + "')"}).Replace("'True'", '$True').Replace("'False'", '$False'))
        # If ($PSCmdlet.ParameterSetName -ne '__AllParameterSets') {Write-Verbose ('[ParameterSet]' + $MyInvocation.MyCommand.Name + ':' + $PSCmdlet.ParameterSetName)}

        $AssociationTypes = @()
        $AssociationTypes += [PSCustomObject]@{'InputObject' = 'activedirectories'; 'Targets' = ('user', 'user_group'); }
        $AssociationTypes += [PSCustomObject]@{'InputObject' = 'commands'; 'Targets' = ('system', 'system_group'); }
        $AssociationTypes += [PSCustomObject]@{'InputObject' = 'ldapservers'; 'Targets' = ('user', 'user_group'); }
        $AssociationTypes += [PSCustomObject]@{'InputObject' = 'policies'; 'Targets' = ('system', 'system_group'); }
        $AssociationTypes += [PSCustomObject]@{'InputObject' = 'applications'; 'Targets' = ('user_group'); } #'user',
        $AssociationTypes += [PSCustomObject]@{'InputObject' = 'radiusservers'; 'Targets' = ('user_group'); } #'user',
        $AssociationTypes += [PSCustomObject]@{'InputObject' = 'systemgroups'; 'Targets' = ('policy', 'user_group', 'command'); }#'user',
        $AssociationTypes += [PSCustomObject]@{'InputObject' = 'systems'; 'Targets' = ('policy', 'user', 'command'); } #'user_group',
        $AssociationTypes += [PSCustomObject]@{'InputObject' = 'usergroups'; 'Targets' = ('active_directory', 'application', 'g_suite', 'ldap_server', 'office_365', 'radius_server', 'system_group'); } #'system',
        $AssociationTypes += [PSCustomObject]@{'InputObject' = 'users'; 'Targets' = ('active_directory', 'g_suite', 'ldap_server', 'office_365', 'system'); }#'application','radius_server','system_group',
        $AssociationTypes += [PSCustomObject]@{'InputObject' = 'gsuites'; 'Targets' = ('user', 'user_group'); }
        $AssociationTypes += [PSCustomObject]@{'InputObject' = 'office365s'; 'Targets' = ('user', 'user_group'); }
        ###All possible Targets####('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group')
    }
    Process
    {
        If ($PSCmdlet.ParameterSetName -eq 'ByName')
        {
            $SearchValue = $InputObjectNames| Where-Object {$InputObject -in $_.Lookup}
            $OutputObject = $AssociationTypes | Where-Object {$SearchValue.Plural -eq $_.InputObject}
        }
        Else
        {
            $OutputObject = $AssociationTypes
        }
    }
    End
    {
        If ($OutputObject)
        {
            Return $OutputObject
        }
        Else
        {
            Write-Error ('The type "' + $InputObject + '" does not exist. Available types are (' + ($OutputObject.InputObject -join ', ') + ')')
        }
    }
}
# ('activedirectories','active_directory','commands','command','ldapservers','ldap_server','policies','policy','applications','application','radiusservers','radius_server','systemgroups','system_group','systems','system','usergroups','user_group','users','user')
# ('activedirectories', 'active_directory', 'commands', 'command', 'ldapservers', 'ldap_server', 'policies', 'policy', 'applications', 'application', 'radiusservers', 'radius_server', 'systemgroups', 'system_group', 'systems', 'system', 'usergroups', 'user_group', 'users', 'user')
# ('activedirectories','commands','ldapservers','policies','applications','radiusservers','systemgroups','systems','usergroups','users')
# ('activedirectories', 'commands', 'ldapservers', 'policies', 'applications', 'radiusservers', 'systemgroups', 'systems', 'usergroups','users')