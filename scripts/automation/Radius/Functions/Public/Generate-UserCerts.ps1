# Import Global Config:
. "$JCScriptRoot/Config.ps1"
Connect-JCOnline $JCAPIKEY -force

################################################################################
# Do not modify below
################################################################################

# Check if CA-Key is saved in env
if ($env:certKeyPassword) {
    Write-Host "Found CA-Key password in env"
    # Check if the key.pem works with the password
    $foundKeyPem = Resolve-Path -Path "$JCScriptRoot/Cert/*key.pem"
    $checkKey = openssl rsa -in $foundKeyPem -check -passin pass:$($env:certKeyPassword) 2>&1
    if ($checkKey -match "RSA key ok") {
        Write-Debug "ENV CA-Key password is works with the current key"
    } else {
        Write-Host "CA-Key password is incorrect"
        Get-CertKeyPass
    }
} else {
    # Get CA-Key password
    Write-Host "CA-Key password not found in the ENV"
    Get-CertKeyPass
}

# Import the functions
Import-Module "$JCScriptRoot/Functions/JCRadiusCertDeployment.psm1" -DisableNameChecking -Force

$SystemHash = Get-JCSystem -returnProperties displayName, os

if (Test-Path -Path "$JCScriptRoot/users.json" -PathType Leaf) {
    Write-Host "[status] Found user.json file"
    $userArray = Get-Content -Raw -Path "$JCScriptRoot/users.json" | ConvertFrom-Json -Depth 6
    # If the json is a single item, explicitly make it a list so we can add to it
    If ($userArray.count -eq 1) {
        $array = New-Object System.Collections.ArrayList
        $array.add($userArray)
        $userArray = $array
    }

} else {
    Write-Host "[status] users.json file not found"
    $userArray = @()
}

# Get user membership of group
$groupMembers = Get-GroupMembership -groupID $JCUSERGROUP
if ($groupMembers) {
    Write-Host "[status] Found $($groupmembers.count) users in Radius User Group"
}

# Create UserCerts dir
if (Test-Path "$JCScriptRoot/UserCerts") {
    Write-Host "[status] User Cert Directory Exists"
} else {
    Write-Host "[status] Creating User Cert Directory"
    New-Item -ItemType Directory -Path "$JCScriptRoot/UserCerts"
}

# if user from group is on the system, continue with script:
foreach ($user in $groupMembers) {
    # Create the User Certs
    $MatchedUser = get-webjcuser -userID $user.id
    Write-Host "Generating Cert for user: $($MatchedUser.username)"

    if ($MatchedUser.id -in $userArray.userId) {
        if (Test-Path -Path "$JCScriptRoot/UserCerts/$($MatchedUser.username)-client-signed.pfx") {
            Write-Host "[status] $($MatchedUser.username) already has certs generated... skipping"
        } else {
            Generate-UserCert -CertType $CertType -user $MatchedUser.username -rootCAKey "$JCScriptRoot/Cert/radius_ca_key.pem" -rootCA "$JCScriptRoot/Cert/radius_ca_cert.pem"
        }
    } else {
        Write-Host "[status] $($MatchedUser.username) not found in users.json"

        # Find user system associations
        $SystemUserAssociations = @()
        $SystemUserAssociations += (Get-JCAssociation -Type user -Id $MatchedUser.id -TargetType system | Select-Object @{N = 'SystemID'; E = { $_.targetId } })

        $systemAssociations = @()
        foreach ($system in $SystemUserAssociations) {
            $systemInfo = $SystemHash | Where-Object _id -EQ $system.SystemID
            $systemTable = @{
                systemId    = $systemInfo._id
                displayName = $systemInfo.displayName
                osFamily    = $systemInfo.os
            }
            $systemAssociations += $systemTable
        }

        $userTable = @{
            userId              = $MatchedUser.id
            userName            = $MatchedUser.username
            localUsername       = $(If ($MatchedUser.hasLocalUsername) {
                    $matchedUser.localUsername
                } else {
                    $matchedUser.username
                })
            systemAssociations  = $systemAssociations
            commandAssociations = @()
        }

        if (Test-Path -Path "$JCScriptRoot/UserCerts/$($MatchedUser.username)-client-signed.pfx") {
            Write-Host "[status] $($MatchedUser.username) has certs generated... adding to users.json"
        } else {
            Generate-UserCert -CertType $CertType -user $MatchedUser -rootCAKey "$JCScriptRoot/Cert/radius_ca_key.pem" -rootCA "$JCScriptRoot/Cert/radius_ca_cert.pem"
        }
        $userArray += $userTable
    }
}

$userArray | ConvertTo-Json -Depth 6 | Out-File "$JCScriptRoot\users.json"

