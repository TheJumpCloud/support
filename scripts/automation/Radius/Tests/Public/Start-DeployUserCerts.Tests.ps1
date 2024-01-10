Describe 'Distribute User Cert Tests' -Tag 'Distribute' {
    Context 'Distribute all certificates for all users forcibly' {
        BeforeAll {
            # get required functions
            . "$JCScriptRoot/Functions/Private/UserJson/Get-UserJsonData.ps1"
            . "$JCScriptRoot/Functions/Private/CertDeployment/Get-CertInfo.ps1"
            . "$JCScriptRoot/Functions/Private/UserTable/Get-UserFromTable.ps1"

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
        It 'users with system associations will have new commands generated; command will not be invoked' {

        }
        It 'users with out system associations will not have new commands generated' {

        }

    }
    Context 'Distribute new certificates for new users forcibly' {
        it 'a new user with a system association will get a new command and it will be invoked' {

        }
        it 'a new user without a system association will not get a new command and it will not be invoked' {

        }

    }
    Context 'Distribute new certificates for new users without invoking' {
        it 'a new user with a system association will get a new command and it will not be invoked' {

        }
        it 'a new user without a system association will not get a new command and it will not be invoked' {

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