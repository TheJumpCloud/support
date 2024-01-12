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
        . "$PSScriptRoot/../../../../../PowerShell/JumpCloud Module/Tests/HelperFunctions.ps1"
        # Manually update user associations for radius members, cache won't pick them up before:
        foreach ($user in $global:JCRRadiusMembers) {
            Set-JCRAssociationHash -UserID $user.userID
        }

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
                $user.certinfo.deployed | Should -Be $false
            }
            start-deployUserCerts -type All -forceInvokeCommands
            Start-Sleep 1
            $userArray = Get-UserJsonData
            foreach ($user in $userArray) {
                # cert should be deployed
                if ($user.systemAssociations) {
                    $user.certinfo.deployed | Should -Be $true
                }
                $user.commandAssociations | ForEach-Object {
                    $command = Get-JcSdkCommand -Id $_.commandId -Fields name
                    $command | should -Not -BeNullOrEmpty
                }
            }
        }
        it 'users without system associations should not have a deployed cert, even if the force option is specified' {
            $user = New-RandomUser -Domain "pesterRadius" | New-JCUser
            $dateBefore = (Get-Date).ToString('MM/dd/yyyy HH:mm:ss')

            Add-JCUserGroupMember -GroupID $Global:JCUSERGROUP -UserID $user.id

            # update membership
            Get-JCRGlobalVars -skipAssociation -force
            Start-GenerateUserCerts -type ByUsername -username $user.username -forceReplaceCerts

            start-deployUserCerts -type ByUsername -username $user.username -forceInvokeCommands
            $obj, $index = Get-UserFromTable -userid $user.id
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
                $user.certinfo.deployed | Should -Be $false
            }
            start-deployUserCerts -type All
            Start-Sleep 1
            $userArray = Get-UserJsonData
            foreach ($user in $userArray) {
                # cert should be deployed
                if ($user.systemAssociations) {
                    $user.certinfo.deployed | Should -Be $false
                }
                $user.commandAssociations | ForEach-Object {
                    $command = Get-JcSdkCommand -Id $_.commandId -Fields name
                    $command | should -Not -BeNullOrEmpty
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
            Add-JCUserGroupMember -GroupID $Global:JCUSERGROUP -UserID $user.id
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
            start-deployUserCerts -type ByUsername -username $user.username -forceInvokeCommands

            $obj, $index = Get-UserFromTable -userid $user.id
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
            Add-JCUserGroupMember -GroupID $Global:JCUSERGROUP -UserID $user.id
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

            $obj, $index = Get-UserFromTable -userid $user.id
            $obj.certInfo.generated | Should -BeGreaterThan $dateBefore
            $obj.certInfo.deployed | Should -Be $false
            $obj.commandAssociations | should -Not -BeNullOrEmpty
            $obj.systemAssociations | should -Not -BeNullOrEmpty

        }

    }
    Context 'Distribute new certificates for a single user forcibly' {
        it 'a user with system associations receeives a new command is created and deployed' {

        }
        it 'a user without system associations receeives a new command is not created and not deployed' {

        }

    }
    Context 'Distribute new certificates for a single user without invoking' {
        it 'a user with system associations receeives a new command is created and is not deployed' {

        }
        it 'a user without system associations receeives a new command is not created and not deployed' {

        }

    }
}