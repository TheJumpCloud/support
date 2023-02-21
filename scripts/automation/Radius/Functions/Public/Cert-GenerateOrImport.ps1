
do {
    Show-GenerateOrImportCertMenu
    $option = Read-Host "Please make a selection"
    switch ($option) {
        '1' {
            . "$JCScriptRoot/Functions/Public/Generate-RootCert.ps1"
        } '2' {
            Get-CertKeyPass
        }
    }
} until ($option.ToUpper() -eq 'E')