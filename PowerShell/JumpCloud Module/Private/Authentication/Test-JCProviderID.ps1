Function Test-JCProviderID {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.String]
        $ProviderID,
        [Parameter()]
        [System.String]
        $FunctionName
    )

    if ([System.String]::IsNullOrEmpty($ProviderID)) {
        throw "The `'$($FunctionName)`' function requires a ProviderID which is only found in JumpCLoud MTP accounts. Non-MTP accounts can not make use of this function"
    } else {
        Return $ProviderID
    }

}