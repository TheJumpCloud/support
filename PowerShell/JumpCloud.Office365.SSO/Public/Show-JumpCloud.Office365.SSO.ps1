function Show-JumpCloud.Office365.SSO {
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

        if ($Test -ne 1) {
            if ($PSCmdlet.ParameterSetName -eq 'xml') {
                $Metadata = Get-MetaDataFromXML -XMLFilePath $XMLFilePath
                $Domain = $Metadata.Domain

            }

            $Results = Get-MgDomainFederationConfiguration -DomainID $domain -ErrorAction SilentlyContinue -ErrorVariable ProcessError

            if ($ProcessError) {
                Connect-MgGraph -Scopes "Domain.Read.All"
                $Results = Get-MgDomainFederationConfiguration -DomainID $domain
            }


            if ($Results -eq $null) {

                $Results = "Federation is not configured for domain: $domain"
            }

        }
    }

    end {
        Return $Results
    }
}
