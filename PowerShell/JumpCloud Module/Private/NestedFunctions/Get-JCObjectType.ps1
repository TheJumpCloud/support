Function Get-JCObjectType
{
    [CmdletBinding()]
    Param()
    DynamicParam
    {
        $ObjectTypes = @()
        $ObjectTypes += [PSCustomObject]@{'Category' = 'JumpCloud'; 'Singular' = 'active_directory'; 'Plural' = 'activedirectories'; 'Targets' = ('user', 'user_group'); 'Url' = '/api/v2/activedirectories'; 'Method' = 'GET'; 'ById' = 'id'; 'ByName' = 'domain'; 'Paginate' = $true; 'SupportRegexFilter' = $true; 'Limit' = 100; }
        $ObjectTypes += [PSCustomObject]@{'Category' = 'JumpCloud'; 'Singular' = 'command'; 'Plural' = 'commands'; 'Targets' = ('system', 'system_group'); 'Url' = '/api/commands'; 'Method' = 'GET'; 'ById' = '_id'; 'ByName' = 'name'; 'Paginate' = $true; 'SupportRegexFilter' = $false; 'Limit' = 100; }
        $ObjectTypes += [PSCustomObject]@{'Category' = 'JumpCloud'; 'Singular' = 'ldap_server'; 'Plural' = 'ldapservers'; 'Targets' = ('user', 'user_group'); 'Url' = '/api/v2/ldapservers'; 'Method' = 'GET'; 'ById' = 'id'; 'ByName' = 'name'; 'Paginate' = $true; 'SupportRegexFilter' = $true; 'Limit' = 100; }
        $ObjectTypes += [PSCustomObject]@{'Category' = 'JumpCloud'; 'Singular' = 'policy'; 'Plural' = 'policies'; 'Targets' = ('system', 'system_group'); 'Url' = '/api/v2/policies'; 'Method' = 'GET'; 'ById' = 'id'; 'ByName' = 'name'; 'Paginate' = $true; 'SupportRegexFilter' = $false; 'Limit' = 100; }
        $ObjectTypes += [PSCustomObject]@{'Category' = 'JumpCloud'; 'Singular' = 'application'; 'Plural' = 'applications'; 'Targets' = ('user_group'); 'Url' = '/api/applications'; 'Method' = 'GET'; 'ById' = '_id'; 'ByName' = 'displayName'; 'Paginate' = $true; 'SupportRegexFilter' = $false; 'Limit' = 100; 'TargetsExcluded' = ('user');}
        $ObjectTypes += [PSCustomObject]@{'Category' = 'JumpCloud'; 'Singular' = 'radius_server'; 'Plural' = 'radiusservers'; 'Targets' = ('user_group'); 'Url' = '/api/radiusservers'; 'Method' = 'GET'; 'ById' = '_id'; 'ByName' = 'name'; 'Paginate' = $true; 'SupportRegexFilter' = $false; 'Limit' = 100;'TargetsExcluded' = ('user'); }
        $ObjectTypes += [PSCustomObject]@{'Category' = 'JumpCloud'; 'Singular' = 'system_group'; 'Plural' = 'systemgroups'; 'Targets' = ('policy', 'user_group', 'command', 'system'); 'Url' = '/api/v2/systemgroups'; 'Method' = 'GET'; 'ById' = 'id'; 'ByName' = 'name'; 'Paginate' = $true; 'SupportRegexFilter' = $true; 'Limit' = 100; 'TargetsExcluded' = ('user');}
        $ObjectTypes += [PSCustomObject]@{'Category' = 'JumpCloud'; 'Singular' = 'system'; 'Plural' = 'systems'; 'Targets' = ('policy', 'user', 'command', 'system_group'); 'Url' = '/api/systems'; 'Method' = 'GET'; 'ById' = '_id'; 'ByName' = 'displayName'; 'Paginate' = $true; 'SupportRegexFilter' = $true; 'Limit' = 100; 'TargetsExcluded' = ('user_group');}
        $ObjectTypes += [PSCustomObject]@{'Category' = 'JumpCloud'; 'Singular' = 'user_group'; 'Plural' = 'usergroups'; 'Targets' = ('active_directory', 'application', 'g_suite', 'ldap_server', 'office_365', 'radius_server', 'system_group', 'user'); 'Url' = '/api/v2/usergroups'; 'Method' = 'GET'; 'ById' = 'id'; 'ByName' = 'name'; 'Paginate' = $true; 'SupportRegexFilter' = $true; 'Limit' = 100; 'TargetsExcluded' = ('system');}
        $ObjectTypes += [PSCustomObject]@{'Category' = 'JumpCloud'; 'Singular' = 'user'; 'Plural' = 'users'; 'Targets' = ('active_directory', 'g_suite', 'ldap_server', 'office_365', 'system', 'user_group'); 'Url' = '/api/systemusers'; 'Method' = 'GET'; 'ById' = '_id'; 'ByName' = 'username'; 'Paginate' = $true; 'SupportRegexFilter' = $true; 'Limit' = 100; 'TargetsExcluded' = ('application','radius_server','system_group');}
        $ObjectTypes += [PSCustomObject]@{'Category' = 'JumpCloud'; 'Singular' = 'g_suite'; 'Plural' = 'gsuites'; 'Targets' = ('user', 'user_group'); 'Url' = '/api/v2/directories'; 'Method' = 'GET'; 'ById' = 'id'; 'ByName' = 'name'; 'Paginate' = $true; 'SupportRegexFilter' = $false; 'Limit' = 100; }
        $ObjectTypes += [PSCustomObject]@{'Category' = 'JumpCloud'; 'Singular' = 'office_365'; 'Plural' = 'office365s'; 'Targets' = ('user', 'user_group'); 'Url' = '/api/v2/directories'; 'Method' = 'GET'; 'ById' = 'id'; 'ByName' = 'name'; 'Paginate' = $true; 'SupportRegexFilter' = $false; 'Limit' = 100; }
        # Custom Types
        $ObjectTypes += [PSCustomObject]@{'Category' = 'Custom'; 'Singular' = 'directory'; 'Plural' = 'directories'; 'Targets' = ($NULL); 'Url' = '/api/v2/directories'; 'Method' = 'GET'; 'ById' = 'id'; 'ByName' = 'name'; 'Paginate' = $true; 'SupportRegexFilter' = $false; 'Limit' = 100; }
        $ObjectTypes += [PSCustomObject]@{'Category' = 'Custom'; 'Singular' = 'group'; 'Plural' = 'groups'; 'Targets' = ($NULL); 'Url' = '/api/v2/groups'; 'Method' = 'GET'; 'ById' = 'id'; 'ByName' = 'name'; 'Paginate' = $true; 'SupportRegexFilter' = $false; 'Limit' = 100; }
        # $ObjectTypes += [PSCustomObject]@{'Category' = 'Custom';'Singular' = 'policyresult'; 'Plural' = 'policyresults';  'Url' = '/api/v2/policies/{Policy_Id}/policyresults'; 'Method' = 'GET'; 'ById' = 'id'; 'ByName' = $false; 'Paginate' = $true; 'SupportRegexFilter' = $false; 'Limit' = 100; }
        # $ObjectTypes += [PSCustomObject]@{'Category' = 'Custom';'Singular' = 'applicationUser'; 'Plural' = 'applicationUsers';  'Url' = '/api/v2/applications/{Application_Id}/users'; 'Method' = 'GET'; 'ById' = 'id'; 'ByName' = $false; 'Paginate' = $true; 'SupportRegexFilter' = $false; 'Limit' = 100; }
        $ObjectTypes += [PSCustomObject]@{'Category' = 'Custom'; 'Singular' = 'search_user'; 'Plural' = 'search_users'; 'Targets' = ('active_directory', 'g_suite', 'ldap_server', 'office_365', 'system', 'user_group'); 'Url' = '/api/search/systemusers'; 'Method' = 'POST'; 'ById' = '_id'; 'ByName' = 'username'; 'Paginate' = $true; 'SupportRegexFilter' = $true; 'Limit' = 100; }
        $ObjectTypes += [PSCustomObject]@{'Category' = 'Custom'; 'Singular' = 'search_system'; 'Plural' = 'search_systems'; 'Targets' = ('policy', 'user', 'command', 'system_group'); 'Url' = '/api/search/systems'; 'Method' = 'POST'; 'ById' = '_id'; 'ByName' = 'displayName'; 'Paginate' = $true; 'SupportRegexFilter' = $true; 'Limit' = 100; }
        # Templates
        # $ObjectTypes += [PSCustomObject]@{'Singular' = ''; 'Plural' = ''; 'Targets' = (''); 'Url' = ''; 'Method' = ''; 'ById' = ''; 'ByName' = ''; 'Paginate' = $true; 'SupportRegexFilter' = $true; 'Limit' = 100; }
        ###All possible Targets####('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group')
        $ObjectTypes = $ObjectTypes | Select-Object *, @{Name = 'Types'; Expression = {@($_.Singular, $_.Plural)}}
        # Build parameter array
        $RuntimeParameterDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
        New-DynamicParameter -Name:('Type') -Type:([System.String]) -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -ParameterSets:('ByName') -ValidateSet:($ObjectTypes.Types) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        Return $RuntimeParameterDictionary
    }
    Begin
    {
        # Create new variables for script
        $PsBoundParameters.GetEnumerator() | ForEach-Object {New-Variable -Name:($_.Key) -Value:($_.Value) -Force}
        # Debug message for parameter call
        Write-Debug ('[CallFunction]' + $MyInvocation.MyCommand.Name + ' ' + ($PsBoundParameters.GetEnumerator() | Sort-Object Key | ForEach-Object { '-' + $_.Key + ":('" + ($_.Value -join "','").Replace("'True'", '$True').Replace("'False'", '$False') + "')"}) )
        If ($PSCmdlet.ParameterSetName -ne '__AllParameterSets') {Write-Verbose ('[ParameterSet]' + $MyInvocation.MyCommand.Name + ':' + $PSCmdlet.ParameterSetName)}
    }
    Process
    {
        $ObjectTypeOutput = Switch ($PSCmdlet.ParameterSetName)
        {
            'ByName' {$ObjectTypes | Where-Object {$Type -in $_.Types}}
            Default {$ObjectTypes}
        }
    }
    End
    {
        If ($ObjectTypeOutput)
        {
            Return $ObjectTypeOutput
        }
        Else
        {
            Write-Error ('The type "' + $Type + '" does not exist. Available types are (' + ($ObjectTypes.Types -join ', ') + ')')
        }
    }
}