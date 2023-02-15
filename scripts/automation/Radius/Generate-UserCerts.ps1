# Import Global Config:
. "$psscriptroot/config.ps1"
Connect-JCOnline $JCAPIKEY -force

################################################################################
# Do not modify below
################################################################################

# Import the functions
Import-Module "$psscriptroot/RadiusCertFunctions.ps1" -Force

$SystemHash = Get-JCSystem -returnProperties displayName, os

if (Test-Path -Path "$PSScriptRoot/users.json" -PathType Leaf) {
    Write-Host "[status] Found user.json file"
    $userArray = Get-Content -Raw -Path "$PSScriptRoot/users.json" | ConvertFrom-Json -Depth 6
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
if (Test-Path "$PSScriptRoot/UserCerts") {
    Write-Host "[status] User Cert Directory Exists"
} else {
    Write-Host "[status] Creating User Cert Directory"
    New-Item -ItemType Directory -Path "$PSScriptRoot/UserCerts"
}

# if user from group is on the system, continue with script:
foreach ($user in $groupMembers) {
    # Create the User Certs
    $MatchedUser = get-webjcuser -userID $user.id

    Write-Host "Generating Cert for user: $($MatchedUser.username)"

    if ($MatchedUser.id -in $userArray.userId) {
        if (Test-Path -Path "$PSScriptRoot/UserCerts/$($MatchedUser.username)-client-signed.pfx") {
            Write-Host "[status] $($MatchedUser.username) already has certs generated... skipping"
        } else {
            Generate-UserCert -CertType $CertType -user $MatchedUser -rootCAKey "$psscriptroot/Cert/selfsigned-ca-key.pem" -rootCA "$psscriptroot/Cert/selfsigned-ca-cert.pem"
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
            systemAssociations  = $systemAssociations
            commandAssociations = @()
        }

        if (Test-Path -Path "$PSScriptRoot/UserCerts/$($MatchedUser.username)-client-signed.pfx") {
            Write-Host "[status] $($MatchedUser.username) has certs generated... adding to users.json"
        } else {
            Generate-UserCert -CertType $CertType -user $MatchedUser -rootCAKey "$psscriptroot/Cert/selfsigned-ca-key.pem" -rootCA "$psscriptroot/Cert/selfsigned-ca-cert.pem"
        }
        $userArray += $userTable
    }
}

$userArray | ConvertTo-Json -Depth 6 | Out-File "$psscriptroot\users.json"

