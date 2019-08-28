<#
.DESCRIPTION
This script block should be called within the Process block of all scripts that use the New-DynamicParameter function.
It will apply the "DefaultValue" parameter to the dynamic parameter.
It will create variables that can be used within the script from the dynamic parameters.
.EXAMPLE
& $ScriptBlock_DefaultDynamicParamProcess -ScriptPsBoundParameters:($PsBoundParameters) -ScriptPSCmdlet:($PSCmdlet) -DynamicParams:($RuntimeParameterDictionary)
.EXAMPLE
Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDynamicParamProcess) -ArgumentList:($PsBoundParameters,$PSCmdlet,$RuntimeParameterDictionary) -NoNewScope
#>
$ScriptBlock_DefaultDynamicParamProcess = {
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]$ScriptPsBoundParameters
        , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()]$ScriptPSCmdlet
        , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 2)][ValidateNotNullOrEmpty()]$DynamicParams
    )
    # For DynamicParam with a default value set that value
    $DynamicParams.Values |
        Where-Object { $_.IsSet -and $_.Attributes.ParameterSetName -in ($ScriptPSCmdlet.ParameterSetName, '__AllParameterSets') } |
        ForEach-Object {
        If (-not ([System.String]::IsNullOrEmpty($_.Value)))
        {
            $ScriptPsBoundParameters[$_.Name] = $_.Value
        }
    }
    # Convert the DynamicParam inputs into new variables for the script to use
    $ScriptPsBoundParameters.GetEnumerator() |
        ForEach-Object {
        If (-not ([System.String]::IsNullOrEmpty($_.Value)))
        {
            Set-Variable -Name:($_.Key) -Value:($_.Value) -Force
        }
    }
}
