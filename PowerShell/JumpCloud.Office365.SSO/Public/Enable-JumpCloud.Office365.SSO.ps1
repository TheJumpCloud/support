function Enable-JumpCloud.Office365.SSO
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, position = 0)]
        [ValidateScript( { Test-Path -Path $_ -PathType leaf })]
        [ValidatePattern( '\.xml$' )]
        [string]$XMLFilePath
    )
    
    begin
    {
        
        $Test = Test-MSOnline   
       
    }
    
    process
    {
        if ($Test -ne 1)
        {
            $Metadata = Get-MetaDataFromXML -XMLFilePath $XMLFilePath
            $IDPUrl = $Metadata.IDPUrl
            $Domain = $Metadata.Domain
            $Certificate = $Metadata.Certificate
            $logoutUrl = "https://console.jumpcloud.com/userconsole/"
    
            
            $DirectorySynchronizationEnabled = Get-MsolCompanyInformation -ErrorAction SilentlyContinue -ErrorVariable ProcessError | Select-Object DirectorySynchronizationEnabled

            if ($ProcessError)
            {
                Connect-MsolService
                $DirectorySynchronizationEnabled = Get-MsolCompanyInformation | Select-Object DirectorySynchronizationEnabled
            }

            $MSDomains = Get-MSOnlineDomains

            if ($MSDomains.($Domain) -eq $null)
            {
                Write-Warning  "Typo? $Domain is not a valid domain within your Office365 tenant"
                Write-Host "To see a list of valid domains in your Office 365 run the command 'Get-MsolDomain'" -ForegroundColor Green
                Write-Host "Update your JumpCloud Office 365 SSO connector with the valid domain, download the XML metadata and try again!" -ForegroundColor Green
                Return
            }
            
            if ( $DirectorySynchronizationEnabled -eq $true)
            {
                Write-Warning  "Directory Synchronization is enabled run the command:'Set-MsolDirSyncEnabled -EnableDirSync $false' to disable and try again"
            }

            else
            {

                $SetDomainParams = @{
                    DomainName                      = $Domain
                    FederationBrandName             = $Domain
                    Authentication                  = "Federated"
                    IssuerUri                       = $Domain
                    LogOffUri                       = $logoutUrl
                    PassiveLogOnUri                 = $IDPUrl
                    ActiveLogOnUri                  = $idpUrl
                    SigningCertificate              = $certificate
                    PreferredAuthenticationProtocol = "SAMLP"
    
                }
    

                try
                {
                    Set-MsolDomainAuthentication @SetDomainParams
                    Write-Host "SSO Configured for domain: $Domain" -ForegroundColor Green
                    Write-Warning "It can take up to 20 minutes for the Office 365 sign in process to update to SSO initiated. You may return sign in errors during this time."

                }
                catch
                {
                    Write-Output $_.errorDetails
                }
        
            
            }

        }
        
    }
    
    end
    {
    }
}
