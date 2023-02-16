function Show-CertDeploymentMenu {
    param (
        [string]$Title = 'Radius Cert Deployment Status'
    )
    Clear-Host
    Write-Host "================ $Title ================"

    Write-Host "1: Press '1' to view results."
    Write-Host "2: Press '2' to view failed command runs"
    Write-Host "3: Press '3' to invoke/retry commands"
    Write-Host "E: Press 'E' to exit."
}