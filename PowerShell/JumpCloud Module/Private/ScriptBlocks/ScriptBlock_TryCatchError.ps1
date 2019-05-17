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
    $DebugPreference = 'Continue' # SilentlyContinue (Default), Continue, Inquire, Stop
    # Write-Debug ('Command: ' + ($CallStack.Command -join ' -> '))
    # Write-Debug ('Arguments: ' + ($CallStack.Arguments -join ' -> '))
    Write-Debug ('Location: ' + ($CallStack.Location -join ' -> '))
    $DebugPreference = 'SilentlyContinue' # SilentlyContinue (Default), Continue, Inquire, Stop
    # $Error.Clear()
    # $EM_ErrorDetailsMessage = $ErrorObject.ErrorDetails.Message
    # $Exception = $ErrorObject.Exception
    # $EM_ExceptionMessage = $Exception.Message
    # While ($Exception.InnerException)
    # {
    #     $Exception = $Exception.InnerException
    #     $EM_InnerException_Message += "`n" + $Exception.Message
    #     Write-Host ('InnerExceptionFound!!!') -BackgroundColor Cyan
    # }
    # # Build error message
    # $OutputArray = @(
    #     "`n"
    #     , "START||EM_ErrorDetailsMessage||START`n'$($EM_ErrorDetailsMessage)'`nEND||EM_ErrorDetailsMessage||END;"
    #     , "START||EM_ExceptionMessage||START`n'$($EM_ExceptionMessage)'`nEND||EM_ExceptionMessage||END;"
    #     , "START||EM_InnerException_Message||START`n'$($EM_InnerException_Message)'`nEND||EM_InnerException_Message||END;"
    #     , "START||PositionMessage||START`n'$($ErrorObject.InvocationInfo.PositionMessage)'`nEND||PositionMessage||END;"
    #     , "START||FullyQualifiedErrorId||START`n'$($ErrorObject.FullyQualifiedErrorId.ToString())'`nEND||FullyQualifiedErrorId||END;"
    # )
    # $OutputString = (($OutputArray | Where-Object {$_}) -join "`n")
    # $OutputString = ($OutputArray -join "`n`n") + "`n########################################################################`n########################################################################"
    $OutputString = $ErrorObject
    # If it should be a terminating error
    If ($BreakInd)
    {
        Throw ($OutputString)
        Break
    }
    Else
    {
        Write-Error ($OutputString)
    }
}