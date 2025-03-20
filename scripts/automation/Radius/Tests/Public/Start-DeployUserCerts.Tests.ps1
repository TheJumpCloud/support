Describe 'Distribute User Cert Tests' -Tag 'Distribute' {
    BeforeAll {
        # Load all functions from private folders
        $Private = @( Get-ChildItem -Path "$JCScriptRoot/Functions/Private/*.ps1" -Recurse)
        Foreach ($Import in $Private) {
            Try {
                . $Import.FullName
            } Catch {
                Write-Error -Message "Failed to import function $($Import.FullName): $_"
            }
        }
        # import helper functions:
        . "$PSScriptRoot/../HelperFunctions.ps1"
        # Manually update user associations for radius members, cache won't pick them up before:
        foreach ($user in $global:JCRRadiusMembers) {
            Set-JCRAssociationHash -UserID $user.userID
        }
        Get-JCRGlobalVars -Force -associateManually
        Start-GenerateRootCert -certKeyPassword "TestCertificate123!@#" -generateType "new" -force

    }
    Context 'Distribute all certificates for all users forcibly' {
        BeforeAll {
            # clear certs:
            $certs = Get-ChildItem -Path "$JCScriptRoot/UserCerts"
            foreach ($cert in $certs) {
                Remove-Item -Path $cert.FullName
            }
            #remove existing users
            $usersToRemove = Get-JCuser -email "*pesterRadius*" | Remove-JCUser -force
            Get-JCRGlobalVars -force -skipAssociation
        }
        it 'users with system associations will have deployed certs' {

            # generate all new certs
            Start-GenerateUserCerts -type All -forceReplaceCerts
            $userArray = Get-UserJsonData
            foreach ($user in $userArray) {
                # cert should not be deployed
                $user.certInfo.deployed | Should -Be $false
            }
            start-deployUserCerts -type All -forceInvokeCommands
            Start-Sleep 1
            $userArray = Get-UserJsonData
            foreach ($user in $userArray) {
                # cert should be deployed for users that have a system association
                if ($user.systemAssociations) {
                    $user.certInfo.deployed | Should -Be $true
                    $user.commandAssociations | ForEach-Object {
                        $command = Get-JcSdkCommand -Id $_.commandId -Fields name
                        $command | should -Not -BeNullOrEmpty
                    }
                }
            }
        }
        it 'users without system associations should not have a deployed cert, even if the force option is specified' {
            $user = New-RandomUser -Domain "pesterRadius" | New-JCUser
            Write-Warning "$($user.username) created with id: $($user.id))"
            $dateBefore = (Get-Date).ToString('MM/dd/yyyy HH:mm:ss')

            Write-Warning "Add $($user.username) to radius Group with id: $($Global:JCR_USER_GROUP)"
            Add-JCUserGroupMember -GroupID $Global:JCR_USER_GROUP -UserID $user.id
            $userMembers = Get-jcusergroupmember -byid $Global:JCR_USER_GROUP

            foreach ($member in $userMembers) {
                Write-Warning "$($member.username) is in the $($member.GroupName) Group"
            }

            # update membership
            Start-Sleep 1
            Get-JCRGlobalVars -force -associationUsername $user.username
            Start-GenerateUserCerts -type ByUsername -username $user.username -forceReplaceCerts

            start-deployUserCerts -type ByUsername -username $user.username -forceInvokeCommands
            $obj, $index = Get-UserFromTable -userId $user.id
            $obj.certInfo.generated | Should -BeGreaterThan $dateBefore
            $obj.certInfo.deployed | Should -Be $false
            $obj.commandAssociations | should -be $null
            $obj.systemAssociations | should -be $null
            # user should not have a command nor should their certinfo show that the cert was deployed
        }

    }
    Context 'Distribute all certificates for all users without invoking' {
        BeforeAll {
            # clear certs:
            $certs = Get-ChildItem -Path "$JCScriptRoot/UserCerts"
            foreach ($cert in $certs) {
                Remove-Item -Path $cert.FullName
            }
            #remove existing users
            $usersToRemove = Get-JCuser -email "*pesterRadius*" | Remove-JCUser -force
            Get-JCRGlobalVars -force -skipAssociation
        }
        It 'users with system associations will have new commands generated; command will not be invoked' {
            # generate all new certs
            Start-GenerateUserCerts -type All -forceReplaceCerts
            $userArray = Get-UserJsonData
            foreach ($user in $userArray) {
                # cert should not be deployed
                $user.certInfo.deployed | Should -Be $false
            }
            start-deployUserCerts -type All
            Start-Sleep 1
            $userArray = Get-UserJsonData
            foreach ($user in $userArray) {
                # cert should be deployed for users that have a system association
                if ($user.systemAssociations) {
                    $user.certInfo.deployed | Should -Be $false
                    $user.commandAssociations | ForEach-Object {
                        $command = Get-JcSdkCommand -Id $_.commandId -Fields name
                        $command | should -Not -BeNullOrEmpty
                    }
                }
            }
        }
        It 'users with out system associations will not have new commands generated' {

        }

    }
    Context 'Distribute new certificates for new users forcibly' {
        BeforeAll {
            # clear certs:
            $certs = Get-ChildItem -Path "$JCScriptRoot/UserCerts"
            foreach ($cert in $certs) {
                Remove-Item -Path $cert.FullName
            }
            #remove existing users
            $usersToRemove = Get-JCuser -email "*pesterRadius*" | Remove-JCUser -force
            Get-JCRGlobalVars -force -skipAssociation
        }
        it 'a new user with a system association will get a new command and it will be invoked' {
            $user = New-RandomUser -Domain "pesterRadius" | New-JCUser
            $dateBefore = (Get-Date).ToString('MM/dd/yyyy HH:mm:ss')
            # add user to membership group
            Add-JCUserGroupMember -GroupID $Global:JCR_USER_GROUP -UserID $user.id
            # get random system
            $system = Get-JCSystem -os windows | Get-Random -Count 1
            Add-JCSystemUser -UserID $user.id -SystemID $system.id

            # update membership
            Get-JCRGlobalVars -force -associationUsername $user.username

            # wait one second to write to the file
            Start-Sleep 1

            # update the json file
            Update-JCRUsersJson
            # now generate the user certs
            Start-GenerateUserCerts -type ByUsername -username $user.username -forceReplaceCerts
            start-deployUserCerts -type ByUsername -username $user.username -forceInvokeCommands

            $obj, $index = Get-UserFromTable -userId $user.id
            $obj.certInfo.generated | Should -BeGreaterThan $dateBefore
            $obj.certInfo.deployed | Should -Be $true
            $obj.commandAssociations | should -Not -BeNullOrEmpty
            $obj.systemAssociations | should -Not -BeNullOrEmpty
        }
    }
    Context 'Distribute new certificates for new users without invoking' {
        it 'a new user with a system association will get a new command and it will not be invoked' {
            $user = New-RandomUser -Domain "pesterRadius" | New-JCUser
            $dateBefore = (Get-Date).ToString('MM/dd/yyyy HH:mm:ss')
            # add user to membership group
            Add-JCUserGroupMember -GroupID $Global:JCR_USER_GROUP -UserID $user.id
            # get random system
            $system = Get-JCSystem -os windows | Get-Random -Count 1
            Add-JCSystemUser -UserID $user.id -SystemID $system.id

            # update membership
            Get-JCRGlobalVars -skipAssociation -force
            # todo: manually update association table to account for new membership
            Set-JCRAssociationHash -userId $user.id
            Update-JCRUsersJson
            # now generate the user certs
            Start-GenerateUserCerts -type ByUsername -username $user.username -forceReplaceCerts
            start-deployUserCerts -type ByUsername -username $user.username

            $obj, $index = Get-UserFromTable -userId $user.id
            $obj.certInfo.generated | Should -BeGreaterThan $dateBefore
            $obj.certInfo.deployed | Should -Be $false
            $obj.commandAssociations | should -Not -BeNullOrEmpty
            $obj.systemAssociations | should -Not -BeNullOrEmpty

        }

    }
    Context 'Distribute new certificates for a single user forcibly' {
        it 'a user with system associations receives a new command is created and deployed' {

        }
        it 'a user without system associations receives a new command is not created and not deployed' {

        }

    }
    Context 'Distribute new certificates for a single user without invoking' {
        it 'a user with system associations receives a new command is created and is not deployed' {

        }
        it 'a user without system associations receives a new command is not created and not deployed' {

        }

    }
    Context 'Cert Commands are generated for EmailSAN, EmailDN, UsernameCn type certs' {
        BeforeAll {
            # Member content | Get the user with 2 system associations mac and windows
            Get-JCRGlobalVars -force -skipAssociation -associateManually
            $certTypeUser = $Global:JCRRadiusMembers | Get-Random -Count 1
            Write-Warning "begin while loop"
            while ($Global:JCRAssociations[$($certTypeUser.userID)].systemAssociations.count -ne 2) {
                $certTypeUser = $Global:JCRRadiusMembers | Get-Random -Count 1
            }
        }
        It 'EmailSAN certs are created and command generated with correct identifiers' {
            # Set config
            $configPath = "$JCScriptRoot/Config.ps1"
            $content = Get-Content -path $configPath
            # set the user cert validity to just 10 days
            $content -replace ('\$Global:JCR_CERT_TYPE = *.+', '$Global:JCR_CERT_TYPE = "EmailSAN"') | Set-Content -Path $configPath
            # Get Cert Before
            $CertInfoBefore = Get-CertInfo -UserCerts -username $certTypeUser.username
            # Generate the user cert:
            Start-GenerateUserCerts -type ByUsername -username $($certTypeUser.username) -forceReplaceCerts
            # CertInfo After
            $CertInfoAfter = Get-CertInfo -UserCerts -username $certTypeUser.username
            # Cert Subject headers should be contain required EmailSAN identifier:
            $CertInfoBefore.subject | Should -Not -Be $CertInfoAfter
            $foundCert = Get-ChildItem -path "$JCScriptRoot/UserCerts/$($certTypeUser.username)-EmailSAN*.crt"
            $foundCert.count | Should -Be 1
            $CertSANInfo = Invoke-Expression "$JCR_OPENSSL x509 -in $($foundCert.fullname) -ext subjectAltName -noout"
            # The cert info should contain the subject alternative name of the user's email
            $CertSANInfo -match "email:" | Should -match "email:$($Global:JCRUsers[$($certTypeUser.userID)].email)"
            # Create the new commands
            Start-DeployUserCerts -type ByUsername -username $certTypeUser.username
            # Go fetch the mac command for the user
            $macCommand = Get-JCCommand -name "RadiusCert-Install:$($certTypeUser.username):MacOSX"
            $windowsCommand = Get-JCCommand -name "RadiusCert-Install:$($certTypeUser.username):Windows"

            # macCommand should contain SN
            $snPattern = 'currentCertSN=\"(.*)\"'
            $snMacMatch = $macCommand.Command | Select-String -Pattern $snPattern
            $snMacMatch.matches.groups[1].value | Should -Be $CertInfoAfter.serial
            # windows should contain SN
            $snPattern = '\(\$\(\$cert\.serialNumber\) -eq \"(.*)\"\)'
            $snWinMatch = $windowsCommand.Command | Select-String -Pattern $snPattern
            $snWinMatch.matches.groups[1].value | Should -Be $CertInfoAfter.serial
        }
        It 'EmailDN certs are created and command generated with correct identifiers' {
            # Set config
            $configPath = "$JCScriptRoot/Config.ps1"
            $content = Get-Content -path $configPath
            # set the cert type
            $content -replace ('\$Global:JCR_CERT_TYPE = *.+', '$Global:JCR_CERT_TYPE = "EmailDN"') | Set-Content -Path $configPath
            # Get Cert Before
            $CertInfoBefore = Get-CertInfo -UserCerts -username $certTypeUser.username
            # Generate the user cert:
            Start-GenerateUserCerts -type ByUsername -username $($certTypeUser.username) -forceReplaceCerts
            # CertInfo After
            $CertInfoAfter = Get-CertInfo -UserCerts -username $certTypeUser.username
            # Cert Subject headers should be contain required EmailDN identifier:
            $CertInfoBefore.subject | Should -Not -Be $CertInfoAfter
            $CertInfoAfter.subject | Should -Match "$($Global:JCRUsers[$($certTypeUser.userID)].email)"
            # Create the new commands
            Start-DeployUserCerts -type ByUsername -username $certTypeUser.username
            # Go fetch the mac command for the user
            $macCommand = Get-JCCommand -name "RadiusCert-Install:$($certTypeUser.username):MacOSX"
            $windowsCommand = Get-JCCommand -name "RadiusCert-Install:$($certTypeUser.username):Windows"

            # macCommand should contain SN
            $snPattern = 'currentCertSN=\"(.*)\"'
            $snMacMatch = $macCommand.Command | Select-String -Pattern $snPattern
            $snMacMatch.matches.groups[1].value | Should -Be $CertInfoAfter.serial
            # windows should contain SN
            $snPattern = '\(\$\(\$cert\.serialNumber\) -eq \"(.*)\"\)'
            $snWinMatch = $windowsCommand.Command | Select-String -Pattern $snPattern
            $snWinMatch.matches.groups[1].value | Should -Be $CertInfoAfter.serial
        }
        It 'UsernameCn certs are created and command generated with correct identifiers' {
            # Set config
            $configPath = "$JCScriptRoot/Config.ps1"
            $content = Get-Content -path $configPath
            # set the cert type
            $content -replace ('\$Global:JCR_CERT_TYPE = *.+', '$Global:JCR_CERT_TYPE = "UsernameCn"') | Set-Content -Path $configPath
            # Get Cert Before
            $CertInfoBefore = Get-CertInfo -UserCerts -username $certTypeUser.username
            # Generate the user cert:
            Start-GenerateUserCerts -type ByUsername -username $($certTypeUser.username) -forceReplaceCerts
            # CertInfo After
            $CertInfoAfter = Get-CertInfo -UserCerts -username $certTypeUser.username
            # Cert Subject headers should be contain required UsernameCn identifier:
            $CertInfoBefore.subject | Should -Not -Be $CertInfoAfter
            $CertInfoAfter.subject | Should -Match "$($certTypeUser.username)"
            # Create the new commands
            Start-DeployUserCerts -type ByUsername -username $certTypeUser.username
            # Go fetch the mac command for the user
            $macCommand = Get-JCCommand -name "RadiusCert-Install:$($certTypeUser.username):MacOSX"
            $windowsCommand = Get-JCCommand -name "RadiusCert-Install:$($certTypeUser.username):Windows"

            # macCommand should contain SN
            $snPattern = 'currentCertSN=\"(.*)\"'
            $snMacMatch = $macCommand.Command | Select-String -Pattern $snPattern
            $snMacMatch.matches.groups[1].value | Should -Be $CertInfoAfter.serial
            # windows should contain SN
            $snPattern = '\(\$\(\$cert\.serialNumber\) -eq \"(.*)\"\)'
            $snWinMatch = $windowsCommand.Command | Select-String -Pattern $snPattern
            $snWinMatch.matches.groups[1].value | Should -Be $CertInfoAfter.serial

        }
        AfterAll {
            # Set config
            $configPath = "$JCScriptRoot/Config.ps1"
            $content = Get-Content -path $configPath
            # set the cert type
            $content -replace ('\$Global:JCR_CERT_TYPE = *.+', '$Global:JCR_CERT_TYPE = "UsernameCn"') | Set-Content -Path $configPath
        }
    }
    Context 'Duplicate Command / Command Result Tests' {
        BeforeEach {
            # create a user that has both a mac and windows association
            $user = New-RandomUser -Domain "pesterRadius" | New-JCUser
            $dateBefore = (Get-Date).ToString('MM/dd/yyyy HH:mm:ss')
            # add user to membership group
            Add-JCUserGroupMember -GroupID $Global:JCR_USER_GROUP -UserID $user.id
            # get random system
            $windowsSystem = Get-JCSystem -os windows | Get-Random -Count 1
            $macSystem = Get-JCSystem -os "Mac OS X" | Get-Random -Count 1
            Add-JCSystemUser -UserID $user.id -SystemID $windowsSystem.id
            Add-JCSystemUser -UserID $user.id -SystemID $macSystem.id

            # update membership
            Get-JCRGlobalVars -skipAssociation -force
            # todo: manually update association table to account for new membership
            Set-JCRAssociationHash -userId $user.id
            Update-JCRUsersJson

            # Generate a user certificate for the user:
            Start-GenerateUserCerts -type ByUsername -username $user.username

            # Get the SHA1 hash for the user's cert:
            $certData = Get-CertInfo -userCerts -username $user.username

        }
        It 'When a duplicate commands with differing trigger SHA1 hashes exists, the command with the old SHA1 hash should be removed' {
            # Set a different SHA1 value to simulate an older cert command
            $oldSha = "$($certData.sha1)1111"
            # Mock some commands with the trigger to already exist if they do not exist
            $macCommandBody = @{
                Name              = "RadiusCert-Install:$($user.username):MacOSX"
                Command           = "sha1234"
                launchType        = "trigger"
                User              = "000000000000000000000000"
                trigger           = "$($oldSha)"
                commandType       = "mac"
                timeout           = 600
                TimeToLiveSeconds = 864000
            }
            $newMacCommand = New-JcSdkCommand @macCommandBody
            $macCmdBefore = Get-JcSdkCommand -Filter @("trigger:eq:$($oldSha)", "commandType:eq:mac")

            # invoke the commands manually to simulate the command queue containing items:
            Start-JcSdkCommand -Id $macCmdBefore.Id -SystemIds $macSystem.id

            $windowsCommandBody = @{
                Name              = "RadiusCert-Install:$($user.username):Windows"
                Command           = "sha1234"
                launchType        = "trigger"
                User              = "000000000000000000000000"
                trigger           = "$($oldSha)"
                commandType       = "windows"
                timeout           = 600
                TimeToLiveSeconds = 864000
            }
            $newWindowsCommand = New-JcSdkCommand @windowsCommandBody
            $windowsCmdBefore = Get-JcSdkCommand -Filter @("trigger:eq:$($oldSha)", "commandType:eq:windows")

            # invoke the commands manually to simulate the command queue containing items:
            Start-JcSdkCommand -Id $WindowsCmdBefore.Id -SystemIds $windowsSystem.id

            # Get the queued commands:
            $queuedCmdsBefore = Get-QueuedCommandByUser -username $user.username

            # Run Start Deploy User Certs by username
            Start-DeployUserCerts -type ByUsername -username $user.username

            # After running, validate that the commands before execution, no longer exist
            $macCmdAfter = Get-JcSdkCommand -Filter @("trigger:eq:$($certData.sha1)", "commandType:eq:mac")
            $windowsCmdAfter = Get-JcSdkCommand -Filter @("trigger:eq:$($certData.sha1)", "commandType:eq:windows")
            # Get the queued after:
            $queuedCmdsAfter = Get-QueuedCommandByUser -username $user.username
            # test that the commands should not exist:
            $macCmdAfter.id | Should -Not -Contain $macCmdBefore.id
            $windowsCmdAfter.id | Should -Not -Contain $windowsCmdBefore.id
            $macCmdAfter | Should -Not -BeNullOrEmpty
            $windowsCmdAfter | Should -Not -BeNullOrEmpty
            { Get-JcSdkCommand -Id $macCmdBefore.id } | Should -Throw # in other words the command should not exist
            { Get-JcSdkCommand -Id $windowsCmdBefore.id } | Should -Throw # in other words the command should not exist
            # test that the queued commands should not exist:
            $queuedCmdsAfter.id | Should -Not -Contain $queuedCmdsBefore.Id
            $queuedCmdsAfter.id | Should -BeNullOrEmpty
            # user.json should have the newID in command associations.
            $allUserData = Get-UserJsonData
            $testUserData = $allUserData | Where-Object { $_.username -eq $user.username }
            $testUserData.commandAssociations.commandId | Should -Not -Contain $macCmdBefore.id
            $testUserData.commandAssociations.commandId | Should -Not -Contain $windowsCmdBefore.id
        }
        It 'When a single command with the same trigger SHA1 hashes exists, a new cert command should not should be generated' {
            # Mock some commands with the trigger to already exist if they do not exist
            $macCommandBody = @{
                Name              = "RadiusCert-Install:$($user.username):MacOSX"
                Command           = "sha1234"
                launchType        = "trigger"
                User              = "000000000000000000000000"
                trigger           = "$($certData.sha1)"
                commandType       = "mac"
                timeout           = 600
                TimeToLiveSeconds = 864000
            }
            $newMacCommand = New-JcSdkCommand @macCommandBody
            $macCmdBefore = Get-JcSdkCommand -Filter @("trigger:eq:$($certData.sha1)", "commandType:eq:mac")

            # invoke the commands manually to simulate the command queue containing items:
            Start-JcSdkCommand -Id $macCmdBefore.Id -SystemIds $macSystem.id

            $windowsCommandBody = @{
                Name              = "RadiusCert-Install:$($user.username):Windows"
                Command           = "sha1234"
                launchType        = "trigger"
                User              = "000000000000000000000000"
                trigger           = "$($certData.sha1)"
                commandType       = "windows"
                timeout           = 600
                TimeToLiveSeconds = 864000
            }
            $newWindowsCommand = New-JcSdkCommand @windowsCommandBody
            $windowsCmdBefore = Get-JcSdkCommand -Filter @("trigger:eq:$($certData.sha1)", "commandType:eq:windows")

            # invoke the commands manually to simulate the command queue containing items:
            Start-JcSdkCommand -Id $WindowsCmdBefore.Id -SystemIds $windowsSystem.id

            # Get the queued commands:
            $queuedCmdsBefore = Get-QueuedCommandByUser -username $user.username

            # Run Start Deploy User Certs by username
            Start-DeployUserCerts -type ByUsername -username $user.username

            # After running, validate that the commands before execution, no longer exist
            $macCmdAfter = Get-JcSdkCommand -Filter @("trigger:eq:$($certData.sha1)", "commandType:eq:mac")
            $windowsCmdAfter = Get-JcSdkCommand -Filter @("trigger:eq:$($certData.sha1)", "commandType:eq:windows")
            # Get the queued after:
            $queuedCmdsAfter = Get-QueuedCommandByUser -username $user.username
            # test that the commands should not exist:
            $macCmdAfter.id | Should -Contain $macCmdBefore.id
            $windowsCmdAfter.id | Should -Contain $windowsCmdBefore.id
            $macCmdAfter | Should -Not -BeNullOrEmpty
            $windowsCmdAfter | Should -Not -BeNullOrEmpty
            { Get-JcSdkCommand -Id $macCmdBefore.id } | Should -Not -Throw # in other words the command should not exist
            { Get-JcSdkCommand -Id $windowsCmdBefore.id } | Should -Not -Throw # in other words the command should not exist
            # test that the queued commands should not exist:
            $queuedCmdsAfter.id | Should -Not -Contain $queuedCmdsBefore.Id
            $queuedCmdsAfter.id | Should -BeNullOrEmpty
            # user.json should have the newID in command associations.
            $allUserData = Get-UserJsonData
            $testUserData = $allUserData | Where-Object { $_.username -eq $user.username }
            $testUserData.commandAssociations.commandId | Should -Contain $macCmdBefore.id
            $testUserData.commandAssociations.commandId | Should -Contain $windowsCmdBefore.id

        }
        It 'When duplicate commands with the same trigger SHA1 hashes exists, one should be removed, a new command should not be generated' {
            # Mock some commands with the trigger to already exist if they do not exist
            $possibleMacIDs = New-Object System.Collections.ArrayList
            $possibleWindowsIDs = New-Object System.Collections.ArrayList
            # define command body for macOS commands
            $macCommandBody = @{
                Name              = "RadiusCert-Install:$($user.username):MacOSX"
                Command           = "sha1234"
                launchType        = "trigger"
                User              = "000000000000000000000000"
                trigger           = "$($certData.sha1)"
                commandType       = "mac"
                timeout           = 600
                TimeToLiveSeconds = 864000
            }
            # add a mac command to the org using the command body
            $newMacCommand = New-JcSdkCommand @macCommandBody

            # update the command body to differentiate the next command:
            $macCommandBody.Command = "sha12345"

            # add a second mac command to the org using the command body
            $newMacCommand = New-JcSdkCommand @macCommandBody

            # get the commands for the user:
            $macCommandsBefore = Get-JcSdkCommand -Filter @("trigger:eq:$($certData.sha1)", "commandType:eq:mac")

            # for each command
            foreach ($cmd in $macCommandsBefore) {
                # add to the list
                $possibleMacIDs.Add($cmd.id)
            }
            # the number of macOS Commands for this user cert and it's identifying sha should be 2
            $possibleMacIDs.count | Should -Be 2

            # invoke the commands manually to simulate the command queue containing items:
            Start-JcSdkCommand -Id $possibleMacIDs[0] -SystemIds $macSystem.id

            # define windows command body
            $windowsCommandBody = @{
                Name              = "RadiusCert-Install:$($user.username):Windows"
                Command           = "sha1234"
                launchType        = "trigger"
                User              = "000000000000000000000000"
                trigger           = "$($certData.sha1)"
                commandType       = "windows"
                timeout           = 600
                TimeToLiveSeconds = 864000
            }
            # create the first windows command
            $newWindowsCommand = New-JcSdkCommand @windowsCommandBody

            # update the command body to differentiate the next command:
            $windowsCommandBody.Command = "sha12345"

            # create the second windows command
            $newWindowsCommand = New-JcSdkCommand @windowsCommandBody

            $windowsCommandsBefore = Get-JcSdkCommand -Filter @("trigger:eq:$($certData.sha1)", "commandType:eq:windows")

            # for each command
            foreach ($cmd in $windowsCommandsBefore) {
                # add to the list
                $possibleWindowsIDs.Add($cmd.id)
            }
            $possibleWindowsIDs.count | Should -Be 2

            # invoke the commands manually to simulate the command queue containing items:
            Start-JcSdkCommand -Id $possibleWindowsIDs[0] -SystemIds $windowsSystem.id

            # Get the queued commands:
            $queuedCmdsBefore = Get-QueuedCommandByUser -username $user.username

            # Run Start Deploy User Certs by username
            Start-DeployUserCerts -type ByUsername -username $user.username

            # After running, validate that the commands before execution, no longer exist
            $macCmdAfter = Get-JcSdkCommand -Filter @("trigger:eq:$($certData.sha1)", "commandType:eq:mac")
            $windowsCmdAfter = Get-JcSdkCommand -Filter @("trigger:eq:$($certData.sha1)", "commandType:eq:windows")
            # Get the queued after:
            $queuedCmdsAfter = Get-QueuedCommandByUser -username $user.username
            # test that one of the commands should exist:

            # $macCmdBefore.id | Should -BeIn $macCmdAfter.id
            $macCmdAfter.count | Should -Be 1
            $macCmdAfter.id | should -BeIn $possibleMacIDs

            # $windowsCmdBefore.id | Should -BeIn $windowsCmdAfter.id
            $windowsCmdAfter.count | Should -Be 1
            $windowsCmdAfter.id | should -BeIn $possibleWindowsIDs

            # test that the queued commands should not exist:
            $queuedCmdsAfter.id | Should -Not -Contain $queuedCmdsBefore.Id
            $queuedCmdsAfter.id | Should -BeNullOrEmpty
            # user.json should have the newID in command associations.
            $allUserData = Get-UserJsonData
            $testUserData = $allUserData | Where-Object { $_.username -eq $user.username }

            $testUserData.commandAssociations.commandId | Should -Contain $windowsCmdAfter.id
            $testUserData.commandAssociations.commandId | Should -Contain $macCmdAfter.id
        }
        It "When the commands are generated the names of the command should match the predetermined naming structure" {
            # Run Start Deploy User Certs by username
            Start-DeployUserCerts -type ByUsername -username $user.username

            $macCommand = Get-JcSdkCommand -Filter @("trigger:eq:$($($certData.sha1))", "commandType:eq:mac")
            $windowsCommand = Get-JcSdkCommand -Filter @("trigger:eq:$($($certData.sha1))", "commandType:eq:windows")

            # macCommand name should be set correctly
            $macCommand.Name | Should -Match "RadiusCert-Install:$($user.username):MacOSX"
            # windowsCommand name should be set correctly
            $windowsCommand.Name | Should -Match "RadiusCert-Install:$($user.username):Windows"

            # validate that the command names are recorded correctly in the users.json file
            $userData = Get-UserFromTable -username $user.username
            $userData.commandAssociations.commandName | Should -Contain "RadiusCert-Install:$($user.username):MacOSX"
            $userData.commandAssociations.commandName | Should -Contain "RadiusCert-Install:$($user.username):Windows"
        }
    }
    Context 'Force Generate Certificate Tests' {
        BeforeEach {
            # create a user that has both a mac and windows association
            $user = New-RandomUser -Domain "pesterRadius" | New-JCUser
            $dateBefore = (Get-Date).ToString('MM/dd/yyyy HH:mm:ss')
            # add user to membership group
            Add-JCUserGroupMember -GroupID $Global:JCR_USER_GROUP -UserID $user.id
            # get random system
            $windowsSystem = Get-JCSystem -os windows | Get-Random -Count 1
            $macSystem = Get-JCSystem -os "Mac OS X" | Get-Random -Count 1
            Add-JCSystemUser -UserID $user.id -SystemID $windowsSystem.id
            Add-JCSystemUser -UserID $user.id -SystemID $macSystem.id

            # update membership
            Get-JCRGlobalVars -skipAssociation -force
            # todo: manually update association table to account for new membership
            Set-JCRAssociationHash -userId $user.id
            Update-JCRUsersJson

            # Generate a user certificate for the user:
            Start-GenerateUserCerts -type ByUsername -username $user.username

            # Get the SHA1 hash for the user's cert:
            $certData = Get-CertInfo -userCerts -username $user.username

            # Mock some commands with the trigger to already exist if they do not exist
            $macCommandBody = @{
                Name              = "RadiusCert-Install:$($user.username):MacOSX"
                Command           = "sha1234"
                launchType        = "trigger"
                User              = "000000000000000000000000"
                trigger           = "$($certData.sha1)"
                commandType       = "mac"
                timeout           = 600
                TimeToLiveSeconds = 864000
            }
            $newMacCommand = New-JcSdkCommand @macCommandBody
            $macCmdBefore = Get-JcSdkCommand -Filter @("trigger:eq:$($certData.sha1)", "commandType:eq:mac")

            # invoke the commands manually to simulate the command queue containing items:
            Start-JcSdkCommand -Id $macCmdBefore.Id -SystemIds $macSystem.id

            $windowsCommandBody = @{
                Name              = "RadiusCert-Install:$($user.username):Windows"
                Command           = "sha1234"
                launchType        = "trigger"
                User              = "000000000000000000000000"
                trigger           = "$($certData.sha1)"
                commandType       = "windows"
                timeout           = 600
                TimeToLiveSeconds = 864000
            }
            $newWindowsCommand = New-JcSdkCommand @windowsCommandBody
            $windowsCmdBefore = Get-JcSdkCommand -Filter @("trigger:eq:$($certData.sha1)", "commandType:eq:windows")

            # invoke the commands manually to simulate the command queue containing items:
            Start-JcSdkCommand -Id $WindowsCmdBefore.Id -SystemIds $windowsSystem.id

            # Get the queued commands:
            $queuedCmdsBefore = Get-QueuedCommandByUser -username $user.username

        }
        It 'When forceGenerate switch is specified, the existing commands & queued commands should be removed' {
            # Run Start Deploy User Certs by username
            Start-DeployUserCerts -type ByUsername -username $user.username -forceGenerateCommands

            # After running, validate that the commands before execution, no longer exist
            $macCmdAfter = Get-JcSdkCommand -Filter @("trigger:eq:$($certData.sha1)", "commandType:eq:mac")
            $windowsCmdAfter = Get-JcSdkCommand -Filter @("trigger:eq:$($certData.sha1)", "commandType:eq:windows")
            # Get the queued after:
            $queuedCmdsAfter = Get-QueuedCommandByUser -username $user.username
            # test that the commands should not exist:
            $macCmdAfter.id | Should -Not -Contain $macCmdBefore.id
            $windowsCmdAfter.id | Should -Not -Contain $windowsCmdBefore.id
            $macCmdAfter | Should -Not -BeNullOrEmpty
            $windowsCmdAfter | Should -Not -BeNullOrEmpty
            { Get-JcSdkCommand -Id $macCmdBefore.id } | Should -Throw # in other words the command should not exist
            { Get-JcSdkCommand -Id $windowsCmdBefore.id } | Should -Throw # in other words the command should not exist
            # test that the queued commands should not exist:
            $queuedCmdsAfter.id | Should -Not -Contain $queuedCmdsBefore.Id
            $queuedCmdsAfter.id | Should -BeNullOrEmpty
            # user.json should have the newID in command associations.
            $allUserData = Get-UserJsonData
            $testUserData = $allUserData | Where-Object { $_.username -eq $user.username }
            $testUserData.commandAssociations.commandId | Should -Not -Contain $macCmdBefore.id
            $testUserData.commandAssociations.commandId | Should -Not -Contain $windowsCmdBefore.id
        }
        It 'When forceGenerate & forceInvoke switches are specified, the existing commands & queued commands should be removed; new commands queues should be queued' {
            # Run Start Deploy User Certs by username
            Start-DeployUserCerts -type ByUsername -username $user.username -forceGenerateCommands -forceInvokeCommands

            # After running, validate that the commands before execution, no longer exist
            $macCmdAfter = Get-JcSdkCommand -Filter @("trigger:eq:$($certData.sha1)", "commandType:eq:mac")
            $windowsCmdAfter = Get-JcSdkCommand -Filter @("trigger:eq:$($certData.sha1)", "commandType:eq:windows")
            # Get the queued after:
            $queuedCmdsAfter = Get-QueuedCommandByUser -username $user.username
            # test that the commands should not exist:
            $macCmdAfter.id | Should -Not -Contain $macCmdBefore.id
            $windowsCmdAfter.id | Should -Not -Contain $windowsCmdBefore.id
            $macCmdAfter | Should -Not -BeNullOrEmpty
            $windowsCmdAfter | Should -Not -BeNullOrEmpty
            { Get-JcSdkCommand -Id $macCmdBefore.id } | Should -Throw # in other words the command should not exist
            { Get-JcSdkCommand -Id $windowsCmdBefore.id } | Should -Throw # in other words the command should not exist
            # test that the queued commands should not exist:
            $queuedCmdsAfter.id | Should -Not -Contain $queuedCmdsBefore.Id
            $queuedCmdsAfter.id | Should -Not -BeNullOrEmpty
            # user.json should have the newID in command associations.
            $allUserData = Get-UserJsonData
            $testUserData = $allUserData | Where-Object { $_.username -eq $user.username }
            $testUserData.commandAssociations.commandId | Should -Not -Contain $macCmdBefore.id
            $testUserData.commandAssociations.commandId | Should -Not -Contain $windowsCmdBefore.id
        }
    }
    context 'Deploy by all' {
        It "deploys user certs by all" {
            Start-DeployUserCerts -type "All" -forceGenerateCommands -forceInvokeCommands
            $allUserDataBefore = Get-UserJsonData
            Start-Sleep 5
            Start-DeployUserCerts -type "All" -forceGenerateCommands -forceInvokeCommands
            $allUserDataAfter = Get-UserJsonData

            foreach ($user in $allUserDataBefore) {
                if ($user.certInfo.deploymentDate) {
                    $user.certInfo.deploymentDate | Should -BeLessThan ($allUserDataAfter | Where-Object { $_.userName -eq $user.UserName }).certInfo.deploymentDate
                }
            }
        }

    }
    Context "Certs generated for users with users with localUsernames and special characters" {

        It "Generates a command for a user with a localUsername (systemUsername)" {
            # create a user that has both a mac and windows association
            $user = New-RandomUser -Domain "pesterRadius" | New-JCUser
            # manually set the user
            $headers = @{
                "x-api-key"    = "$env:JCApiKey"
                "content-type" = "application/json"
            }
            # set a unique systemUsername for the user
            $body = @{
                'systemUsername' = "$($user.username)$($user.unix_guid)"
            } | ConvertTo-Json
            # update the user
            $response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/systemusers/$($user.id)" -Method PUT -Headers $headers -ContentType 'application/json' -Body $body
            # get the before date
            $dateBefore = (Get-Date).ToString('MM/dd/yyyy HH:mm:ss')
            # add user to membership group
            Add-JCUserGroupMember -GroupID $Global:JCR_USER_GROUP -UserID $user.id
            # get random system
            $windowsSystem = Get-JCSystem -os windows | Get-Random -Count 1
            $macSystem = Get-JCSystem -os "Mac OS X" | Get-Random -Count 1
            # associate the system
            Add-JCSystemUser -UserID $user.id -SystemID $windowsSystem.id
            Add-JCSystemUser -UserID $user.id -SystemID $macSystem.id


            # update membership
            Get-JCRGlobalVars -skipAssociation -force
            # todo: manually update association table to account for new membership
            Set-JCRAssociationHash -userId $user.id
            Update-JCRUsersJson

            # Generate a user certificate for the user:
            Start-GenerateUserCerts -type ByUsername -username $user.username

            # Get the SHA1 hash for the user's cert:
            $certData = Get-CertInfo -userCerts -username $user.username

            # Run Start Deploy User Certs by username
            Start-DeployUserCerts -type ByUsername -username $user.username

            # get the commands
            $windowsCmdAfter = Get-JcSdkCommand -Filter @("trigger:eq:$($certData.sha1)", "commandType:eq:windows")
            $macCmdAfter = Get-JcSdkCommand -Filter @("trigger:eq:$($certData.sha1)", "commandType:eq:mac")
            # validate that the correct local user name is found in the command body:
            $macCmdAfter.command | Should -Match "userCompare=`"$($response.systemUsername)`""
            $windowsCmdAfter.command | Should -Match "-eq `"$($response.systemUsername)`""

        }
        It "Generates a command for a user with a hyphen in their username" {
            # create a user that has both a mac and windows association
            $user = New-RandomUser -Domain "pesterRadius" | New-JCUser
            # manually update the user with a hyphen in their username
            $user = Set-JCSdkUser -id $($user.id) -username "$($user.username)-$($user.username)"
            # get the before date
            $dateBefore = (Get-Date).ToString('MM/dd/yyyy HH:mm:ss')
            # add user to membership group
            Add-JCUserGroupMember -GroupID $Global:JCR_USER_GROUP -UserID $user.id
            # get random system
            $windowsSystem = Get-JCSystem -os windows | Get-Random -Count 1
            $macSystem = Get-JCSystem -os "Mac OS X" | Get-Random -Count 1
            # associate the system
            Add-JCSystemUser -UserID $user.id -SystemID $windowsSystem.id
            Add-JCSystemUser -UserID $user.id -SystemID $macSystem.id

            # update membership
            Get-JCRGlobalVars -skipAssociation -force
            # todo: manually update association table to account for new membership
            Set-JCRAssociationHash -userId $user.id
            Update-JCRUsersJson

            # Generate a user certificate for the user:
            Start-GenerateUserCerts -type ByUsername -username $user.username

            # Get the SHA1 hash for the user's cert:
            $certData = Get-CertInfo -userCerts -username $user.username

            # Run Start Deploy User Certs by username
            Start-DeployUserCerts -type ByUsername -username $user.username

            # get the commands
            $windowsCmdAfter = Get-JcSdkCommand -Filter @("trigger:eq:$($certData.sha1)", "commandType:eq:windows")
            $macCmdAfter = Get-JcSdkCommand -Filter @("trigger:eq:$($certData.sha1)", "commandType:eq:mac")
            # validate that the correct local user name is found in the command body:
            $macCmdAfter.command | Should -Match "userCompare=`"$($user.username)`""
            $windowsCmdAfter.command | Should -Match "-eq `"$($user.username)`""
        }
    }
}