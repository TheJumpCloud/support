function Show-RadiusMainMenu {
    param (
        [string]$Title = ' JumpCloud Radius Cert Deployment '
    )
    # Get cert information
    $rootCAInfo = Get-CertInfo -rootCa
    $userCertInfo = Get-CertInfo -UserCerts

    # Find all certs that will expire between current date and cut off date
    try {
        $Global:expiringCerts = Get-ExpiringCertInfo -certInfo $userCertInfo -cutoffDate $module.PrivateData.config['certExpirationWarningDays'].value
    } catch {
        Write-Debug "No user certs exist, there are no user certs which will expire soon"
    }

    # Get UserGroup information from Config.ps1
    $radiusUserGroup = Get-JcSdkUserGroup -Id $module.PrivateData.config['userGroup'].value | Select-Object Name
    $radiusUserGroupMemberCount = (Get-JcSdkUserGroupMember -GroupId $module.PrivateData.config['userGroup'].value).Count

    # Get SSID information from Config.ps1
    $radiusSSID = ($module.PrivateData.config['networkSSID'].value).replace(';', ' ')

    # Output for Users
    Clear-Host

    # ==== TITLE ====
    Write-Host $(PadCenter -string $Title -char '=')
    Write-Host $(PadCenter -string "Edit the variables in Config.ps1 before continuing this script `n" -char ' ') -ForegroundColor Yellow
    # /==== TITLE ====

    # ==== ROOT CA ====
    Write-Host $(PadCenter -string ' Root CA ' -char '-')
    if ($rootCAInfo -eq $null) {
        Write-Host $(PadCenter -string "No Root CA detected`n" -char ' ') -ForegroundColor Yellow
    } else {
        Write-Host $(PadCenter -string "Root CA Serial Number: $($rootCAInfo.serial)" -char ' ') -ForegroundColor Green
        Write-Host $(PadCenter -string "Root CA Expiration: $($rootCAInfo.notAfter)`n" -char ' ') -ForegroundColor Green
    }
    if ($Global:expiringCerts) {
        Write-Host $(PadCenter -string "$($Global:expiringCerts.Count) user certs will expire in 15 days `n" -char ' ') -ForegroundColor Red
    }
    Write-Host $(PadCenter -string " Details " -char '-')
    # /==== ROOT CA ====

    # ==== GROUP/SSID/Global Variables  ====
    Write-Host $(PadCenter -string "Radius User Group: $($radiusUserGroup.Name)" -char " ") -ForegroundColor Green
    Write-Host $(PadCenter -string "Total Radius Users: $($radiusUserGroupMemberCount)" -char " ") -ForegroundColor Green
    Write-Host $(PadCenter -string "Radius SSID(s): $radiusSSID" -char " ") -ForegroundColor Green
    if ($IsMacOS) {
        Write-Host $(PadCenter -string "Last Updated User/System Data: $($module.PrivateData.config['lastUpdate'].value)" -char " ") -ForegroundColor Green
    } If ($isWindows) {
        Write-Host $(PadCenter -string "Last Updated User/System Data: $($module.PrivateData.config['lastUpdate'].value.value)" -char " ") -ForegroundColor Green
    }

    Write-Host $(PadCenter -string "-" -char '-')
    Write-Host "1: Press '1' to generate/update your Root Certificate."
    Write-Host "2: Press '2' to generate/update your User Certificate(s)."
    Write-Host "3: Press '3' to distribute your User Certificate(s)."
    Write-Host "4: Press '4' to monitor your User Certification Distribution."
    Write-Host "4: Press '5' to update User/System Data."
    Write-Host "Q: Press 'Q' to quit."
}