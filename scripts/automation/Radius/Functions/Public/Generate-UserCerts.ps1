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
Import-Module "$JCScriptRoot/Functions/JCRadiusCertDeployment.psm1" -DisableNameChecking -Force

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

# Get user membership of group
# TODO: update group membership if last date is -gt 30 mins
if ( -not $GLOBAL:RadiusUserMembership ) {
    $GLOBAL:RadiusUserMembership = Get-JCUserGroupMember -ByID $JCUSERGROUP
    $groupMembers = $GLOBAL:RadiusUserMembership
} else {
    $groupMembers = $GLOBAL:RadiusUserMembership
}
if ($groupMembers) {
    Write-Host "[status] Found $($groupmembers.count) users in Radius User Group"
}

# Get SystemHash
# TODO: update group membership if last date is -gt 30 mins
# TODO: global variable and track time last updated
$SystemHash = Get-JCSystem -returnProperties displayName, os

# Create UserCerts dir
if (Test-Path "$JCScriptRoot/UserCerts") {
    Write-Host "[status] User Cert Directory Exists"
} else {
    Write-Host "[status] Creating User Cert Directory"
    New-Item -ItemType Directory -Path "$JCScriptRoot/UserCerts"
}

function Show-GenerationMenu {
    $title = 'JumpCloud Radius Cert Deployment'
    Clear-Host
    Write-Host "================ $Title ================"
    Write-Host "1: Press '1' to generate new certificates for NEW RADIUS users. $([char]0x1b)[96mNOTE: This will only generate certificates for users who have not yet had a certificate generated."
    Write-Host "2: Press '2' to generate new certificates for ONE Specific RADIUS user. $([char]0x1b)[96mNOTE: you will be prompted to overwrite any previously generated certificates"
    Write-Host "3: Press '3' to re-generate new certificates for ALL users. $([char]0x1b)[96mNOTE: This will overwrite any previously generated certificates"
    Write-Host "4: Press '4' to re-generate new certificates for users who's cert is set to expire shortly. $([char]0x1b)[96mNOTE: This will overwrite any previously generated certificates"
    Write-Host "E: Press 'E' to exit."
}
Do {
    Show-GenerationMenu
    $confirmation = Read-Host "Please make a selection"
    switch ($confirmation) {
        '1' {
            # process all users, generate certificates for uses who do not yet have a certificate
            foreach ($user in $groupMembers) {
                # Get the user details:
                $MatchedUser = get-webjcuser -userID $user.id
                Write-Host "Generating Cert for user: $($MatchedUser.username)"
                if ($matchedUser.id -in $userArray.userid) {
                    if (Test-Path -Path "$JCScriptRoot/UserCerts/$($MatchedUser.username)-client-signed.pfx") {
                        Write-Host "[status] $($MatchedUser.username) already has certs generated... skipping"
                    } else {
                        # Generate a new cert for this user:
                        Generate-UserCert -CertType $CertType -user $MatchedUser -rootCAKey "$JCScriptRoot/Cert/radius_ca_key.pem" -rootCA "$JCScriptRoot/Cert/radius_ca_cert.pem" | Out-Null
                    }
                } else {
                    Write-Host "[status] $($MatchedUser.username) not found in users.json"

                    # Find user system associations
                    $SystemUserAssociations = @()
                    $SystemUserAssociations += (Get-JCAssociation -Type user -Id $MatchedUser.id -TargetType system | Select-Object @{N = 'SystemID'; E = { $_.targetId } })

                    $systemAssociations = @()
                    foreach ($system in $SystemUserAssociations) {
                        $systemInfo = $SystemHash | Where-Object _id -EQ $system.SystemID
                        $systemTable = @{
                            systemId    = $systemInfo._id
                            displayName = $systemInfo.displayName
                            osFamily    = $systemInfo.os
                        }
                        $systemAssociations += $systemTable
                    }

                    $userTable = @{
                        userId              = $MatchedUser.id
                        userName            = $MatchedUser.username
                        localUsername       = $(If ($MatchedUser.hasLocalUsername) {
                                $matchedUser.localUsername
                            } else {
                                $matchedUser.username
                            })
                        systemAssociations  = $systemAssociations
                        commandAssociations = @()
                    }

                    if (Test-Path -Path "$JCScriptRoot/UserCerts/$($MatchedUser.username)-client-signed.pfx") {
                        Write-Host "[status] $($MatchedUser.username) has certs generated... adding to users.json"
                    } else {
                        Generate-UserCert -CertType $CertType -user $MatchedUser -rootCAKey "$JCScriptRoot/Cert/radius_ca_key.pem" -rootCA "$JCScriptRoot/Cert/radius_ca_cert.pem" | Out-Null
                    }
                    $userArray += $userTable
                }
            }
            # Update UserArray
            $userArray | ConvertTo-Json -Depth 6 | Out-File "$JCScriptRoot\users.json"
            Break
        }
        '2' {
            # process individual users, generate certificates for users who have not been added to users.json
            # if users have been added to users.json, prompt to re-generate
            Clear-Variable "ConfirmUser"
            while (-not $confirmUser) {
                $confirmationUser = Read-Host "Enter the Username or UserID of the user"
                $confirmUser = Test-User -username $confirmationUser -debug
            }
            # get data about the user
            $MatchedUser = get-webjcuser -userID $confirmUser.UserID
            # Generate a new cert for this user:
            if ($matchedUser.id -in $userArray.userid) {
                if (Test-Path -Path "$JCScriptRoot/UserCerts/$($MatchedUser.username)-client-signed.pfx") {
                    Do {
                        $overwrite = Read-Host "do you want to overwrite yn?"
                        switch ($overwrite) {
                            'y' {
                                Generate-UserCert -CertType $CertType -user $MatchedUser -rootCAKey "$JCScriptRoot/Cert/radius_ca_key.pem" -rootCA "$JCScriptRoot/Cert/radius_ca_cert.pem" | Out-Null
                                Break

                            }
                            'n' {
                                Write-Host "[status] $($MatchedUser.username) already has certs generated... skipping"
                                Break

                            }
                        }
                    } until (($overwrite -eq "y") -or ($overwrite -eq "n"))
                } else {
                    # Generate a new cert for this user:
                    Generate-UserCert -CertType $CertType -user $MatchedUser -rootCAKey "$JCScriptRoot/Cert/radius_ca_key.pem" -rootCA "$JCScriptRoot/Cert/radius_ca_cert.pem" | Out-Null
                }
            } else {
                Write-Host "[status] $($MatchedUser.username) not found in users.json"

                # Find user system associations
                $SystemUserAssociations = @()
                $SystemUserAssociations += (Get-JCAssociation -Type user -Id $MatchedUser.id -TargetType system | Select-Object @{N = 'SystemID'; E = { $_.targetId } })

                $systemAssociations = @()
                foreach ($system in $SystemUserAssociations) {
                    $systemInfo = $SystemHash | Where-Object _id -EQ $system.SystemID
                    $systemTable = @{
                        systemId    = $systemInfo._id
                        displayName = $systemInfo.displayName
                        osFamily    = $systemInfo.os
                    }
                    $systemAssociations += $systemTable
                }

                $userTable = @{
                    userId              = $MatchedUser.id
                    userName            = $MatchedUser.username
                    localUsername       = $(If ($MatchedUser.hasLocalUsername) {
                            $matchedUser.localUsername
                        } else {
                            $matchedUser.username
                        })
                    systemAssociations  = $systemAssociations
                    commandAssociations = @()
                }

                if (Test-Path -Path "$JCScriptRoot/UserCerts/$($MatchedUser.username)-client-signed.pfx") {
                    Write-Host "[status] $($MatchedUser.username) has certs generated... adding to users.json"
                } else {
                    Generate-UserCert -CertType $CertType -user $MatchedUser -rootCAKey "$JCScriptRoot/Cert/radius_ca_key.pem" -rootCA "$JCScriptRoot/Cert/radius_ca_cert.pem" | Out-Null
                }
                $userArray += $userTable
            }
            # Update UserArray
            $userArray | ConvertTo-Json -Depth 6 | Out-File "$JCScriptRoot\users.json"
            Break
        }
        '3' {
            # process new users, re-generate certificates for users who have not been added to users.json
            # TODO: implement
            Break
        }
        '4' {
            #TODO: overwrite soon to expire certificates

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



