# Import Global Config:
. "$psscriptroot/config.ps1"

################################################################################
# Do not modify below
################################################################################

# functions
################################################################################
function get-GroupMembership {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [system.string]
        $groupID
    )
    begin {
        $skip = 0
        $limit = 100
        $headers = @{
            "x-api-key" = $JCAPIKEY
            "x-org-id"  = $JCORGID
        }
        $paginate = $true
        $list = @()
    }
    process {
        while ($paginate) {
            $response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/v2/usergroups/$JCUSERGROUP/membership?limit=$limit&skip=$skip" -Method GET -Headers $headers
            $list += $response
            $skip += $limit
            if ($response.count -lt $limit) {
                $paginate = $false
            }
        }
    }
    end {
        return $list
    }
}

function get-webjcuser {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [system.string]
        $userID
    )
    begin {
        $headers = @{
            "x-api-key" = $JCAPIKEY
            "x-org-id"  = $JCORGID
        }
    }
    process {
        $response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/systemusers/$userID" -Method GET -Headers $headers
    }
    end {
        # return ${id, username, email }
        $userObj = [PSCustomObject]@{
            username = $response.username
            id       = $response._id
            email    = $response.email
        }
        return $userObj
    }
}

function Generate-UserCert {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet("EmailSAN", "EmailDn", "UsernameCN")]
        [system.String]
        $CertType,
        [Parameter(Mandatory = $true,
            HelpMessage = "Path to one or more locations.")]
        [ValidateNotNullOrEmpty()]
        [string]
        $rootCAKey,
        [Parameter(Mandatory = $true,
            HelpMessage = "Path to one or more locations.")]
        [ValidateNotNullOrEmpty()]
        [string]
        $rootCA,
        [Parameter(Mandatory = $true,
            HelpMessage = "User Object Containing, id, username, email")]
        [System.Object]
        $user
    )
    begin {
        if (-Not (Test-Path -Path $rootCAKey)) {
            Throw "RootCAKey could not be found in project direcotry, have you run Generate-Cert.ps1?"
            exit 1
        }
        if (-Not (Test-Path -Path $rootCA)) {
            Throw "RootCA could not be found in project direcotry, have you run Generate-Cert.ps1?"
            exit 1
        }
    }
    process {
        # Set Extension Path
        $opensslBinary = '/usr/local/Cellar/openssl@3/3.0.7/bin/openssl'
        $ExtensionPath = "$psscriptroot/Extensions/extensions-$($CertType).cnf"
        # User Certificate Signing Request:
        $userCSR = "$psscriptroot/UserCerts/$($user.username)-cert-req.csr"
        # Set key, crt, pfx variables:
        $userKey = "$psscriptroot/UserCerts/$($user.username)-$($CertType)-client-signed.key"
        $userCert = "$psscriptroot/UserCerts/$($user.username)-$($CertType)-client-signed-cert.crt"
        $userPfx = "$psscriptroot/UserCerts/$($user.username)-client-signed.pfx"

        switch ($CertType) {
            'EmailSAN' {
                # replace extension subjectAltName
                $extContent = Get-Content -Path $ExtensionPath -Raw
                $extContent -replace ("subjectAltName.*", "subjectAltName = email:$($user.email)") | Set-Content -Path $ExtensionPath -NoNewline -Force
                # Get CSR & Key
                Write-Host "[status] Get CSR & Key"
                Invoke-Expression "$opensslBinary req -newkey rsa:2048 -nodes -keyout $userKey -subj `"/C=$($subj.countryCode)/ST=$($subj.stateCode)/L=$($subj.Locality)/O=$($JCORGID)/OU=$($subj.OrganizationUnit)`" -out $userCSR"
                # take signing request, make cert # specify extensions requets
                Write-Host "[status] take signing request, make cert # specify extensions requets"
                Invoke-Expression "$opensslBinary x509 -req -extfile $ExtensionPath -days $JCUSERCERTVALIDITY -in $userCSR -CA $rootCA -CAkey $rootCAKey -passin pass:$($JCORGID) -CAcreateserial -out $userCert -extensions v3_req"
                # validate the cert we cant see it once it goes to pfx
                Write-Host "[status] validate the cert we cant see it once it goes to pfx"
                Invoke-Expression "$opensslBinary x509 -noout -text -in $userCert"
                # legacy needed if we take a cert like this then pass it out
                Write-Host "[status] legacy needed if we take a cert like this then pass it out"
                Invoke-Expression "$opensslBinary pkcs12 -export -out $userPfx -inkey $userKey -in $userCert -passout pass:$($JCUSERCERTPASS) -legacy"
            }
            'EmailDn' {
                # Create Client cert with email in the subject distinguished name
                Invoke-Expression "$opensslBinary genrsa -out $userKey 2048 -noout"
                # Generate User CSR
                Invoke-Expression "$opensslBinary req -nodes -new -key $rootCAKey -passin pass:$($JCORGID) -out $($userCSR) -subj /C=$($subj.countryCode)/ST=$($subj.stateCode)/L=$($subj.Locality)/O=$($JCORGID)/OU=$($subj.OrganizationUnit)/CN=$($subj.CommonName)"
                Invoke-Expression "$opensslBinary req -new -key $userKey -out $userCsr -config $ExtensionPath -subj `"/C=$($subj.countryCode)/ST=$($subj.stateCode)/L=$($subj.Locality)/O=$($JCORGID)/OU=$($subj.OrganizationUnit)/CN=/emailAddress=$($user.email)`""
                # Gennerate User Cert
                Invoke-Expression "$opensslBinary x509 -req -in $userCsr -CA $rootCA -CAkey $rootCAKey -days $JCUSERCERTVALIDITY -passin pass:$($JCORGID) -CAcreateserial -out $userCert -extfile $ExtensionPath"
                # Combine key and cert to create pfx file
                Invoke-Expression "$opensslBinary pkcs12 -export -out $userPfx -inkey $userKey -in $userCert -passout pass:$($JCUSERCERTPASS) -legacy"
                # Output
                Invoke-Expression "$opensslBinary x509 -noout -text -in $userCert"
                # invoke-expression "$opensslBinary pkcs12 -clcerts -nokeys -in $userPfx -passin pass:$($JCUSERCERTPASS)"
            }
            'UsernameCN' {
                # Create Client cert with email in the subject distinguished name
                Invoke-Expression "$opensslBinary genrsa -out $userKey 2048"
                # Generate User CSR
                Invoke-Expression "$opensslBinary req -nodes -new -key $rootCAKey -passin pass:$($JCORGID) -out $($userCSR) -subj /C=$($subj.countryCode)/ST=$($subj.stateCode)/L=$($subj.Locality)/O=$($JCORGID)/OU=$($subj.OrganizationUnit)/CN=$($subj.CommonName)"
                Invoke-Expression "$opensslBinary req -new -key $userKey -out $userCSR -config $ExtensionPath -subj `"/C=$($subj.countryCode)/ST=$($subj.stateCode)/L=$($subj.Locality)/O=$($JCORGID)/OU=$($subj.OrganizationUnit)/CN=$($user.username)`""
                # Gennerate User Cert
                Invoke-Expression "$opensslBinary x509 -req -in $userCSR -CA $rootCA -CAkey $rootCAKey -days $JCUSERCERTVALIDITY -CAcreateserial -passin pass:$($JCORGID) -out $userCert -extfile $ExtensionPath"
                # Combine key and cert to create pfx file
                Invoke-Expression "$opensslBinary pkcs12 -export -out $userPfx -inkey $userKey -in $userCert -inkey $userKey -passout pass:$($JCUSERCERTPASS) -legacy"
                # Output
                Invoke-Expression "$opensslBinary x509 -noout -text -in $userCert"
                # invoke-expression "$opensslBinary pkcs12 -clcerts -nokeys -in $userPfx -passin pass:$($JCUSERCERTPASS)"
            }
        }

    }
    end {
        # Clean Up User Certs Directory remove non .crt files
        # $userCertFiles = Get-ChildItem -Path "$PSScriptRoot/UserCerts"
        # $userCertFiles | Where-Object { $_.Name -notmatch ".pfx" } | ForEach-Object {
        #     Remove-Item -path $_.fullname
        # }

    }
}

# main
################################################################################
$SystemHash = Get-JCSystem -returnProperties displayName, os

if (Test-Path -Path "$PSScriptRoot/users.json" -PathType Leaf) {
    Write-Host "[status] Found user.json file"
    $userArray = Get-Content -Raw -Path "$PSScriptRoot/users.json" | ConvertFrom-Json -Depth 4
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
        Write-Host "[status] $($MatchedUser.username) not found in users.json, generating cert"
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

        Generate-UserCert -CertType $CertType -user $MatchedUser -rootCAKey "$psscriptroot/Cert/selfsigned-ca-key.pem" -rootCA "$psscriptroot/Cert/selfsigned-ca-cert.pem"

        $userArray += $userTable
    }
}

$userArray | ConvertTo-Json -Depth 4 | Out-File "$psscriptroot\users.json"