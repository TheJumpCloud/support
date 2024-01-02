# Import Global Config:
. "$JCScriptRoot/config.ps1"
Connect-JCOnline $JCAPIKEY -force

################################################################################
# Do not modify below
################################################################################

# Import the functions
# Import-Module "$JCScriptRoot/Functions/JCRadiusCertDeployment.psm1" -DisableNameChecking -Force

# Import the users.json file and convert to PSObject
$userArray = Get-Content -Raw -Path "$JCScriptRoot/users.json" | ConvertFrom-Json -Depth 10

# TODO: surface this information
# Check to see if previous commands exist
$SearchFilter = @{
    searchTerm = "RadiusCert-Install:"
    fields     = @('name')
}
$RadiusCertCommands = Search-JcSdkCommand -SearchFilter $SearchFilter -Fields name
# $RadiusCertCommands = Get-JCCommand -returnProperties name | Where-Object { $_.Name -like 'RadiusCert-Install*' }
# Split out the username from the commands so we can tell which users do not have a command already
$RadiusCertCommandList = New-Object System.Collections.ArrayList
foreach ($command in $RadiusCertCommands) {
    $commandSplit = $command.name.split(':')
    $RadiusCertCommandList.Add([PSCustomObject]@{
            CommandName = $command.name
            Username    = $commandSplit[1]
            CommandID   = $command._id
        }) | Out-Null
}
$existingCommandUsers = $RadiusCertCommandList.Username | Get-Unique
$newRadiusUsers = (Compare-Object $userarray.username $existingCommandUsers).InputObject

# TODO: revamp with menu screen
# TODO: generate new commands for a single user
# TODO: why this if statement here:
if ($RadiusCertCommands.Count -ge 1) {
    Write-Host "[status] $([char]0x1b)[96mRadiusCert commands detected, please make a selection."
    Write-Host "1: Press '1' to generate new commands for ALL users. $([char]0x1b)[96mNOTE: This will remove any previously generated Radius User Certificate Commands titled 'RadiusCert-Install:*'"
    Write-Host "2: Press '2' to generate new commands for NEW RADIUS users. $([char]0x1b)[96mNOTE: This will only generate commands for users who did not have a cert previously"
    Write-Host "3: Press '3' to generate new commands for ONE Specific RADIUS user."
    Write-Host "E: Press 'E' to exit."
    do {
        $confirmation = Read-Host "Please make a selection"

        switch ($confirmation) {
            '1' {
                # Get queued commands
                $queuedCommands = Get-JCQueuedCommands
                # Clear any queued commands for old RadiusCert commands
                foreach ($command in $RadiusCertCommands) {
                    if ($command._id -in $queuedCommands.command) {
                        $queuedCommandInfo = $queuedCommands | Where-Object command -EQ $command._id
                        Clear-JCQueuedCommand -workflowId $queuedCommandInfo.id
                    }
                }
                Write-Host "[status] Removing $($RadiusCertCommands.Count) commands"
                # Delete previous commands
                $RadiusCertCommands | Remove-JCCommand -force | Out-Null
                # Clean up users.json array
                $userArray | ForEach-Object { $_.commandAssociations = @() }
                $confirmation = 'E'
            }
            '2' {
                If ($newRadiusUsers) {
                    $UserSelectionArray = foreach ($user in $newRadiusUsers) {
                        $userArray | where-Object { $_.username -eq $user }
                    }
                }
                # $userArray
                Write-Host "[status] Proceeding with execution"
                $confirmation = 'E'
            }
            '3' {
                try {
                    Clear-Variable -Name "ConfirmUser" -ErrorAction Ignore
                } catch {
                    New-Variable -Name "ConfirmUser" -Value $null
                }
                while (-not $confirmUser) {
                    # TODO: Offer option to go back a step and exit the while loop
                    $confirmationUser = Read-Host "Enter the Username or UserID of the user"
                    $confirmUser = Test-UserFromHash -username $confirmationUser -debug
                }

                # Get the userobject + index from users.json
                $userObject, $userIndex = Get-UserFromTable -jsonFilePath "$JCScriptRoot/users.json" -userID $confirmUser.id
                # $userArrayIndex = $userArray.username.IndexOf($confirmUser.username)
                $UserSelectionArray = $userArray[$userIndex]
                # # $UserSelectionArray = $userArray | where-Object { $_.username -eq $confirmUser.username }
                # # Get queued commands
                # $queuedCommands = Get-JCQueuedCommands | Where-Object { $_.name -match $confirmUser.username }
                # # Clear any queued commands for old RadiusCert commands
                # foreach ($command in $RadiusCertCommands) {
                #     if ($command._id -in $queuedCommands.command) {
                #         $queuedCommandInfo = $queuedCommands | Where-Object command -EQ $command._id
                #         Clear-JCQueuedCommand -workflowId $queuedCommandInfo.id
                #     }
                # }
                # $RadiusCertCommands = $RadiusCertCommands | Where-Object { $_.name -match $confirmUser.username }
                # Write-Host "[status] Removing $($RadiusCertCommands.Count) commands"
                # # Delete previous commands
                # $RadiusCertCommands | Remove-JCCommand -force | Out-Null
                # # Clean up users.json array
                # $UserSelectionArray | ForEach-Object { $_.commandAssociations = @() }
                Deploy-UserCertificate -userObject $UserSelectionArray
            }
        }
    } while ($confirmation -ne 'E')
}

# Create commands for each user
# foreach ($user in $UserSelectionArray) {

#     #### Begin removal of queued commands + existing command:
#     # TODO: get existing command for the user + remove
#     Write-Warning "clearing existing commands for $($user.username)"
#     $radiusCommandsByUser = Get-CommandByUsername -username $user.username
#     foreach ($command in $radiusCommandsByUser) {
#         Remove-JcSdkCommand -Id $command.id | Out-Null
#     }
#     Write-Warning "clearing queued commands for $($user.username)"
#     # TODO: get queued command for the user + remove
#     $queuedRadiusCommandsByUser = Get-queuedCommandByUser -username $user.username
#     foreach ($queuedCommand in $queuedRadiusCommandsByUser) {
#         Clear-JCQueuedCommand -workflowId $queuedCommand.id | Out-Null
#     }
#     # now clear out the user command associations from users.json
#     $User.commandAssociations = @()
#     #### End removal of queued commands + existing command
#     Write-Warning "PROCESSING:"
#     $user
#     Write-Warning "..."
#     # Get certificate and zip to upload to Commands
#     $userCertFiles = Get-ChildItem -Path "$JCScriptRoot/UserCerts" -Filter "$($user.userName)-*"
#     # set crt and pfx filepaths
#     $userCrt = ($userCertFiles | Where-Object { $_.Name -match "crt" }).FullName
#     $userPfx = ($userCertFiles | Where-Object { $_.Name -match "pfx" }).FullName
#     # define .zip name
#     $userPfxZip = "$JCScriptRoot/UserCerts/$($user.userName)-client-signed.zip"
#     # get certInfo for commands:
#     $certInfo = Get-CertInfo -UserCerts -username $user.username

#     # $certInfo = Invoke-Expression "$opensslBinary x509 -in $($userCrt) -enddate -serial -subject -issuer -noout"
#     # $certHash = @{}
#     # $certInfo | ForEach-Object {
#     #     $property = $_ | ConvertFrom-StringData
#     #     $certHash += $property
#     # }
#     switch ($certType) {
#         'EmailSAN' {
#             # set cert identifier to SAN email of cert
#             $sanID = Invoke-Expression "$opensslBinary x509 -in $($userCrt) -ext subjectAltName -noout"
#             $regex = 'email:(.*?)$'
#             $subjMatch = Select-String -InputObject "$($sanID)" -Pattern $regex
#             $certIdentifier = $subjMatch.matches.Groups[1].value
#             # in macOS search user certs by email
#             $macCertSearch = 'e'
#         }
#         'EmailDN' {
#             # Else set cert identifier to email of cert subject
#             $regex = 'emailAddress = (.*?)$'
#             $subjMatch = Select-String -InputObject "$($certHash.Subject)" -Pattern $regex
#             $certIdentifier = $subjMatch.matches.Groups[1].value
#             # in macOS search user certs by email
#             $macCertSearch = 'e'
#         }
#         'UsernameCn' {
#             # if username just set cert identifier to username
#             $certIdentifier = $($user.userName)
#             # in macOS search user certs by common name (username)
#             $macCertSearch = 'c'
#         }
#     }
#     # Create the zip
#     Compress-Archive -Path $userPfx -DestinationPath $userPfxZip -CompressionLevel NoCompression -Force
#     # Find OS of System
#     switch ($user.systemAssociations.device_os) {
#         'macOS' {
#             # Get the macOS system ids
#             $systemIds = $user.systemAssociations | Where-Object { $_.osFamily -eq 'macOS' } | Select-Object systemId

#             # Check to see if previous commands exist
#             $Command = Get-JCCommand -name "RadiusCert-Install:$($user.userName):MacOSX"

#             if ($Command.Count -ge 1) {
#                 $confirmation = Write-Host "[status] RadiusCert-Install:$($user.userName):MacOSX command already exists, skipping..."
#                 continue
#             }

#             # Create new Command and upload the signed pfx
#             try {
#                 $CommandBody = @{
#                     Name              = "RadiusCert-Install:$($user.userName):MacOSX"
#                     Command           = @"
# unzip -o /tmp/$($user.userName)-client-signed.zip -d /tmp
# chmod 755 /tmp/$($user.userName)-client-signed.pfx
# currentUser=`$(/usr/bin/stat -f%Su /dev/console)
# currentUserUID=`$(id -u "`$currentUser")
# currentCertSN="$($certHash.serial)"
# networkSsid="$($NETWORKSSID)"
# # store orig case match value
# caseMatchOrigValue=`$(shopt -p nocasematch; true)
# # set to case-insensitive
# shopt -s nocasematch
# userCompare="$($user.localUsername)"
# if [[ "`$currentUser" ==  "`$userCompare" ]]; then
#     # restore case match type
#     `$caseMatchOrigValue
#     certs=`$(security find-certificate -a -$($macCertSearch) "$($certIdentifier)" -Z /Users/$($user.localUsername)/Library/Keychains/login.keychain)
#     regexSHA='SHA-1 hash: ([0-9A-F]{5,40})'
#     regexSN='"snbr"<blob>=0x([0-9A-F]{5,40})'
#     global_rematch() {
#         # Set local variables
#         local s=`$1 regex=`$2
#         # While string matches regex expression
#         while [[ `$s =~ `$regex ]]; do
#             # Echo out the match
#             echo "`${BASH_REMATCH[1]}"
#             # Remove the string
#             s=`${s#*"`${BASH_REMATCH[1]}"}
#         done
#     }
#     # Save results
#     # Get Text Results
#     textSHA=`$(global_rematch "`$certs" "`$regexSHA")
#     # Set as array for SHA results
#     arraySHA=(`$textSHA)
#     # Get Text Results
#     textSN=`$(global_rematch "`$certs" "`$regexSN")
#     # Set as array for SN results
#     arraySN=(`$textSN)
#     # set import var
#     import=true
#     if [[ `${#arraySN[@]} == `${#arraySHA[@]} ]]; then
#         len=`${#arraySN[@]}
#         for (( i=0; i<`$len; i++ )); do
#             if [[ `$currentCertSN == `${arraySN[`$i]} ]]; then
#                 echo "Found Cert: SN: `${arraySN[`$i]} SHA: `${arraySHA[`$i]}"
#                 installedCertSN=`${arraySN[`$i]}
#                 installedCertSHA=`${arraySHA[`$i]}
#                 # if cert is installed, no need to update
#                 import=false
#             else
#                 echo "Removing previously installed radius cert:"
#                 echo "SN: `${arraySN[`$i]} SHA: `${arraySHA[`$i]}"
#                 security delete-certificate -Z "`${arraySHA[`$i]}" /Users/$($user.localUsername)/Library/Keychains/login.keychain
#             fi
#         done

#     else
#         echo "array length mismatch, will not delete old certs"
#     fi

#     if [[ `$import == true ]]; then
#         /bin/launchctl asuser "`$currentUserUID" sudo -iu "`$currentUser" /usr/bin/security import /tmp/$($user.userName)-client-signed.pfx -x -k /Users/$($user.localUsername)/Library/Keychains/login.keychain -P $JCUSERCERTPASS -T "/System/Library/SystemConfiguration/EAPOLController.bundle/Contents/Resources/eapolclient"
#         if [[ `$? -eq 0 ]]; then
#             echo "Import Success"
#             # get the SHA hash of the newly imported cert
#             installedCertSN=`$(/bin/launchctl asuser "`$currentUserUID" sudo -iu "`$currentUser" /usr/bin/security find-certificate -$($macCertSearch) "$($certIdentifier)" -Z /Users/$($user.localUsername)/Library/Keychains/login.keychain | grep snbr | awk '{print `$1}' | sed 's/"snbr"<blob>=0x//g')
#             if [[ `$installedCertSN == `$currentCertSN ]]; then
#                 installedCertSHA=`$(/bin/launchctl asuser "`$currentUserUID" sudo -iu "`$currentUser" /usr/bin/security find-certificate -$($macCertSearch) "$($certIdentifier)" -Z /Users/$($user.localUsername)/Library/Keychains/login.keychain | grep SHA-1 | awk '{print `$3}')
#             fi

#         else
#             echo "import failed"
#             exit 4
#         fi
#     else
#         echo "cert already imported"
#     fi

#     # check if the cert secruity preference is set:
#     IFS=';' read -ra network <<< "`$networkSsid"
#     for i in "`${network[@]}"; do
#         echo "begin setting network SSID: `$i"
#         if /bin/launchctl asuser "`$currentUserUID" sudo -iu "`$currentUser" /usr/bin/security get-identity-preference -s "com.apple.network.eap.user.identity.wlan.ssid.`$i" -Z "`$installedCertSHA"; then
#             echo "it was already set"
#         else
#             echo "certificate not linked from SSID: `$i to certSN: `$currentCertSN, setting now"
#             /bin/launchctl asuser "`$currentUserUID" sudo -iu "`$currentUser" /usr/bin/security set-identity-preference -s "com.apple.network.eap.user.identity.wlan.ssid.`$i" -Z "`$installedCertSHA"
#             if [[ `$? -eq 0 ]]; then
#             echo "SSID: `$i and certificate linked"
#             else
#                 echo "Could not associate SSID: `$i and certifiacte"
#             fi
#         fi
#     done

#     # print results
#     echo "################## Cert Install Results ##################"
#     echo "Installed Cert SN: `$installedCertSN"
#     echo "Installed Cert SHA1: `$installedCertSHA"
#     echo "##########################################################"

#     # Finally clean up files
#     if [[ -f "/tmp/$($user.userName)-client-signed.zip" ]]; then
#         echo "Removing Temp Zip"
#         rm "/tmp/$($user.userName)-client-signed.zip"
#     fi
#     if [[ -f "/tmp/$($user.userName)-client-signed.pfx" ]]; then
#         echo "Removing Temp Pfx"
#         rm "/tmp/$($user.userName)-client-signed.pfx"
#     fi
# else
#     # restore case match type
#     `$caseMatchOrigValue
#     echo "Current logged in user, `$currentUser, does not match expected certificate user. Please ensure $($user.localUsername) is signed in and retry"
#     # Finally clean up files
#     if [[ -f "/tmp/$($user.userName)-client-signed.zip" ]]; then
#         echo "Removing Temp Zip"
#         rm "/tmp/$($user.userName)-client-signed.zip"
#     fi
#     if [[ -f "/tmp/$($user.userName)-client-signed.pfx" ]]; then
#         echo "Removing Temp Pfx"
#         rm "/tmp/$($user.userName)-client-signed.pfx"
#     fi
#     exit 4
# fi

# "@
#                     launchType        = "trigger"
#                     User              = "000000000000000000000000"
#                     trigger           = "RadiusCertInstall"
#                     commandType       = "mac"
#                     timeout           = 600
#                     TimeToLiveSeconds = 864000
#                     files             = (New-JCCommandFile -certFilePath $userPfxZip -FileName "$($user.userName)-client-signed.zip" -FileDestination "/tmp/$($user.userName)-client-signed.zip")
#                 }
#                 $NewCommand = New-JcSdkCommand @CommandBody

#                 # Find newly created command and add system as target
#                 # TODO: Condition for duplicate commands
#                 $Command = Get-JCCommand -name "RadiusCert-Install:$($user.userName):MacOSX"
#                 $systemIds | ForEach-Object { Set-JcSdkCommandAssociation -CommandId:("$($Command._id)") -Op 'add' -Type:('system') -Id:("$($_.systemId)") | Out-Null }
#             } catch {
#                 throw $_
#             }

#             $CommandTable = [PSCustomObject]@{
#                 commandId            = $command._id
#                 commandName          = $command.name
#                 commandPreviouslyRun = $false
#                 commandQueued        = $false
#                 systems              = $systemIds
#             }

#             $user.commandAssociations += $CommandTable

#             Write-Host "[status] Successfully created $($Command.name): User - $($user.userName); OS - Mac OS X"

#         }
#         'Windows' {
#             # Get the Windows system ids
#             $systemIds = $user.systemAssociations | Where-Object { $_.osFamily -eq 'Windows' } | Select-Object systemId

#             # Check to see if previous commands exist
#             $Command = Get-JCCommand -name "RadiusCert-Install:$($user.userName):Windows"

#             if ($Command.Count -ge 1) {
#                 $confirmation = Write-Host "[status] RadiusCert-Install:$($user.userName):Windows command already exists, skipping..."
#                 continue
#             }

#             # Create new Command and upload the signed pfx
#             try {
#                 $CommandBody = @{
#                     Name              = "RadiusCert-Install:$($user.userName):Windows"
#                     Command           = @"
# `$ErrorActionPreference = "Stop"
# [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# `$PkgProvider = Get-PackageProvider
# If ("Nuget" -notin `$PkgProvider.Name){
#     Install-PackageProvider -Name NuGet -Force
# }
# `$CurrentUser = (Get-WMIObject -ClassName Win32_ComputerSystem).Username
# if ( -Not [string]::isNullOrEmpty(`$CurrentUser) ){
#     `$CurrentUser = `$CurrentUser.Split('\')[1]
# } else {
#     `$CurrentUser = `$null
# }
# if (`$CurrentUser -eq "$($user.localUsername)") {
#     if (-not(Get-InstalledModule -Name RunAsUser -errorAction "SilentlyContinue")) {
#         Write-Host "RunAsUser Module not installed, Installing..."
#         Install-Module RunAsUser -Force
#         Import-Module RunAsUser -Force
#     } else {
#         Write-Host "RunAsUser Module installed, importing into session..."
#         Import-Module RunAsUser -Force
#     }
#     # create temp new radius directory
#     If (Test-Path "C:\RadiusCert"){
#         Write-Host "Radius Temp Cert Directory Exists"
#     } else {
#         New-Item "C:\RadiusCert" -itemType Directory
#     }
#     # expand archive as root and copy to temp location
#     Expand-Archive -LiteralPath C:\Windows\Temp\$($user.userName)-client-signed.zip -DestinationPath C:\RadiusCert -Force
#     `$password = ConvertTo-SecureString -String $JCUSERCERTPASS -AsPlainText -Force
#     `$ScriptBlockInstall = { `$password = ConvertTo-SecureString -String $JCUSERCERTPASS -AsPlainText -Force
#     Import-PfxCertificate -Password `$password -FilePath "C:\RadiusCert\$($user.userName)-client-signed.pfx" -CertStoreLocation Cert:\CurrentUser\My
#     }
#     `$imported = Get-PfxData -Password `$password -FilePath "C:\RadiusCert\$($user.userName)-client-signed.pfx"
#     # Get Current Certs As User
#     `$ScriptBlockCleanup = {
#         `$certs = Get-ChildItem Cert:\CurrentUser\My\

#         foreach (`$cert in `$certs){
#             if (`$cert.subject -match "$($certIdentifier)") {
#                 if (`$(`$cert.serialNumber) -eq "$($certHash.serial)"){
#                     write-host "Found Cert:``nCert SN: `$(`$cert.serialNumber)"
#                 } else {
#                     write-host "Removing Cert:``nCert SN: `$(`$cert.serialNumber)"
#                     Get-ChildItem "Cert:\CurrentUser\My\`$(`$cert.thumbprint)" | remove-item
#                 }
#             }
#         }
#     }
#     `$scriptBlockValidate = {
#         if (Get-ChildItem Cert:\CurrentUser\My\`$(`$imported.thumbrprint)){
#             return `$true
#         } else {
#             return `$false
#         }
#     }
#     Write-Host "Importing Pfx Certificate for $($user.userName)"
#     `$certInstall = Invoke-AsCurrentUser -ScriptBlock `$ScriptBlockInstall -CaptureOutput
#     `$certInstall
#     Write-Host "Cleaning Up Previously Installed Certs for $($user.userName)"
#     `$certCleanup = Invoke-AsCurrentUser -ScriptBlock `$ScriptBlockCleanup -CaptureOutput
#     `$certCleanup
#     Write-Host "Validating Installed Certs for $($user.userName)"
#     `$certValidate = Invoke-AsCurrentUser -ScriptBlock `$scriptBlockValidate -CaptureOutput
#     write-host `$certValidate

#     # finally clean up temp files:
#     If (Test-Path "C:\Windows\Temp\$($user.userName)-client-signed.zip"){
#         Remove-Item "C:\Windows\Temp\$($user.userName)-client-signed.zip"
#     }
#     If (Test-Path "C:\RadiusCert\$($user.userName)-client-signed.pfx"){
#         Remove-Item "C:\RadiusCert\$($user.userName)-client-signed.pfx"
#     }

#     # Lastly validate if the cert was installed
#     if (`$certValidate.Trim() -eq "True"){
#         Write-Host "Cert was installed"
#     } else {
#         Throw "Cert was not installed"
#     }
# } else {
#     if (`$CurrentUser -eq `$null){
#         Write-Host "No users are signed into the system. Please ensure $($user.userName) is signed in and retry."
#     } else {
#         Write-Host "Current logged in user, `$CurrentUser, does not match expected certificate user. Please ensure $($user.localUsername) is signed in and retry."
#     }
#     # finally clean up temp files:
#     If (Test-Path "C:\Windows\Temp\$($user.userName)-client-signed.zip"){
#         Remove-Item "C:\Windows\Temp\$($user.userName)-client-signed.zip"
#     }
#     If (Test-Path "C:\RadiusCert\$($user.userName)-client-signed.pfx"){
#         Remove-Item "C:\RadiusCert\$($user.userName)-client-signed.pfx"
#     }
#     exit 4
# }
# "@
#                     launchType        = "trigger"
#                     trigger           = "RadiusCertInstall"
#                     commandType       = "windows"
#                     shell             = "powershell"
#                     timeout           = 600
#                     TimeToLiveSeconds = 864000
#                     files             = (New-JCCommandFile -certFilePath $userPfxZip -FileName "$($user.userName)-client-signed.zip" -FileDestination "C:\Windows\Temp\$($user.userName)-client-signed.zip")
#                 }
#                 $NewCommand = New-JcSdkCommand @CommandBody

#                 # Find newly created command and add system as target
#                 $Command = Get-JCCommand -name "RadiusCert-Install:$($user.userName):Windows"
#                 $systemIds | ForEach-Object { Set-JcSdkCommandAssociation -CommandId:("$($Command._id)") -Op 'add' -Type:('system') -Id:("$($_.systemId)") | Out-Null }
#             } catch {
#                 throw $_
#             }

#             $CommandTable = [PSCustomObject]@{
#                 commandId            = $command._id
#                 commandName          = $command.name
#                 commandPreviouslyRun = $false
#                 commandQueued        = $false
#                 systems              = $systemIds
#             }

#             $user.commandAssociations += $CommandTable
#             Write-Host "[status] Successfully created $($Command.name): User - $($user.userName); OS - Windows"

#         }
#         $null {
#             Write-Warning "$($user.username) is not associated with any systems, skipping command generation"


#         }
#     }

#     # Invoke Commands
#     #TODO:: skip if this is not per user basis
#     $confirmation = Read-Host "Would you like to invoke commands? [y/n]"
#     # TODO: replace this with set-JCUserTable earlier after we create a command(s) for the user
#     $UserArray | ConvertTo-Json -Depth 6 | Out-File "$JCScriptRoot\users.json"

#     while ($confirmation -ne 'y') {
#         if ($confirmation -eq 'n') {
#             Write-Host "[status] To invoke the commands at a later time, select option '4' to monitor your User Certification Distribution"
#             Write-Host "[status] Returning to main menu"
#             exit
#         }
#         $confirmation = Read-Host "Would you like to invoke commands? [y/n]"
#     }

#     # TODO: for individual users, invoke command retry by username
#     # else invoke for all?
#     $invokeCommands = invoke-commandByUsername -userID $user.userid
#     # $invokeCommands = Invoke-CommandsRetry -jsonFile "$JCScriptRoot\users.json"
#     Write-Host "[status] Commands Invoked"

#     # TODO: Set-JCUserTable -Commands to update the user array.
#     # Set commandPreviouslyRun property to true
#     $user.commandAssociations | ForEach-Object { $_.commandPreviouslyRun = $true }

#     $UserArray | ConvertTo-Json -Depth 6 | Out-File "$JCScriptRoot\users.json"

# }
Write-Host "[status] Select option '4' to monitor your User Certification Distribution"
Write-Host "[status] Returning to main menu"
