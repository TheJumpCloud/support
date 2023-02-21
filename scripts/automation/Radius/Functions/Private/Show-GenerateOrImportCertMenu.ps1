function Show-GenerateOrImportCertMenu {
    param (
        [string]$Title = 'Generate or Import Cert'
    )
    Clear-Host
    Write-Host "================ $Title ================"

    Write-Host "1: Press '1' to Generate your root certificate"
    Write-Host "2: Press '2' to Enter Cert Key Password"
    Write-Host "E: Press 'E' to exit."
}