Function Get-DynamicParamAssociation
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][string]$Action
        , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 1)][string]$Type
    )
    # Build parameter array
    $Params = @()
    # Get type list
    $JCTypes = Get-JCType | Where-Object { $_.Category -eq 'JumpCloud' };
    If ($Action -and $Type)
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
        # Define the new parameters
        If ($JCObjectCount -ge 1 -and $JCObjectCount -le 300)
        {
            $JCObject = Get-JCObject -Type:($Type);
            If ($JCObjectCount -eq 1)
            {
                # Don't require Id and Name to be passed through and set a default value
                $Params += @{
                    'Name'                            = 'Id';
                    'Type'                            = [System.String[]];
                    'Position'                        = 2;
                    'ValueFromPipelineByPropertyName' = $true;
                    'Mandatory'                       = $false;
                    'ValidateNotNullOrEmpty'          = $true;
                    'Alias'                           = @(($JCObject.ById).Where( { $_ -ne 'Id' }) | Select-Object -Unique);
                    'ParameterSets'                   = @('ById');
                    'DefaultValue'                    = $JCObject.($JCObject.ById);
                    'HelpMessage'                     = 'The unique id of the object.'
                }
                $Params += @{
                    'Name'                            = 'Name';
                    'Type'                            = [System.String[]];
                    'Position'                        = 3;
                    'ValueFromPipelineByPropertyName' = $true;
                    'Mandatory'                       = $false;
                    'ValidateNotNullOrEmpty'          = $true;
                    'Alias'                           = @(($JCObject.ByName).Where( { $_ -ne 'Name' }) | Select-Object -Unique);
                    'ParameterSets'                   = @('ByName');
                    'DefaultValue'                    = $JCObject.($JCObject.ByName);
                    'HelpMessage'                     = 'The name of the object.'
                }
            }
            Else
            {
                # Do populate validate set with list of items
                $Params += @{
                    'Name'                            = 'Id';
                    'Type'                            = [System.String[]];
                    'Position'                        = 2;
                    'ValueFromPipelineByPropertyName' = $true;
                    'Mandatory'                       = $true;
                    'ValidateNotNullOrEmpty'          = $true;
                    'Alias'                           = @(($JCObject.ById).Where( { $_ -ne 'Id' }) | Select-Object -Unique);
                    'ValidateSet'                     = @($JCObject.($JCObject.ById | Select-Object -Unique));
                    'ParameterSets'                   = @('ById');
                    'HelpMessage'                     = 'The unique id of the object.'
                }
                $Params += @{
                    'Name'                            = 'Name';
                    'Type'                            = [System.String[]];
                    'Position'                        = 3;
                    'ValueFromPipelineByPropertyName' = $true;
                    'Mandatory'                       = $true;
                    'ValidateNotNullOrEmpty'          = $true;
                    'Alias'                           = @(($JCObject.ByName).Where( { $_ -ne 'Name' }) | Select-Object -Unique);
                    'ValidateSet'                     = @($JCObject.($JCObject.ByName | Select-Object -Unique));
                    'ParameterSets'                   = @('ByName');
                    'HelpMessage'                     = 'The name of the object.'
                }
            }
            If ($Action -eq 'get')
            {
                $Params += @{
                    'Name'                            = 'TargetType';
                    'Type'                            = [System.String[]];
                    'Position'                        = 4;
                    'ValueFromPipelineByPropertyName' = $true;
                    'Mandatory'                       = $false;
                    'ValidateNotNullOrEmpty'          = $true;
                    'Alias'                           = ('TargetSingular');
                    'ValidateSet'                     = (($JCObject.Targets.TargetSingular | Select-Object -Unique) + ($JCObject.TargetsExcluded.TargetExcludedSingular | Select-Object -Unique));
                    'DefaultValue'                    = (($JCObject.Targets.TargetSingular | Select-Object -Unique) + ($JCObject.TargetsExcluded.TargetExcludedSingular | Select-Object -Unique));
                    'HelpMessage'                     = 'The target object type.'
                }
            }
            Else
            {
                $Params += @{
                    'Name'                            = 'TargetType';
                    'Type'                            = [System.String[]];
                    'Position'                        = 4;
                    'ValueFromPipelineByPropertyName' = $true;
                    'Mandatory'                       = $false;
                    'ValidateNotNullOrEmpty'          = $true;
                    'Alias'                           = ('TargetSingular');
                    'ValidateSet'                     = ($JCObject.Targets.TargetSingular | Select-Object -Unique);
                    'DefaultValue'                    = ($JCObject.Targets.TargetSingular | Select-Object -Unique);
                    'HelpMessage'                     = 'The target object type.'
                }
            }
        }
        Else
        {
            # Don't populate validate set
            $Params += @{
                'Name'                            = 'Id';
                'Type'                            = [System.String[]];
                'Position'                        = 2;
                'ValueFromPipelineByPropertyName' = $true;
                'Mandatory'                       = $true;
                'ValidateNotNullOrEmpty'          = $true;
                'Alias'                           = @(($JCTypes.ById).Where( { $_ -ne 'Id' }) | Select-Object -Unique);
                'ParameterSets'                   = @('ById');
                'HelpMessage'                     = 'The unique id of the object.'
            }
            $Params += @{
                'Name'                            = 'Name';
                'Type'                            = [System.String[]];
                'Position'                        = 3;
                'ValueFromPipelineByPropertyName' = $true;
                'Mandatory'                       = $true;
                'ValidateNotNullOrEmpty'          = $true;
                'Alias'                           = @(($JCTypes.ByName).Where( { $_ -ne 'Name' }) | Select-Object -Unique);
                'ParameterSets'                   = @('ByName');
                'HelpMessage'                     = 'The name of the object.'
            }
            If ($Action -eq 'get')
            {
                $Params += @{
                    'Name'                            = 'TargetType';
                    'Type'                            = [System.String[]];
                    'Position'                        = 4;
                    'ValueFromPipelineByPropertyName' = $true;
                    'Mandatory'                       = $false;
                    'ValidateNotNullOrEmpty'          = $true;
                    'Alias'                           = ('TargetSingular');
                    'ValidateSet'                     = (($JCTypes.Targets.TargetSingular | Select-Object -Unique) + ($JCTypes.TargetsExcluded.TargetExcludedSingular | Select-Object -Unique));
                    'DefaultValue'                    = (($JCTypes.Targets.TargetSingular | Select-Object -Unique) + ($JCTypes.TargetsExcluded.TargetExcludedSingular | Select-Object -Unique));
                    'HelpMessage'                     = 'The target object type.'
                }
            }
            Else
            {
                $Params += @{
                    'Name'                            = 'TargetType';
                    'Type'                            = [System.String[]];
                    'Position'                        = 4;
                    'ValueFromPipelineByPropertyName' = $true;
                    'Mandatory'                       = $false;
                    'ValidateNotNullOrEmpty'          = $true;
                    'Alias'                           = ('TargetSingular');
                    'ValidateSet'                     = ($JCTypes.Targets.TargetSingular | Select-Object -Unique);
                    'DefaultValue'                    = ($JCTypes.Targets.TargetSingular | Select-Object -Unique);
                    'HelpMessage'                     = 'The target object type.'
                }
            }
        }
    }
    Else
    {
        $Params += @{
            'Name'                            = 'Id';
            'Type'                            = [System.String[]];
            'Position'                        = 2;
            'ValueFromPipelineByPropertyName' = $true;
            'Mandatory'                       = $true;
            'ValidateNotNullOrEmpty'          = $true;
            'Alias'                           = @(($JCTypes.ById).Where( { $_ -ne 'Id' }) | Select-Object -Unique);
            'ParameterSets'                   = @('ById');
            'HelpMessage'                     = 'The unique id of the object.'
        }
        $Params += @{
            'Name'                            = 'Name';
            'Type'                            = [System.String[]];
            'Position'                        = 3;
            'ValueFromPipelineByPropertyName' = $true;
            'Mandatory'                       = $true;
            'ValidateNotNullOrEmpty'          = $true;
            'Alias'                           = @(($JCTypes.ByName).Where( { $_ -ne 'Name' }) | Select-Object -Unique);
            'ParameterSets'                   = @('ByName');
            'HelpMessage'                     = 'The name of the object.'
        }
        If ($Action -eq 'get')
        {
            $Params += @{
                'Name'                            = 'TargetType';
                'Type'                            = [System.String[]];
                'Position'                        = 4;
                'ValueFromPipelineByPropertyName' = $true;
                'Mandatory'                       = $true;
                'ValidateNotNullOrEmpty'          = $true;
                'Alias'                           = ('TargetSingular');
                'ValidateSet'                     = (($JCTypes.Targets.TargetSingular | Select-Object -Unique) + ($JCTypes.TargetsExcluded.TargetExcludedSingular | Select-Object -Unique));
                'HelpMessage'                     = 'The target object type.'
            }
        }
        Else
        {
            $Params += @{
                'Name'                            = 'TargetType';
                'Type'                            = [System.String[]];
                'Position'                        = 4;
                'ValueFromPipelineByPropertyName' = $true;
                'Mandatory'                       = $true;
                'ValidateNotNullOrEmpty'          = $true;
                'Alias'                           = ('TargetSingular');
                'ValidateSet'                     = ($JCTypes.Targets.TargetSingular | Select-Object -Unique);
                'HelpMessage'                     = 'The target object type.'
            }
        }
    }
    If ($Action -eq 'get')
    {
        $Params += @{
            'Name'                            = 'Raw';
            'Type'                            = [Switch];
            'Position'                        = 5;
            'ValueFromPipelineByPropertyName' = $true;
            'DefaultValue'                    = $false;
            'DontShow'                        = $true;
            'HelpMessage'                     = 'Returns the raw and unedited output from the api endpoint.'
        }
        $Params += @{
            'Name'                            = 'Direct';
            'Type'                            = [Switch];
            'Position'                        = 5;
            'ValueFromPipelineByPropertyName' = $true;
            'DefaultValue'                    = $false;
            'HelpMessage'                     = 'Returns only "Direct" associations.'
        }
        $Params += @{
            'Name'                            = 'Indirect';
            'Type'                            = [Switch];
            'Position'                        = 6;
            'ValueFromPipelineByPropertyName' = $true;
            'DefaultValue'                    = $false;
            'HelpMessage'                     = 'Returns only "Indirect" associations.'
        }
        $Params += @{
            'Name'                            = 'IncludeInfo';
            'Type'                            = [Switch];
            'Position'                        = 7;
            'ValueFromPipelineByPropertyName' = $true;
            'ParameterSets'                   = @('ById', 'ByName');
            'DefaultValue'                    = $false;
            'HelpMessage'                     = 'Appends "Info" and "TargetInfo" properties to output.'
        }
        $Params += @{
            'Name'                            = 'IncludeNames';
            'Type'                            = [Switch];
            'Position'                        = 8;
            'ValueFromPipelineByPropertyName' = $true;
            'ParameterSets'                   = @('ById', 'ByName');
            'DefaultValue'                    = $false;
            'HelpMessage'                     = 'Appends "Name" and "TargetName" properties to output.'
        }
        $Params += @{
            'Name'                            = 'IncludeVisualPath';
            'Type'                            = [Switch];
            'Position'                        = 9;
            'ValueFromPipelineByPropertyName' = $true;
            'ParameterSets'                   = @('ById', 'ByName');
            'DefaultValue'                    = $false;
            'HelpMessage'                     = 'Appends "visualPathById", "visualPathByName", and "visualPathByType" properties to output.'
        }
    }
    If ($Action -in ('add', 'remove'))
    {
        $Params += @{
            'Name'                            = 'TargetId';
            'Type'                            = [System.String];
            'Position'                        = 5;
            'ValueFromPipelineByPropertyName' = $true;
            'HelpMessage'                     = 'The unique id of the target object.'
        }
        $Params += @{
            'Name'                            = 'TargetName';
            'Type'                            = [System.String];
            'Position'                        = 6;
            'ValueFromPipelineByPropertyName' = $true;
            'HelpMessage'                     = 'The name of the target object.'
        }
        $Params += @{
            'Name'                            = 'Force';
            'Type'                            = [Switch];
            'Position'                        = 8;
            'ValueFromPipelineByPropertyName' = $true;
            'DefaultValue'                    = $false;
            'HelpMessage'                     = 'Bypass user confirmation when adding or removing associations.'
        }
    }
    If ($Action -eq 'add')
    {
        $Params += @{
            'Name'                            = 'Attributes';
            'Type'                            = [System.Management.Automation.PSObject];
            'Position'                        = 7;
            'ValueFromPipelineByPropertyName' = $true;
            'Alias'                           = 'compiledAttributes';
            'HelpMessage'                     = 'Add attributes that define the association such as if they are an admin.'
        }
    }
    # Create new parameters
    $RuntimeParameterDictionary = $Params |
        ForEach-Object { New-Object PSObject -Property:($_) } |
        New-DynamicParameter
    # Return parameters
    Return $RuntimeParameterDictionary
}