function Show-RadiusMainMenu {
    param (
        [string]$Title = 'JumpCloud Radius Cert Deployment'
    )
    # Get cert information
    $rootCAInfo = Get-CertInfo -rootCa
    $userCertInfo = Get-CertInfo -UserCerts

    # Determine cut off date for expiring certs
    $cutoffDate = (Get-Date).AddDays(15).Date

    # Find all certs that will expire between current date and cut off date
    $expiringCerts = Get-ExpiringCertInfo -certInfo $userCertInfo -cutoffDate $cutoffDate

    # Output for Users
    Clear-Host
    Write-Host "================ $Title ================"
    Write-Host "$([char]0x1b)[33mEdit the variables in Config.ps1 before continuing this script `n"
    if ($rootCAInfo -eq $null) {
        Write-Host "$([char]0x1b)[33mNo Root CA detected`n"
    } else {
        Write-Host "$([char]0x1b)[32mRoot CA Serial Number: $($rootCAInfo.serial)"
        Write-Host "$([char]0x1b)[32mRoot CA Expiration: $($rootCAInfo.notAfter)`n"
    }
    if ($expiringCerts) {
        Write-Host "$([char]0x1b)[91m$($expiringCerts.Count) user certs will expire in 15 days `n"
    }

    Write-Host "1: Press '1' to generate your Root Certificate."
    Write-Host "2: Press '2' to generate/update your User Certificate(s)."
    Write-Host "3: Press '3' to distribute your User Certificate(s)."
    Write-Host "4: Press '4' to monitor your User Certification Distribution."
    Write-Host "Q: Press 'Q' to quit."
}