function Get-JCRCertReport {
    param(
        [Parameter(Mandatory)]
        [ValidateScript({
                $directory = Split-Path -Path $_ -Parent
                if (-not (Test-Path -Path $directory -PathType Container)) {
                    throw "The directory '$directory' does not exist."
                }
                if (-not ($_ -like '*.csv')) {
                    throw "The specified path '$_' does not end with '.csv'."
                }
                return $true
            })]
        [System.IO.FileInfo]$ExportFilePath
    )
    if ($Global:JCRSettings.sessionImport -eq $false) {
        Get-JCRGlobalVars
        $Global:JCRSettings.sessionImport = $true
    }

    # Initialize an empty array to store the results
    $reportData = New-Object System.Collections.ArrayList

    $radiusMembersPath = Join-Path -Path $JCRScriptRoot -ChildPath "data/radiusMembers.json"
    $certHashPath = Join-Path -Path $JCRScriptRoot -ChildPath "data/certHash.json"
    $associationHashPath = Join-Path -Path $JCRScriptRoot -ChildPath "data/associationHash.json"

    if (!(Test-Path $radiusMembersPath)) {
        Write-Error "radiusMembers.json not found at $radiusMembersPath"
        continue # Skip to the next group if file not found
    }
    if (!(Test-Path $certHashPath)) {
        Write-Error "certHash.json not found at $certHashPath"
        continue # Skip to the next group if file not found
    }
    if (!(Test-Path $associationHashPath)) {
        Write-Error "associationHash.json not found at $associationHashPath"
        continue # Skip to the next group if file not found
    }


    $radiusMembers = Get-Content $radiusMembersPath | ConvertFrom-Json
    $certHashes = Get-Content $certHashPath | ConvertFrom-Json
    $associationHash = Get-Content $associationHashPath | ConvertFrom-Json


    foreach ($user in $radiusMembers) {
        $userSystemAssociations = $associationHash.$($user.userID).systemAssociations
        $userCerts = Get-CertInfo -UserCerts -username $user.username
        foreach ($system in $userSystemAssociations) {
            $reportEntry = [ordered]@{}
            $reportEntry.username = $user.username
            $reportEntry.userid = $user.userid
            $reportEntry.systemHostname = $system.hostname
            $reportEntry.systemID = $system.systemId
            $reportEntry.systemOS = $system.osFamily


            # Check if certificate is installed on the device
            $certInstalled = $false
            $certificateSerialNumber = $userCerts.serial
            $certificateExpirationDate = $userCerts.notAfter

            if ($certHashes.$($userCerts.sha1).systemId -contains $system.systemId) {
                $certInstalled = $true
            }

            $reportEntry.certSerialNumber = $certificateSerialNumber
            $reportEntry.certExpirationDate = $certificateExpirationDate
            $reportEntry.certInstalled = $certInstalled

            $reportData.Add([pscustomobject]$reportEntry) | Out-Null
        }
    }


    # Export to CSV
    $reportData | Export-Csv -Path $ExportFilePath -NoTypeInformation
    Write-Host "Certificate report generated at: $ExportFilePath"
}