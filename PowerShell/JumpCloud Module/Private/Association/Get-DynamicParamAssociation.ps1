Function Get-DynamicParamAssociation
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][string]$Action
        , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 1)][string]$Type
        , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 2, HelpMessage = 'Bypass user confirmation and ValidateSet when adding or removing associations.')][ValidateNotNullOrEmpty()][Switch]$Force
    )
    # Define the new parameters
    $Param_Id = @{
        'Name'                            = 'Id';
        'Type'                            = [System.String[]];
        'Position'                        = 3;
        'ValueFromPipelineByPropertyName' = $true;
        'ValidateNotNullOrEmpty'          = $true;
        'ParameterSets'                   = @('ById');
        'HelpMessage'                     = 'The unique id of the object.';
    }
    $Param_Name = @{
        'Name'                            = 'Name';
        'Type'                            = [System.String[]];
        'Position'                        = 4;
        'ValueFromPipelineByPropertyName' = $true;
        'ValidateNotNullOrEmpty'          = $true;
        'ParameterSets'                   = @('ByName');
        'HelpMessage'                     = 'The name of the object.';
    }
    $Param_TargetType = @{
        'Name'                            = 'TargetType';
        'Type'                            = [System.String[]];
        'Position'                        = 5;
        'ValueFromPipelineByPropertyName' = $true;
        'ValidateNotNullOrEmpty'          = $true;
        'Alias'                           = ('TargetSingular');
        'HelpMessage'                     = 'The target object type.';
    }
    $Param_associationType = @{
        'Name'                            = 'associationType';
        'Type'                            = [System.String[]];
        'Position'                        = 6;
        'ValueFromPipelineByPropertyName' = $true;
        'ValidateSet'                     = @('direct', 'direct/indirect', 'indirect');
        'DefaultValue'                    = $false;
        'DontShow'                        = $true;
        'HelpMessage'                     = 'Used for piping only to determine type of association when coming from Add-JCAssociation or Remove-JCAssociation.';
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
        $Param_Id.Add('Mandatory', $true)
        $Param_Name.Add('Mandatory', $true)
        $Param_TargetType.Add('Mandatory', $true)
        $Param_Id.Add('Alias', ($JCTypes.ById | Where-Object { $_ -ne 'Id' } | Select-Object -Unique))
        $Param_Name.Add('Alias', ($JCTypes.ByName | Where-Object { $_ -ne 'Name' } | Select-Object -Unique))
        $Param_TargetType.Add('ValidateSet', ($JCTypes.Targets.TargetSingular | Select-Object -Unique))
    }
    Else
    {
        # Determine if help files are being built
        If ((Get-PSCallStack).Command -like '*MarkdownHelp')
        {
            $JCObjectCount = 999999
        }
        Else
        {
            # Get targets list
            $JCTypes = $JCTypes | Where-Object { $_.TypeName.TypeNameSingular -eq $Type };
            # Get count of JCObject to determine if script should load dynamic parameters
            $JCObjectCount = (Get-JCObject -Type:($Type) -ReturnCount).totalCount
        }
        $Param_TargetType.Add('Mandatory', $false)
        If ($JCObjectCount -ge 1 -and $JCObjectCount -le 300)
        {
            # Get all objects of the specific type
            $JCObject = Get-JCObject -Type:($Type);
            $Param_Id.Add('Alias', ($JCObject.ById | Where-Object { $_ -ne 'Id' } | Select-Object -Unique))
            $Param_Name.Add('Alias', ($JCObject.ByName | Where-Object { $_ -ne 'Name' } | Select-Object -Unique))
            $Param_TargetType.Add('DefaultValue', ($JCObject.Targets.TargetSingular | Select-Object -Unique))
            $Param_TargetType.Add('ValidateSet', ($JCObject.Targets.TargetSingular | Select-Object -Unique))
            If ($JCObjectCount -eq 1)
            {
                # Don't require Id and Name to be passed through and set a default value
                $Param_Id.Add('Mandatory', $false)
                $Param_Name.Add('Mandatory', $false)
                $Param_Id.Add('DefaultValue', $JCObject.($JCObject.ById))
                $Param_Name.Add('DefaultValue', $JCObject.($JCObject.ByName))
            }
            Else
            {
                # Do populate validate set with list of items
                $Param_Id.Add('Mandatory', $true)
                $Param_Name.Add('Mandatory', $true)
                If (!($Force))
                {
                    $Param_Id.Add('ValidateSet', @($JCObject.($JCObject.ById | Select-Object -Unique)))
                    $Param_Name.Add('ValidateSet', @($JCObject.($JCObject.ByName | Select-Object -Unique)))
                }
            }
        }
        Else
        {
            # Don't populate validate set
            $Param_Id.Add('Mandatory', $true)
            $Param_Name.Add('Mandatory', $true)
            $Param_Id.Add('Alias', ($JCTypes.ById | Where-Object { $_ -ne 'Id' } | Select-Object -Unique))
            $Param_Name.Add('Alias', ($JCTypes.ByName | Where-Object { $_ -ne 'Name' } | Select-Object -Unique))
            $Param_TargetType.Add('ValidateSet', ($JCTypes.Targets.TargetSingular | Select-Object -Unique))
            $Param_TargetType.Add('DefaultValue', ($JCTypes.Targets.TargetSingular | Select-Object -Unique))
        }
    }
    # Create the parameter array
    $Params = @()
    # Add parameters to array
    $Params += $Param_Id
    $Params += $Param_Name
    $Params += $Param_TargetType
    If ($Action -eq 'get')
    {
        $Params += $Param_Raw
        $Params += $Param_Direct
        $Params += $Param_Indirect
        $Params += $Param_IncludeInfo
        $Params += $Param_IncludeNames
        $Params += $Param_IncludeVisualPath
    }
    If ($Action -in ('add', 'remove'))
    {
        $Params += $Param_TargetId
        $Params += $Param_TargetName
        $Params += $Param_associationType
    }
    If ($Action -eq 'add')
    {
        $Params += $Param_Attributes
    }
    # Create new parameters
    $RuntimeParameterDictionary = $Params |
        ForEach-Object { New-Object -TypeName:('PSObject') -Property:($_) } |
        New-DynamicParameter
    # Return parameters
    Return $RuntimeParameterDictionary
}