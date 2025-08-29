function Show-CertDeploymentMenu {
    $title = ' JumpCloud Radius Cert Deployment '
    Clear-Host
    Write-Host $(PadCenter -string $Title -char '=')
    Write-Host $(PadCenter -string "Select an option below to view certificate deployment status`n" -char ' ') -ForegroundColor Yellow

    # ==== instructions ====
    Write-Host $(PadCenter -string ' Certificate Deployment Result Options ' -char '-')
    # List options:
    Write-Host "1: Press '1' to view certificate deployment status. `n`t$([char]0x1b)[96mNOTE: This will display every user, their associated devices and which systems have successfully installed the `n`tcurrent certificate."
    Write-Host "2: Press '2' to view command results. `n`t$([char]0x1b)[96mNOTE: This will display all command results and their status"
    Write-Host "3: Press '3' to view failed command runs. `n`t$([char]0x1b)[96mNOTE: This will display all failed command results and their status messages."
    Write-Host "4: Press '4' to invoke/retry commands."
    Write-Host "E: Press 'E' to exit."

    Write-Host $(PadCenter -string "-" -char '-')

}