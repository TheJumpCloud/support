
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
        if ($domainMatches) {
            if (($domainMatches.Matches.Groups[0].Value -match "https://") -or ($domainMatches.Matches.Groups[0].Value -match "urn:rui:")) {
                # entity ID should match https: or urn:uri:
                $entityID = $domainMatches.Matches.Groups[0].Value
            }
            # domain should be the second group match from the $domainMatches variable
            $domain = $domainMatches.Matches.Groups[2].Value

        } else {
            throw "The supplied EntityID: $($XMLInfo.EntityDescriptor.entityID) does not appear to be correct. The domain name may be missing 'https://' or 'urn:uri:' as a prefix to the domain name. EX: within the JumpCloud SSO application for O365, supply an EntityID value such as 'https://myDomain.com' or 'urn:uri:myDomain.com'"
        }


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