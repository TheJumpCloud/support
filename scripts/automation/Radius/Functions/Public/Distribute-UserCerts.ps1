# Import Global Config:
# . "$JCScriptRoot/config.ps1"
# Connect-JCOnline $JCAPIKEY -force

################################################################################
# Do not modify below
################################################################################

# Import the users.json file and convert to PSObject
$userArray = Get-Content -Raw -Path "$JCScriptRoot/users.json" | ConvertFrom-Json -Depth 10

# TODO: surface this information
# Check to see if previous commands exist
# $SearchFilter = @{
#     searchTerm = "RadiusCert-Install:"
#     fields     = @('name')
# }
# $RadiusCertCommands = Search-JcSdkCommand -SearchFilter $SearchFilter -Fields name

# $RadiusCertCommandList = New-Object System.Collections.ArrayList
# foreach ($command in $RadiusCertCommands) {
#     $commandSplit = $command.name.split(':')
#     $RadiusCertCommandList.Add([PSCustomObject]@{
#             CommandName = $command.name
#             Username    = $commandSplit[1]
#             CommandID   = $command._id
#         }) | Out-Null
# }
# $existingCommandUsers = $RadiusCertCommandList.Username | Get-Unique
# $newRadiusUsers = (Compare-Object $userarray.username $existingCommandUsers).InputObject

# TODO: revamp with menu screen
# TODO: generate new commands for a single user
# TODO: why this if statement here:
do {
    Show-DistributionMenu -CertObjectArray $userArray.certInfo
    $confirmation = Read-Host "Please make a selection"

    switch ($confirmation) {
        '1' {
            for ($i = 0; $i -lt $userArray.Count; $i++) {
                <# Action that will repeat until the condition is met #>
                Show-ProgressBarText -completedItems $i -totalItems $userArray.Count -ActionText "Distributing Radius Certificates"
                $var = Deploy-UserCertificate -userObject $userArray[$i] -force | Out-Null
                Write-Host "`r" -NoNewline
            }
            Show-StatusMessage -Message "Finished Distributing Certificates"
        }
        '2' {
            $usersWithoutLatestCert = $userArray | Where-Object { ( $_.deployed -eq $false) -or (-not $_.deployed) }

            for ($i = 0; $i -lt $usersWithoutLatestCert.Count; $i++) {
                <# Action that will repeat until the condition is met #>
                Show-ProgressBarText -completedItems $i -totalItems $usersWithoutLatestCert.Count -ActionText "Distributing Radius Certificates"
                $var = Deploy-UserCertificate -userObject $usersWithoutLatestCert[$i] -force | Out-Null
                Write-Host "`r" -NoNewline
            }
            Show-StatusMessage -Message "Finished Distributing Certificates"

        }
        '3' {
            try {
                Clear-Variable -Name "ConfirmUser" -ErrorAction Ignore
            } catch {
                New-Variable -Name "ConfirmUser" -Value $null
            }
            while (-not $confirmUser) {
                # TODO: Offer option to go back a step and exit the while loop
                $confirmationUser = Read-Host "Enter the Username or UserID of the user"
                $confirmUser = Test-UserFromHash -username $confirmationUser -debug
            }
            # Get the userobject + index from users.json
            $userObject, $userIndex = Get-UserFromTable -jsonFilePath "$JCScriptRoot/users.json" -userID $confirmUser.id
            # Add user to a list for processing
            $UserSelectionArray = $userArray[$userIndex]
            # Process existing commands/ Generate new commands/ Deploy new Certificate
            Deploy-UserCertificate -userObject $UserSelectionArray
        }
    }
} while ($confirmation -ne 'E')


Write-Host "[status] Select option '4' to monitor your User Certification Distribution"
Write-Host "[status] Returning to main menu"
