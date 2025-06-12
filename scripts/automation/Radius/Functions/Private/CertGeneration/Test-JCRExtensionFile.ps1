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
            'C'  = $global:JCRConfig.certSubjectHeaderCountryCode.value
            'ST' = $global:JCRConfig.certSubjectHeaderStateCode.value
            'L'  = $global:JCRConfig.certSubjectHeaderLocality.value
            'O'  = $global:JCRConfig.certSubjectHeaderOrganization.value
            'OU' = $global:JCRConfig.certSubjectHeaderOrganizationUnit.value
            'CN' = $global:JCRConfig.certSubjectHeaderCommonName.value
        }

        foreach ($key in $expected.Keys) {
            $pattern = "$key\s*=\s*(.+)"
            if ($extContent -match $pattern) {
                $actual = $Matches[1].Trim()
                if ($actual -ne $expected[$key]) {
                    Write-Error "Mismatch in $($ext.Name): $key expected '$($expected[$key])' but found '$actual'"
                    $allValid = $false
                }
            } else {
                Write-Error "Header $key not found in $($ext.Name)"
                $allValid = $false
            }
        }
    }
    return $allValid
}