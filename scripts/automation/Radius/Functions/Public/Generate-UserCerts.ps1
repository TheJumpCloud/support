# TODO: param for testing

# Import Global Config:
. "$JCScriptRoot/config.ps1"
Connect-JCOnline $JCAPIKEY -force

################################################################################
# Do not modify below
################################################################################
# Check if CA-Key is saved in env
if ($env:certKeyPassword) {
    Write-Host "Found CA-Key password in env"
    # Check if the key.pem works with the password
    $foundKeyPem = Resolve-Path -Path "$JCScriptRoot/Cert/*key.pem"
    $checkKey = openssl rsa -in $foundKeyPem -check -passin pass:$($env:certKeyPassword) 2>&1
    if ($checkKey -match "RSA key ok") {
        Write-Debug "ENV CA-Key password is works with the current key"
    } else {
        Write-Host "CA-Key password is incorrect"
        Get-CertKeyPass
    }
} else {
    # Get CA-Key password
    Write-Host "CA-Key password not found in the ENV"
    Get-CertKeyPass
}

# Import the functions
# Import-Module "$JCScriptRoot/Functions/JCRadiusCertDeployment.psm1" -DisableNameChecking -Force

# Import User.Json/ create list if it does not exist
if (Test-Path -Path "$JCScriptRoot/users.json" -PathType Leaf) {
    Write-Host "[status] Found user.json file"
    $userArray = Get-Content -Raw -Path "$JCScriptRoot/users.json" | ConvertFrom-Json -Depth 6
    # If the json is a single item, explicitly make it a list so we can add to it
    If ($userArray.count -eq 1) {
        $array = New-Object System.Collections.ArrayList
        $array.add($userArray)
        $userArray = $array
    }

} else {
    Write-Host "[status] users.json file not found"
    $userArray = @()
}

# Create UserCerts dir
if (Test-Path "$JCScriptRoot/UserCerts") {
    Write-Host "[status] User Cert Directory Exists"
} else {
    Write-Host "[status] Creating User Cert Directory"
    New-Item -ItemType Directory -Path "$JCScriptRoot/UserCerts"
}

function Show-GenerationMenu {
    $title = ' JumpCloud Radius Cert Deployment '
    Clear-Host
    Write-Host $(PadCenter -string $Title -char '=')
    Write-Host $(PadCenter -string "Select an option below to generate/regenerate user certificates`n" -char ' ') -ForegroundColor Yellow
    # ==== instructions ====
    # TODO: move notes from below into a more legible location
    # Write-Host $(PadCenter -string ' User Certificate Options ' -char '-')
    # Write-Host $(PadCenter -string "$([char]0x1b)[96m[]: This will only generate certificates for users who do not have a certificate file yet.`n" -char ' ')

    if ($Global:expiringCerts) {
        Write-Host $(PadCenter -string ' Certs Expiring Soon ' -char '-')
        $Global:expiringCerts | Format-Table -Property username, @{name = 'Remaining Days'; expression = { (New-TimeSpan -Start (Get-Date) -End ("$($_.notAfter)")).Days } }, @{name = "Expires On"; expression = { $_.notAfter } }
    }

    Write-Host $(PadCenter -string "-" -char '-')
    Write-Host "1: Press '1' to generate new certificates for NEW RADIUS users. `n`t$([char]0x1b)[96mNOTE: This will only generate certificates for users who do not have a certificate file yet."
    Write-Host "2: Press '2' to generate new certificates for ONE RADIUS user. `n`t$([char]0x1b)[96mNOTE: you will be prompted to overwrite any previously generated certificates"
    Write-Host "3: Press '3' to re-generate new certificates for ALL users. `n`t$([char]0x1b)[96mNOTE: This will overwrite any local generated certificates"
    Write-Host "4: Press '4' to re-generate new certificates for users who's cert is set to expire shortly. `n`t$([char]0x1b)[96mNOTE: This will overwrite any local generated certificates"
    Write-Host "E: Press 'E' to exit."
}
Do {
    Show-GenerationMenu
    $confirmation = Read-Host "Please make a selection"

    switch ($confirmation) {
        '1' {
            # process all users, generate certificates for uses who do not yet have a certificate
            # Get List of files, figure out userList of users who've not had a cert generated:
            $userCertFiles = Get-ChildItem -Path "$JCScriptRoot/UserCerts/" -Filter "*-client-signed.pfx"
            $certFileList = New-Object System.Collections.ArrayList
            foreach ($file in $userCertFiles) {
                $userFromFile = $file.BaseName.Replace("-client-signed", "")
                $certFileList.add($userFromFile) | Out-Null
            }
            # Get each RadiusMember User:
            foreach ($user in $Global:JCRRadiusMembers.keys) {
                # Get the user details:
                $MatchedUser = $GLOBAL:JCRUsers[$user]
                # If the user has a certificate continue
                if ($MatchedUser.username -in $certFileList) {
                    #if the cert already exists, break
                    Write-Host "[status] $($MatchedUser.username) has a certificate already. skipping..."
                } else {
                    # if the user does not have a certificate, generate
                    Generate-UserCert -CertType $CertType -user $MatchedUser -rootCAKey "$JCScriptRoot/Cert/radius_ca_key.pem" -rootCA "$JCScriptRoot/Cert/radius_ca_cert.pem" | Out-Null
                    # Get the user from the users.json file
                    $userObject, $userIndex = Get-UserFromTable -jsonFilePath "$JCScriptRoot/users.json" -userID $MatchedUser.id
                    # set user table:
                    if ($userIndex -ge 0) {
                        # update the new certificate info & set commandAssociation to $null
                        # TODO: commandAssociation not being set to null
                        $certInfo = Get-CertInfo -UserCerts -username $MatchedUser.username
                        Set-UserTable -index $userIndex -certInfoObject $certInfo -commandAssociationsObject $null
                    } else {
                        # Create a new table entry
                        New-UserTable -id $MatchedUser.id -username $MatchedUser.username -localUsername $MatchedUser.systemUsername
                    }
                }
            }
            Break
        }
        '2' {
            while (-not $confirmUser.id) {
                $confirmationUser = Read-Host "Enter the Username or UserID of the user"
                $confirmUser = Test-UserFromHash -username $confirmationUser -debug
            }
            # Generate a new cert for this user:
            if (Test-Path -Path "$JCScriptRoot/UserCerts/$($confirmUser.username)-client-signed.pfx") {
                Do {
                    $overwrite = Read-Host "do you want to overwrite y/n?"
                    switch ($overwrite) {
                        'y' {
                            Generate-UserCert -CertType $CertType -user $confirmUser -rootCAKey "$JCScriptRoot/Cert/radius_ca_key.pem" -rootCA "$JCScriptRoot/Cert/radius_ca_cert.pem" | Out-Null
                            Break

                        }
                        'n' {
                            Write-Host "[status] $($confirmUser.username) already has certs generated... skipping"
                            Break

                        }
                    }
                } until (($overwrite -eq "y") -or ($overwrite -eq "n"))
            } else {
                # Generate a new cert for this user:
                Generate-UserCert -CertType $CertType -user $confirmUser -rootCAKey "$JCScriptRoot/Cert/radius_ca_key.pem" -rootCA "$JCScriptRoot/Cert/radius_ca_cert.pem" | Out-Null
            }
            # Get the user from the users.json file
            $userObject, $userIndex = Get-UserFromTable -jsonFilePath "$JCScriptRoot/users.json" -userID $confirmUser.id
            # set user table:
            if ($userIndex -ge 0) {
                Write-Warning "setting existing table for user $($confirmUser.username)"
                # update the new certificate info & set commandAssociation to $null
                # TODO: commandAssociation not being set to null
                $certInfo = Get-CertInfo -UserCerts -username $confirmUser.username
                Set-UserTable -index $userIndex -certInfoObject $certInfo -commandAssociationsObject $null
            } else {
                Write-Warning "setting new table for user $($confirmUser.username)"
                # Create a new table entry
                New-UserTable -id $confirmUser.id -username $confirmUser.username -localUsername $confirmUser.systemUsername
            }
            # clear the user variable:
            Clear-Variable "ConfirmUser"
            Break
        }
        '3' {
            # re-generate new certificates for ALL users
            foreach ($user in $Global:JCRRadiusMembers.keys) {
                # Get the user details:
                $MatchedUser = $GLOBAL:JCRUsers[$user]
                # Regenerate
                Generate-UserCert -CertType $CertType -user $MatchedUser -rootCAKey "$JCScriptRoot/Cert/radius_ca_key.pem" -rootCA "$JCScriptRoot/Cert/radius_ca_cert.pem" | Out-Null
                # Get the user from the users.json file
                $userObject, $userIndex = Get-UserFromTable -jsonFilePath "$JCScriptRoot/users.json" -userID $MatchedUser.id
                # set user table:
                if ($userIndex -ge 0) {
                    # update the new certificate info & set commandAssociation to $null
                    # TODO: commandAssociation not being set to null
                    $certInfo = Get-CertInfo -UserCerts -username $MatchedUser.username
                    Set-UserTable -index $userIndex -certInfoObject $certInfo -commandAssociationsObject $null
                } else {
                    # Create a new table entry
                    New-UserTable -id $MatchedUser.id -username $MatchedUser.username -localUsername $MatchedUser.systemUsername
                }
            }
            Break
        }
        '4' {

            do {
                $overwrite = Read-Host "do you want to overwrite yn?"
                switch ($overwrite) {
                    'y' {
                        foreach ($userCert in $Global:expiringCerts) {
                            $userArrayIndex = $userArray.username.IndexOf($userCert.username)
                            $IdentifiedUser = $userArray[$userArrayIndex]
                            $MatchedUser = $GLOBAL:JCRUsers[$IdentifiedUser.userid]
                            Generate-UserCert -CertType $CertType -user $MatchedUser -rootCAKey "$JCScriptRoot/Cert/radius_ca_key.pem" -rootCA "$JCScriptRoot/Cert/radius_ca_cert.pem" | Out-Null
                            # Get the user from the users.json file
                            $userObject, $userIndex = Get-UserFromTable -jsonFilePath "$JCScriptRoot/users.json" -userID $MatchedUser.id
                            # set user table:
                            if ($userIndex -ge 0) {
                                # update the new certificate info & set commandAssociation to $null
                                # TODO: commandAssociation not being set to null
                                $certInfo = Get-CertInfo -UserCerts -username $MatchedUser.username
                                Set-UserTable -index $userIndex -certInfoObject $certInfo -commandAssociationsObject $null
                            } else {
                                # Create a new table entry
                                New-UserTable -id $MatchedUser.id -username $MatchedUser.username -localUsername $MatchedUser.systemUsername
                            }
                        }
                        Break
                    }
                    'n' {
                        Write-Host "[status] $($MatchedUser.username) already has certs generated... skipping"
                        Break

                    }
                }
            } until (($overwrite -eq "y") -or ($overwrite -eq "n"))
        }
        'E' {
            Write-Host "Returning to main menu"
        }
        default {
            Write-Host "Invalid Choice. Please try again"
            Break
        }
    }
} while ($confirmation -ne 'E')



