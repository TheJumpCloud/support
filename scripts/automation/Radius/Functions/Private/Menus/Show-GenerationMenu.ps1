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

        $Global:expiringCerts | Format-Table -Property username, @{name = 'Remaining Days'; expression = {
                (New-TimeSpan -Start (Get-Date -Format "o") -End ([dateTime]("$($_.notAfter)"))).Days
            }
        }, @{name = "Expires On"; expression = {
                [datetime]($_.notAfter)
            }
        }
    }

    Write-Host $(PadCenter -string ' User Certificate Generation Options ' -char '-')
    # List Options
    Write-WrappedHost "1: Press '1' to generate new certificates for NEW RADIUS users."
    Write-WrappedHost "NOTE: This will only generate certificates for users who do not have a certificate file yet." -ForegroundColor Cyan -Indent
    Write-WrappedHost "2: Press '2' to generate new certificates for ONE RADIUS user."
    Write-WrappedHost "NOTE: you will be prompted to overwrite any previously generated certificates." -ForegroundColor Cyan -Indent
    Write-WrappedHost "3: Press '3' to re-generate new certificates for ALL users."
    Write-WrappedHost "NOTE: This will overwrite any local generated certificates." -ForegroundColor Cyan -Indent
    Write-WrappedHost "4: Press '4' to re-generate new certificates for users who's cert is set to expire shortly."
    Write-WrappedHost "NOTE: This will overwrite any local generated certificates." -ForegroundColor Cyan -Indent
    Write-WrappedHost "E: Press 'E' to return to main menu."

    Write-Host $(PadCenter -string "-" -char '-')
}