function Test-JCRExtensionFile {
    [CmdletBinding()]
    param ()

    $extensionsDir = Join-Path $JCRScriptRoot "Extensions"
    $exts = Get-ChildItem -Path (Resolve-Path -Path $extensionsDir) -Filter "extensions-*.cnf"
    $allValid = $true

    foreach ($ext in $exts) {
        Write-Host "Validating Subject Headers for $($ext.Name)"
        $extContent = Get-Content -Path $ext.FullName -Raw

        $expected = @{
            'C'  = $global:JCRConfig.certSubjectHeader.Value.CountryCode
            'ST' = $global:JCRConfig.certSubjectHeader.Value.StateCode
            'L'  = $global:JCRConfig.certSubjectHeader.Value.Locality
            'O'  = $global:JCRConfig.certSubjectHeader.Value.Organization
            'OU' = $global:JCRConfig.certSubjectHeader.Value.OrganizationUnit
            'CN' = $global:JCRConfig.certSubjectHeader.Value.CommonName
        }

        foreach ($key in $expected.Keys) {
            $pattern = "$key\s*=\s*(.+)"
            if ($extContent -match $pattern) {
                $actual = $Matches[1].Trim()
                if ($actual -ne $expected[$key]) {
                    $allValid = $false
                }
            } else {
                $allValid = $false
            }
        }
    }
    return $allValid
}