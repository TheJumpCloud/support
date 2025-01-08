Describe 'Generate User Cert Tests' -Tag "GenerateUserCerts" {
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
        Start-GenerateRootCert -certKeyPassword "testCertificate123!@#"
    }
    Context 'Certs forcibly re-generated for all users' {
        It 'Certs re-generated have actually been re-written for all users' {
            # first generate user certs
            Start-GenerateUserCerts -type All -forceReplaceCerts
            # capture the current time and cert times.
            $timeBefore = (Get-Date).ToString('MM/dd/yyyy HH:mm:ss')
            $certsBefore = Get-CertInfo -UserCerts
            # wait one second.
            Start-Sleep 1
            Start-GenerateUserCerts -type All -forceReplaceCerts
            # validate that the commands were created for valid users
            # Get Certs
            $certs = Get-CertInfo -UserCerts
            foreach ($cert in $certs) {
                $matchingBeforeCert = $certsBefore | Where-Object { $username -eq $cert.username }
                # Each cert should have a generated date -gt the $timeBefore
                $cert.generated | Should -BeGreaterThan $timeBefore
                $cert.generated | Should -BeGreaterThan $matchingBeforeCert.generated
                $cert.serial | Should -Not -Be $matchingBeforeCert.serial
                $cert.sha1 | Should -Not -Be $matchingBeforeCert.sha1
            }
        }
    }
    Context 'Certs generated for newly added users' {
        BeforeAll {

        }
        It 'When a new user is added to the radius group, the tool will generate a new cert' {
            # create a new user
            $user = New-RandomUser -Domain "pesterRadius" | New-JCUser
            # add a user to the radius Group
            Add-JCUserGroupMember -GroupID $Global:JCR_USER_GROUP -UserID $user.id
            # Get the certs before
            $certsBefore = Get-ChildItem -Path "$JCScriptRoot/UserCerts"
            # wait one moment
            Start-Sleep 2
            # update the cache
            Get-JCRGlobalVars -force -skipAssociation -associateManually
            # wait just one moment before testing membership since we are writing a file
            Start-Sleep 1
            # the new user should be in the membership list:
            $global:JCRRadiusMembers.username | Should -Contain $user.username
            # Generate the user cert:
            Start-GenerateUserCerts -type ByUsername -username $($user.username) -forceReplaceCerts
            # Get the certs after
            $certsAfter = Get-ChildItem -Path "$JCScriptRoot/UserCerts"
            # filter by username
            $UserCerts = $certsAfter | Where-Object { $_.Name -match "$($user.username)" }
            # the files and each type of expected cert file should exist
            $UserCerts.Name | Should -Match $user.username
            $UserCerts.fullname | Where-Object { $_ -match ".csr" } | Should -Exist
            $UserCerts.fullname | Where-Object { $_ -match ".pfx" } | Should -Exist
            $UserCerts.fullname | Where-Object { $_ -match ".crt" } | Should -Exist
            $UserCerts.fullname | Where-Object { $_ -match ".key" } | Should -Exist
            # cleanup
            Remove-JCUserGroupMember -GroupID $Global:JCR_USER_GROUP -UserID $user.id
            # update cache
            Get-JCRGlobalVars -force -skipAssociation
            # wait just one moment before testing membership since we are writing a file
            Start-Sleep 1
            # the global variables should be cleaned up
            $global:JCRRadiusMembers.username | Should -Not -Contain $user.username
        }

    }
    Context 'Certs generated for users who have certs that are about set to expire soon' {
        BeforeAll {
            # import necessary functions:
            . "$JCScriptRoot/Functions/Private/CertDeployment/Get-CertInfo.ps1"
            . "$JCScriptRoot/Functions/Private/CertDeployment/Get-ExpiringCertInfo.ps1"
            # Set config
            $configPath = "$JCScriptRoot/Config.ps1"
            $content = Get-Content -Path $configPath
            # set the user cert validity to just 10 days
            $content -replace ('\$Global:JCR_USER_CERT_VALIDITY_DAYS = *.+', '$Global:JCR_USER_CERT_VALIDITY_DAYS = 10') | Set-Content -Path $configPath

            # update cache
            Get-JCRGlobalVars -force -skipAssociation

            # get user from membership list
            $RandomUsername = $global:JCRRadiusMembers.username | Get-Random -Count 1

            # regenerate user cert
            Start-GenerateUserCerts -type ByUsername -username $($RandomUsername) -forceReplaceCerts

            # Update Global Expiring list:
            $userCertInfo = Get-CertInfo -UserCerts
            # Determine cut off date for expiring certs
            # Find all certs that will expire between current date and cut off date
            $Global:expiringCerts = Get-ExpiringCertInfo -certInfo $userCertInfo -cutoffDate $Global:JCR_USER_CERT_EXPIRE_WARNING_DAYS

        }
        It 'Certs that are set to expire soon can be updated programmatically' {
            # at this point expiring certs should be populated from beforeAll block
            $Global:expiringCerts | Should -Not -BeNullOrEmpty
            # reset the validity counter
            $content = Get-Content -Path $configPath
            # set the user cert validity to 90 days
            $content -replace ('\$Global:JCR_USER_CERT_VALIDITY_DAYS = *.+', '$Global:JCR_USER_CERT_VALIDITY_DAYS = 90') | Set-Content -Path $configPath
            # Get the certs before generation minus the .zip if it exists
            $certsBefore = Get-ChildItem -Path "$JCScriptRoot/UserCerts" -Filter "$($RandomUsername)*" -Exclude "*.zip"
            # get the date before
            $dateBefore = (Get-Date).ToString('MM/dd/yyyy HH:mm:ss')
            Start-Sleep 1
            # Generate certs for expired users, this should replace any expiring certs
            Start-GenerateUserCerts -type ExpiringSoon -forceReplaceCerts
            # Update Global Expiring list:
            $userCertInfo = Get-CertInfo -UserCerts
            $Global:expiringCerts = Get-ExpiringCertInfo -certInfo $userCertInfo -cutoffDate $Global:JCR_USER_CERT_EXPIRE_WARNING_DAYS
            # there should be no more certs left in the expiring cert var
            $Global:expiringCerts | Should -BeNullOrEmpty
            # Get the certs after generation minus the .zip if it exists
            $certsAfter = Get-ChildItem -Path "$JCScriptRoot/UserCerts" -Filter "$($RandomUsername)*" -Exclude "*.zip"
            # test each file, it should have been written
            foreach ($cert in $certsAfter) {
                Write-Host "$($cert.Name)"
                $beforeWriteTime = (($certsBefore | Where-Object { $_.Name -eq $cert.Name })).LastWriteTime.Ticks
                $afterWriteTime = (($certsAfter | Where-Object { $_.Name -eq $cert.Name })).LastWriteTime.Ticks
                # the time written on the cert should be updated
                $beforeWriteTime | Should -Not -Be $afterWriteTime
            }
            # the user cert table should have been updated too
            $certInfo = Get-CertInfo -UserCerts -username $RandomUsername
            $certInfo.count | Should -Be 1
            $certInfo.generated | Should -BeGreaterThan $dateBefore
        }
        AfterAll {
            # reset the validity counter
            $content = Get-Content -Path $configPath
            # set the user cert validity to 90 days
            $content -replace ('\$Global:JCR_USER_CERT_VALIDITY_DAYS = *.+', '$Global:JCR_USER_CERT_VALIDITY_DAYS = 90') | Set-Content -Path $configPath
        }


    }
    Context 'Certs generated for users with users with localUsernames and special characters' {

        BeforeEach {
            # create a new user
            $user = New-RandomUser -Domain "pesterRadius" | New-JCUser

        }
        It 'A user with a localUsername (SystemUsername) will generate a cert' {
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
            # add a user to the radius Group
            Add-JCUserGroupMember -GroupID $Global:JCR_USER_GROUP -UserID $user.id
            # Get the certs before
            $certsBefore = Get-ChildItem -Path "$JCScriptRoot/UserCerts"
            # wait one moment
            Start-Sleep 2
            # update the cache
            Get-JCRGlobalVars -force -skipAssociation -associateManually
            # wait just one moment before testing membership since we are writing a file
            Start-Sleep 1
            # the new user should be in the membership list:
            $global:JCRRadiusMembers.username | Should -Contain $user.username
            # Generate the user cert:
            Start-GenerateUserCerts -type ByUsername -username $($user.username) -forceReplaceCerts
            # Get the certs after
            $certsAfter = Get-ChildItem -Path "$JCScriptRoot/UserCerts"
            # filter by username
            $UserCerts = $certsAfter | Where-Object { $_.Name -match "$($user.username)" }
            # the files and each type of expected cert file should exist
            # specifically for this test, the username should not be the localUsername (systemUsername)
            $UserCerts.Name | Should -Match $user.username
            $userCerts.Name | Should -Not -Match $response.systemUsername
            $UserCerts.fullname | Where-Object { $_ -match ".csr" } | Should -Exist
            $UserCerts.fullname | Where-Object { $_ -match ".pfx" } | Should -Exist
            $UserCerts.fullname | Where-Object { $_ -match ".crt" } | Should -Exist
            $UserCerts.fullname | Where-Object { $_ -match ".key" } | Should -Exist

        }
        It 'A user with a hyphen in their username will generate a cert' {
            # manually update the user with a hyphen in their username
            $user = Set-JcSdkUser -Id $($user.id) -Username "$($user.username)-$($user.username)"
            # add a user to the radius Group
            Add-JCUserGroupMember -GroupID $Global:JCR_USER_GROUP -UserID $user.id
            # Get the certs before
            $certsBefore = Get-ChildItem -Path "$JCScriptRoot/UserCerts"
            # wait one moment
            Start-Sleep 2
            # update the cache
            Get-JCRGlobalVars -force -skipAssociation -associateManually
            # wait just one moment before testing membership since we are writing a file
            Start-Sleep 1
            # the new user should be in the membership list:
            $global:JCRRadiusMembers.username | Should -Contain $user.username
            # Generate the user cert:
            Start-GenerateUserCerts -type ByUsername -username $($user.username) -forceReplaceCerts
            # Get the certs after
            $certsAfter = Get-ChildItem -Path "$JCScriptRoot/UserCerts"
            # filter by username
            $UserCerts = $certsAfter | Where-Object { $_.Name -match "$($user.username)" }
            # the files and each type of expected cert file should exist
            # specifically for this test, the username should not be the localUsername (systemUsername)
            $UserCerts.Name | Should -Match $user.username
            $UserCerts.fullname | Where-Object { $_ -match ".csr" } | Should -Exist
            $UserCerts.fullname | Where-Object { $_ -match ".pfx" } | Should -Exist
            $UserCerts.fullname | Where-Object { $_ -match ".crt" } | Should -Exist
            $UserCerts.fullname | Where-Object { $_ -match ".key" } | Should -Exist
        }
        AfterEach {
            # cleanup
            Remove-JCUserGroupMember -GroupID $Global:JCR_USER_GROUP -UserID $user.id
            # update cache
            Get-JCRGlobalVars -force -skipAssociation
            # wait just one moment before testing membership since we are writing a file
            Start-Sleep 1
            # the global variables should be cleaned up
            $global:JCRRadiusMembers.username | Should -Not -Contain $user.username

        }

    }
    Context 'Certs generated when userGroup only contains 1 user' {
        BeforeAll {
            # Save users in userGroup to variable for later
            $RadiusMembers = Get-JCUserGroupMember -GroupID $Global:JCR_USER_GROUP

            # Remove all members from UserGroup
            $RadiusMembers | ForEach-Object {
                $userRemoval = Remove-JCUserGroupMember -GroupID $Global:JCR_USER_GROUP -UserID $_.UserID
            }

            # Add One Member back to the Group
            $SingleUser = $RadiusMembers | Select-Object -First 1
            $userAdd = Add-JCUserGroupMember -GroupID $Global:JCR_USER_GROUP -UserID $SingleUser.UserID
        }
        It "When the Radius UserGroup only contains 1 user, the generation functions will not error" {
            # update the cache
            Get-JCRGlobalVars -force -skipAssociation -associateManually

            Start-Sleep 1

            # the updated Radius Members cache should only contain 1 user
            $global:JCRRadiusMembers.username.Count | Should -Be 1

            # the new user should be in the membership list:
            $global:JCRRadiusMembers.username | Should -Contain $SingleUser.username

            # Check for non-terminating errors
            Start-GenerateUserCerts -type ByUsername -username $($SingleUser.username) -forceReplaceCerts -ErrorVariable err
            $err.Count | -Should -Be 0
        }
        AfterAll {
            # Remove the single User
            $userRemoval = Remove-JCUserGroupMember -GroupID $Global:JCR_USER_GROUP -UserID $SingleUser.UserID

            # Add original members back to the UserGroup
            $userAdd = $RadiusMembers | Add-JCUserGroupMember -GroupID $Global:JCR_USER_GROUP -UserID $_.UserID

            # update cache
            Get-JCRGlobalVars -force -skipAssociation
        }
    }
}