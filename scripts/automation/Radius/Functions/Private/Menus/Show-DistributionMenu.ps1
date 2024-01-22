function Show-DistributionMenu {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.Object]
        $certObjectArray
    )

    $title = ' JumpCloud Radius Cert Deployment '
    Clear-Host
    Write-Host $(PadCenter -string $Title -char '=')
    Write-Host $(PadCenter -string "Select an option below to deploy user certificates to systems`n" -char ' ') -ForegroundColor Yellow
    # deployment progress of newly generated certs
    if ($certObjectArray) {

        Write-Host $(PadCenter -string ' Certificate Information ' -char '-')
        Write-Host "Total # of local user certificates:" $certObjectArray.count
        Write-Host "Total # of already distributed certificates:" ($certObjectArray | Where-Object { $_.deployed -eq $true }).count
        Write-Host "Total # of un-deployed certificates:" ($certObjectArray | Where-Object { ( $_.deployed -eq $false) -or (-not $_.deployed) }).count

    }
    # ==== instructions ====
    Write-Host $(PadCenter -string ' User Certificate Deployment Options ' -char '-')
    # List options:
    Write-Host "1: Press '1' to generate new commands for ALL users. `n`t$([char]0x1b)[96mNOTE: This will remove any previously generated Radius User Certificate Commands titled 'RadiusCert-Install:*'`n`tand re-deploy their certificate file"
    Write-Host "2: Press '2' to generate new commands for NEW RADIUS users. `n`t$([char]0x1b)[96mNOTE: This will only generate commands for users whos certificate has not been deployed."
    Write-Host "3: Press '3' to generate new commands for ONE Specific RADIUS user."
    Write-Host "E: Press 'E' to return to main menu."

    Write-Host $(PadCenter -string "-" -char '-')
}