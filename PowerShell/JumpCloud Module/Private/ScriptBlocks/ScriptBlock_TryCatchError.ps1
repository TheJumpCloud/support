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
    )
    $Exception = $ErrorObject.Exception
    $Message = $Exception.Message
    While ($Exception.InnerException)
    {
        $Exception = $Exception.InnerException
        $Message += "`n" + $Exception.Message
    }
    Write-Error ($ErrorObject.FullyQualifiedErrorId.ToString() + "`n" + $ErrorObject.InvocationInfo.PositionMessage + "`n" + $Message)
    $Error.Clear()
}