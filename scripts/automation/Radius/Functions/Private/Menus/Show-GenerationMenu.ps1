function Show-GenerationMenu {
    $title = ' JumpCloud Radius Cert Deployment '
    Clear-Host
    Write-Host $(PadCenter -string $Title -char '=')
    Write-Host $(PadCenter -string "Select an option below to generate/regenerate user certificates`n" -char ' ') -ForegroundColor Yellow
    # ==== instructions ====
    # TODO: move notes from below into a more legible location
    # Write-Host $(PadCenter -string "$([char]0x1b)[96m[]: This will only generate certificates for users who do not have a certificate file yet.`n" -char ' ')

    if ($Global:expiringCerts) {
        Write-Host $(PadCenter -string ' Certs Expiring Soon ' -char '-')
        $Global:expiringCerts | Format-Table -Property username, @{name = 'Remaining Days'; expression = { (New-TimeSpan -Start (Get-Date) -End ("$($_.notAfter)")).Days } }, @{name = "Expires On"; expression = { $_.notAfter } }
    }

    Write-Host $(PadCenter -string ' User Certificate Generation Options ' -char '-')
    # List Options
    Write-Host "1: Press '1' to generate new certificates for NEW RADIUS users. `n`t$([char]0x1b)[96mNOTE: This will only generate certificates for users who do not have a certificate file yet."
    Write-Host "2: Press '2' to generate new certificates for ONE RADIUS user. `n`t$([char]0x1b)[96mNOTE: you will be prompted to overwrite any previously generated certificates."
    Write-Host "3: Press '3' to re-generate new certificates for ALL users. `n`t$([char]0x1b)[96mNOTE: This will overwrite any local generated certificates."
    Write-Host "4: Press '4' to re-generate new certificates for users who's cert is set to expire shortly. `n`t$([char]0x1b)[96mNOTE: This will overwrite any local generated certificates."
    Write-Host "E: Press 'E' to return to main menu."

    Write-Host $(PadCenter -string "-" -char '-')
}