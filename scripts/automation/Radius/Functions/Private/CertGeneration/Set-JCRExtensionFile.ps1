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
C = $($global:JCRConfig.certSubjectHeaderCountryCode.value)
ST = $($global:JCRConfig.certSubjectHeaderStateCode.value)
L = $($global:JCRConfig.certSubjectHeaderLocality.value)
O = $($global:JCRConfig.certSubjectHeaderOrganization.value)
OU = $($global:JCRConfig.certSubjectHeaderOrganizationUnit.value)
CN = $($global:JCRConfig.certSubjectHeaderCommonName.value)

"@
        $updatedContent = $extContent -Replace "(\[req_distinguished_name\][\s\S]*?)(?=\[v3_req\])", $reqDistinguishedName
        Set-Content -Path $ext.FullName -Value $updatedContent -NoNewline -Force
    }
}