function Show-CertDeploymentMenu {
    $title = ' JumpCloud Radius Cert Deployment '
    Clear-Host
    Write-Host $(PadCenter -string $Title -char '=')
    Write-Host $(PadCenter -string "Select an option below to view certificate deployment status`n" -char ' ') -ForegroundColor Yellow

    # ==== instructions ====
    Write-Host $(PadCenter -string ' Certificate Deployment Result Options ' -char '-')
    # List options:
    Write-WrappedHost "1: Press '1' to view certificate deployment status."
    Write-WrappedHost "NOTE: This will display every user, their associated devices and which systems have successfully installed the current certificate." -ForegroundColor Cyan -Indent
    Write-WrappedHost "2: Press '2' to view command results."
    Write-WrappedHost "NOTE: This will display all command results and their status." -ForegroundColor Cyan -Indent
    Write-WrappedHost "3: Press '3' to view failed command runs."
    Write-WrappedHost "NOTE: This will display all failed command results and their status messages." -ForegroundColor Cyan -Indent
    Write-WrappedHost "4: Press '4' to invoke/retry commands."
    Write-WrappedHost "E: Press 'E' to exit."

    Write-Host $(PadCenter -string "-" -char '-')

}