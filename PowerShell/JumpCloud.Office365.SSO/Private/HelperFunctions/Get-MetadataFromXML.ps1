
function Get-MetadataFromXML {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateScript( { Test-Path -Path $_ -PathType leaf })]
        [ValidatePattern( '\.xml$' )]
        [string]$XMLFilePath
    )

    [xml]$XMLInfo = Get-Content $XMLFilePath

    $certificate = $XMLInfo.EntityDescriptor.IDPSSODescriptor.KeyDescriptor.KeyInfo.X509Data.X509Certificate
    $domain = $XMLInfo.EntityDescriptor.entityID
    $IDPUrl = $XMLInfo.EntityDescriptor.IDPSSODescriptor.SingleSignOnService.location[0]

    $MetaData = [PSCustomObject]@{
        Certificate = $certificate
        Domain      = $domain
        IDPUrl      = $IDPUrl
    }

    Return $MetaData
}