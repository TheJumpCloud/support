<#
.EXAMPLE
& $ScriptBlock_DefaultDynamicParamProcess -ScriptPsBoundParameters:($PsBoundParameters) -ScriptPSCmdlet:($PSCmdlet) -DynamicParams:($RuntimeParameterDictionary)
.EXAMPLE
Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDynamicParamProcess) -ArgumentList:($PsBoundParameters,$PSCmdlet,$RuntimeParameterDictionary) -NoNewScope
#>
$ScriptBlock_DefaultDynamicParamProcess = {
    Param(
        $ScriptPsBoundParameters
        , $ScriptPSCmdlet
        , $DynamicParams
    )
    # For DynamicParam with a default value set that value
    $DynamicParams.Values |
        Where-Object { $_.IsSet -and $_.Attributes.ParameterSetName -in ($ScriptPSCmdlet.ParameterSetName, '__AllParameterSets') } |
        ForEach-Object { $ScriptPsBoundParameters[$_.Name] = $_.Value }
    # Convert the DynamicParam inputs into new variables for the script to use
    $ScriptPsBoundParameters.GetEnumerator() |
        ForEach-Object {Set-Variable -Name:($_.Key) -Value:($_.Value) -Force}
}
