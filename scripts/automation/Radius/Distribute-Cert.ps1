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
                Name        = "RadiusCert-Install:$($UserInfo.username):$($SystemInfo.displayName)"
                Command     = @"
unzip /tmp/$($UserInfo.username)-client-signed.zip
security import /tmp/$($UserInfo.username)-client-signed.pfx -k /Users/$($UserInfo.username)/Library/Keychains/login.keychain -P $JCUSERCERTPASS
"@
                launchType  = "trigger"
                User        = "000000000000000000000000"
                trigger     = "RadiusCertInstall"
                commandType = "mac"
                timeout     = 600
                files       = (New-JCCommandFile -certFilePath $userPfxZip -FileName "$($UserInfo.username)-client-signed.zip" -FileDestination "/tmp/$($UserInfo.username)-client-signed.zip")
            }
            $NewCommand = New-JCSdkCommand @CommandBody

            # Find newly created command and add system as target
            $Command = Get-JCCommand -name "RadiusCert-Install:$($UserInfo.username):$($SystemInfo.displayName)"
            Add-JCCommandTarget -CommandID:$Command._id -SystemID:$SystemInfo._id | Out-Null
        } catch {
            throw $_
        }
        Write-Host "Successfully created $($Command.name): User - $($UserInfo.Username); System - $($SystemInfo.displayName)"
    } elseif ($SystemInfo.os -eq 'Windows') {
        try {
            $CommandBody = @{
                Name        = "RadiusCert-Install:$($UserInfo.username):$($SystemInfo.displayName)"
                Command     = @"
if (`$env:username -eq $($UserInfo.Username)) {
    if (-not(Get-InstalledModule -Name RunAsUser)) {
        Install-Module RunAsUser -Force
        Import-Module RunAsUser -Force
    } else {
        Import-Module RunAsUser -Force
    }
    Expand-Archive -LiteralPath C:\Windows\Temp\$($UserInfo.username)-client-signed.zip -DestinationPath C:\Windows\Temp -Force
    `$password = ConvertTo-SecureString -String $JCUSERCERTPASS -AsPlainText -Force
    `$ScriptBlock = { Get-ChildItem -Path C:\Windows\Temp\$($UserInfo.username)-client-signed.pfx | Import-PfxCertificate -CertStoreLocation Cert:\CurrentUser\My -Password `$password }
    `$JSON = Invoke-AsCurrentUser -ScriptBlock `$ScriptBlock -CaptureOutput
    `$JSON | ConvertFrom-JSON
} else {
    Write-Error "Current logged in user, `$env:username, does not match expected certificate user, please ensure $($UserInfo.Username) is signed in and retry."
    exit 4
}
"@
                launchType  = "trigger"
                trigger     = "RadiusCertInstall"
                commandType = "windows"
                shell       = "powershell"
                timeout     = 600
                files       = (New-JCCommandFile -certFilePath $userPfxZip -FileName "$($UserInfo.username)-client-signed.zip" -FileDestination "C:\Windows\Temp\$($UserInfo.username)-client-signed.zip")
            }
            $NewCommand = New-JCSdkCommand @CommandBody

            # Find newly created command and add system as target
            $Command = Get-JCCommand -name "RadiusCert-Install:$($UserInfo.username):$($SystemInfo.displayName)"

            #TODO: ADD COMMAND-SYSTEM ASSOCIATIONS
        } catch {
            throw $_
        }
        Write-Host "Successfully created $($Command.name): User - $($UserInfo.Username); System - $($SystemInfo.displayName)"

        #TODO: CREATE WATCHER FUNCTION TO MONITOR COMMAND RESULTS/STATUS
    } else { continue }
}
