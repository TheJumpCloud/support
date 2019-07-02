Function Get-JCSystemInsights
{
    [CmdletBinding()]
    Param()
    DynamicParam
    {
        $Type = 'system'
        $JCTypes = Get-JCType | Where-Object { $_.TypeName.TypeNameSingular -eq $Type };
        $RuntimeParameterDictionary = New-DynamicParameter -Name:('Table') -Type:([System.String]) -Mandatory -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -ParameterSets:('Default', 'ById', 'ByName', 'ByValue') -HelpMessage:('The SystemInsights table to query against.') -ValidateSet:($JCTypes.SystemInsights.Table)
        Get-JCCommonParameters -Type:($Type) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        Return $RuntimeParameterDictionary
    }
    Begin
    {
        # Debug message for parameter call
        Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDebugMessageBegin) -ArgumentList:($MyInvocation, $PsBoundParameters, $PSCmdlet) -NoNewScope
        $Results = @()
    }
    Process
    {
        # For DynamicParam with a default value set that value and then convert the DynamicParam inputs into new variables for the script to use
        Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDynamicParamProcess) -ArgumentList:($PsBoundParameters, $PSCmdlet, $RuntimeParameterDictionary) -NoNewScope
        If ($JCSettings.SETTINGS.betaFeatures.systemInsights)
        {
            # Create hash table to store variables
            $FunctionParameters = [ordered]@{}
            # Add input parameters from function in to hash table and filter out unnecessary parameters
            $PSBoundParameters.GetEnumerator() | Where-Object {$_.Value} | ForEach-Object {$FunctionParameters.Add($_.Key, $_.Value) | Out-Null}
            $FunctionParameters.Add('Type', $JCTypes.TypeName.TypeNameSingular) | Out-Null
            # Run the command
            $Results += Get-JCObject @FunctionParameters
        }
        Else
        {
            Write-Error ('SystemInsights is not enabled for your org. Please email JumpCloud at "accounts@jumpcloud.com" to enable the SystemInsights feature.')
        }
    }
    End
    {
        Return $Results
    }
}
