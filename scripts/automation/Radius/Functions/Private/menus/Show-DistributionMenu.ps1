function Show-DistributionMenu {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.Object]
        $certObjectArray
    )
    begin {
        # $userCertInfo = (Get-Content -Raw -Path "$JCScriptRoot/users.json" | ConvertFrom-Json -Depth 10).certInfo
    }
    process {


        $title = ' JumpCloud Radius Cert Deployment '
        Clear-Host
        Write-Host $(PadCenter -string $Title -char '=')
        Write-Host $(PadCenter -string "Select an option below to deploy user certificates to systems`n" -char ' ') -ForegroundColor Yellow
        # deployment progress of newly generated certs
        if ($userCertInfo) {

            Write-Host $(PadCenter -string ' Certificate Information ' -char '-')
            Write-Host "Total # of local user certificates:" $userCertInfo.count
            Write-Host "Total # of already distributed certificates:" ($userCertInfo | Where-Object { $_.deployed -eq $true }).count
            Write-Host "Total # of un-deployed certificates:" ($userCertInfo | Where-Object { ( $_.deployed -eq $false) -or (-not $_.deployed) }).count

        }
        # ==== instructions ====
        # TODO: move notes from below into a more legible location
        Write-Host $(PadCenter -string ' User Certificate Deployment Options ' -char '-')
        # List options:
        Write-Host "1: Press '1' to generate new commands for ALL users. `n`t$([char]0x1b)[96mNOTE: This will remove any previously generated Radius User Certificate Commands titled 'RadiusCert-Install:*'`n`tand re-deploy their certificate file"
        Write-Host "2: Press '2' to generate new commands for NEW RADIUS users. `n`t$([char]0x1b)[96mNOTE: This will only generate commands for users whos certificate has not been deployed."
        Write-Host "3: Press '3' to generate new commands for ONE Specific RADIUS user."
        Write-Host "E: Press 'E' to exit."

        Write-Host $(PadCenter -string "-" -char '-')
    }
    end {

    }
}