Function Get-JCSystemInsights
{
    [CmdletBinding()]
    Param()
    DynamicParam
    {
        $JCType = Get-JCType | Where-Object { $_.TypeName.TypeNameSingular -eq 'system' };
        # Build parameter array
        $RuntimeParameterDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
        New-DynamicParameter -Name:('Table') -Type:([System.String]) -Position:(0) -Mandatory -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -HelpMessage:('The SystemInsights table to query against.') -ValidateSet:($JCType.SystemInsights.tables) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('Id') -Type:([System.String]) -Position:(1) -Mandatory -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -ParameterSets:('ById') -HelpMessage:('Filter by the Id of the system') -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('Name') -Type:([System.String]) -Position:(2) -Mandatory -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -ParameterSets:('ByName') -HelpMessage:('Filter by the Name of the system.') -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
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
            $FunctionParameters.Add('Type', $JCType.TypeName.TypeNameSingular) | Out-Null
            $FunctionParameters.Remove('Table') | Out-Null
            $FunctionParameters.Add('SystemInsights', $Table) | Out-Null
            # Run the command
            $Results += Get-JCObject @FunctionParameters
        }
        Else
        {
            Write-Error ('SystemInsights is not enabled for your org. Please email JumpCloud at {InsertEmailHere} to enable the SystemInsights feature.')
        }
    }
    End
    {
        Return $Results
    }
}
