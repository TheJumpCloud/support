Function Get-DynamicParamAssociation
{
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
                    'Alias'                           = ($JCTypes.ById).Where( { $_ -ne 'Id' }) | Select-Object -Unique;
                    'ParameterSets'                   = @('ById:Show');
                    'DefaultValue'                    = $JCObject.($JCObject.ById)
                }
                $Params += @{
                    'Name'                            = 'Name';
                    'Type'                            = [System.String[]];
                    'Position'                        = 3;
                    'ValueFromPipelineByPropertyName' = $true;
                    'Mandatory'                       = $false;
                    'ValidateNotNullOrEmpty'          = $true;
                    'Alias'                           = ($JCTypes.ByName).Where( { $_ -ne 'Name' }) | Select-Object -Unique;
                    'ParameterSets'                   = @('ByName:Show');
                    'DefaultValue'                    = $JCObject.($JCObject.ByName)
                }
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
                    'Alias'                           = ($JCTypes.ById).Where( { $_ -ne 'Id' }) | Select-Object -Unique;
                    'ValidateSet'                     = @($JCObject.($JCObject.ById | Select-Object -Unique));
                    'ParameterSets'                   = @('ById:Show');
                }
                $Params += @{
                    'Name'                            = 'Name';
                    'Type'                            = [System.String[]];
                    'Position'                        = 3;
                    'ValueFromPipelineByPropertyName' = $true;
                    'Mandatory'                       = $true;
                    'ValidateNotNullOrEmpty'          = $true;
                    'Alias'                           = ($JCTypes.ByName).Where( { $_ -ne 'Name' }) | Select-Object -Unique;
                    'ValidateSet'                     = @($JCObject.($JCObject.ByName | Select-Object -Unique));
                    'ParameterSets'                   = @('ByName:Show');
                }
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
                'Alias'                           = ($JCTypes.ById).Where( { $_ -ne 'Id' }) | Select-Object -Unique;
                'ParameterSets'                   = @('ById:Show');
            }
            $Params += @{
                'Name'                            = 'Name';
                'Type'                            = [System.String[]];
                'Position'                        = 3;
                'ValueFromPipelineByPropertyName' = $true;
                'Mandatory'                       = $true;
                'ValidateNotNullOrEmpty'          = $true;
                'Alias'                           = ($JCTypes.ByName).Where( { $_ -ne 'Name' }) | Select-Object -Unique;
                'ParameterSets'                   = @('ByName:Show');
            }
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
            'Alias'                           = ($JCTypes.ById).Where( { $_ -ne 'Id' }) | Select-Object -Unique;
            'ParameterSets'                   = @('ById:Show');
        }
        $Params += @{
            'Name'                            = 'Name';
            'Type'                            = [System.String[]];
            'Position'                        = 3;
            'ValueFromPipelineByPropertyName' = $true;
            'Mandatory'                       = $true;
            'ValidateNotNullOrEmpty'          = $true;
            'Alias'                           = ($JCTypes.ByName).Where( { $_ -ne 'Name' }) | Select-Object -Unique;
            'ParameterSets'                   = @('ByName:Show');
        }
        $Params += @{
            'Name'                            = 'TargetType';
            'Type'                            = [System.String[]];
            'Position'                        = 4;
            'ValueFromPipelineByPropertyName' = $true;
            'Mandatory'                       = $true;
            'ValidateNotNullOrEmpty'          = $true;
            'Alias'                           = ('TargetSingular');
            'ValidateSet'                     = ($JCTypes.Targets.TargetSingular | Select-Object -Unique);
        }
    }
    If ($Action -eq 'get')
    {
        $Params += @{
            'Name'                            = 'Raw';
            'Type'                            = [Switch];
            'Position'                        = 5;
            'ValueFromPipelineByPropertyName' = $true;
            'ParameterSets'                   = @('ById:Show', 'ByName:Show');
            'DefaultValue'                    = $false;
            'DontShow'                        = $true;
        }
        $Params += @{
            'Name'                            = 'ShowInfo';
            'Type'                            = [Switch];
            'Position'                        = 5;
            'ValueFromPipelineByPropertyName' = $true;
            'ParameterSets'                   = @('ById:Show', 'ByName:Show');
            'DefaultValue'                    = $false;
        }
        $Params += @{
            'Name'                            = 'ShowNames';
            'Type'                            = [Switch];
            'Position'                        = 6;
            'ValueFromPipelineByPropertyName' = $true;
            'ParameterSets'                   = @('ById:Show', 'ByName:Show');
            'DefaultValue'                    = $false;
        }
        $Params += @{
            'Name'                            = 'ShowVisualPath';
            'Type'                            = [Switch];
            'Position'                        = 7;
            'ValueFromPipelineByPropertyName' = $true;
            'ParameterSets'                   = @('ById:Show', 'ByName:Show');
            'DefaultValue'                    = $false;
        }
        $Params += @{
            'Name'                            = 'ShowDirect';
            'Type'                            = [Switch];
            'Position'                        = 8;
            'ValueFromPipelineByPropertyName' = $true;
            'DefaultValue'                    = $false;
        }
        $Params += @{
            'Name'                            = 'ShowIndirect';
            'Type'                            = [Switch];
            'Position'                        = 8;
            'ValueFromPipelineByPropertyName' = $true;
            'DefaultValue'                    = $false;
        }
    }
    If ($Action -in ('add', 'remove'))
    {
        $Params += @{
            'Name'                            = 'TargetId';
            'Type'                            = [System.String];
            'Position'                        = 5;
            'ValueFromPipelineByPropertyName' = $true;
            'Mandatory'                       = $true;
            'ValidateNotNullOrEmpty'          = $true;
            'ParameterSets'                   = @('ById:Show');
        }
        $Params += @{
            'Name'                            = 'TargetName';
            'Type'                            = [System.String];
            'Position'                        = 6;
            'ValueFromPipelineByPropertyName' = $true;
            'Mandatory'                       = $true;
            'ValidateNotNullOrEmpty'          = $true;
            'ParameterSets'                   = @('ByName:Show');
        }
        $Params += @{
            'Name'                            = 'Force';
            'Type'                            = [Switch];
            'Position'                        = 8;
            'ValueFromPipelineByPropertyName' = $true;
            'DefaultValue'                    = $false;
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
        }
    }
    # Create new parameters
    $RuntimeParameterDictionary = $Params |
        ForEach-Object { New-Object PSObject -Property:($_) } |
        New-DynamicParameter
    # Return parameters
    Return $RuntimeParameterDictionary
}