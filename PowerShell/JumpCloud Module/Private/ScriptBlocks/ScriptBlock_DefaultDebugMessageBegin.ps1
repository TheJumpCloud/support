<#
.EXAMPLE
& $ScriptBlock_DefaultDebugMessageBegin -ScriptMyInvocation:($MyInvocation) -ScriptPsBoundParameters:($PsBoundParameters) -ScriptPSCmdlet:($PSCmdlet)
.EXAMPLE
Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDebugMessageBegin) -ArgumentList:($MyInvocation,$PsBoundParameters,$PSCmdlet)
.EXAMPLE
& $ScriptBlock_DefaultDebugMessageBegin -ScriptMyInvocation:($MyInvocation) -ScriptPsBoundParameters:($PsBoundParameters) -ScriptPSCmdlet:($PSCmdlet) -ShowInConsole:($true) -BackgroundColor:('Green') -ForegroundColor:('Black')
#>
$ScriptBlock_DefaultDebugMessageBegin = {
    Param(
        $ScriptMyInvocation
        , $ScriptPsBoundParameters
        , $ScriptPSCmdlet
        , [bool]$ShowInConsole = $false
        , [ValidateSet('Black', 'DarkBlue', 'DarkGreen', 'DarkCyan', 'DarkRed', 'DarkMagenta', 'DarkYellow', 'Gray', 'DarkGray', 'Blue', 'Green', 'Cyan', 'Red', 'Magenta', 'Yellow', 'White')]$BackgroundColor = 'Cyan'
        , [ValidateSet('Black', 'DarkBlue', 'DarkGreen', 'DarkCyan', 'DarkRed', 'DarkMagenta', 'DarkYellow', 'Gray', 'DarkGray', 'Blue', 'Green', 'Cyan', 'Red', 'Magenta', 'Yellow', 'White')]$ForegroundColor = 'Black'
    )
    # Debug message for parameter call
    If ($ShowInConsole)
    {
        Write-Host ('[CallFunction]' + $ScriptMyInvocation.MyCommand.Name + ' ' + ($ScriptPsBoundParameters.GetEnumerator() | Sort-Object Key | ForEach-Object { ('-' + $_.Key + ":('" + ($_.Value -join "','") + "')").Replace("'True'", '$True').Replace("'False'", '$False')}) ) -BackgroundColor:($BackgroundColor) -ForegroundColor:($ForegroundColor)
        If ($ScriptPSCmdlet.ParameterSetName -ne '__AllParameterSets') { Write-Verbose ('[ParameterSet]' + $ScriptMyInvocation.MyCommand.Name + ':' + $ScriptPSCmdlet.ParameterSetName) }
    }
    Else
    {
        Write-Debug ('[CallFunction]' + $ScriptMyInvocation.MyCommand.Name + ' ' + ($ScriptPsBoundParameters.GetEnumerator() | Sort-Object Key | ForEach-Object { ('-' + $_.Key + ":('" + ($_.Value -join "','") + "')").Replace("'True'", '$True').Replace("'False'", '$False')}) )
        If ($ScriptPSCmdlet.ParameterSetName -ne '__AllParameterSets') { Write-Verbose ('[ParameterSet]' + $ScriptMyInvocation.MyCommand.Name + ':' + $ScriptPSCmdlet.ParameterSetName) }
    }
}
