function Disable-JumpCloud.Office365.SSO {
    [CmdletBinding(DefaultParameterSetName = 'domain')]
    param (
        [Parameter(Mandatory, position = 0, ParameterSetName = 'xml')]
        [ValidateScript( { Test-Path -Path $_ -PathType leaf })]
        [ValidatePattern( '\.xml$' )]
        [string]$XMLFilePath,
        [Parameter(Mandatory, ParameterSetName = 'domain')]
        [string]$Domain
    )

    begin {
        $Test = Test-MgGraph

    }

    process {
        if ($test -ne 1) {
            if ($PSCmdlet.ParameterSetName -eq 'xml') {
                $Metadata = Get-MetaDataFromXML -XMLFilePath $XMLFilePath
                $Domain = $Metadata.Domain

            }


            Update-MgDomain -DomainId $Domain -AuthenticationType Managed -ErrorAction SilentlyContinue -ErrorVariable ProcessError

            if ($ProcessError) {
                Connect-MgGraph -Scopes "Domain.ReadWrite.All"

                try {
                    Update-MgDomain -DomainName $Domain -AuthenticationType Managed
                    Write-Host "SSO disabled for domain: $Domain" -ForegroundColor Green
                    Write-Warning "It can take up to 20 minutes for the Office 365 sign in process to revert back to normal. You may return sign in errors during this time."
                } catch {
                    Return $_.ErrorDetails
                }
            } else {
                Write-Host "SSO disabled for domain: $Domain" -ForegroundColor Green
                Write-Warning "It can take up to 20 minutes for the Office 365 sign in process to revert back to normal. You may return sign in errors during this time."
            }
        }
    }

    end {
    }
}
