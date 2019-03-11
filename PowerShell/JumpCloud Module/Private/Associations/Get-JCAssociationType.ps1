Function Get-JCAssociationType
{
    [CmdletBinding()]
    Param()
    DynamicParam
    {
        $TypeCommand = @()
        $TypeCommand += [PSCustomObject]@{'Singular' = 'active_directory'; 'Plural' = 'activedirectories'; 'Targets' = ('user', 'user_group'); }
        $TypeCommand += [PSCustomObject]@{'Singular' = 'command'; 'Plural' = 'commands'; 'Targets' = ('system', 'system_group'); }
        $TypeCommand += [PSCustomObject]@{'Singular' = 'ldap_server'; 'Plural' = 'ldapservers'; 'Targets' = ('user', 'user_group'); }
        $TypeCommand += [PSCustomObject]@{'Singular' = 'policy'; 'Plural' = 'policies'; 'Targets' = ('system', 'system_group'); }
        $TypeCommand += [PSCustomObject]@{'Singular' = 'application'; 'Plural' = 'applications'; 'Targets' = ('user_group'); } #'user',
        $TypeCommand += [PSCustomObject]@{'Singular' = 'radius_server'; 'Plural' = 'radiusservers'; 'Targets' = ('user_group'); } #'user',
        $TypeCommand += [PSCustomObject]@{'Singular' = 'system_group'; 'Plural' = 'systemgroups'; 'Targets' = ('policy', 'user_group', 'command', 'system'); }#'user',
        $TypeCommand += [PSCustomObject]@{'Singular' = 'system'; 'Plural' = 'systems'; 'Targets' = ('policy', 'user', 'command', 'system_group'); } #'user_group',
        $TypeCommand += [PSCustomObject]@{'Singular' = 'user_group'; 'Plural' = 'usergroups'; 'Targets' = ('active_directory', 'application', 'g_suite', 'ldap_server', 'office_365', 'radius_server', 'system_group', 'user'); } #'system',
        $TypeCommand += [PSCustomObject]@{'Singular' = 'user'; 'Plural' = 'users'; 'Targets' = ('active_directory', 'g_suite', 'ldap_server', 'office_365', 'system', 'user_group'); }#'application','radius_server','system_group',
        $TypeCommand += [PSCustomObject]@{'Singular' = 'g_suite'; 'Plural' = 'gsuites'; 'Targets' = ('user', 'user_group'); }
        $TypeCommand += [PSCustomObject]@{'Singular' = 'office_365'; 'Plural' = 'office365s'; 'Targets' = ('user', 'user_group'); }
        ###All possible Targets####('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group')
        $TypeCommand = $TypeCommand | Select-Object *, @{Name = 'Type'; Expression = {@($_.Singular, $_.Plural)}}
        # Build parameter array
        $RuntimeParameterDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
        New-DynamicParameter -Name:('InputObject') -Type:([System.String]) -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -ParameterSets:('ByName') -ValidateSet:($TypeCommand.Type) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        Return $RuntimeParameterDictionary
    }
    Begin
    {
        # Create new variables for script
        $PsBoundParameters.GetEnumerator() | ForEach-Object {New-Variable -Name:($_.Key) -Value:($_.Value) -Force}
        # Debug message for parameter call
        # Write-Debug ('[CallFunction]' + $MyInvocation.MyCommand.Name + ' ' + ($PsBoundParameters.GetEnumerator() | Sort-Object Key | ForEach-Object { '-' + $_.Key + ":('" + ($_.Value -join "','") + "')"}).Replace("'True'", '$True').Replace("'False'", '$False'))
        # If ($PSCmdlet.ParameterSetName -ne '__AllParameterSets') {Write-Verbose ('[ParameterSet]' + $MyInvocation.MyCommand.Name + ':' + $PSCmdlet.ParameterSetName)}
    }
    Process
    {
        If ($PSCmdlet.ParameterSetName -eq 'ByName')
        {
            $OutputObject = $TypeCommand | Where-Object {$InputObject -in $_.Type}
        }
        Else
        {
            $OutputObject = $TypeCommand
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
            Write-Error ('The type "' + $InputObject + '" does not exist. Available types are (' + ($OutputObject.Type -join ', ') + ')')
        }
    }
}