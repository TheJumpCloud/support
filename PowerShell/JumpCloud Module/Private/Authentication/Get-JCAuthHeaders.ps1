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
            $token = Get-JCAccessToken
            $headers['Authorization'] = "Bearer $token"
        } else {
            $headers['x-api-key'] = "$($env:JCApiKey)"
        }
        return $headers
    }
}
