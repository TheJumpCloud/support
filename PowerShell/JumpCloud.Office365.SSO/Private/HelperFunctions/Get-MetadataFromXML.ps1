
function Get-MetadataFromXML {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateScript( { Test-Path -Path $_ -PathType leaf })]
        [ValidatePattern( '\.xml$' )]
        [string]$XMLFilePath
    )
    begin {

        [xml]$XMLInfo = Get-Content $XMLFilePath
    }
    process {

        $certificate = $XMLInfo.EntityDescriptor.IDPSSODescriptor.KeyDescriptor.KeyInfo.X509Data.X509Certificate
        # domain should be extracted from entityID
        $domainMatches = $XMLInfo.EntityDescriptor.entityID | Select-String -Pattern '(https:\/\/|urn:uri:)(=?.*)'
        if (($domainMatches.Matches.Groups[0].Value -match "https://") -or ($domainMatches.Matches.Groups[0].Value -match "urn:rui:")) {
            # entity ID should match https: or urn:uri:
            $entityID = $domainMatches.Matches.Groups[0].Value
        }
        # domain should be the second group match from the $domainMatches variable
        $domain = $domainMatches.Matches.Groups[2].Value

        $IDPUrl = $XMLInfo.EntityDescriptor.IDPSSODescriptor.SingleSignOnService.location[0]

        $MetaData = [PSCustomObject]@{
            Certificate = $certificate
            Domain      = $domain
            EntityID    = $entityID
            IDPUrl      = $IDPUrl
        }

    }
    end {

        Return $MetaData
    }
}
Get-MetadataFromXML -XMLFilePath "/Users/jworkman/Downloads/JumpCloud-office365-metadata (3).xml"