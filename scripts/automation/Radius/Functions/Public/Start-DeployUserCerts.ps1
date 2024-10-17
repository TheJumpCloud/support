
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
        $forceInvokeCommands,
        # Force invoke commands after generation
        [Parameter(HelpMessage = 'Switch to force generate new commands on systems', ParameterSetName = 'cli')]
        [switch]
        $forceGenerateCommands
    )

    # Import the users.json file and convert to PSObject
    $userArray = Get-UserJsonData
    # identify users that need their certs still deployed
    $usersWithoutLatestCert = Get-UsersThatNeedCertWork -userData $userArray

    do {
        switch ($PSCmdlet.ParameterSetName) {
            'gui' {
                Show-DistributionMenu -CertObjectArray $userArray.certInfo -usersThatNeedCert $usersWithoutLatestCert.count -totalUserCount $userArray.count
                $confirmation = Read-Host "Please make a selection"

                # This can be updated later if necessary but for now if using the GUI, the $forceGenerateCommands switch will always be false
                # Thus the GUI will never overwrite commands unless the SHA1 value does not match the local cert SHA1
                switch ($forceGenerateCommands) {
                    $true {
                        $generateCommands = $true
                    }
                    $false {
                        $generateCommands = $false
                    }
                }
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
                switch ($forceGenerateCommands) {
                    $true {
                        $generateCommands = $true
                    }
                    $false {
                        $generateCommands = $false
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

                # set thread safe variables:
                $resultArray = [System.Collections.Concurrent.ConcurrentBag[object]]::new()
                $workDoneArray = [System.Collections.Concurrent.ConcurrentBag[object]]::new()

                $userArray| Foreach-Object -ThrottleLimit 5 -Parallel {
                    # set the required variables
                    $JCAPIKEY = $using:JCAPIKEY
                    $JCORGID = $using:JCORGID
                    $JCScriptRoot = $using:JCScriptRoot

                    # set the required global variables
                    $Global:JCRUsers = $using:JCRUsers
                    $Global:JCRSystems = $using:JCRSystems
                    $Global:JCRAssociations = $using:JCRAssociations
                    $Global:JCRRadiusMembers = $using:JCRRadiusMembers
                    $Global:JCRCertHash = $using:JCRCertHash

                    # set the thread safe variables
                    $resultArray = $using:resultArray
                    $workDoneArray = $using:workDoneArray

                    # import the private functions:
                    $Private = @( Get-ChildItem -Path "$JCScriptRoot/Functions/Private/*.ps1" -Recurse)
                    Foreach ($Import in $Private) {
                        Try {
                            . $Import.FullName
                        } Catch {
                            Write-Error -Message "Failed to import function $($Import.FullName): $_"
                        }
                    }

                    # deploy user certs:
                    $result, $workDone = Deploy-UserCertificate -userObject $_ -forceInvokeCommands $using:invokeCommands -forceGenerateCommands $using:generateCommands
                    # keep track of results & work done
                    $resultArray.Add($result)
                    $WorkDoneArray.Add($workDone)

                }

                # update the userTable:
                foreach ($item in $workDoneArray) {
                    Set-UserTable -index $item.userIndex -commandAssociationsObject $item.commandAssociationsObject -certInfoObject $item.certInfoObject
                }

                # print the progress:
                $resultCount = $resultArray.Count
                $resultItemCount = 1
                foreach ($item in $resultArray) {
                    Show-RadiusProgress -completedItems ($resultItemCount) -totalItems $resultArray.Count -ActionText "Distributing Radius Certificates" -previousOperationResult $item
                    $resultItemCount++
                }

                # for ($i = 0; $i -lt $userArray.Count; $i++) {
                #     $result, $workDone = Deploy-UserCertificate -userObject $userArray[$i] -forceInvokeCommands $invokeCommands -forceGenerateCommands $generateCommands
                #     # update user json
                #     Set-UserTable -index $workDone.userIndex -commandAssociationsObject $workDone.commandAssociationsObject -certInfoObject $workDone.certInfoObject

                #     # show progress
                #     Show-RadiusProgress -completedItems ($i + 1) -totalItems $userArray.Count -ActionText "Distributing Radius Certificates" -previousOperationResult $result
                # }
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
                if (-Not $usersWithoutLatestCert) {
                    $usersWithoutLatestCert = Get-UsersThatNeedCertWork -userData $userArray
                }

                # set thread safe variables:
                $resultArray = [System.Collections.Concurrent.ConcurrentBag[object]]::new()
                $workDoneArray = [System.Collections.Concurrent.ConcurrentBag[object]]::new()
                # foreach user:
                $usersWithoutLatestCert | Foreach-Object -ThrottleLimit 5 -Parallel {
                    # set the required variables
                    $JCAPIKEY = $using:JCAPIKEY
                    $JCORGID = $using:JCORGID
                    $JCScriptRoot = $using:JCScriptRoot

                    # set the required global variables
                    $Global:JCRUsers = $using:JCRUsers
                    $Global:JCRSystems = $using:JCRSystems
                    $Global:JCRAssociations = $using:JCRAssociations
                    $Global:JCRRadiusMembers = $using:JCRRadiusMembers
                    $Global:JCRCertHash = $using:JCRCertHash

                    # set the thread safe variables
                    $resultArray = $using:resultArray
                    $workDoneArray = $using:workDoneArray

                    # import the private functions:
                    $Private = @( Get-ChildItem -Path "$JCScriptRoot/Functions/Private/*.ps1" -Recurse)
                    Foreach ($Import in $Private) {
                        Try {
                            . $Import.FullName
                        } Catch {
                            Write-Error -Message "Failed to import function $($Import.FullName): $_"
                        }
                    }

                    # deploy user certs:
                    $result, $workDone = Deploy-UserCertificate -userObject $_ -forceInvokeCommands $using:invokeCommands -forceGenerateCommands $using:generateCommands
                    # keep track of results & work done
                    $resultArray.Add($result)
                    $WorkDoneArray.Add($workDone)
                }

                # update the userTable:
                foreach ($item in $workDoneArray) {
                    Set-UserTable -index $item.userIndex -commandAssociationsObject $item.commandAssociationsObject -certInfoObject $item.certInfoObject
                }

                # print the progress:
                $resultCount = $resultArray.Count
                $resultItemCount = 1
                foreach ($item in $resultArray) {
                    Show-RadiusProgress -completedItems ($resultItemCount) -totalItems $resultArray.Count -ActionText "Distributing Radius Certificates" -previousOperationResult $item
                    $resultItemCount++
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
                    $userObject, $userIndex = Get-UserFromTable -userID $confirmUser.id
                    # Add user to a list for processing
                    $UserSelectionArray = $userArray[$userIndex]
                    # Process existing commands/ Generate new commands/ Deploy new Certificate
                    switch ($PSCmdlet.ParameterSetName) {
                        'gui' {
                            $result, $workDone = Deploy-UserCertificate -userObject $UserSelectionArray -prompt
                        }
                        'cli' {
                            $result, $workDone = Deploy-UserCertificate -userObject $UserSelectionArray -forceInvokeCommands $invokeCommands -forceGenerateCommands $generateCommands
                        }
                    }
                    # update user json
                    Set-UserTable -index $workDone.userIndex -commandAssociationsObject $workDone.commandAssociationsObject -certInfoObject $workDone.certInfoObject

                    # show progress
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