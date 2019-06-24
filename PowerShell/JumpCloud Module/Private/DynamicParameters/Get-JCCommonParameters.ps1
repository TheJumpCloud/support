Function Get-JCCommonParameters
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 0, HelpMessage = 'The RuntimeDefinedParameterDictionary to store variables.')][ValidateNotNullOrEmpty()][System.Management.Automation.RuntimeDefinedParameterDictionary]$RuntimeParameterDictionary = (New-Object -TypeName:([System.Management.Automation.RuntimeDefinedParameterDictionary]))
        , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 1, HelpMessage = 'The type of the object.')][ValidateNotNullOrEmpty()][ValidateSet('command', 'ldap_server', 'policy', 'application', 'radius_server', 'system_group', 'system', 'user_group', 'user', 'g_suite', 'office_365')][Alias('TypeNameSingular')][System.String]$Type
        , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 2, HelpMessage = 'Bypass user confirmation and ValidateSet when adding or removing associations.')][ValidateNotNullOrEmpty()][Switch]$Force
    )
    # Define the new parameters
    $Param_Id = @{
        'Name'                            = 'Id';
        'Type'                            = [System.String[]];
        'Position'                        = 0;
        'ValueFromPipelineByPropertyName' = $true;
        'ValidateNotNullOrEmpty'          = $true;
        'ParameterSets'                   = @('ById');
        'HelpMessage'                     = 'The unique id of the object.';
    }
    $Param_Name = @{
        'Name'                            = 'Name';
        'Type'                            = [System.String[]];
        'Position'                        = 1;
        'ValueFromPipelineByPropertyName' = $true;
        'ValidateNotNullOrEmpty'          = $true;
        'ParameterSets'                   = @('ByName');
        'HelpMessage'                     = 'The name of the object.';
    }
    $Param_Fields = @{
        'Name'                            = 'Fields';
        'Type'                            = [System.Array];
        'Position'                        = 2;
        'ValueFromPipelineByPropertyName' = $true;
        'ValidateNotNullOrEmpty'          = $true;
        'HelpMessage'                     = 'An array of the fields/properties/columns you want to return from the search.';
    }
    $Param_Filter = @{
        'Name'                            = 'Filter';
        'Type'                            = [System.String];
        'Position'                        = 3;
        'ValueFromPipelineByPropertyName' = $true;
        'ValidateNotNullOrEmpty'          = $true;
        'HelpMessage'                     = 'Filters to narrow down search.';
    }
    $Param_Limit = @{
        'Name'                            = 'Limit';
        'Type'                            = [System.Int32];
        'Position'                        = 4;
        'ValueFromPipelineByPropertyName' = $true;
        'ValidateRange'                   = (1, [int]::MaxValue);
    }
    $Param_Skip = @{
        'Name'                            = 'Skip';
        'Type'                            = [System.Int32];
        'Position'                        = 5;
        'ValueFromPipelineByPropertyName' = $true;
        'ValidateRange'                   = (1, [int]::MaxValue);
    }
    # Get type list
    $JCTypes = Get-JCType | Where-Object { $_.Category -eq 'JumpCloud' };
    # Add properties to the parameters based upon the setup of the org for performance considerations
    If (!($Type))
    {
        $Param_Id.Add('Mandatory', $true)
        $Param_Id.Add('Alias', ($JCTypes.ById | Where-Object { $_ -ne 'Id' } | Select-Object -Unique))
        $Param_Name.Add('Mandatory', $true)
        $Param_Name.Add('Alias', ($JCTypes.ByName | Where-Object { $_ -ne 'Name' } | Select-Object -Unique))
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
            # Populate default values
            $Param_Limit.Add('DefaultValue', $JCTypes.Limit)
            $Param_Skip.Add('DefaultValue', $JCTypes.Skip)
        }
        If ($JCObjectCount -ge 1 -and $JCObjectCount -le 300)
        {
            # Get all objects of the specific type
            $JCObject = Get-JCObject -Type:($Type);
            $Param_Id.Add('Alias', ($JCObject.ById | Where-Object { $_ -ne 'Id' } | Select-Object -Unique))
            $Param_Name.Add('Alias', ($JCObject.ByName | Where-Object { $_ -ne 'Name' } | Select-Object -Unique))
            If ($JCObjectCount -eq 1)
            {
                # Don't require Id and Name to be passed through and set a default value
                $Param_Id.Add('Mandatory', $false)
                $Param_Id.Add('DefaultValue', $JCObject.($JCObject.ById))
                $Param_Name.Add('Mandatory', $false)
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
            $Param_Id.Add('Alias', ($JCTypes.ById | Where-Object { $_ -ne 'Id' } | Select-Object -Unique))
            $Param_Name.Add('Mandatory', $true)
            $Param_Name.Add('Alias', ($JCTypes.ByName | Where-Object { $_ -ne 'Name' } | Select-Object -Unique))
        }
    }
    # Add RuntimeDictionary to each parameter
    $ParamVarPrefix = 'Param_'
    Get-Variable | Where-Object {$_.Name -like '*' + $ParamVarPrefix + '*'} | ForEach-Object {
        $_.Value.Add('RuntimeParameterDictionary', $RuntimeParameterDictionary)
        $VarName = $_.Name
        $VarValue = $_.Value
        Try
        {
            New-DynamicParameter @VarValue | Out-Null
        }
        Catch
        {
            Write-Error -Message:('Unable to create dynamic parameter:"' + $VarName.Replace($ParamVarPrefix, '') + '"; Error:' + $Error)
        }
    }
    Return $RuntimeParameterDictionary
}