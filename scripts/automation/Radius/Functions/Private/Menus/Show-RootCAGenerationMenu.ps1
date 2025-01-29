function Show-RootCAGenerationMenu {
    $title = ' JumpCloud Radius Root CA Cert Deployment '
    Clear-Host
    Write-Host $(PadCenter -string $Title -char '=')
    Write-Host $(PadCenter -string "Select an option below to generate/regenerate root certificate`n" -char ' ') -ForegroundColor Yellow

    $rootCAInfo = Get-CertInfo -rootCa
    Write-Host $(PadCenter -string ' Root CA ' -char '-')
    if ($rootCAInfo -eq $null) {
        Write-Host $(PadCenter -string "No Root CA detected`n" -char ' ') -ForegroundColor Yellow
    } else {
        Write-Host $(PadCenter -string "Root CA Serial Number: $($rootCAInfo.serial)" -char ' ') -ForegroundColor Green
        Write-Host $(PadCenter -string "Root CA Expiration: $($rootCAInfo.notAfter)`n" -char ' ') -ForegroundColor Green

        # If root CA is expiring within 30 days, display warning
        $expirationDate = [datetime]$rootCAInfo.notAfter
        $currentDate = Get-Date
        $daysRemaining = ($expirationDate - $currentDate).Days

        # Check if expiration is less root cert warning days
        if ($daysRemaining -lt $JCR_ROOT_CERT_Expire_Warning_Days) {
            Write-Host $(PadCenter -string "WARNING: The root certificate is expiring in $daysRemaining day(s) on $expirationDate! Please press '3' to regenerate your root cert.") -ForegroundColor Yellow
        }
    }


    Write-Host $(PadCenter -string ' Root Certificate Generation Options ' -char '-')
    # List Options
    # Generate new root CA
    Write-Host "1: Press '1' to generate new root certificate. `n`t$([char]0x1b)[96mNOTE: you will be prompted to overwrite any previously generated certificates. This will generate a new root CA with a new serial number and user certs generated with the previous CA will no longer authenticate."

    # Replace root CA
    Write-Host "2: Press '2' to replace current root certificate. `n`t$([char]0x1b)[96mNOTE: if you replace root CA it will contain a different serial number and user certs generated with the previous CA will no longer authenticate."

    # Regenerate with the same serial number
    Write-Host "3: Press '3' to renew root certificate. `n`t$([char]0x1b)[96mNOTE: renewing the root CA will contain the same serial number and CA subject headers. User certs generated with the previous CA will continue to authenticate."

    # Return to main menu
    Write-Host "E: Press 'E' to return to main menu."

    Write-Host $(PadCenter -string "-" -char '-')
}