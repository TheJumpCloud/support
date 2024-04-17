# todo: rename to be PS-ApprovedVerb "New-UserCert"
function Start-GenerateUserCerts {
    [CmdletBinding(DefaultParameterSetName = 'gui')]
    param (
        # Type of certs to distribute, All, New or byUsername
        [Parameter(HelpMessage = 'Type of certificate to initialize. To generate all new certificates for existing users, specify "all", To generate certificates for users who have not yet had certificates generated, specify "new". To generate certificates by an individual, speficy "ByUsername" and populate the "username" parameter. To generate certificates for users who have certificates expiring in 15 days or less, specify "ExpiringSoon".', ParameterSetName = 'cli', Mandatory)]
        [ValidateSet("All", "New", "ByUsername", "ExpiringSoon")]
        [system.String]
        $type,
        # username
        [Parameter(HelpMessage = 'The JumpCloud username of an individual user', ParameterSetName = 'cli')]
        [System.String]
        $username,
        # Force invoke commands after generation
        [Parameter(HelpMessage = 'When specified, this parameter will replace certificates if they already exist on the current filesystem', ParameterSetName = 'cli')]
        [switch]
        $forceReplaceCerts
    )
    #### begin function setup:
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

    # get userArray or initialize
    $userArray = Get-UserJsonData

    # Create UserCerts dir
    if (Test-Path "$JCScriptRoot/UserCerts") {
        Write-Host "[status] User Cert Directory Exists"
    } else {
        Write-Host "[status] Creating User Cert Directory"
        New-Item -ItemType Directory -Path "$JCScriptRoot/UserCerts"
    }
    #### end function setup

    Do {
        switch ($PSCmdlet.ParameterSetName) {
            'gui' {
                Show-GenerationMenu
                $confirmation = Read-Host "Please make a selection"
            }
            'cli' {
                $confirmationMap = @{
                    'New'          = '1';
                    "ByUsername"   = '2';
                    'All'          = '3';
                    "ExpiringSoon" = '4';
                }
                $confirmation = $confirmationMap[$type]
                # if force invoke is set, invoke the commands after generation:
                switch ($forceReplaceCerts) {
                    $true {
                        $replcaeCerts = $true
                    }
                    $false {
                        $replcaeCerts = $false
                    }
                }
            }
        }

        switch ($confirmation) {
            '1' {
                # process all users, generate certificates for uses who do not yet have a certificate
                # Get each RadiusMember User:
                for ($i = 0; $i -lt $JCRRadiusMembers.count; $i++) {
                    $result = Invoke-UserCertProcess -radiusMember $JCRRadiusMembers[$i] -certType $JCR_CERT_TYPE
                    Show-RadiusProgress -completedItems ($i + 1) -totalItems $JCRRadiusMembers.count -ActionText "Generating Radius Certificates" -previousOperationResult $result
                }
                switch ($PSCmdlet.ParameterSetName) {
                    'gui' {
                        Show-StatusMessage -Message "Finished Generating Certificates"
                    }
                    'cli' {
                        return
                    }
                }
            }
            '2' {
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
                    $userObject, $userIndex = Get-UserFromTable -userID $confirmUser.id
                    switch ($forceReplaceCerts) {
                        $true {
                            switch ($PSCmdlet.ParameterSetName) {
                                'gui' {
                                    $result = Invoke-UserCertProcess -radiusMember $userObject -certType $JCR_CERT_TYPE -forceReplaceCert
                                }
                                'cli' {
                                    $result = Invoke-UserCertProcess -radiusMember $userObject -certType $JCR_CERT_TYPE -forceReplaceCert
                                }
                            }
                        }
                        $false {
                            switch ($PSCmdlet.ParameterSetName) {
                                'gui' {
                                    $result = Invoke-UserCertProcess -radiusMember $userObject -certType $JCR_CERT_TYPE -Prompt
                                }
                                'cli' {
                                    $result = Invoke-UserCertProcess -radiusMember $userObject -certType $JCR_CERT_TYPE
                                }
                            }
                        }
                    }
                    Show-RadiusProgress -completedItems $userObject.count  -totalItems $userObject.count -ActionText "Generating Radius Certificates" -previousOperationResult $result
                }
                switch ($PSCmdlet.ParameterSetName) {
                    'gui' {
                        Show-StatusMessage -Message "Finished Generating Certificates"
                    }
                    'cli' {
                        return
                    }
                }
            }

            '3' {
                # re-generate new certificates for ALL users; will force rewrite all certs
                switch ($PSCmdlet.ParameterSetName) {
                    'gui' {
                        $overwriteExistingCerts = Get-ResponsePrompt -message "Are you confident you want to replace all locally generated user certificates?"
                        switch ($overwriteExistingCerts) {
                            $true {
                                continue
                            }
                            $false {
                                return
                            }
                        }
                    }
                }
                # Get each RadiusMember User:
                for ($i = 0; $i -lt $JCRRadiusMembers.count; $i++) {
                    $result = Invoke-UserCertProcess -radiusMember $JCRRadiusMembers[$i] -certType $JCR_CERT_TYPE -forceReplaceCert
                    Show-RadiusProgress -completedItems ($i + 1) -totalItems $JCRRadiusMembers.count -ActionText "Generating Radius Certificates" -previousOperationResult $result
                }
                switch ($PSCmdlet.ParameterSetName) {
                    'gui' {
                        Show-StatusMessage -Message "Finished Generating Certificates"
                    }
                    'cli' {
                        return
                    }
                }
            }
            '4' {
                # TODO: if there are no certs set to expire in 'x' days inform when pressing this option
                # recalculate expiring certs:
                $userCertInfo = Get-CertInfo -UserCerts
                # Get expiring certs:
                $Global:expiringCerts = Get-ExpiringCertInfo -certInfo $userCertInfo -cutoffDate $Global:JCR_USER_CERT_EXPIRE_WARNING_DAYS
                for ($i = 0; $i -lt $ExpiringCerts.Count; $i++) {
                    $userCert = $ExpiringCerts[$i]
                    <# Action that will repeat until the condition is met #>
                    $userArrayIndex = $userArray.username.IndexOf($userCert.username)
                    $IdentifiedUser = $userArray[$userArrayIndex]
                    $result = Invoke-UserCertProcess -radiusMember $IdentifiedUser -certType $JCR_CERT_TYPE -forceReplaceCert
                    Show-RadiusProgress -completedItems ($i + 1) -totalItems $ExpiringCerts.count -ActionText "Generating Radius Certificates" -previousOperationResult $result

                    # recalculate expiring certs:
                    $userCertInfo = Get-CertInfo -UserCerts
                }
                $Global:expiringCerts = Get-ExpiringCertInfo -certInfo $userCertInfo -cutoffDate $Global:JCR_USER_CERT_EXPIRE_WARNING_DAYS
                switch ($PSCmdlet.ParameterSetName) {
                    'gui' {
                        Show-StatusMessage -Message "Finished Generating Certificates"
                    }
                    'cli' {
                        return
                    }
                }
            }
            'E' {
                Write-Host "Returning to main menu"
            }
            default {
                Write-Host "Invalid Choice. Please try again"
            }
        }

    } while ($confirmation -ne 'E')
}



