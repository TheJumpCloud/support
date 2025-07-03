function Enable-JumpCloud.Office365.SSO {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, position = 0)]
        [ValidateScript( { Test-Path -Path $_ -PathType leaf })]
        [ValidatePattern( '\.xml$' )]
        [string]$XMLFilePath
    )

    begin {
        $Test = Test-MgGraph
    }

    process {
        if ($Test -ne 1) {
            $Metadata = Get-MetaDataFromXML -XMLFilePath $XMLFilePath
            $IDPUrl = $Metadata.IDPUrl
            $Domain = $Metadata.Domain
            $EntityID = $Metadata.EntityID
            $Certificate = $Metadata.Certificate
            $logoutUrl = "https://console.jumpcloud.com/userconsole/"

            $DirectorySynchronizationEnabled = Get-MgOrganization -ErrorAction SilentlyContinue -ErrorVariable ProcessError | Select-Object OnPremisesSyncEnabled

            if ($ProcessError) {
                Connect-MgGraph -Scopes "Domain.ReadWrite.All"
                $DirectorySynchronizationEnabled = Get-MgOrganization | Select-Object OnPremisesSyncEnabled
            }

            $MSDomains = Get-MgGraphDomains

            if ($MSDomains.($Domain) -eq $null) {
                Write-Warning  "Typo? $Domain is not a valid domain within your Office365 tenant"
                Write-Host "To see a list of valid domains in your Office 365 run the command 'Get-MgDomain'" -ForegroundColor Green
                Write-Host "Update your JumpCloud Office 365 SSO connector with the valid domain, download the XML metadata and try again!" -ForegroundColor Green
                Return
            }

            if ( $DirectorySynchronizationEnabled -eq $true) {
                Write-Warning  "Directory Synchronization is enabled run the command:'Update-MgOrganization -OrganizationId (Get-MgOrganization).Id -BodyParameter @{onPremisesSyncEnabled = $false}' to disable and try again"
            }

            else {
                $SetDomainParams = @{
                    DomainName                      = $Domain
                    DisplayName                     = $Domain
                    IssuerUri                       = $EntityID
                    SignOutUri                      = $logoutUrl
                    PassiveSignInUri                = $IDPUrl
                    ActiveSignInUri                 = $idpUrl
                    SigningCertificate              = $certificate
                    PreferredAuthenticationProtocol = "saml"
                    federatedIdpMfaBehavior         = "acceptIfMfaDoneByFederatedIdp"
                }

                try {

                    New-MgDomainFederationConfiguration -DomainId $Domain -BodyParameter $SetDomainParams

                    Update-MgDomain -DomainId $Domain -AuthenticationType Federated

                    Write-Host "SSO Configured for domain: $Domain" -ForegroundColor Green
                    Write-Warning "It can take up to 20 minutes for the Office 365 sign in process to update to SSO initiated. You may return sign in errors during this time."

                } catch {
                    Write-Output $_.errorDetails
                }
            }

        }

    }

    end {
    }
}
