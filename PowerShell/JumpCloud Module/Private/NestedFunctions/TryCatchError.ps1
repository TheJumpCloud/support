$TryCatchError = {
    Param($ErrorObject)
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