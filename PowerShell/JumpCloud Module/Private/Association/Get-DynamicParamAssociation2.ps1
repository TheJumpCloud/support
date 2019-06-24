Function Get-DynamicParamAssociation2
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][ValidateSet('add', 'get', 'remove')][string]$Action
        , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 1, HelpMessage = 'The type of the object.')][ValidateNotNullOrEmpty()][ValidateSet('command', 'ldap_server', 'policy', 'application', 'radius_server', 'system_group', 'system', 'user_group', 'user', 'g_suite', 'office_365')][Alias('TypeNameSingular')][string]$Type
        , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 2, HelpMessage = 'Bypass user confirmation and ValidateSet when adding or removing associations.')][ValidateNotNullOrEmpty()][Switch]$Force
    )
    # Define the new parameters
    $Param_TargetType = @{
        'Name'                            = 'TargetType';
        'Type'                            = [System.String[]];
        'Position'                        = 5;
        'ValueFromPipelineByPropertyName' = $true;
        'ValidateNotNullOrEmpty'          = $true;
        'Alias'                           = ('TargetSingular');
        'HelpMessage'                     = 'The type of the target object.';
    }
    $Param_associationType = @{
        'Name'                            = 'associationType';
        'Type'                            = [System.String[]];
        'Position'                        = 6;
        'ValueFromPipelineByPropertyName' = $true;
        'ValidateSet'                     = @("direct", "direct`/indirect", "indirect");
        'DontShow'                        = $true;
        'HelpMessage'                     = 'Used for piping only to determine type of association when coming from Add-JCAssociation or Remove-JCAssociation.';
        'Mandatory'                       = $false;
    }
    $Param_Raw = @{
        'Name'                            = 'Raw';
        'Type'                            = [Switch];
        'Position'                        = 7;
        'ValueFromPipelineByPropertyName' = $true;
        'DefaultValue'                    = $false;
        'DontShow'                        = $true;
        'HelpMessage'                     = 'Returns the raw and unedited output from the api endpoint.';
    }
    $Param_Direct = @{
        'Name'                            = 'Direct';
        'Type'                            = [Switch];
        'Position'                        = 8;
        'ValueFromPipelineByPropertyName' = $true;
        'DefaultValue'                    = $false;
        'HelpMessage'                     = 'Returns only "Direct" associations.';
    }
    $Param_Indirect = @{
        'Name'                            = 'Indirect';
        'Type'                            = [Switch];
        'Position'                        = 9;
        'ValueFromPipelineByPropertyName' = $true;
        'DefaultValue'                    = $false;
        'HelpMessage'                     = 'Returns only "Indirect" associations.';
    }
    $Param_IncludeInfo = @{
        'Name'                            = 'IncludeInfo';
        'Type'                            = [Switch];
        'Position'                        = 10;
        'ValueFromPipelineByPropertyName' = $true;
        'ParameterSets'                   = @('ById', 'ByName');
        'DefaultValue'                    = $false;
        'HelpMessage'                     = 'Appends "Info" and "TargetInfo" properties to output.';
    }
    $Param_IncludeNames = @{
        'Name'                            = 'IncludeNames';
        'Type'                            = [Switch];
        'Position'                        = 11;
        'ValueFromPipelineByPropertyName' = $true;
        'ParameterSets'                   = @('ById', 'ByName');
        'DefaultValue'                    = $false;
        'HelpMessage'                     = 'Appends "Name" and "TargetName" properties to output.';
    }
    $Param_IncludeVisualPath = @{
        'Name'                            = 'IncludeVisualPath';
        'Type'                            = [Switch];
        'Position'                        = 12;
        'ValueFromPipelineByPropertyName' = $true;
        'ParameterSets'                   = @('ById', 'ByName');
        'DefaultValue'                    = $false;
        'HelpMessage'                     = 'Appends "visualPathById", "visualPathByName", and "visualPathByType" properties to output.';
    }
    $Param_TargetId = @{
        'Name'                            = 'TargetId';
        'Type'                            = [System.String];
        'Position'                        = 13;
        'ValueFromPipelineByPropertyName' = $true;
        'HelpMessage'                     = 'The unique id of the target object.';
    }
    $Param_TargetName = @{
        'Name'                            = 'TargetName';
        'Type'                            = [System.String];
        'Position'                        = 14;
        'ValueFromPipelineByPropertyName' = $true;
        'HelpMessage'                     = 'The name of the target object.';
    }
    $Param_Attributes = @{
        'Name'                            = 'Attributes';
        'Type'                            = [System.Management.Automation.PSObject];
        'Position'                        = 15;
        'ValueFromPipelineByPropertyName' = $true;
        'Alias'                           = 'compiledAttributes';
        'HelpMessage'                     = 'Add attributes that define the association such as if they are an admin.';
    }
    # Get type list
    $JCTypes = Get-JCType | Where-Object { $_.Category -eq 'JumpCloud' };
    # Add properties to the parameters based upon the setup of the org for performance considerations
    If (!($Action -and $Type))
    {
        $Param_TargetType.Add('Mandatory', $true)
        $Param_TargetType.Add('ValidateSet', ($JCTypes.Targets.TargetSingular | Select-Object -Unique))
        $RuntimeParameterDictionary = Get-JCCommonParameters
    }
    Else
    {
        # Get targets list
        $JCTypes = $JCTypes | Where-Object { $_.TypeName.TypeNameSingular -eq $Type };
        $Param_TargetType.Add('Mandatory', $false)
        $Param_TargetType.Add('ValidateSet', ($JCTypes.Targets.TargetSingular | Select-Object -Unique))
        $Param_TargetType.Add('DefaultValue', ($JCTypes.Targets.TargetSingular | Select-Object -Unique))
        $RuntimeParameterDictionary = Get-JCCommonParameters -Type:($Type)
    }
    New-DynamicParameter $Param_TargetType | Out-Null
    If ($Action -eq 'get')
    {
        New-DynamicParameter $Param_Raw | Out-Null
        New-DynamicParameter $Param_Direct | Out-Null
        New-DynamicParameter $Param_Indirect | Out-Null
        New-DynamicParameter $Param_IncludeInfo | Out-Null
        New-DynamicParameter $Param_IncludeNames | Out-Null
        New-DynamicParameter $Param_IncludeVisualPath | Out-Null
    }
    If ($Action -in ('add', 'remove'))
    {
        New-DynamicParameter $Param_TargetId | Out-Null
        New-DynamicParameter $Param_TargetName | Out-Null
        New-DynamicParameter $Param_associationType | Out-Null
    }
    If ($Action -eq 'add')
    {
        New-DynamicParameter $Param_Attributes | Out-Null
    }

    Return $RuntimeParameterDictionary
}