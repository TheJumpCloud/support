Function Get-JCSystemInsights
{
    [CmdletBinding()]
    Param()
    DynamicParam
    {
        $Type = 'system'
        $Action = 'get'
        $JCTypes = Get-JCType | Where-Object { $_.TypeName.TypeNameSingular -eq $Type };
        $RuntimeParameterDictionary = New-DynamicParameter -Name:('Table') -Type:([System.String]) -Mandatory -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -ParameterSets:('Default', 'ById', 'ByName', 'ByValue') -HelpMessage:('The SystemInsights table to query against.') -ValidateSet:($JCTypes.SystemInsights.Table);
        Get-JCCommonParameters  -Action:($Action) -Type:($Type) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null;
        Return $RuntimeParameterDictionary
    }
    Begin
    {
        Connect-JCOnline -force | Out-Null
        # Debug message for parameter call
        $PSBoundParameters | Out-DebugParameter | Write-Debug
        $Results = @()
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
            $PSBoundParameters.GetEnumerator() | Where-Object { $_.Value } | ForEach-Object { $FunctionParameters.Add($_.Key, $_.Value) | Out-Null }
            $FunctionParameters.Add('Type', $JCTypes.TypeName.TypeNameSingular) | Out-Null
            # Run the command
            $Results += Get-JCObject @FunctionParameters
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
