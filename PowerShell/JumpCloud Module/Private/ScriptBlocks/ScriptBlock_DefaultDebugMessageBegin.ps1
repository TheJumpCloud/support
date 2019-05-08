<#
.DESCRIPTION
This script block should be called within the Begin block of all scripts. This will create a standard format for all debug messages making it easier to troubleshoot functions.
.EXAMPLE
& $ScriptBlock_DefaultDebugMessageBegin -ScriptMyInvocation:($MyInvocation) -ScriptPsBoundParameters:($PsBoundParameters) -ScriptPSCmdlet:($PSCmdlet)
.EXAMPLE
Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDebugMessageBegin) -ArgumentList:($MyInvocation,$PsBoundParameters,$PSCmdlet) -NoNewScope
.EXAMPLE
Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDebugMessageBegin) -ArgumentList:($MyInvocation,$PsBoundParameters,$PSCmdlet, $true, 'Green', 'Black') -NoNewScope
#>
$ScriptBlock_DefaultDebugMessageBegin = {
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()]$ScriptMyInvocation
        , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)]$ScriptPsBoundParameters
        , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 2)][ValidateNotNullOrEmpty()]$ScriptPSCmdlet
        , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 3)][bool]$ShowInConsole = $false
        , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 4)][ValidateSet('Black', 'DarkBlue', 'DarkGreen', 'DarkCyan', 'DarkRed', 'DarkMagenta', 'DarkYellow', 'Gray', 'DarkGray', 'Blue', 'Green', 'Cyan', 'Red', 'Magenta', 'Yellow', 'White')]$BackgroundColor = 'Cyan'
        , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 5)][ValidateSet('Black', 'DarkBlue', 'DarkGreen', 'DarkCyan', 'DarkRed', 'DarkMagenta', 'DarkYellow', 'Gray', 'DarkGray', 'Blue', 'Green', 'Cyan', 'Red', 'Magenta', 'Yellow', 'White')]$ForegroundColor = 'Black'
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
