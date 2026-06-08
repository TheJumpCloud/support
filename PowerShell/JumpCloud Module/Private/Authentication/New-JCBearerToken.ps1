function New-JCBearerToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][System.String]$ClientId,
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][System.String]$ClientSecret
    )
    begin {
        # Debug message for parameter call (mask ClientSecret in debug output)
        $debugParams = @{ ClientId = $ClientId; ClientSecret = '***' }
        $debugParams | Out-DebugParameter | Write-Debug

        $tokenUrl = switch ($env:JCEnvironment) {
            'EU' { 'https://admin-oauth.id.eu.jumpcloud.com/oauth2/token' }
            default { 'https://admin-oauth.id.jumpcloud.com/oauth2/token' }
        }
    }
    process {
        # JumpCloud's admin OAuth endpoint requires client_secret_basic: credentials go in the
        # Authorization header, body carries only grant_type.
        $basicAuth = [System.Convert]::ToBase64String(
            [System.Text.Encoding]::UTF8.GetBytes("${ClientId}:${ClientSecret}")
        )
        $authHeaders = @{ Authorization = "Basic $basicAuth" }
        $body = 'scope=api&grant_type=client_credentials'
        try {
            Write-Verbose ('Requesting OAuth access token from: ' + $tokenUrl)
            $response = Invoke-RestMethod -Uri $tokenUrl -Method POST -Headers $authHeaders -Body $body -ContentType 'application/x-www-form-urlencoded'
        } catch {
            # Capture the original failure: the inner try/catch below rebinds $_, which would
            # otherwise corrupt the error we surface here.
            $outerError = $_
            # Surface the OAuth error payload (error / error_description) when the server returned one.
            $oauthErrorDetail = ''
            if ($outerError.Exception.Response) {
                try {
                    $errStream = $outerError.Exception.Response.GetResponseStream()
                    if ($errStream) {
                        $reader = New-Object System.IO.StreamReader($errStream)
                        $oauthErrorDetail = $reader.ReadToEnd()
                        $reader.Close()
                    }
                } catch {
                    if ($outerError.ErrorDetails -and $outerError.ErrorDetails.Message) {
                        $oauthErrorDetail = $outerError.ErrorDetails.Message
                    }
                }
            }
            if (-not $oauthErrorDetail -and $outerError.ErrorDetails -and $outerError.ErrorDetails.Message) {
                $oauthErrorDetail = $outerError.ErrorDetails.Message
            }
            $msg = "Failed to obtain OAuth access token from $tokenUrl. $($outerError.Exception.Message)"
            if ($oauthErrorDetail) {
                $msg += " Response body: $oauthErrorDetail"
            }
            throw $msg
        }

        if ([System.String]::IsNullOrEmpty($response.access_token)) {
            throw "OAuth token endpoint returned no access_token. Response: $($response | ConvertTo-Json -Compress)"
        }

        $expiresAt = (Get-Date).AddSeconds([int]$response.expires_in)

        # Persist creds and token so future calls can detect expiry and re-issue
        $env:JCAccessToken = $response.access_token
        $env:JCAccessTokenExpiresAt = $expiresAt.ToString('o')
        $env:JCClientId = $ClientId
        $env:JCClientSecret = $ClientSecret
        $global:JCAccessToken = $env:JCAccessToken
        $global:JCAccessTokenExpiresAt = $expiresAt

        return [PSCustomObject]@{
            AccessToken = $response.access_token
            TokenType   = $response.token_type
            ExpiresIn   = [int]$response.expires_in
            ExpiresAt   = $expiresAt
        }
    }
    end {}
}