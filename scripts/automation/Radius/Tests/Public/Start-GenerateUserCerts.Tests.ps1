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
                $cert.generated | should -BeGreaterThan $timeBefore
                $cert.generated | should -BeGreaterThan $matchingBeforeCert.generated
                $cert.serial | should -Not -Be $matchingBeforeCert.serial
                $cert.sha1 | should -Not -Be $matchingBeforeCert.sha1
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
            $UserCerts.fullname | where-object { $_ -match ".csr" } | Should -exist
            $UserCerts.fullname | where-object { $_ -match ".pfx" } | Should -exist
            $UserCerts.fullname | where-object { $_ -match ".crt" } | Should -exist
            $UserCerts.fullname | where-object { $_ -match ".key" } | Should -exist
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
            $content = Get-Content -path $configPath
            # set the user cert validity to just 10 days
            $content -replace ('\$Global:JCR_USER_CERT_VALIDITY_DAYS = *.+', '$Global:JCR_USER_CERT_VALIDITY_DAYS = 10') | Set-Content -Path $configPath

            # update cache
            Get-JCRGlobalVars -force -skipAssociation

            # get user from membership list
            $RandomUsername = $global:JCRRadiusMembers.username | Get-Random -count 1

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
            $Global:expiringCerts | Should -not -BeNullOrEmpty
            # reset the validity counter
            $content = Get-Content -path $configPath
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
                $beforeWriteTime | should -Not -Be $afterWriteTime
            }
            # the user cert table should have been updated too
            $certInfo = Get-CertInfo -UserCerts -username $RandomUsername
            $certInfo.count | should -be 1
            $certInfo.generated | Should -BeGreaterThan $dateBefore
        }
        AfterAll {
            # reset the validity counter
            $content = Get-Content -path $configPath
            # set the user cert validity to 90 days
            $content -replace ('\$Global:JCR_USER_CERT_VALIDITY_DAYS = *.+', '$Global:JCR_USER_CERT_VALIDITY_DAYS = 90') | Set-Content -Path $configPath
        }


    }
    Context 'Certs generated for users with users with localUsernames and special characters' {

        BeforeEach {
            # create a new user
            $user = New-RandomUser -Domain "pesterRadius" | New-JCUser

        }
        it 'A user with a localUsername (SystemUsername) will generate a cert' {
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
            $UserCerts.fullname | where-object { $_ -match ".csr" } | Should -exist
            $UserCerts.fullname | where-object { $_ -match ".pfx" } | Should -exist
            $UserCerts.fullname | where-object { $_ -match ".crt" } | Should -exist
            $UserCerts.fullname | where-object { $_ -match ".key" } | Should -exist

        }
        it 'A user with a hyphen in their username will generate a cert' {
            # manually update the user with a hyphen in their username
            $user = Set-JCSdkUser -id $($user.id) -username "$($user.username)-$($user.username)"
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
            $UserCerts.fullname | where-object { $_ -match ".csr" } | Should -exist
            $UserCerts.fullname | where-object { $_ -match ".pfx" } | Should -exist
            $UserCerts.fullname | where-object { $_ -match ".crt" } | Should -exist
            $UserCerts.fullname | where-object { $_ -match ".key" } | Should -exist
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
}