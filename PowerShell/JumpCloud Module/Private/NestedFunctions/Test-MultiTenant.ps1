function Test-MultiTenant
{
    param (
        $JumpCloudAPIKey
    )

    $hdrs = @{
        'Content-Type' = 'application/json'
        'Accept'       = 'application/json'
        'X-API-KEY'    = $JumpCloudAPIKey
    }

    try
    {
        $ConnectionTestURL = "https://console.jumpcloud.com/api/settings"
        Invoke-RestMethod -Method GET -Uri $ConnectionTestURL -Headers $hdrs -UserAgent 'Pwsh_1.8.0'  | Out-Null

        Return $False
    }
    catch
    {
        
        try
        {   
            $MultiTenantURL = "https://console.jumpcloud.com/api/organizations/"

            Invoke-RestMethod -Method GET -Uri $MultiTenantURL -Headers $hdrs -UserAgent 'Pwsh_1.8.0'  | Out-Null

            Return $true
            
        }
        catch
        {

            Return $False
            
        }


    
    }

}