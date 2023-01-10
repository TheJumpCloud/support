# Import Global Config:
. "$psscriptroot/config.ps1"
Connect-JCOnline $JCAPIKEY -force

# Functions
function New-JCCommandFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][System.IO.FileInfo]$certFilePath,
        [Parameter(Mandatory = $true)][String]$FileName,
        [Parameter(Mandatory = $true)][String]$FileDestination
    )
    begin {
        $headers = @{
            "x-api-key" = $JCAPIKEY
            "x-org-id"  = $JCORGID
        }
        $body = @{
            content     = [convert]::ToBase64String((Get-Content -Path $certFilePath -AsByteStream))
            name        = $FileName
            destination = $FileDestination
        }

    }
    process {
        $CommandFile = Invoke-RestMethod -Uri 'https://console.jumpcloud.com/api/files' -Method POST -Headers $headers -Body $body
    }
    end {
        return $CommandFile._id
    }
}
# End Functions

# Get hashtables for users and systems
$UserHash = Get-JCUser -returnProperties username
$SystemHash = Get-JCSystem -returnProperties displayName, os

# Get all users in the defined user group
$JCUSERS = Get-JCUserGroupMember -ByID $JCUSERGROUP

# Find user to system associations
$SystemUserAssociations = @()
$JCUSERS | ForEach-Object {
    $SystemUserAssociations += (Get-JCAssociation -Type user -Id $_.UserID -TargetType system | Select-Object @{N = 'UserID'; E = { $_.id } }, @{N = 'SystemID'; E = { $_.targetId } })
}

# Create commands for each association
foreach ($association in $SystemUserAssociations) {
    # Gather user and system information
    $SystemInfo = $SystemHash | Where-Object { $association.SystemID -eq $_._id }
    $UserInfo = $UserHash | Where-Object { $association.UserID -eq $_._id }

    # Get certificate and zip to upload to Commands
    $userPfx = "$psscriptroot/UserCerts/$($UserInfo.username)-client-signed.pfx"
    $userPfxZip = "$psscriptroot/UserCerts/$($UserInfo.username)-client-signed.zip"

    Compress-Archive -Path $userPfx -DestinationPath $userPfxZip -CompressionLevel NoCompression -Force
    # Find OS of System
    if ($SystemInfo.os -eq 'Mac OS X') {
        # Create new Command and upload the signed pfx
        try {
            $CommandBody = @{
                Name              = "RadiusCert-Install:$($UserInfo.username):$($SystemInfo.displayName)"
                Command           = @"
set -e
unzip -o /tmp/$($UserInfo.username)-client-signed.zip -d /tmp
currentUser=$(/usr/bin/stat -f%Su /dev/console)
currentUserUID=$(id -u "$currentUser")
if [[ $currentUser ==  $($UserInfo.username) ]]; then
    /bin/launchctl asuser "$currentUserUID" sudo -iu "$currentUser" /usr/bin/security import /tmp/$($UserInfo.username)-client-signed.pfx -k /Users/$($UserInfo.username)/Library/Keychains/login.keychain -P $JCUSERCERTPASS
else
    echo "Current logged in user, $currentUser, does not match expected certificate user. Please ensure $($UserInfo.username) is signed in and retry"
    exit 4
fi

"@
                launchType        = "trigger"
                User              = "000000000000000000000000"
                trigger           = "RadiusCertInstall"
                commandType       = "mac"
                timeout           = 600
                TimeToLiveSeconds = 864000
                files             = (New-JCCommandFile -certFilePath $userPfxZip -FileName "$($UserInfo.username)-client-signed.zip" -FileDestination "/tmp/$($UserInfo.username)-client-signed.zip")
            }
            $NewCommand = New-JcSdkCommand @CommandBody

            # Find newly created command and add system as target
            # TODO: Condition for duplicate commands
            $Command = Get-JCCommand -name "RadiusCert-Install:$($UserInfo.username):$($SystemInfo.displayName)"
            Set-JcSdkCommandAssociation -CommandId:("$($Command._id)") -Op 'add' -Type:('system') -Id:("$($association.SystemID)") | Out-Null
        } catch {
            throw $_
        }
        Write-Host "[status] Successfully created $($Command.name): User - $($UserInfo.Username); System - $($SystemInfo.displayName)"
    } elseif ($SystemInfo.os -eq 'Windows') {
        try {
            $CommandBody = @{
                Name              = "RadiusCert-Install:$($UserInfo.username):$($SystemInfo.displayName)"
                Command           = @"
`$CurrentUser = ((Get-WMIObject -ClassName Win32_ComputerSystem).Username).Split('\')[1]
if (`$CurrentUser -eq "$($UserInfo.Username)") {
    if (-not(Get-InstalledModule -Name RunAsUser)) {
        Write-Host "RunAsUser Module not installed, Installing..."
        Install-Module RunAsUser -Force
        Import-Module RunAsUser -Force
    } else {
        Write-Host "RunAsUser Module installed, importing into session..."
        Import-Module RunAsUser -Force
    }
    Expand-Archive -LiteralPath C:\Windows\Temp\$($UserInfo.username)-client-signed.zip -DestinationPath C:\Windows\Temp -Force
    `$password = ConvertTo-SecureString -String $JCUSERCERTPASS -AsPlainText -Force
    `$ScriptBlock = { `$password = ConvertTo-SecureString -String "secret1234!" -AsPlainText -Force
     Import-PfxCertificate -Password `$password -FilePath "C:\Windows\Temp\$($UserInfo.username)-client-signed.pfx" -CertStoreLocation Cert:\CurrentUser\My
}
     Write-Host "Importing Pfx Certificate for $($UserInfo.username)"
    `$JSON = Invoke-AsCurrentUser -ScriptBlock `$ScriptBlock -CaptureOutput
    `$JSON
} else {
    Write-Host "Current logged in user, `$CurrentUser, does not match expected certificate user. Please ensure $($UserInfo.Username) is signed in and retry."
    exit 4
}
"@
                launchType        = "trigger"
                trigger           = "RadiusCertInstall"
                commandType       = "windows"
                shell             = "powershell"
                timeout           = 600
                TimeToLiveSeconds = 864000
                files             = (New-JCCommandFile -certFilePath $userPfxZip -FileName "$($UserInfo.username)-client-signed.zip" -FileDestination "C:\Windows\Temp\$($UserInfo.username)-client-signed.zip")
            }
            $NewCommand = New-JcSdkCommand @CommandBody

            # Find newly created command and add system as target
            $Command = Get-JCCommand -name "RadiusCert-Install:$($UserInfo.username):$($SystemInfo.displayName)"
            Set-JcSdkCommandAssociation -CommandId:("$($Command._id)") -Op 'add' -Type:('system') -Id:("$($association.SystemID)") | Out-Null
        } catch {
            throw $_
        }
        Write-Host "[status] Successfully created $($Command.name): User - $($UserInfo.Username); System - $($SystemInfo.displayName)"
    } else {
        continue
    }
}

# Invoke Commands
Write-Host "[status] Invoking RadiusCert-Install Commands"
$confirmation = Read-Host "Are you sure you want to proceed? [y/n]"
$CommandArray = @()
$RadiusCommands = Get-JCCommand | Where-Object trigger -Like 'RadiusCertInstall'


while ($confirmation -ne 'y') {
    if ($confirmation -eq 'n') {
        Write-Host "[status] To invoke the commands at a later time, run the following script: $PSScriptRoot/Monitor-Commands.ps1"
        Write-Host "[status] Exiting..."

        foreach ($command in $RadiusCommands) {
            $CommandTable = [PSCustomObject]@{
                commandId            = $command._id
                commandName          = $command.name
                commandPreviouslyRun = $false
                commandQueued        = $false
                lastRun              = ""
                resultTimestamp      = ""
                result               = ""
                exitCode             = ""
            }
            $CommandArray += $CommandTable
        }
        $CommandArray | ConvertTo-Json | Out-File "$psscriptroot\commands.json"
        exit
    }
}
[void](Invoke-JCCommand -trigger 'RadiusCertInstall')
Write-Host "[status] Commands Invoked"

$RadiusCommands | ForEach-Object {
    $CommandTable = [PSCustomObject]@{
        commandId            = $command._id
        commandName          = $command.name
        commandPreviouslyRun = $true
        commandQueued        = $false
        lastRun              = (Get-Date -Format o -AsUTC)
        resultTimestamp      = ""
        result               = ""
        exitCode             = ""
    }
    $CommandArray += $CommandTable
}

$CommandArray | ConvertTo-Json | Out-File "$psscriptroot\commands.json"

Write-Host "[status] Run the Monitor-Commands.ps1 script to track command results and output results"
Write-Host "[status] Exiting..."
