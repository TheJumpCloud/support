<#
.DESCRIPTION
This script block should be called in all Try Catch Finally statements within the Catch block. This will create a standard format for all errors making it easier to troubleshoot nested functions.
.EXAMPLE
& $ScriptBlock_TryCatchError -ErrorObject:($Error)
.EXAMPLE
Invoke-Command -ScriptBlock:($ScriptBlock_TryCatchError) -ArgumentList:($Error) -NoNewScope
#>
$ScriptBlock_TryCatchError = {
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]$ErrorObject
        , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 1)][bool]$BreakInd = $false
    )
    $CallStack = Get-PSCallStack
    [array]::Reverse($CallStack)
    Write-Debug ('Command: ' + ($CallStack.Command -join ' -> '))
    Write-Debug ('Arguments: ' + ($CallStack.Arguments -join ' -> '))
    Write-Debug ('Location: ' + ($CallStack.Location -join ' -> '))
    # If it should be a terminating error
    If ($BreakInd) {
        Throw ($ErrorObject)
        Break
    } Else {
        Write-Error ($ErrorObject)
    }
}