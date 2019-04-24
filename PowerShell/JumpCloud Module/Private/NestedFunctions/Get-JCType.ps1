Function Get-JCType
{
    [CmdletBinding()]
    Param()
    DynamicParam
    {
        $JCTypeContent = Get-Content -Raw -Path:($PSScriptRoot + '/JCTypes.json')
        $JCTypes = ($JCTypeContent | ConvertFrom-Json) | Select-Object *, @{Name = 'Types'; Expression = { @($_.TypeName.TypeNameSingular, $_.TypeName.TypeNamePlural) } }
        # Build parameter array
        $RuntimeParameterDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
        New-DynamicParameter -Name:('Type') -Type:([System.String]) -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -ParameterSets:('ByName') -ValidateSet:($JCTypes.Types) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        Return $RuntimeParameterDictionary
    }
    Begin
    {
        # Debug message for parameter call
        & $ScriptBlock_DefaultDebugMessageBegin -ScriptMyInvocation:($MyInvocation) -ScriptPsBoundParameters:($PsBoundParameters) -ScriptPSCmdlet:($PSCmdlet)
    }
    Process
    {
        # For DynamicParam with a default value set that value and then convert the DynamicParam inputs into new variables for the script to use
        & $ScriptBlock_DefaultDynamicParamProcess -ScriptPsBoundParameters:($PsBoundParameters) -ScriptPSCmdlet:($PSCmdlet) -DynamicParams:($RuntimeParameterDictionary)
        Try
        {
            $JCTypeOutput = Switch ($PSCmdlet.ParameterSetName)
            {
                'ByName' { $JCTypes | Where-Object { $Type -in $_.Types } }
                Default { $JCTypes }
            }
        }
        Catch
        {
            Invoke-Command -ScriptBlock:($ScriptBlock_TryCatchError) -ArgumentList:($_)
        }
    }
    End
    {
        If ($JCTypeOutput)
        {
            Return $JCTypeOutput
        }
        Else
        {
            Write-Error ('The type "' + $Type + '" does not exist. Available types are (' + ($JCTypes.Types -join ', ') + ')')
        }
    }
}