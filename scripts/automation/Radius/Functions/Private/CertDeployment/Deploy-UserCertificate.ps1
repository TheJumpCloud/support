function Deploy-UserCertificate {
    [CmdletBinding()]
    param (
        # Input from users.json
        [Parameter(HelpMessage = 'An individual or array of user objects from users.json', Mandatory)]
        [System.Object[]]
        $userObject,
        # when specified will force newly generated commands to be invoked on systems
        [Parameter(HelpMessage = 'When specified, this parameter will invoke commands on systems associated to the user from the "userObject" parameter')]
        [bool]
        $forceInvokeCommands,
        # when specified will generated a new command for the given user
        [Parameter(HelpMessage = 'When specified, this parameter will generate new commands for the user from the "userObject" parameter')]
        [bool]
        $forceGenerateCommands,
        # prompt replace existing certificate
        [Parameter(HelpMessage = 'When specified, this parameter will prompt for user input and ask if generated commands should be invoked on associated systems')]
        [switch]
        $prompt
    )

    begin {
        $workToBeDone = [PSCustomObject]@{
            remainingMacOSDevices        = $null
            remainingWindowsSDevices     = $null
            removeQueuedCommands         = $null
            removeCommands               = $null
            forceGenerateMacOSCommands   = $false
            forceGenerateWindowsCommands = $false
            macOSCommandID               = $null
            windowsCommandID             = $null
            commandIDsToRemove           = New-Object System.Collections.ArrayList
            commandQueueIDsToRemove      = New-Object System.Collections.ArrayList
            commandQueueIDsDuplicates    = New-Object System.Collections.ArrayList
        }

        $status_commandGenerated = $false
        $result_deployed = $false

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
                $workToBeDone.forceGenerateMacOSCommands = $true
                $workToBeDone.forceGenerateWindowsCommands = $true
            }
            $false {
                $workToBeDone.forceGenerateMacOSCommands = $false
                $workToBeDone.forceGenerateWindowsCommands = $false
            }
        }
        switch ($prompt) {
            $true {
                $invokeCommandsChoice = Get-ResponsePrompt -message "Would you like to invoke commands after they've been generated?"
                switch ($invokeCommandsChoice) {
                    $true {
                        $invokeCommands = $true
                    }
                    $false {
                        $invokeCommands = $false
                    }
                }
            }
        }
    }

    process {
        foreach ($user in $userObject) {
            ## first determine if the local cert sha is the same as the cert sha in the admin console:
            # Write-Warning "processing user: $($user.username)"
            # Write-Warning "user: $user"

            # Get the commands for this user:
            $radiusCommandsByUser = Get-CommandByUsername -username $user.username
            if ($radiusCommandsByUser) {
                $macOSCommands = ($radiusCommandsByUser | Where-Object { $_.Name -match "MacOSX" })
                $windowsOSCommands = ($radiusCommandsByUser | Where-Object { $_.Name -match "Windows" })
            }

            # Get the queued commands for the user
            $queuedRadiusCommandsByUser = Get-queuedCommandByUser -username $user.username
            if ($queuedRadiusCommandsByUser) {
                $windowsQueuedCommands = $queuedRadiusCommandsByUser | Where-Object { $_.name -match "Windows" }
                $macOSQueuedCommands = $queuedRadiusCommandsByUser | Where-Object { $_.name -match "macOS" }
            } else {
                $windowsQueuedCommands = $null
                $macOSQueuedCommands = $null
            }

            # Get the users certificate Details:
            # Get certificate and zip to upload to Commands
            $userCertFiles = Get-ChildItem -Path (Resolve-Path -Path "$($global:JCRConfig.radiusDirectory.value)/UserCerts") -Filter "$($user.userName)-*"
            # set crt and pfx filepaths
            $userCrt = ($userCertFiles | Where-Object { $_.Name -match "crt" }).FullName
            $userPfx = ($userCertFiles | Where-Object { $_.Name -match "pfx" }).FullName
            # define .zip name
            $userPfxZip = "$($global:JCRConfig.radiusDirectory.value)/UserCerts/$($user.userName)-client-signed.zip"
            # get certInfo for commands:
            $certInfo = Get-CertInfo -UserCerts -username $user.username
            # Determine if the commands have matching SHA1 values:


            if ($macOSCommands) {
                # verify the certs match for macOS systems:
                foreach ($maOSRadiusCommand in $macOSCommands) {
                    # if we want to forceGenerate new commands, add all commands to the remove list
                    switch ($workToBeDone.forceGenerateMacOSCommands) {
                        $true {
                            # add the command to the list to remove
                            $workToBeDone.commandIDsToRemove.Add($maOSRadiusCommand.Id) | Out-Null

                        }
                        $false {
                            if ((-Not $workToBeDone.macOSCommandID) -AND ($maOSRadiusCommand.trigger -eq $certInfo.sha1)) {
                                # set the existing command IDs:
                                # There is a potential for this to be a bug, if duplicate commands with the same SHA1 trigger exist, this code just selects the first one and removes the second in the next iteration
                                $workToBeDone.macOSCommandID = ($radiusCommandsByUser | Where-Object { $_.Name -match "MacOSX" }).Id | Select-Object -First 1
                            } elseif (($workToBeDone.macOSCommandID) -AND ($maOSRadiusCommand.trigger -eq $certInfo.sha1)) {
                                # add the duplicate command to the list to remove
                                $workToBeDone.commandIDsToRemove.Add($maOSRadiusCommand.Id) | Out-Null
                            } else {
                                # add the command to the list to remove
                                $workToBeDone.commandIDsToRemove.Add($maOSRadiusCommand.Id) | Out-Null
                            }
                        }
                    }
                }
            } else {
                $workToBeDone.macOSCommandID = $null
            }
            if ($windowsOSCommands) {
                # verify the certs match for windows systems:
                foreach ($windowsOSRadiusCommands in $windowsOSCommands) {
                    switch ($workToBeDone.forceGenerateWindowsCommands) {
                        $true {
                            # add the command to the list to remove
                            $workToBeDone.commandIDsToRemove.Add($windowsOSRadiusCommands.Id) | Out-Null
                        }
                        $false {
                            if ((-Not $workToBeDone.windowsCommandID) -AND ($windowsOSRadiusCommands.trigger -eq $certInfo.sha1)) {
                                # set the existing command IDs:
                                # There is a potential for this to be a bug, if duplicate commands with the same SHA1 trigger exist, this code just selects the first one and removes the second in the next iteration
                                $workToBeDone.windowsCommandID = ($radiusCommandsByUser | Where-Object { $_.Name -match "Windows" }).Id | Select-Object -First 1
                            } elseif (($workToBeDone.windowsCommandID) -AND ($windowsOSRadiusCommands.trigger -eq $certInfo.sha1)) {
                                # add the duplicate command to the list to remove
                                $workToBeDone.commandIDsToRemove.Add($windowsOSRadiusCommands.Id) | Out-Null
                            } else {
                                # add the command to the list to remove
                                $workToBeDone.commandIDsToRemove.Add($windowsOSRadiusCommands.Id) | Out-Null
                            }
                        }
                    }
                }
            } else {
                $workToBeDone.windowsCommandID = $null
            }



            if ($windowsQueuedCommands) {
                if ($workToBeDone.windowsCommandID) {
                    # Get queued commands that are from a previous command; delete those
                    foreach ($queuedCommand in $windowsQueuedCommands) {
                        if ($queuedCommand.command -eq $workToBeDone.windowsCommandID) {
                            # TODO: nothing to do here?
                            $workToBeDone.commandQueueIDsDuplicates.Add($queuedCommand.Id) | Out-Null
                        } else {
                            # if the queued commands does not match the cert command, remove all these queued commands
                            $workToBeDone.commandQueueIDsToRemove.Add($queuedCommand.Id) | Out-Null
                        }
                    }
                } else {
                    foreach ($queuedCommand in $windowsQueuedCommands) {
                        # if there are commands in queue for the user but no matching cert command, remove all the items in the queue
                        $workToBeDone.commandQueueIDsToRemove.Add($queuedCommand.Id) | Out-Null
                    }
                }
            }
            if ($macOSQueuedCommands) {
                if ($workToBeDone.windowsCommandID) {

                    foreach ($queuedCommand in $macOSQueuedCommands) {
                        if ($queuedCommand.command -eq $workToBeDone.macOSCommandID) {
                            # TODO: nothing to do here?
                            $workToBeDone.commandQueueIDsDuplicates.Add($queuedCommand.Id) | Out-Null
                        } else {
                            # if the queued commands does not match the cert command, remove all these queued commands
                            $workToBeDone.commandQueueIDsToRemove.Add($queuedCommand.Id) | Out-Null
                        }
                    }
                } else {
                    foreach ($queuedCommand in $macOSQueuedCommands) {
                        # if there are commands in queue for the user but no matching cert command, remove all the items in the queue
                        $workToBeDone.commandQueueIDsToRemove.Add($queuedCommand.Id) | Out-Null
                    }
                }
            }

            # remove the commands:
            if ($workToBeDone.commandIDsToRemove) {
                foreach ($commandIDToRemove in $workToBeDone.commandIDsToRemove) {
                    Remove-JcSdkCommand -Id $commandIDToRemove | Out-Null
                }
            }
            # remove queued commands:
            if ($workToBeDone.commandQueueIDsToRemove) {
                foreach ($commandQueueIDToRemove in $workToBeDone.commandQueueIDsToRemove) {
                    Clear-JCQueuedCommand -workflowId $commandQueueIDToRemove | Out-Null
                }
            }
            # remove queued commands:
            if ($workToBeDone.commandQueueIDsDuplicates) {
                foreach ($commandQueueIDToRemove in $workToBeDone.commandQueueIDsDuplicates) {
                    Clear-JCQueuedCommand -workflowId $commandQueueIDToRemove | Out-Null
                }
            }
            ## determine the systems that need the cert
            try {
                $userCertHashData = $Global:JCRCertHash["$($user.certInfo.sha1)"]

            } catch {
                $userCertHashData = $null
            }
            if ($userCertHashData) {
                # set the remaining systems that don't have the cert:
                # macOS
                $workToBeDone.remainingMacOSDevices = $user.systemAssociations | Where-Object { ($_.systemID -notin $userCertHashData.systemId ) -And ($_.osFamily) -eq "macOS" }
                # windows
                $workToBeDone.remainingWindowsSDevices = $user.systemAssociations | Where-Object { ($_.systemID -notin $userCertHashData.systemId ) -And ($_.osFamily) -eq "Windows" }

                # if there's work to be done but not a valid cert command, generate the command
                if (($workToBeDone.remainingMacOSDevices) -AND (-Not $workToBeDone.macOSCommandID)) {
                    $workToBeDone.forceGenerateMacOSCommands = $true
                }
                # if there's work to be done but not a valid cert command, generate the command
                if (($workToBeDone.remainingWindowsSDevices) -AND (-Not $workToBeDone.windowsCommandID)) {
                    $workToBeDone.forceGenerateWindowsCommands = $true
                }
                # regenerate the cert to keep it on the console:
                if ((-Not $workToBeDone.remainingMacOSDevices) -AND (-Not $workToBeDone.macOSCommandID)) {
                    $workToBeDone.forceGenerateMacOSCommands = $true
                }
                if ((-Not $workToBeDone.remainingWindowsSDevices) -AND (-Not $workToBeDone.windowsCommandID)) {
                    $workToBeDone.forceGenerateWindowsCommands = $true
                }
            } else {
                # set the remaining devices to the association list from users.json
                # macOS
                $workToBeDone.remainingMacOSDevices = $user.systemAssociations | Where-Object { ($_.osFamily) -eq "macOS" }
                # Windows
                $workToBeDone.remainingWindowsSDevices = $user.systemAssociations | Where-Object { ($_.osFamily) -eq "Windows" }
                # if there's work to be done but not a valid cert command, generate the command
                if (($workToBeDone.remainingMacOSDevices) -AND (-Not $workToBeDone.macOSCommandID)) {
                    $workToBeDone.forceGenerateMacOSCommands = $true
                }
                # if there's work to be done but not a valid cert command, generate the command
                if (($workToBeDone.remainingWindowsSDevices) -AND (-Not $workToBeDone.windowsCommandID)) {
                    $workToBeDone.forceGenerateWindowsCommands = $true
                }
                # regenerate the cert to keep it on the console:
                if ((-Not $workToBeDone.remainingMacOSDevices) -AND (-Not $workToBeDone.macOSCommandID)) {
                    $workToBeDone.forceGenerateMacOSCommands = $true
                }
                if ((-Not $workToBeDone.remainingWindowsSDevices) -AND (-Not $workToBeDone.windowsCommandID)) {
                    $workToBeDone.forceGenerateWindowsCommands = $true
                }
            }
            # now clear out the user command associations from users.json
            $user.commandAssociations = @()

            If (-Not $certInfo) {
                Write-host "$($user.username) did not have a certificate generated"
                $status_commandGenerated = $false
                $result_deployed = $false
                continue
            } else {
                # explicitly validate that the subject header exists
                if (-Not $certInfo.subject) {
                    Write-host "$($user.username) has a certificate file but no subject was found"
                    $status_commandGenerated = $false
                    $result_deployed = $false
                    continue
                }
                # explicitly validate that the serial number exists
                if (-Not $certInfo.serial) {
                    Write-host "$($user.username) has a certificate file but no serial number was found"
                    $status_commandGenerated = $false
                    $result_deployed = $false
                    continue
                }
            }

            if (($workToBeDone.forcegenerateMacOSCommands) -OR ($workToBeDone.forceGenerateWindowsCommands)) {
                # determine certType
                switch ($($global:JCRConfig.certType.value)) {
                    'EmailSAN' {
                        # set cert identifier to SAN email of cert
                        $sanID = Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) x509 -in $($userCrt) -ext subjectAltName -noout"
                        $regex = 'email:(.*?)$'
                        $JCR_SUBJECT_HEADERSMatch = Select-String -InputObject "$($sanID)" -Pattern $regex
                        $certIdentifier = $JCR_SUBJECT_HEADERSMatch.matches.Groups[1].value
                        # in macOS search user certs by email
                        $macCertSearch = 'e'
                        # On windows devices, search certs by Subject Alternative Name this is required to remove previously generated certs
                        $windowsCertHereString = @"
        `$SANMatch = `$cert.Extensions | Where-Object { `$_.Oid.FriendlyName -eq "Subject Alternative Name" }
        if (`$SANMatch){
            if ((`$SANMatch).format(`$true) -match "$($certIdentifier)") {
                if (`$(`$cert.serialNumber) -eq "$($certInfo.serial)"){
                    write-host "Found Cert:``nCert SN: `$(`$cert.serialNumber)"
                } else {
                    write-host "Removing Cert:``nCert SN: `$(`$cert.serialNumber)"
                    Get-ChildItem "Cert:\CurrentUser\My\`$(`$cert.thumbprint)" | remove-item
                }
            }
        }
"@

                    }
                    'EmailDN' {
                        # Else set cert identifier to email of cert subject
                        $regex = 'emailAddress\s*=\s*(.*?)$'
                        $JCR_SUBJECT_HEADERSMatch = Select-String -InputObject "$($certInfo.Subject)" -Pattern $regex
                        $certIdentifier = $JCR_SUBJECT_HEADERSMatch.matches.Groups[1].value
                        # in macOS search user certs by email
                        $macCertSearch = 'e'
                        # On windows devices, search certs by Subject
                        $windowsCertHereString = @"
        if (`$cert.subject -match "$($certIdentifier)") {
            if (`$(`$cert.serialNumber) -eq "$($certInfo.serial)"){
                write-host "Found Cert:``nCert SN: `$(`$cert.serialNumber)"
            } else {
                write-host "Removing Cert:``nCert SN: `$(`$cert.serialNumber)"
                Get-ChildItem "Cert:\CurrentUser\My\`$(`$cert.thumbprint)" | remove-item
            }
        }
"@
                    }
                    'UsernameCn' {
                        # if username just set cert identifier to username
                        $certIdentifier = $($user.userName)
                        # in macOS search user certs by common name (username)
                        $macCertSearch = 'c'
                        # On windows devices, search certs by Subject
                        $windowsCertHereString = @"
        if (`$cert.subject -match "$($certIdentifier)") {
            if (`$(`$cert.serialNumber) -eq "$($certInfo.serial)"){
                write-host "Found Cert:``nCert SN: `$(`$cert.serialNumber)"
            } else {
                write-host "Removing Cert:``nCert SN: `$(`$cert.serialNumber)"
                Get-ChildItem "Cert:\CurrentUser\My\`$(`$cert.thumbprint)" | remove-item
            }
        }
"@
                    }
                }
                # Create the zip
                Compress-Archive -Path $userPfx -DestinationPath $userPfxZip -CompressionLevel NoCompression -Force
            }


            if ($workToBeDone.forcegenerateMacOSCommands) {
                # Get the macOS system ids
                $systemIds = (Get-SystemsThatNeedCertWork -userData $user -osType "macOS")
                if ($systemIds.count -gt 0) {

                    # Create new Command and upload the signed pfx
                    try {
                        $CommandBody = @{
                            Name              = "RadiusCert-Install:$($user.userName):MacOSX"
                            Command           = @"
unzip -o /tmp/$($user.userName)-client-signed.zip -d /tmp
chmod 755 /tmp/$($user.userName)-client-signed.pfx
currentUser=`$(/usr/bin/stat -f%Su /dev/console)
currentUserUID=`$(id -u "`$currentUser")
currentCertSN="$($certInfo.serial)"
networkSsid="$($global:JCRConfig.networkSSID.value)"
# store orig case match value
caseMatchOrigValue=`$(shopt -p nocasematch; true)
# set to case-insensitive
shopt -s nocasematch
userCompare="$($user.localUsername)"
if [[ "`$currentUser" ==  "`$userCompare" ]]; then
# restore case match type
`$caseMatchOrigValue
certs=`$(security find-certificate -a -$($macCertSearch) "$($certIdentifier)" -Z /Users/$($user.localUsername)/Library/Keychains/login.keychain)
regexSHA='SHA-1 hash: ([0-9A-F]{5,40})'
regexSN='"snbr"<blob>=0x([0-9A-F]{5,40})'
global_rematch() {
    # Set local variables
    local s=`$1 regex=`$2
    # While string matches regex expression
    while [[ `$s =~ `$regex ]]; do
        # Echo out the match
        echo "`${BASH_REMATCH[1]}"
        # Remove the string
        s=`${s#*"`${BASH_REMATCH[1]}"}
    done
}
# Save results
# Get Text Results
textSHA=`$(global_rematch "`$certs" "`$regexSHA")
# Set as array for SHA results
arraySHA=(`$textSHA)
# Get Text Results
textSN=`$(global_rematch "`$certs" "`$regexSN")
# Set as array for SN results
arraySN=(`$textSN)
# set import var
import=true
if [[ `${#arraySN[@]} == `${#arraySHA[@]} ]]; then
    len=`${#arraySN[@]}
    for (( i=0; i<`$len; i++ )); do
        if [[ `$currentCertSN == `${arraySN[`$i]} ]]; then
            echo "Found Cert: SN: `${arraySN[`$i]} SHA: `${arraySHA[`$i]}"
            installedCertSN=`${arraySN[`$i]}
            installedCertSHA=`${arraySHA[`$i]}
            # if cert is installed, no need to update
            import=false
        else
            echo "Removing previously installed radius cert:"
            echo "SN: `${arraySN[`$i]} SHA: `${arraySHA[`$i]}"
            security delete-certificate -Z "`${arraySHA[`$i]}" /Users/$($user.localUsername)/Library/Keychains/login.keychain
        fi
    done

else
    echo "array length mismatch, will not delete old certs"
fi

if [[ `$import == true ]]; then
    /bin/launchctl asuser "`$currentUserUID" sudo -iu "`$currentUser" /usr/bin/security import /tmp/$($user.userName)-client-signed.pfx -x -k /Users/$($user.localUsername)/Library/Keychains/login.keychain -P $($global:JCRConfig.certSecretPass.value) -T "/System/Library/SystemConfiguration/EAPOLController.bundle/Contents/Resources/eapolclient"
    if [[ `$? -eq 0 ]]; then
        echo "Import Success"
        # get the SHA hash of the newly imported cert
        installedCertSN=`$(/bin/launchctl asuser "`$currentUserUID" sudo -iu "`$currentUser" /usr/bin/security find-certificate -$($macCertSearch) "$($certIdentifier)" -Z /Users/$($user.localUsername)/Library/Keychains/login.keychain | grep snbr | awk '{print `$1}' | sed 's/"snbr"<blob>=0x//g')
        if [[ `$installedCertSN == `$currentCertSN ]]; then
            installedCertSHA=`$(/bin/launchctl asuser "`$currentUserUID" sudo -iu "`$currentUser" /usr/bin/security find-certificate -$($macCertSearch) "$($certIdentifier)" -Z /Users/$($user.localUsername)/Library/Keychains/login.keychain | grep SHA-1 | awk '{print `$3}')
        fi

    else
        echo "import failed"
        exit 4
    fi
else
    echo "cert already imported"
fi

# check if the cert security preference is set:
IFS=';' read -ra network <<< "`$(`$global:JCRConfig.networkSSID.value)"
for i in "`${network[@]}"; do
    echo "begin setting network SSID: `$i"
    if /bin/launchctl asuser "`$currentUserUID" sudo -iu "`$currentUser" /usr/bin/security get-identity-preference -s "com.apple.network.eap.user.identity.wlan.ssid.`$i" -Z "`$installedCertSHA"; then
        echo "it was already set"
    else
        echo "certificate not linked from SSID: `$i to certSN: `$currentCertSN, setting now"
        /bin/launchctl asuser "`$currentUserUID" sudo -iu "`$currentUser" /usr/bin/security set-identity-preference -s "com.apple.network.eap.user.identity.wlan.ssid.`$i" -Z "`$installedCertSHA"
        if [[ `$? -eq 0 ]]; then
        echo "SSID: `$i and certificate linked"
        else
            echo "Could not associate SSID: `$i and certifiacte"
        fi
    fi
done

# print results
echo "################## Cert Install Results ##################"
echo "Installed Cert SN: `$installedCertSN"
echo "Installed Cert SHA1: `$installedCertSHA"
echo "##########################################################"

# Finally clean up files
if [[ -f "/tmp/$($user.userName)-client-signed.zip" ]]; then
    echo "Removing Temp Zip"
    rm "/tmp/$($user.userName)-client-signed.zip"
fi
if [[ -f "/tmp/$($user.userName)-client-signed.pfx" ]]; then
    echo "Removing Temp Pfx"
    rm "/tmp/$($user.userName)-client-signed.pfx"
fi

# update si table
# The conf file is JSON and can be parsed using JSON.parse() in a supported language.
conf="`$(cat /opt/jc/jcagent.conf)"
regex='\"systemKey\":\"([a-zA-Z0-9_]+)\"'
if [[ `${conf} =~ `$regex ]] ; then
systemKey="`${BASH_REMATCH[1]}"
fi
# get the certUUID
regex='\"certuuid\":\"([a-zA-Z0-9_]+)\"'
if [[ `${conf} =~ `$regex ]] ; then
certUUID="`${BASH_REMATCH[1]}"
fi

# get the key /cert locations
keyLocation="/opt/jc/client.key"
certLocation="/opt/jc/client.crt"
caCertLocation="/opt/jc/ca.crt"

# Get json certificate data from osquery and add missing windows certificate columns
certJson=`$(/opt/jc/bin/jcosqueryi --json "select *, '' AS sid, '' AS store, '' AS store_id, '' AS store_location, '' AS username from certificates;")

# post
curl --cert `$certLocation --key `$keyLocation --cacert `$caCertLocation \
-X POST 'https://agent.jumpcloud.com/systeminsights/snapshots/certificates' \
-H "x-system-id: `$systemKey" \
-H "x-ssl-client-dn: /CN=`$certUUID/O=JumpCloud" \
-H 'Content-Type: application/json' \
--data-raw '{
    "data": '"`$certJson"'
}'

else
# restore case match type
`$caseMatchOrigValue
echo "Current logged in user, `$currentUser, does not match expected certificate user. Please ensure $($user.localUsername) is signed in and retry"
# Finally clean up files
if [[ -f "/tmp/$($user.userName)-client-signed.zip" ]]; then
    echo "Removing Temp Zip"
    rm "/tmp/$($user.userName)-client-signed.zip"
fi
if [[ -f "/tmp/$($user.userName)-client-signed.pfx" ]]; then
    echo "Removing Temp Pfx"
    rm "/tmp/$($user.userName)-client-signed.pfx"
fi
exit 4
fi

"@
                            launchType        = "trigger"
                            User              = "000000000000000000000000"
                            trigger           = "$($certInfo.sha1)"
                            commandType       = "mac"
                            timeout           = 600
                            TimeToLiveSeconds = 864000
                            files             = (New-JCCommandFile -certFilePath $userPfxZip -FileName "$($user.userName)-client-signed.zip" -FileDestination "/tmp/$($user.userName)-client-signed.zip")
                        }
                        $NewCommand = New-JcSdkCommand @CommandBody

                    } catch {
                        $status_commandGenerated = $false
                        # throw $_
                    }
                    # Find newly created command and add system as target
                    $Command = Get-JcSdkCommand -Filter @("trigger:eq:$($certInfo.sha1)", "commandType:eq:mac")
                    $workToBeDone.macOSCommandID = $Command.Id

                    $CommandTable = [PSCustomObject]@{
                        commandId            = $workToBeDone.macOSCommandID
                        commandName          = $command.name
                        commandPreviouslyRun = $false
                        commandQueued        = $false
                        systems              = $systemIds
                    }

                    $user.commandAssociations += $CommandTable

                    # Write-Host "[status] Successfully created $($Command.name): User - $($user.userName); OS - Mac OS X"
                    $status_commandGenerated = $true


                }
            }

            if (-Not ($workToBeDone.forceGenerateMacOSCommands) -And ($workToBeDone.macOSCommandID)) {
                $systemIds = (Get-SystemsThatNeedCertWork -userData $user -osType "macOS")

                $Command = Get-JcSdkCommand -Filter @("trigger:eq:$($certInfo.sha1)", "commandType:eq:mac")
                $CommandTable = [PSCustomObject]@{
                    commandId            = $workToBeDone.macOSCommandID
                    commandName          = $command.name
                    commandPreviouslyRun = $false
                    commandQueued        = $false
                    systems              = $systemIds
                }

                $user.commandAssociations += $CommandTable

            }

            if (($invokeCommands) -And ($workToBeDone.remainingMacOSDevices)) {
                try {
                    $commandStart = Start-JcSdkCommand -Id $workToBeDone.macOSCommandID -SystemIds $workToBeDone.remainingMacOSDevices.systemId | Out-Null
                    $result_deployed = $true
                } catch {
                    $result_deployed = $false
                }
            }
            # set the command associations
            if (($workToBeDone.remainingMacOSDevices) -And ($workToBeDone.macOSCommandID)) {

                $workToBeDone.remainingMacOSDevices | ForEach-Object {
                    try {

                        $commandAssociation = Set-JcSdkCommandAssociation -CommandId:("$($workToBeDone.macOSCommandID)") -Op 'add' -Type:('system') -Id:("$($_.systemId)") | Out-Null
                    } catch {
                        "already exists/ couldn't add" | Out-Null
                    }
                }

            }
            if ($workToBeDone.forceGenerateWindowsCommands) {
                # Get the Windows system ids
                $systemIds = (Get-SystemsThatNeedCertWork -userData $user -osType "windows")
                # If there are no systemIds to process, skip generating the command:
                if ($systemIds.count -gt 0) {
                    # Create new Command and upload the signed pfx
                    try {
                        $CommandBody = @{
                            Name              = "RadiusCert-Install:$($user.userName):Windows"
                            Command           = @"
`$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
`$PkgProvider = Get-PackageProvider
If ("Nuget" -notin `$PkgProvider.Name){
Install-PackageProvider -Name NuGet -Force
}
`$CurrentUser = (Get-WMIObject -ClassName Win32_ComputerSystem).Username
if ( -Not [string]::isNullOrEmpty(`$CurrentUser) ){
`$CurrentUser = `$CurrentUser.Split('\')[1]
} else {
`$CurrentUser = `$null
}
if (`$CurrentUser -eq "$($user.localUsername)") {
if (-not(Get-InstalledModule -Name RunAsUser -errorAction "SilentlyContinue")) {
    Write-Host "RunAsUser Module not installed, Installing..."
    Install-Module RunAsUser -Force
    Import-Module RunAsUser -Force
} else {
    Write-Host "RunAsUser Module installed, importing into session..."
    Import-Module RunAsUser -Force
}
# create temp new radius directory
If (Test-Path "C:\RadiusCert"){
    Write-Host "Radius Temp Cert Directory Exists"
} else {
    New-Item "C:\RadiusCert" -itemType Directory
}
# expand archive as root and copy to temp location
Expand-Archive -LiteralPath C:\Windows\Temp\$($user.userName)-client-signed.zip -DestinationPath C:\RadiusCert -Force
`$password = ConvertTo-SecureString -String $($global:JCRConfig.certSecretPass.value) -AsPlainText -Force
`$ScriptBlockInstall = { `$password = ConvertTo-SecureString -String $($global:JCRConfig.certSecretPass.value) -AsPlainText -Force
Import-PfxCertificate -Password `$password -FilePath "C:\RadiusCert\$($user.userName)-client-signed.pfx" -CertStoreLocation Cert:\CurrentUser\My
}
`$imported = Get-PfxData -Password `$password -FilePath "C:\RadiusCert\$($user.userName)-client-signed.pfx"
# Get Current Certs As User
`$ScriptBlockCleanup = {
    `$certs = Get-ChildItem Cert:\CurrentUser\My\

    foreach (`$cert in `$certs){
        $windowsCertHereString
    }
}
`$scriptBlockValidate = {
    if (Get-ChildItem Cert:\CurrentUser\My\`$(`$imported.thumbrprint)){
        return `$true
    } else {
        return `$false
    }
}
Write-Host "Importing Pfx Certificate for $($user.userName)"
`$certInstall = Invoke-AsCurrentUser -ScriptBlock `$ScriptBlockInstall -CaptureOutput
`$certInstall
Write-Host "Cleaning Up Previously Installed Certs for $($user.userName)"
`$certCleanup = Invoke-AsCurrentUser -ScriptBlock `$ScriptBlockCleanup -CaptureOutput
`$certCleanup
Write-Host "Validating Installed Certs for $($user.userName)"
`$certValidate = Invoke-AsCurrentUser -ScriptBlock `$scriptBlockValidate -CaptureOutput
write-host `$certValidate

# finally clean up temp files:
If (Test-Path "C:\Windows\Temp\$($user.userName)-client-signed.zip"){
    Remove-Item "C:\Windows\Temp\$($user.userName)-client-signed.zip"
}
If (Test-Path "C:\RadiusCert\$($user.userName)-client-signed.pfx"){
    Remove-Item "C:\RadiusCert\$($user.userName)-client-signed.pfx"
}

# Lastly validate if the cert was installed
if (`$certValidate.Trim() -eq "True"){
    Write-Host "Cert was installed"
} else {
    Throw "Cert was not installed"
}

# update si table
# define curl path:
`$curlPath = "C:\ProgramData\chocolatey\bin\curl.exe"
if (Test-Path -Path `$curlPath) {

    # Parse the systemKey from the cong file.
    `$config = get-content 'C:\Program Files\JumpCloud\Plugins\Contrib\jcagent.conf'
    `$regex = 'systemKey\":\"(\w+)\"'
    `$systemKey = [regex]::Match(`$config, `$regex).Groups[1].Value
    # get the certUUID
    `$regex = 'certuuid\":\"(\w+)\"'
    `$certUUID = [regex]::Match(`$config, `$regex).Groups[1].Value

    # Get the key/ cert location
    `$keyLocation = "C:\Program Files\JumpCloud\Plugins\Contrib\client.key"
    `$certLocation = "C:\Program Files\JumpCloud\Plugins\Contrib\client.crt"
    `$caCertLocation = "C:\Program Files\JumpCloud\Plugins\Contrib\ca.crt"

    # Get json certificate data from osquery
    `$certs = . "C:\Program Files\JumpCloud\jcosqueryi" --json "select * from certificates"
    # format the data
    `$certsText = "{``"data``":`$certs}"
    # save the data to a temp file
    `$certJsonFile = "C:\Windows\Temp\jsonFile.txt"
    `$certsText | Out-File -FilePath `$certJsonFile -Force -Encoding utf8
    # submit the request
    C:\ProgramData\chocolatey\bin\curl.exe --cert "`$certLocation" --key "`$keyLocation" --cacert "`$caCertLocation" --header "x-system-id: `$systemKey" --header "x-ssl-client-dn: /CN=`$certUUID/O=JumpCloud" --header "Content-type:application/json " -d @C:\Windows\Temp\jsonFile.txt --url 'https://agent.jumpcloud.com/systeminsights/snapshots/certificates'
    # remove the temp file
    Remove-Item -Path `$certJsonFile
} else {
    Write-Host "Curl might not be installed, system insights will update certificate information on this device within an hour"
}
} else {
if (`$CurrentUser -eq `$null){
    Write-Host "No users are signed into the system. Please ensure $($user.userName) is signed in and retry."
} else {
    Write-Host "Current logged in user, `$CurrentUser, does not match expected certificate user. Please ensure $($user.localUsername) is signed in and retry."
}
# finally clean up temp files:
If (Test-Path "C:\Windows\Temp\$($user.userName)-client-signed.zip"){
    Remove-Item "C:\Windows\Temp\$($user.userName)-client-signed.zip"
}
If (Test-Path "C:\RadiusCert\$($user.userName)-client-signed.pfx"){
    Remove-Item "C:\RadiusCert\$($user.userName)-client-signed.pfx"
}
exit 4
}
"@
                            launchType        = "trigger"
                            trigger           = "$($certInfo.sha1)"
                            commandType       = "windows"
                            shell             = "powershell"
                            timeout           = 600
                            TimeToLiveSeconds = 864000
                            files             = (New-JCCommandFile -certFilePath $userPfxZip -FileName "$($user.userName)-client-signed.zip" -FileDestination "C:\Windows\Temp\$($user.userName)-client-signed.zip")
                        }
                        $NewCommand = New-JcSdkCommand @CommandBody

                    } catch {
                        $status_commandGenerated = $false
                    }
                    # Find newly created command and add system as target
                    $Command = Get-JcSdkCommand -Filter @("trigger:eq:$($certInfo.sha1)", "commandType:eq:windows")
                    $workToBeDone.windowsCommandID = $command.Id

                    $CommandTable = [PSCustomObject]@{
                        commandId            = $workToBeDone.windowsCommandID
                        commandName          = $command.name
                        commandPreviouslyRun = $false
                        commandQueued        = $false
                        systems              = $systemIds
                    }

                    $user.commandAssociations += $CommandTable
                    # Write-Host "[status] Successfully created $($Command.name): User - $($user.userName); OS - Windows"
                    $status_commandGenerated = $true
                }
            }
            if (-Not ($workToBeDone.forceGenerateWindowsCommands) -And ($workToBeDone.windowsCommandID)) {
                $systemIds = (Get-SystemsThatNeedCertWork -userData $user -osType "windows")

                $Command = Get-JcSdkCommand -Filter @("trigger:eq:$($certInfo.sha1)", "commandType:eq:windows")
                $CommandTable = [PSCustomObject]@{
                    commandId            = $workToBeDone.windowsCommandID
                    commandName          = $command.name
                    commandPreviouslyRun = $false
                    commandQueued        = $false
                    systems              = $systemIds
                }

                $user.commandAssociations += $CommandTable

            }
            if (($invokeCommands) -AND ($workToBeDone.remainingWindowsSDevices)) {
                try {
                    $commandStart = Start-JcSdkCommand -Id $workToBeDone.windowsCommandID -SystemIds $workToBeDone.remainingWindowsSDevices.systemId | Out-Null
                    $result_deployed = $true
                } catch {
                    $result_deployed = $false
                }
            }
            # set the command associations
            if (($workToBeDone.remainingWindowsSDevices) -And ($workToBeDone.windowsCommandID)) {
                $workToBeDone.remainingWindowsSDevices | ForEach-Object {
                    try {
                        $commandAssociation = Set-JcSdkCommandAssociation -CommandId:("$($workToBeDone.windowsCommandID)") -Op 'add' -Type:('system') -Id:("$($_.systemId)") | Out-Null
                    } catch {
                        "already exists/ couldn't add" | Out-Null
                    }
                }

            }
        }
        # TODO: get the userIndex only?
        $userObjectFromTable, $userIndex = Get-UserFromTable -userid $user.userid

        switch ($invokeCommands) {
            $true {
                if ($user.commandAssociations) {
                    $user.commandAssociations | ForEach-Object { $_.commandPreviouslyRun = $true }
                    # set the deployed status to true, set the date
                    if (Get-Member -inputObject $user.certInfo -name "deployed" -MemberType Properties) {
                        # if ($userObjectFromTable.certInfo.deployed) {
                        $user.certInfo.deployed = $true
                    } else {
                        $user.certInfo | Add-Member -Name 'deployed' -Type NoteProperty -Value $false

                    }
                    if (Get-Member -inputObject $user.certInfo -name "deploymentDate" -MemberType Properties) {
                        # if ($userObjectFromTable.certInfo.deploymentDate) {
                        $user.certInfo.deploymentDate = (Get-Date -Format "o")

                    } else {
                        $user.certInfo | Add-Member -Name 'deploymentDate' -Type NoteProperty -Value (Get-Date -Format "o")
                    }
                }
            }
            $false {
                $result_deployed = $false
            }
            Default {
            }



        }
    }


    end {
        $resultTable = [ordered]@{
            'Username'          = $user.username;
            'Command Generated' = $status_commandGenerated;
            'Command Deployed'  = $result_deployed
        }
        $workDone = [PSCustomObject]@{
            userIndex                 = $userIndex
            commandAssociationsObject = $user.commandAssociations
            certInfoObject            = $user.certInfo
        }

        return $resultTable, $workDone
    }
}
