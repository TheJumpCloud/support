# Import Global Config:
# . "$JCScriptRoot/config.ps1"
# Connect-JCOnline $JCAPIKEY -force
[CmdletBinding(DefaultParameterSetName = 'gui')]
param (
    [Parameter(ParameterSetName = 'cli')]
    [ValidateSet("All", "New", "ByUsername")]
    [system.String]
    $generateType,
    # Parameter help description
    [Parameter(ParameterSetName = 'cli')]
    [System.String]
    $username
)

################################################################################
# Do not modify below
################################################################################
# TODO: move into function file & rename
function pfi {
    $promptForInvokeInput = $true
    while ($promptForInvokeInput) {
        $invokeCommands = Read-Host "Would you like to invoke commands after generating them y/n? (or 'E' to return to menu)"
        switch ($invokeCommands) {
            'e' {
                $promptForInvokeInput = $false
                break
            }
            'n' {
                return $false
            }
            'y' {
                return $true
            }
            default {
                write-host "invalid input please type 'y' or 'n' (or 'E' to return to menu)"
            }
        }
    }
}

# Import the users.json file and convert to PSObject
$userArray = Get-Content -Raw -Path "$JCScriptRoot/users.json" | ConvertFrom-Json -Depth 10

do {
    switch ($PSCmdlet.ParameterSetName) {
        'gui' {
            Show-DistributionMenu -CertObjectArray $userArray.certInfo
            $confirmation = Read-Host "Please make a selection"
            $invokeCommands = pfi
        }
        'cli' {
            $confirmationMap = @{
                'All'        = '1';
                'New'        = '2';
                "ByUsername" = '3';
            }
            $confirmation = $confirmationMap[$generateType]
        }
    }

    switch ($confirmation) {
        '1' {
            for ($i = 0; $i -lt $userArray.Count; $i++) {
                $result = Deploy-UserCertificate -userObject $userArray[$i] -invokeCommands $invokeCommands
                Show-RadiusProgress -completedItems ($i + 1) -totalItems $userArray.Count -ActionText "Distributing Radius Certificates" -previousOperationResult $result
                # Write-Host "`r" -NoNewline
            }
            Show-StatusMessage -Message "Finished Distributing Certificates"
        }
        '2' {
            # TODO: prompt to invoke after creating commands
            $usersWithoutLatestCert = $userArray | Where-Object { ( $_.certinfo.deployed -eq $false) -or (-not $_.certinfo.deployed) }
            for ($i = 0; $i -lt $usersWithoutLatestCert.Count; $i++) {
                $result = Deploy-UserCertificate -userObject $usersWithoutLatestCert[$i] -invokeCommands $invokeCommands
                Show-RadiusProgress -completedItems ($i + 1) -totalItems $usersWithoutLatestCert.Count -ActionText "Distributing Radius Certificates" -previousOperationResult $result
                # Write-Host "`r" -NoNewline
            }
            Show-StatusMessage -Message "Finished Distributing Certificates"

        }
        '3' {
            switch ($PSCmdlet.ParameterSetName) {
                'gui' {
                    try {
                        Clear-Variable -Name "ConfirmUser" -ErrorAction Ignore
                    } catch {
                        New-Variable -Name "ConfirmUser" -Value $null
                    }
                    while (-not $confirmUser) {
                        $confirmationUser = Read-Host "Enter the Username of the user (or '@exit' to return to menu)"
                        if ($confirmationUser -eq '@exit') {
                            break
                        }
                        try {
                            $confirmUser = Test-UserFromHash -username $confirmationUser -debug
                        } catch {
                            Write-Warning "User specified $confirmationUser was not found within the Radius Server Membership Lists"
                        }
                    }
                }
                'cli' {
                    $confirmUser = Test-UserFromHash -username $username -debug
                }
            }
            if ($confirmUser) {
                # Get the userobject + index from users.json
                $userObject, $userIndex = Get-UserFromTable -jsonFilePath "$JCScriptRoot/users.json" -userID $confirmUser.id
                # Add user to a list for processing
                $UserSelectionArray = $userArray[$userIndex]
                # Process existing commands/ Generate new commands/ Deploy new Certificate
                $result = Deploy-UserCertificate -userObject $UserSelectionArray -invokeCommands $invokeCommands
                Show-RadiusProgress -completedItems $UserSelectionArray.count -totalItems $UserSelectionArray.Count -ActionText "Distributing Radius Certificates" -previousOperationResult $result
                Show-StatusMessage -Message "Finished Distributing Certificates"
            }
        }
    }
} while ($confirmation -ne 'E')
