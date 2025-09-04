function Show-DistributionMenu {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.Object]
        $certObjectArray,
        [Parameter()]
        [System.Int32]
        $usersThatNeedCertCount,
        [Parameter()]
        [System.Int32]
        $TotalUserCount
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
        Write-Host "Users that have all their certificates installed: $([int]$TotalUserCount-[int]$usersThatNeedCertCount) of $TotalUserCount"

    }
    # ==== instructions ====
    Write-Host $(PadCenter -string ' User Certificate Deployment Options ' -char '-')
    # List options:
    Write-WrappedHost "1: Press '1' to generate new commands for ALL users."
    Write-WrappedHost "NOTE: This will remove any previously generated Radius User Certificate Commands titled 'RadiusCert-Install:*' and re-deploy their certificate file." -ForegroundColor Cyan -Indent
    Write-WrappedHost "2: Press '2' to generate new commands for NEW RADIUS users."
    Write-WrappedHost "NOTE: This will only generate commands for users whos certificate has not been deployed." -ForegroundColor Cyan -Indent
    Write-WrappedHost "3: Press '3' to generate new commands for ONE Specific RADIUS user."
    Write-WrappedHost "E: Press 'E' to return to main menu."

    Write-Host $(PadCenter -string "-" -char '-')
}