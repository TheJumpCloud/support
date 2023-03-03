# Import Global Config:
. "$JCScriptRoot/config.ps1"
Connect-JCOnline $JCAPIKEY -force

################################################################################
# Do not modify below
################################################################################

# Import the functions
Import-Module "$JCScriptRoot/Functions/JCRadiusCertDeployment.psm1" -DisableNameChecking -Force

# Import the users.json file and convert to PSObject
$userArray = Get-Content -Raw -Path "$JCScriptRoot/users.json" | ConvertFrom-Json -Depth 6
# Check to see if previous commands exist
$RadiusCertCommands = Get-JCCommand | Where-Object { $_.Name -like 'RadiusCert-Install*' }

if ($RadiusCertCommands.Count -ge 1) {
    Write-Host "[status] $([char]0x1b)[96mRadiusCert commands detected, please make a selection."
    Write-Host "1: Press '1' to generate new commands for ALL users. $([char]0x1b)[96mNOTE: This will remove any previously generated Radius User Certificate Commands titled 'RadiusCert-Install:*'"
    Write-Host "2: Press '2' to generate new commands for NEW RADIUS users. $([char]0x1b)[96mNOTE: This will only generate commands for users who did not have a cert previously"
    Write-Host "E: Press 'E' to exit."
    $confirmation = Read-Host "Please make a selection"
    while ($confirmation -ne 'E') {
        if ($confirmation -eq '1') {
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
            break
        } elseif ($confirmation -eq '2') {
            Write-Host "[status] Proceeding with execution"
            break
        }
    }

    # Break out of the scriptblock and return to main menu
    if ($confirmation -eq 'E') {
        break
    }
}

# Create commands for each user
foreach ($user in $userArray) {
    # Get certificate and zip to upload to Commands
    $userCertFiles = Get-ChildItem -Path "$JCScriptRoot/UserCerts" -Filter "$($user.userName)*"
    # set crt and pfx filepaths
    $userCrt = ($userCertFiles | Where-Object { $_.Name -match "crt" }).FullName
    $userPfx = ($userCertFiles | Where-Object { $_.Name -match "pfx" }).FullName
    # define .zip name
    $userPfxZip = "$JCScriptRoot/UserCerts/$($user.userName)-client-signed.zip"
    # get certInfo for commands:
    $certInfo = Invoke-Expression "$opensslBinary x509 -in $($userCrt) -enddate -serial -subject -issuer -noout"
    $certHash = @{}
    $certInfo | ForEach-Object {
        $property = $_ | ConvertFrom-StringData
        $certHash += $property
    }
    switch ($certType) {
        'EmailSAN' {
            # set cert identifier to SAN email of cert
            $sanID = Invoke-Expression "$opensslBinary x509 -in $($userCrt) -ext subjectAltName -noout"
            $regex = 'email:(.*?)$'
            $subjMatch = Select-String -InputObject "$($sanID)" -Pattern $regex
            $certIdentifier = $subjMatch.matches.Groups[1].value
            # in macOS search user certs by email
            $macCertSearch = 'e'
        }
        'EmailDN' {
            # Else set cert identifier to email of cert subject
            $regex = 'emailAddress = (.*?)$'
            $subjMatch = Select-String -InputObject "$($certHash.Subject)" -Pattern $regex
            $certIdentifier = $subjMatch.matches.Groups[1].value
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
    if ($user.systemAssociations.osFamily -contains 'Mac OS X') {
        # Get the macOS system ids
        $systemIds = $user.systemAssociations | Where-Object { $_.osFamily -eq 'Mac OS X' } | Select-Object systemId

        # Check to see if previous commands exist
        $Command = Get-JCCommand -name "RadiusCert-Install:$($user.userName):MacOSX"

        if ($Command.Count -ge 1) {
            $confirmation = Write-Host "[status] RadiusCert-Install:$($user.userName):MacOSX command already exists, skipping..."
            continue
        }

        # TODO: is common name the same depending on the CertType?
        # Create new Command and upload the signed pfx
        try {
            $CommandBody = @{
                Name              = "RadiusCert-Install:$($user.userName):MacOSX"
                Command           = @"
set -e
unzip -o /tmp/$($user.userName)-client-signed.zip -d /tmp
currentUser=`$(/usr/bin/stat -f%Su /dev/console)
currentUserUID=`$(id -u "`$currentUser")
currentCertSN="$($certHash.serial)"
networkSsid="$($NETWORKSSID)"
if [[ `$currentUser ==  $($user.userName) ]]; then
    certs=`$(security find-certificate -a -$($macCertSearch) "$($certIdentifier)" -Z /Users/$($user.userName)/Library/Keychains/login.keychain)
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
                # if cert is installed, no need to update
                import=false
            else
                echo "Removing previously installed radius cert:"
                echo "SN: `${arraySN[`$i]} SHA: `${arraySHA[`$i]}"
                security delete-certificate -Z "`${arraySHA[`$i]}" /Users/$($user.userName)/Library/Keychains/login.keychain
            fi
        done

    else
        echo "array length mismatch, will not delete old certs"
    fi

    if [[ `$import == true ]]; then
        /bin/launchctl asuser "`$currentUserUID" sudo -iu "`$currentUser" /usr/bin/security import /tmp/$($user.userName)-client-signed.pfx -k /Users/$($user.userName)/Library/Keychains/login.keychain -P $JCUSERCERTPASS -T "/System/Library/SystemConfiguration/EAPOLController.bundle/Contents/Resources/eapolclient"
        if [[ `$? -eq 0 ]]; then
            echo "Import Success"
        else
            echo "import failed"
            exit 4
        fi
        # set ssid info; this prevents multiple password prompts
        /bin/launchctl asuser "`$currentUserUID" sudo -iu "`$currentUser" /usr/bin/security set-identity-preference -s "com.apple.network.eap.user.identity.wlan.ssid.`$networkSsid" -$($macCertSearch) "$($certIdentifier)"
        if [[ `$? -eq 0 ]]; then
            echo "SSID and certificate linked"
        else
            echo "Could not associate SSID and certifiacte"
        fi
    else
        echo "cert already imported"
    fi

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
    echo "Current logged in user, `$currentUser, does not match expected certificate user. Please ensure $($user.userName) is signed in and retry"
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
            # TODO: Condition for duplicate commands
            $Command = Get-JCCommand -name "RadiusCert-Install:$($user.userName):MacOSX"
            $systemIds | ForEach-Object { Set-JcSdkCommandAssociation -CommandId:("$($Command._id)") -Op 'add' -Type:('system') -Id:("$($_.systemId)") | Out-Null }
        } catch {
            throw $_
        }

        $CommandTable = [PSCustomObject]@{
            commandId            = $command._id
            commandName          = $command.name
            commandPreviouslyRun = $false
            commandQueued        = $false
            systems              = $systemIds
        }

        $user.commandAssociations += $CommandTable

        Write-Host "[status] Successfully created $($Command.name): User - $($user.userName); OS - Mac OS X"
    }
    if ($user.systemAssociations.osFamily -contains 'Windows') {
        # Get the Windows system ids
        $systemIds = $user.systemAssociations | Where-Object { $_.osFamily -eq 'Windows' } | Select-Object systemId

        # Check to see if previous commands exist
        $Command = Get-JCCommand -name "RadiusCert-Install:$($user.userName):Windows"

        if ($Command.Count -ge 1) {
            $confirmation = Write-Host "[status] RadiusCert-Install:$($user.userName):Windows command already exists, skipping..."
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
`$CurrentUser = ((Get-WMIObject -ClassName Win32_ComputerSystem).Username).Split('\')[1]
if (`$CurrentUser -eq "$($user.userName)") {
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
    `$password = ConvertTo-SecureString -String $JCUSERCERTPASS -AsPlainText -Force
    `$ScriptBlockInstall = { `$password = ConvertTo-SecureString -String "secret1234!" -AsPlainText -Force
    Import-PfxCertificate -Password `$password -FilePath "C:\RadiusCert\$($user.userName)-client-signed.pfx" -CertStoreLocation Cert:\CurrentUser\My
    }
    `$imported = Get-PfxData -Password `$password -FilePath "C:\RadiusCert\$($user.userName)-client-signed.pfx"
    # Get Current Certs As User
    `$ScriptBlockCleanup = {
        `$certs = Get-ChildItem Cert:\CurrentUser\My\

        foreach (`$cert in `$certs){
            if (`$cert.subject -match "$($certIdentifier)") {
                if (`$(`$cert.serialNumber) -eq "$($certHash.serial)"){
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
    if (`$certValidate){
        Write-Host "Cert was installed"
    } else {
        Throw "Cert was not installed"
    }
} else {
    Write-Host "Current logged in user, `$CurrentUser, does not match expected certificate user. Please ensure $($user.userName) is signed in and retry."
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
            throw $_
        }

        $CommandTable = [PSCustomObject]@{
            commandId            = $command._id
            commandName          = $command.name
            commandPreviouslyRun = $false
            commandQueued        = $false
            systems              = $systemIds
        }

        $user.commandAssociations += $CommandTable
        Write-Host "[status] Successfully created $($Command.name): User - $($user.userName); OS - Windows"
    }
}

# Invoke Commands
$confirmation = Read-Host "Would you like to invoke commands? [y/n]"
$UserArray | ConvertTo-Json -Depth 6 | Out-File "$JCScriptRoot\users.json"

while ($confirmation -ne 'y') {
    if ($confirmation -eq 'n') {
        Write-Host "[status] To invoke the commands at a later time, select option '4' to monitor your User Certification Distribution"
        Write-Host "[status] Returning to main menu"
        exit
    }
    $confirmation = Read-Host "Would you like to invoke commands? [y/n]"
}

$invokeCommands = Invoke-CommandsRetry -jsonFile "$JCScriptRoot\users.json"
Write-Host "[status] Commands Invoked"

# Set commandPreviouslyRun property to true
$userArray.commandAssociations | ForEach-Object { $_.commandPreviouslyRun = $true }

$UserArray | ConvertTo-Json -Depth 6 | Out-File "$JCScriptRoot\users.json"

Write-Host "[status] Select option '4' to monitor your User Certification Distribution"
Write-Host "[status] Returning to main menu"