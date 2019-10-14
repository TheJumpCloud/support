Function New-JCObject
{
    [CmdletBinding()]
    param (
        [Parameter()][System.String]$Module = 'JumpCloudApiSdkV*'
        , [Parameter()][Switch]$AutoPopulate
    )
    DynamicParam
    {
        $ModuleCommands = Get-Command -Module:($Module)
        $Param_CommandVerb = @{
            'Name'                            = 'CommandVerb';
            'Type'                            = [System.String[]];
            'Mandatory'                       = $true;
            'ValueFromPipelineByPropertyName' = $true;
            'ValidateSet'                     = $ModuleCommands.Verb | Select-Object -Unique;
            'HelpMessage'                     = 'The verb of the cmdlet.';
            'Position'                        = 2;
        }
        $Param_CommandNoun = @{
            'Name'                            = 'CommandNoun';
            'Type'                            = [System.String[]];
            'Mandatory'                       = $true;
            'ValueFromPipelineByPropertyName' = $true;
            'ValidateSet'                     = $ModuleCommands.Noun | Select-Object -Unique;
            'HelpMessage'                     = 'The Noun of the cmdlet.';
            'Position'                        = 3;
        }
        $RuntimeParameterDictionary = (New-Object -TypeName:([System.Management.Automation.RuntimeDefinedParameterDictionary]))
        # Build output
        $ParamVarPrefix = 'Param_'
        Get-Variable -Scope:('Local') | Where-Object { $_.Name -like '*' + $ParamVarPrefix + '*' } | Sort-Object { [int]$_.Value.Position } | ForEach-Object {
            # Add RuntimeDictionary to each parameter
            $_.Value.Add('RuntimeParameterDictionary', $RuntimeParameterDictionary)
            # Creating each parameter
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
    Begin
    {
    }
    Process
    {
        Function Build-JCObjectTemplate
        {
            [CmdletBinding()]
            param (
                [Parameter()][System.String]$ModelName
                , [Parameter()][Switch]$AutoPopulate
            )
            $ModelCreateTemplate = '[{0}]::New()'
            $NewObjectCommand = $ModelCreateTemplate -f $ModelName
            If ($ModelName -like '*Models.I*')
            {
                $NewObjectCommand = $NewObjectCommand.Replace('Models.I', 'Models.')
            }
            If ($NewObjectCommand -like "*`[`]`]*")
            {
                $NewObjectCommand = $NewObjectCommand.Replace('[]]', ']')
            }
            $NewObject = Invoke-Expression -Command:($NewObjectCommand)
            ForEach ($Property In $NewObject.PSObject.Properties | Sort-Object TypeNameOfValue)
            {
                If ($Property.TypeNameOfValue -like '*.Models.*' )
                {
                    $NewPropertyObject = If (-not $AutoPopulate)
                    {
                        Build-JCObjectTemplate -ModelName:($Property.TypeNameOfValue)
                    }
                    Else
                    {
                        Build-JCObjectTemplate -ModelName:($Property.TypeNameOfValue) -AutoPopulate
                    }
                    $NewObject.($Property.Name) = $NewPropertyObject
                }
                Else
                {
                    If (-not $AutoPopulate)
                    {
                        $NewObject.($Property.Name) = $null
                    }
                    Else
                    {
                        If ($Property.Name -eq 'email')
                        {
                            $NewObject.($Property.Name) = 'Test_' + $Property.Name + '@test.com'
                        }
                        ElseIf ($Property.TypeNameOfValue -eq 'System.String')
                        {
                            $NewObject.($Property.Name) = 'Test_' + $Property.Name
                        }
                        ElseIf ($Property.TypeNameOfValue -eq 'System.String[]')
                        {
                            $ArrayLength = 3
                            $ArrayLengthCounter = 0
                            $Array = While ($ArrayLengthCounter -le $ArrayLength)
                            {
                                $ArrayLengthCounter ++
                                'Test_' + $Property.Name + '_' + [System.String]$ArrayLengthCount
                            }
                            $NewObject.($Property.Name) = $Array
                        }
                        ElseIf ($Property.TypeNameOfValue -like '*System.Boolean*')
                        {
                            $NewObject.($Property.Name) = $true
                        }
                        ElseIf ($Property.TypeNameOfValue -like '*System.DateTime*')
                        {
                            $NewObject.($Property.Name) = Get-Date
                        }
                        ElseIf ($Property.TypeNameOfValue -like '*System.Int32*')
                        {
                            $NewObject.($Property.Name) = 111
                        }
                        Else
                        {
                            # $Property | Select-Object Name, TypeNameOfValue
                            Write-Error ('Unknown dataType: ' + $Property.TypeNameOfValue )
                        }
                    }
                }
            }
            Return $NewObject
        }
        # For DynamicParam with a default value set that value and then convert the DynamicParam inputs into new variables for the script to use
        Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDynamicParamProcess) -ArgumentList:($PsBoundParameters, $PSCmdlet, $RuntimeParameterDictionary) -NoNewScope
        $Commands = Get-Command -Verb:($CommandVerb) -Noun:($CommandNoun)
        ForEach ($Command In $Commands)
        {
            # Get commands that match the parameters
            $ModelName = (($Command.ParameterSets | Where-Object { $_.Name -in ('Create', 'Put') } ).Parameters | Where-Object { $_.ParameterType -like '*.Models.*' }).ParameterType.FullName
            If (-not [System.String]::IsNullOrEmpty($ModelName))
            {
                If (-not $AutoPopulate)
                {
                    Return Build-JCObjectTemplate -ModelName:($ModelName)
                }
                Else
                {
                    Return Build-JCObjectTemplate -ModelName:($ModelName) -AutoPopulate
                }
            }
            Else
            {
                Write-Error ('The command "' + $Command.Name + '" has no parameters.')
            }
        }
    }
    End
    {
    }
}