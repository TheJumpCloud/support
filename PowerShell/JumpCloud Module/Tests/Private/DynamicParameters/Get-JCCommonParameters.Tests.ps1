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
    Function Get-JCCommonParametersTestCases
    {
        # Tests
        # 'add', 'new' = 'Param_Name'
        # 'remove' = 'Param_Id'
        # 'set' = 'Param_Id', 'Param_Name', 'Param_SearchBy', 'Param_SearchByValue'
        # 'get' = 'Param_Id', 'Param_Name', 'Param_SearchBy', 'Param_SearchByValue', 'Param_Fields', 'Param_Filter', 'Param_Limit', 'Param_Skip', 'Param_Paginate'
        # 'copy' = 'Param_Id', 'Param_Name'
        $ParameterResults = @()
        $Actions = ('get', 'add', 'new', 'remove', 'copy', 'set') # ToDo: Not sure how to add other actions to test yet.
        $JCTypes = Get-JCType | Where-Object { $_.Category -eq 'JumpCloud' }
        ForEach ($Action In $Actions)
        {
            ForEach ($JCType In $JCTypes)
            {
                switch ($Action)
                {
                    'get'
                    {
                        $ParamValidation = [ordered]@{
                            Action   = $Action
                            Type     = $JCType.TypeName.TypeNameSingular
                            Limit    = $JCType.Limit
                            Skip     = $JCType.Skip
                            Paginate = $JCType.Paginate
                        }
                        $Parameters = Test-JCCommonParameters -Action:($Action) -Type:($JCType.TypeName.TypeNameSingular)
                    }
                    'add'
                    {
                        $ParamValidation = [ordered]@{
                            Action = $Action
                            Type   = $JCType.TypeName.TypeNameSingular
                            Name   = 'TestName'
                        }
                        $Parameters = Test-JCCommonParameters -Action:($Action) -Type:($JCType.TypeName.TypeNameSingular) -Name:($ParamValidation.Name)
                    }
                    'new'
                    {
                        $ParamValidation = [ordered]@{
                            Action = $Action
                            Type   = $JCType.TypeName.TypeNameSingular
                            Name   = 'TestName'
                        }
                        $Parameters = Test-JCCommonParameters -Action:($Action) -Type:($JCType.TypeName.TypeNameSingular) -Name:($ParamValidation.Name)
                    }
                    'remove'
                    {
                        $ParamValidation = [ordered]@{
                            Action = $Action
                            Type   = $JCType.TypeName.TypeNameSingular
                            Id     = '1234'
                        }
                        $Parameters = Test-JCCommonParameters -Action:($Action) -Type:($JCType.TypeName.TypeNameSingular) -Id:($ParamValidation.Id)
                    }
                    'copy'
                    {
                        $ParamValidation = [ordered]@{
                            Action = $Action
                            Type   = $JCType.TypeName.TypeNameSingular
                            Id     = '1234'
                            # Name   = 'TestName'
                        }
                        $Parameters = Test-JCCommonParameters -Action:($Action) -Type:($JCType.TypeName.TypeNameSingular) -Id:($ParamValidation.Id)
                        # $Parameters = Test-JCCommonParameters -Action:($Action) -Type:($JCType.TypeName.TypeNameSingular) -Name:($ParamValidation.Name)
                    }
                    'set'
                    {
                        $ParamValidation = [ordered]@{
                            Action = $Action
                            Type   = $JCType.TypeName.TypeNameSingular
                            Id     = '1234'
                            # Name   = 'TestName'
                        }
                        $Parameters = Test-JCCommonParameters -Action:($Action) -Type:($JCType.TypeName.TypeNameSingular) -Id:($ParamValidation.Id)
                        # $Parameters = Test-JCCommonParameters -Action:($Action) -Type:($JCType.TypeName.TypeNameSingular) -Name:($ParamValidation.Name)
                    }
                    Default { Write-Error ('Unknown $Action type: ' + $Action) }
                }
                $ParameterResults += @{
                    testDescription = 'JCCommonParameters with action of "' + $Action + '" and type of "' + $JCType.TypeName.TypeNameSingular + '" should return a parameter called "' + $_.Key + '" with a value of "' + $_.Value + '".';
                    ParamValidation = $ParamValidation;
                    Parameters      = $Parameters;
                }
            }
        }
        Return $ParameterResults
    }
    It('<testDescription>') -TestCases:(Get-JCCommonParametersTestCases) {
        $Parameters.($_.Key) | Should -Be $ParamValidation.($_.Key)
    }
}
