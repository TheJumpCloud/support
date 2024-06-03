function Get-InstalledCertsFromUsersJson {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.Object[]]
        $userData
    )

    begin {
        $CertificateStatus = New-Object System.Collections.ArrayList

    }
    process {
        foreach ($user in $userData) {

            $systemTotalCount = $($User.systemAssociations).count
            $installCount = $($user.deploymentInfo).count
            $CertificateStatus.add( [PSCustomObject]@{
                    Username             = $($User.username)
                    CertificateGenerated = if ($User.certInfo.sha1) { "$([char]0x1b)[92mYes" }
                    TotalSystems         = $systemTotalCount
                    InstallStatus        = if ($systemTotalCount -eq 0) { "$([char]0x1b)[91m0/0" } elseif ($installCount -eq $systemTotalCount) { "$([char]0x1b)[92m$installCount/$systemTotalCount" } else { "$([char]0x1b)[93m$installCount/$systemTotalCount" }
                }
            ) | Out-Null
        }

    }
    end {
        $CertificateStatus
    }
}