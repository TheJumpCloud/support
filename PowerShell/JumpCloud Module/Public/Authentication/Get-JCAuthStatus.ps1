function Get-JCAuthStatus {
    [CmdletBinding()]
    param ()
    process {
        $authMethod = Get-JCActiveAuthMethod

        if ($authMethod -eq 'clientSecret') {
            $maskedClientId = if (-not [System.String]::IsNullOrEmpty($env:JCClientId)) {
                $idLen = $env:JCClientId.Length
                if ($idLen -gt 12) {
                    $env:JCClientId.Substring(0, 8) + '...' + $env:JCClientId.Substring($idLen - 4)
                } else {
                    '***'
                }
            } else {
                $null
            }

            $expiresAt = $null
            $timeUntilExpiry = $null
            $isTokenExpired = $null
            if (-not [System.String]::IsNullOrEmpty($env:JCAccessTokenExpiresAt)) {
                $expiresAt = [datetime]::Parse($env:JCAccessTokenExpiresAt, $null, [System.Globalization.DateTimeStyles]::RoundtripKind)
                $timeUntilExpiry = $expiresAt - (Get-Date)
                $isTokenExpired = $timeUntilExpiry.TotalSeconds -le 0
            }

            return [PSCustomObject]@{
                Method          = $authMethod
                Environment     = $env:JCEnvironment
                OrgId           = $env:JCOrgId
                OrgName         = $env:JCOrgName
                HasAccessToken  = -not [System.String]::IsNullOrEmpty($env:JCAccessToken)
                HasClientId     = -not [System.String]::IsNullOrEmpty($env:JCClientId)
                HasClientSecret = -not [System.String]::IsNullOrEmpty($env:JCClientSecret)
                ClientId        = $maskedClientId
                TokenExpiresAt  = $expiresAt
                TimeUntilExpiry = $timeUntilExpiry
                IsTokenExpired  = $isTokenExpired
            }
        } else {
            return [PSCustomObject]@{
                Method      = $authMethod
                Environment = $env:JCEnvironment
                OrgId       = $env:JCOrgId
                OrgName     = $env:JCOrgName
                HasApiKey   = -not [System.String]::IsNullOrEmpty($env:JCApiKey)
            }
        }
    }
}
