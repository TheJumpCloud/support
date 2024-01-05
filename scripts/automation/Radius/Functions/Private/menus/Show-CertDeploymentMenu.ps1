function Show-CertDeploymentMenu {
    $title = ' JumpCloud Radius Cert Deployment '
    Clear-Host
    Write-Host $(PadCenter -string $Title -char '=')
    Write-Host $(PadCenter -string "Select an option below to view certificate deployment status`n" -char ' ') -ForegroundColor Yellow

    # ==== instructions ====
    Write-Host $(PadCenter -string ' Certificate Deployment Result Options ' -char '-')
    # List options:
    Write-Host "1: Press '1' to view results."
    Write-Host "2: Press '2' to view failed command runs"
    Write-Host "3: Press '3' to invoke/retry commands"
    Write-Host "E: Press 'E' to exit."

    Write-Host $(PadCenter -string "-" -char '-')

}