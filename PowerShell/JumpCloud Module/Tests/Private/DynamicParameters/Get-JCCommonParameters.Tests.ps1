Describe -Tag:('JCCommonParameters') 'Test-JCCommonParameters tests' {
    # Function to mimic how Get-JCCommonParameters is called and used.
    Function Test-JCCommonParameters
    {
        [CmdletBinding()]
        Param($Action, $Type)
        DynamicParam
        {
            $RuntimeParameterDictionary = Get-JCCommonParameters -Action:($Action) -Type:($Type);
            Return $RuntimeParameterDictionary
        }
        Begin
        {
        }
        Process
        {
            # For DynamicParam with a default value set that value and then convert the DynamicParam inputs into new variables for the script to use
            Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDynamicParamProcess) -ArgumentList:($PsBoundParameters, $PSCmdlet, $RuntimeParameterDictionary) -NoNewScope
            Try
            {
                # Create hash table to store variables
                $FunctionParameters = [ordered]@{ }
                # Add input parameters from function in to hash table and filter out unnecessary parameters
                $PSBoundParameters.GetEnumerator() | Where-Object { -not [System.String]::IsNullOrEmpty($_.Value) } | ForEach-Object { $FunctionParameters.Add($_.Key, $_.Value) | Out-Null }
                # Run the command
                $Results += $FunctionParameters
            }
            Catch
            {
                Write-Error ($_)
            }
        }
        End
        {
            Return $Results
        }
    }
    # Tests
    $Actions = ('get') #, 'add', 'new', 'remove', 'set') # ToDo: Not sure how to add other actions to test yet.
    $JCTypes = Get-JCType | Where-Object { $_.Category -eq 'JumpCloud' }
    ForEach ($Action In $Actions)
    {
        ForEach ($JCType In $JCTypes)
        {
            $Parameters = Test-JCCommonParameters -Action:($Action) -Type:($JCType.TypeName.TypeNameSingular)
            $ParamValidation = switch ($Action)
            {
                'get'
                {
                    [ordered]@{
                        Action   = $Action
                        Type     = $JCType.TypeName.TypeNameSingular
                        Limit    = $JCType.Limit
                        Skip     = $JCType.Skip
                        Paginate = $JCType.Paginate
                    }
                }
                Default { Write-Error 'Unknown $Action type: ' + $Action }
            }
            $ParamValidation.GetEnumerator() | ForEach-Object {
                It ('JCCommonParameters with action of "' + $Action + '" and type of "' + $JCType.TypeName.TypeNameSingular + '" should return a parameter called "' + $_.Key + '" with a value of "' + $_.Value + '".') {
                    $Parameters.($_.Key) | Should -Be $ParamValidation.($_.Key)
                }
            }
        }
    }
}