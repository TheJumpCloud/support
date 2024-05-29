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
        # prompt replace existing certificate
        [Parameter(HelpMessage = 'When specified, this parameter will prompt for user imput and ask if generated commands should be invoked on associated systems')]
        [switch]
        $prompt
    )

    begin {
        switch ($forceInvokeCommands) {
            $true {
                $invokeCommands = $true
            }
            $false {
                $invokeCommands = $false
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

            #### Begin removal of queued commands + existing command:
            # remove commands
            $radiusCommandsByUser = Get-CommandByUsername -username $user.username
            foreach ($command in $radiusCommandsByUser) {
                Remove-JcSdkCommand -Id $command.id | Out-Null
            }
            # remove queued commands
            $queuedRadiusCommandsByUser = Get-queuedCommandByUser -username $user.username
            foreach ($queuedCommand in $queuedRadiusCommandsByUser) {
                Clear-JCQueuedCommand -workflowId $queuedCommand.id | Out-Null
            }
            # now clear out the user command associations from users.json
            $User.commandAssociations = @()
            #### End removal of queued commands + existing command
            # Get certificate and zip to upload to Commands
            $userCertFiles = Get-ChildItem -Path "$JCScriptRoot/UserCerts" -Filter "$($user.userName)-*"
            # set crt and pfx filepaths
            $userCrt = ($userCertFiles | Where-Object { $_.Name -match "crt" }).FullName
            $userPfx = ($userCertFiles | Where-Object { $_.Name -match "pfx" }).FullName
            # define .zip name
            $userPfxZip = "$JCScriptRoot/UserCerts/$($user.userName)-client-signed.zip"
            # get certInfo for commands:
            $certInfo = Get-CertInfo -UserCerts -username $user.username
            # determine certType
            switch ($JCR_CERT_TYPE) {
                'EmailSAN' {
                    # set cert identifier to SAN email of cert
                    $sanID = Invoke-Expression "$JCR_OPENSSL x509 -in $($userCrt) -ext subjectAltName -noout"
                    $regex = 'email:(.*?)$'
                    $JCR_SUBJECT_HEADERSMatch = Select-String -InputObject "$($sanID)" -Pattern $regex
                    $certIdentifier = $JCR_SUBJECT_HEADERSMatch.matches.Groups[1].value
                    # in macOS search user certs by email
                    $macCertSearch = 'e'
                }
                'EmailDN' {
                    # Else set cert identifier to email of cert subject
                    $regex = 'emailAddress = (.*?)$'
                    $JCR_SUBJECT_HEADERSMatch = Select-String -InputObject "$($certInfo.Subject)" -Pattern $regex
                    $certIdentifier = $JCR_SUBJECT_HEADERSMatch.matches.Groups[1].value
                    # in macOS search user certs by email
                    $macCertSearch = 'e'
                }
                'UsernameCn' {
                    # if username just set cert identifier to username
                    $certIdentifier = $($user.userName)
                    # in macOS search user certs by common name (username)
                    $macCertSearch = 'c'
                }
            }
            # Create the zip
            Compress-Archive -Path $userPfx -DestinationPath $userPfxZip -CompressionLevel NoCompression -Force
            # Find OS of System
            switch ($user.systemAssociations.osFamily) {
                'macOS' {
                    # Get the macOS system ids
                    $systemIds = $user.systemAssociations | Where-Object { $_.osFamily -eq 'macOS' } | Select-Object systemId
                    # If the certificate is already on the device, no need to process the command
                    $systemIds = $systemIds | Where-Object { $_.systemId -notin $user.deploymentInfo.SystemId }
                    # If there are no systemIds to process, skip generating the command:
                    if ($systemIds.count -eq 0) {
                        Write-Warning "There are no remaining macOS systems for $($user.username)'s cert to be installed on"
                        continue
                    }
                    # Check to see if previous commands exist
                    $Command = Get-JCCommand -name "RadiusCert-Install:$($user.userName):MacOSX"

                    if ($Command.Count -ge 1) {
                        # $confirmation = Write-Host "[status] RadiusCert-Install:$($user.userName):MacOSX command already exists, skipping..."
                        $status_commandGenerated = $false
                        continue
                    }

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
networkSsid="$($JCR_NETWORKSSID)"
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
        /bin/launchctl asuser "`$currentUserUID" sudo -iu "`$currentUser" /usr/bin/security import /tmp/$($user.userName)-client-signed.pfx -x -k /Users/$($user.localUsername)/Library/Keychains/login.keychain -P $JCR_USER_CERT_PASS -T "/System/Library/SystemConfiguration/EAPOLController.bundle/Contents/Resources/eapolclient"
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

    # check if the cert secruity preference is set:
    IFS=';' read -ra network <<< "`$JCR_NETWORKSSID"
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
                            trigger           = "RadiusCertInstall"
                            commandType       = "mac"
                            timeout           = 600
                            TimeToLiveSeconds = 864000
                            files             = (New-JCCommandFile -certFilePath $userPfxZip -FileName "$($user.userName)-client-signed.zip" -FileDestination "/tmp/$($user.userName)-client-signed.zip")
                        }
                        $NewCommand = New-JcSdkCommand @CommandBody

                        # Find newly created command and add system as target
                        $Command = Get-JCCommand -name "RadiusCert-Install:$($user.userName):MacOSX"
                        $systemIds | ForEach-Object { Set-JcSdkCommandAssociation -CommandId:("$($Command._id)") -Op 'add' -Type:('system') -Id:("$($_.systemId)") | Out-Null }
                    } catch {
                        $status_commandGenerated = $false
                        # throw $_
                    }

                    $CommandTable = [PSCustomObject]@{
                        commandId            = $command._id
                        commandName          = $command.name
                        commandPreviouslyRun = $false
                        commandQueued        = $false
                        systems              = $systemIds
                    }

                    $user.commandAssociations += $CommandTable

                    # Write-Host "[status] Successfully created $($Command.name): User - $($user.userName); OS - Mac OS X"
                    $status_commandGenerated = $true

                }
                'windows' {
                    # Get the Windows system ids
                    $systemIds = $user.systemAssociations | Where-Object { $_.osFamily -eq 'windows' } | Select-Object systemId
                    # If the certificate is already on the device, no need to process the command
                    $systemIds = $systemIds | Where-Object { $_.systemId -notin $user.deploymentInfo.SystemId }
                    # If there are no systemIds to process, skip generating the command:
                    if ($systemIds.count -eq 0) {
                        Write-Warning "There are no remaining windows systems for $($user.username)'s cert to be installed on"
                        continue
                    }
                    # Check to see if previous commands exist
                    $Command = Get-JCCommand -name "RadiusCert-Install:$($user.userName):Windows"

                    if ($Command.Count -ge 1) {
                        # $confirmation = Write-Host "[status] RadiusCert-Install:$($user.userName):Windows command already exists, skipping..."
                        $status_commandGenerated = $false
                        continue
                    }

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
    `$password = ConvertTo-SecureString -String $JCR_USER_CERT_PASS -AsPlainText -Force
    `$ScriptBlockInstall = { `$password = ConvertTo-SecureString -String $JCR_USER_CERT_PASS -AsPlainText -Force
    Import-PfxCertificate -Password `$password -FilePath "C:\RadiusCert\$($user.userName)-client-signed.pfx" -CertStoreLocation Cert:\CurrentUser\My
    }
    `$imported = Get-PfxData -Password `$password -FilePath "C:\RadiusCert\$($user.userName)-client-signed.pfx"
    # Get Current Certs As User
    `$ScriptBlockCleanup = {
        `$certs = Get-ChildItem Cert:\CurrentUser\My\

        foreach (`$cert in `$certs){
            if (`$cert.subject -match "$($certIdentifier)") {
                if (`$(`$cert.serialNumber) -eq "$($certInfo.serial)"){
                    write-host "Found Cert:``nCert SN: `$(`$cert.serialNumber)"
                } else {
                    write-host "Removing Cert:``nCert SN: `$(`$cert.serialNumber)"
                    Get-ChildItem "Cert:\CurrentUser\My\`$(`$cert.thumbprint)" | remove-item
                }
            }
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
                            trigger           = "RadiusCertInstall"
                            commandType       = "windows"
                            shell             = "powershell"
                            timeout           = 600
                            TimeToLiveSeconds = 864000
                            files             = (New-JCCommandFile -certFilePath $userPfxZip -FileName "$($user.userName)-client-signed.zip" -FileDestination "C:\Windows\Temp\$($user.userName)-client-signed.zip")
                        }
                        $NewCommand = New-JcSdkCommand @CommandBody

                        # Find newly created command and add system as target
                        $Command = Get-JCCommand -name "RadiusCert-Install:$($user.userName):Windows"
                        $systemIds | ForEach-Object { Set-JcSdkCommandAssociation -CommandId:("$($Command._id)") -Op 'add' -Type:('system') -Id:("$($_.systemId)") | Out-Null }
                    } catch {
                        $status_commandGenerated = $false
                        # throw $_
                    }

                    $CommandTable = [PSCustomObject]@{
                        commandId            = $command._id
                        commandName          = $command.name
                        commandPreviouslyRun = $false
                        commandQueued        = $false
                        systems              = $systemIds
                    }

                    $user.commandAssociations += $CommandTable
                    # Write-Host "[status] Successfully created $($Command.name): User - $($user.userName); OS - Windows"
                    $status_commandGenerated = $true

                }
                $null {
                    Write-host "$($user.username) is not associated with any systems, skipping command generation"
                    $status_commandGenerated = $false
                    $result_deployed = $false
                }
            }
            # Update the user table with the information from the generated commands:
            $userObjectFromTable, $userIndex = Get-UserFromTable -userid $user.userid

            Set-UserTable -index $userIndex -commandAssociationsObject $user.commandAssociations
            switch ($invokeCommands) {
                $true {
                    # finally update the user table to note that the command has been run, the cert has been deployed
                    # get the object once more:
                    $userObjectFromTable, $userIndex = Get-UserFromTable -userid $user.userid
                    # Set commandPreviouslyRun property to true if there are command associations to set
                    if ($userObjectFromTable.commandAssociations) {
                        $userObjectFromTable.commandAssociations | ForEach-Object { $_.commandPreviouslyRun = $true }
                        # set the deployed status to true, set the date
                        if (Get-Member -inputObject $userObjectFromTable.certInfo -name "deployed" -MemberType Properties) {
                            # if ($userObjectFromTable.certInfo.deployed) {
                            $userObjectFromTable.certInfo.deployed = $true
                        } else {
                            $userObjectFromTable.certInfo | Add-Member -Name 'deployed' -Type NoteProperty -Value $false

                        }
                        if (Get-Member -inputObject $userObjectFromTable.certInfo -name "deploymentDate" -MemberType Properties) {
                            # if ($userObjectFromTable.certInfo.deploymentDate) {
                            $userObjectFromTable.certInfo.deploymentDate = (Get-Date)

                        } else {

                            $userObjectFromTable.certInfo | Add-Member -Name 'deploymentDate' -Type NoteProperty -Value (Get-Date)
                        }
                        Set-UserTable -index $userIndex -commandAssociationsObject $userObjectFromTable.commandAssociations -certInfoObject $userObjectFromTable.certInfo
                        $invokeCommands = invoke-commandByUserId -userID $user.userId
                        $result_deployed = $true
                    }
                }
                $false {
                    $result_deployed = $false
                }
                Default {
                }
            }


        }
    }


    end {
        #TODO: eventually add message if we fail to generate a command
        $resultTable = [ordered]@{
            'Username'          = $user.username;
            'Command Generated' = $status_commandGenerated;
            'Command Deployed'  = $result_deployed
        }

        return $resultTable
    }
}
