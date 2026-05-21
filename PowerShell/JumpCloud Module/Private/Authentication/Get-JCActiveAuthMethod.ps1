function Get-JCActiveAuthMethod {
    [CmdletBinding()]
    [OutputType([System.String])]
    param()
    if ($global:JCConfig -and
        $global:JCConfig.authPreference -and
        -not [System.String]::IsNullOrWhiteSpace($global:JCConfig.authPreference.Method)) {
        return $global:JCConfig.authPreference.Method
    }
    return 'apiKey'
}
