

function Get-CertBySHA {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $sha1
    )

    begin {
        # define list
        $list = New-Object System.Collections.ArrayList


    }

    process {
        # for macOS certs search
        $macCertResultList = Get-JcSdkSystemInsightCertificate -Filter "sha1:eq:$sha1"
        # for windows certs search with uppercase:
        $windowsCertResultList = Get-JcSdkSystemInsightCertificate -Filter "sha1:eq:$($sha1.toUpper())"
        foreach ($cert in $macCertResultList) {
            $list.Add($cert) | Out-Null
        }
        foreach ($cert in $windowsCertResultList | Where-Object { $_.StoreId -notmatch "_Classes" }) {
            $list.Add($cert) | Out-Null
        }
        if ($list) {
            $userDeploymentTable = New-DeploymentTable -resultList $list
        }

    }

    end {
        return $userDeploymentTable

    }
}