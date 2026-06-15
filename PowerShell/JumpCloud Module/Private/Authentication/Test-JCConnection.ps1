function Test-JCConnection {
    # Returns $true when the module needs to (re)authenticate for the active auth method.
    # apiKey: true when no API key is cached. clientSecret: true when there is no valid bearer token.
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        switch (Get-JCActiveAuthMethod) {
            'clientSecret' {
                return -not (Get-JCAccessToken).IsValid
            }
            default {
                return [System.String]::IsNullOrEmpty($env:JCApiKey)
            }
        }
    }
}
