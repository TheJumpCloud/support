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
        $ConnectionTestURL = "$JCUrlBasePath/api/v2/ldapservers"
        Invoke-RestMethod -Method GET -Uri $ConnectionTestURL -Headers $hdrs -UserAgent $JCUserAgent  | Out-Null

        Return $False
    }
    catch
    {
        
        try
        {   
            $MultiTenantURL = "$JCUrlBasePath/api/organizations/"

            Invoke-RestMethod -Method GET -Uri $MultiTenantURL -Headers $hdrs -UserAgent $JCUserAgent  | Out-Null

            Return $true
            
        }
        catch
        {

            Return $False
            
        }


    
    }

}