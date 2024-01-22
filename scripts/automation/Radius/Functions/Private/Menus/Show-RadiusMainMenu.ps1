function Show-RadiusMainMenu {
    param (
        [string]$Title = ' JumpCloud Radius Cert Deployment '
    )
    # Get cert information
    $rootCAInfo = Get-CertInfo -rootCa
    $userCertInfo = Get-CertInfo -UserCerts

    # Determine cut off date for expiring certs
    $global:cutoffDate = (Get-Date).AddDays(15).Date

    # Find all certs that will expire between current date and cut off date
    $Global:expiringCerts = Get-ExpiringCertInfo -certInfo $userCertInfo -cutoffDate $cutoffDate

    # Get UserGroup information from Config.ps1
    $radiusUserGroup = Get-JcSdkUserGroup -Id $global:JCUSERGROUP | Select-Object Name
    $radiusUserGroupMemberCount = (Get-JcSdkUserGroupMember -GroupId $global:JCUSERGROUP).Count

    # Get SSID information from Config.ps1
    $radiusSSID = $Global:NETWORKSSID.replace(';', ' ')

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
        Write-Host $(PadCenter -string "$($($Global:expiringCerts.subject).Count) user certs will expire in 15 days `n" -char ' ') -ForegroundColor Red
    }
    Write-Host $(PadCenter -string " Details " -char '-')
    # /==== ROOT CA ====

    # ==== GROUP/SSID/Global Variables  ====
    Write-Host $(PadCenter -string "Radius User Group: $($radiusUserGroup.Name)" -char " ") -ForegroundColor Green
    Write-Host $(PadCenter -string "Total Radius Users: $($radiusUserGroupMemberCount)" -char " ") -ForegroundColor Green
    Write-Host $(PadCenter -string "Radius SSID(s): $radiusSSID" -char " ") -ForegroundColor Green
    Write-Host $(PadCenter -string "Last Updated User/System Data: $($Global:JCRConfig.globalVars.lastupdate)" -char " ") -ForegroundColor Green
    # Write-Host "`n"
    # if ($radiusSSID.count -gt 1) {
    #     Write-Host $(PadCenter -string "Radius SSIDs:" -char " ") -ForegroundColor Green
    #     $radiusSSID | ForEach-Object {
    #         Write-Host $(PadCenter -string $_ -char " ") -ForegroundColor Green
    #     }
    # } else {
    #     Write-Host $(PadCenter -string "Radius SSID: $radiusSSID" -char " ") -ForegroundColor Green
    #     Write-Host "`n"
    # }
    # /==== GROUP/SSID ====

    Write-Host $(PadCenter -string "-" -char '-')
    Write-Host "1: Press '1' to generate your Root Certificate."
    Write-Host "2: Press '2' to generate/update your User Certificate(s)."
    Write-Host "3: Press '3' to distribute your User Certificate(s)."
    Write-Host "4: Press '4' to monitor your User Certification Distribution."
    Write-Host "4: Press '5' to update User/System Data"
    Write-Host "Q: Press 'Q' to quit."
}