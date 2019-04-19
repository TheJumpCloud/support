Function Get-JCObjectType
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
        Write-Debug ('[CallFunction]' + $MyInvocation.MyCommand.Name + ' ' + ($PsBoundParameters.GetEnumerator() | Sort-Object Key | ForEach-Object { ('-' + $_.Key + ":('" + ($_.Value -join "','") + "')").Replace("'True'", '$True').Replace("'False'", '$False') }) )
        If ($PSCmdlet.ParameterSetName -ne '__AllParameterSets') { Write-Verbose ('[ParameterSet]' + $MyInvocation.MyCommand.Name + ':' + $PSCmdlet.ParameterSetName) }
    }
    Process
    {
        # For parameters with a default value set that value
        $NewParams.Values | Where-Object { $_.IsSet -and $_.Attributes.ParameterSetName -eq $PSCmdlet.ParameterSetName } | ForEach-Object { $PSBoundParameters[$_.Name] = $_.Value }
        # Create new variables for script
        $PsBoundParameters.GetEnumerator() | ForEach-Object { Set-Variable -Name:($_.Key) -Value:($_.Value) -Force }
        $JCTypeOutput = Switch ($PSCmdlet.ParameterSetName)
        {
            'ByName' { $JCTypes | Where-Object { $Type -in $_.Types } }
            Default { $JCTypes }
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