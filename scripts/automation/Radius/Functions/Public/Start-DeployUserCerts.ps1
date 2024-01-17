
function Start-DeployUserCerts {
    [CmdletBinding(DefaultParameterSetName = 'gui')]
    param (
        # Type of certs to distribute, All, New or byUsername
        [Parameter(HelpMessage = 'Type of cert deployment to initiate', ParameterSetName = 'cli', Mandatory)]
        [ValidateSet("All", "New", "ByUsername")]
        [system.String]
        $type,
        # username
        [Parameter(HelpMessage = 'The JumpCloud username of a user to deploy a certificate', ParameterSetName = 'cli')]
        [System.String]
        $username,
        # Force invoke commands after generation
        [Parameter(HelpMessage = 'Switch to force invoke generated commands on systems', ParameterSetName = 'cli')]
        [switch]
        $forceInvokeCommands
    )

    # Import the users.json file and convert to PSObject
    $userArray = Get-UserJsonData

    do {
        switch ($PSCmdlet.ParameterSetName) {
            'gui' {
                Show-DistributionMenu -CertObjectArray $userArray.certInfo
                $confirmation = Read-Host "Please make a selection"

            }
            'cli' {
                $confirmationMap = @{
                    'All'        = '1';
                    'New'        = '2';
                    "ByUsername" = '3';
                }
                $confirmation = $confirmationMap[$type]
                # if force invoke is set, invoke the commands after generation:
                switch ($forceInvokeCommands) {
                    $true {
                        $invokeCommands = $true
                    }
                    $false {
                        $invokeCommands = $false
                    }
                }
            }
        }

        switch ($confirmation) {
            '1' {
                # case for all users
                switch ($PSCmdlet.ParameterSetName) {
                    'gui' {
                        $invokeCommands = Get-ResponsePrompt -message "Would you like to invoke commands after they've been generated?"
                        if (($invokeCommands -ne $true) -And ($invokeCommands -ne $false)) {
                            return
                        }
                    }
                }
                for ($i = 0; $i -lt $userArray.Count; $i++) {
                    $result = Deploy-UserCertificate -userObject $userArray[$i] -forceInvokeCommands $invokeCommands
                    Show-RadiusProgress -completedItems ($i + 1) -totalItems $userArray.Count -ActionText "Distributing Radius Certificates" -previousOperationResult $result
                }
                # return after an action if cli, else stay in function
                switch ($PSCmdlet.ParameterSetName) {
                    'gui' {
                        Show-StatusMessage -Message "Finished Distributing Certificates"
                    }
                    'cli' {
                        return
                    }
                }
            }
            '2' {
                # case for new users; users that do not have certinfo marked as already deployed (i.e. users with new certs or un-deployed certs)
                switch ($PSCmdlet.ParameterSetName) {
                    'gui' {
                        $invokeCommands = Get-ResponsePrompt -message "Would you like to invoke commands after they've been generated?"
                        if (($invokeCommands -ne $true) -And ($invokeCommands -ne $false)) {
                            return
                        }
                    }
                }
                $usersWithoutLatestCert = $userArray | Where-Object { ( $_.certinfo.deployed -eq $false) -or (-not $_.certinfo.deployed) }
                for ($i = 0; $i -lt $usersWithoutLatestCert.Count; $i++) {
                    $result = Deploy-UserCertificate -userObject $usersWithoutLatestCert[$i] -forceInvokeCommands $invokeCommands
                    Show-RadiusProgress -completedItems ($i + 1) -totalItems $usersWithoutLatestCert.Count -ActionText "Distributing Radius Certificates" -previousOperationResult $result
                }
                # return after an action if cli, else stay in function
                switch ($PSCmdlet.ParameterSetName) {
                    'gui' {
                        Show-StatusMessage -Message "Finished Distributing Certificates"
                    }
                    'cli' {
                        return
                    }
                }
            }
            '3' {
                # case for users by username
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
                    switch ($PSCmdlet.ParameterSetName) {
                        'gui' {
                            $result = Deploy-UserCertificate -userObject $UserSelectionArray -prompt
                        }
                        'cli' {
                            $result = Deploy-UserCertificate -userObject $UserSelectionArray -forceInvokeCommands $invokeCommands
                        }
                    }
                    Show-RadiusProgress -completedItems $UserSelectionArray.count -totalItems $UserSelectionArray.Count -ActionText "Distributing Radius Certificates" -previousOperationResult $result
                }
                # return after an action if cli, else stay in function
                switch ($PSCmdlet.ParameterSetName) {
                    'gui' {
                        Show-StatusMessage -Message "Finished Distributing Certificates"
                    }
                    'cli' {
                        return
                    }
                }
            }
        }
    } while ($confirmation -ne 'E')
}