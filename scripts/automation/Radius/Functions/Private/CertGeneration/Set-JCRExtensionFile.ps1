function Set-JCRExtensionFile {
    [CmdletBinding()]
    param ()

    $extensionsDir = Join-Path $JCRScriptRoot "Extensions"
    $exts = Get-ChildItem -Path (Resolve-Path -Path $extensionsDir) -Filter "extensions-*.cnf"
    foreach ($ext in $exts) {
        Write-Host "Updating Subject Headers for $($ext.Name)"
        $extContent = Get-Content -Path $ext.FullName -Raw
        $reqDistinguishedName = @"
[req_distinguished_name]
C = $($global:JCRConfig.certSubjectHeader.Value.CountryCode)
ST = $($global:JCRConfig.certSubjectHeader.Value.StateCode)
L = $($global:JCRConfig.certSubjectHeader.Value.Locality)
O = $($global:JCRConfig.certSubjectHeader.Value.Organization)
OU = $($global:JCRConfig.certSubjectHeader.Value.OrganizationUnit)
CN = $($global:JCRConfig.certSubjectHeader.Value.CommonName)

"@
        $updatedContent = $extContent -Replace "(\[req_distinguished_name\][\s\S]*?)(?=\[v3_req\])", $reqDistinguishedName
        Set-Content -Path $ext.FullName -Value $updatedContent -NoNewline -Force
    }
}