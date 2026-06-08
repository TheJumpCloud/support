function Get-JCAuthHeaders {
    [CmdletBinding()]
    param ()
    process {
        $headers = @{
            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'x-org-id'     = "$($env:JCOrgId)"
        }

        $authMethod = Get-JCActiveAuthMethod

        if ($authMethod -eq 'clientSecret') {
            # Validate the cached token first; only mint a new one when missing or expired.
            $tokenInfo = Get-JCAccessToken
            if (-not $tokenInfo.IsValid) {
                if ([System.String]::IsNullOrEmpty($env:JCClientId) -or [System.String]::IsNullOrEmpty($env:JCClientSecret)) {
                    throw 'Access token is missing or expired and ClientId/ClientSecret are not available. Run Connect-JCOnline to re-authenticate.'
                }
                Write-Verbose 'Access token missing or expired; requesting a new bearer token.'
                New-JCBearerToken -ClientId $env:JCClientId -ClientSecret $env:JCClientSecret | Out-Null
                $tokenInfo = Get-JCAccessToken
            }
            $headers['Authorization'] = "Bearer $($tokenInfo.AccessToken)"
        } else {
            $headers['x-api-key'] = "$($env:JCApiKey)"
        }
        return $headers
    }
}
