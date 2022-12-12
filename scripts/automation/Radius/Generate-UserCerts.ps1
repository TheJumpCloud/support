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
            $response = Invoke-restmethod -Uri "https://console.jumpcloud.com/api/v2/usergroups/$JCUSERGROUP/membership?limit=$limit&skip=$skip" -Method GET -Headers $headers
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


function get-systemAssociation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [system.string]
        $systemID
    )
    begin {
        $skip = 0
        $limit = 100
        $paginate = $true
        $headers = @{
            "x-api-key" = $JCAPIKEY
            "x-org-id"  = $JCORGID
        }
        $list = @()
    }
    process {
        while ($paginate) {
            $response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/v2/systems/$systemID/associations?targets=user&$limit&skip=$skip" -Method GET -Headers $headers
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
        $ExtensionPath = "$psscriptroot/Extensions/extensions-$($CertType).cnf"
        # Generate User Certificate Signing Request:
        $userCSR = "$psscriptroot/UserCerts/$($user.username)-cert-req.csr"
        openssl req -nodes -new -key $rootCAKey -passin pass:$($JCORGID) -out "$($userCSR)" -subj "/C=$($subj.countryCode)/ST=$($subj.stateCode)/L=$($subj.Locality)/O=$($JCORGID)/OU=$($subj.OrganizationUnit)/CN=$($subj.CommonName)"
        # Set key, crt, pfx variables:
        $userKey = "$psscriptroot/UserCerts/$($user.username)-$($CertType)-client-signed.key"
        $userCert = "$psscriptroot/UserCerts/$($user.username)-$($CertType)-client-signed-cert.crt"
        $userPfx = "$psscriptroot/UserCerts/$($user.username)-client-signed.pfx"

        switch ($CertType) {
            'EmailSAN' {
                # replace extension subjectAltName
                $extContent = Get-Content -Path $ExtensionPath -Raw
                $extContent -replace ("subjectAltName.*", "subjectAltName = email:$($user.email)") | Set-Content -Path $ExtensionPath -NoNewline -Force
                # Create Client cert with email in the subject distinguished name
                openssl genrsa -out $userKey 2048
                openssl req -new -key $userKey -out $userCSR -config $ExtensionPath -subj "$($userCSR)" -subj "/C=$($subj.countryCode)/ST=$($subj.stateCode)/L=$($subj.Locality)/O=$($JCORGID)/OU=$($subj.OrganizationUnit)"
                openssl x509 -req -in $userCSR -CA $rootCA -CAkey $rootCAKey -days 30 -CAcreateserial -passin pass:$($JCORGID) -out $userCert -extfile $ExtensionPath

                # Combine key and cert to create pfx file
                openssl pkcs12 -export -out $userPfx -inkey $userKey -in $userCert -passout pass:$($JCORGID)

                # Output
                openssl x509 -noout -text -in $userCert
                openssl pkcs12 -clcerts -nokeys -in $userPfx -passin pass:$($JCORGID)
            }
            'EmailDn' {
                # Create Client cert with email in the subject distinguished name
                openssl genrsa -out $userKey 2048 -noout
                openssl req -new -key $userKey -out $userCsr -config $ExtensionPath -subj "$($userCSR)" -subj "/C=$($subj.countryCode)/ST=$($subj.stateCode)/L=$($subj.Locality)/O=$($JCORGID)/OU=$($subj.OrganizationUnit)/CN=/emailAddress=$($user.email)"
                openssl x509 -req -in $userCsr -CA $rootCA -CAkey $rootCAKey -days 30 -passin pass:$($JCORGID) -CAcreateserial -out $userCert -extfile $ExtensionPath

                # Combine key and cert to create pfx file
                openssl pkcs12 -export -out $userPfx -inkey $userKey -in $userCert -passout pass:$($JCORGID)

                # Output
                openssl x509 -noout -text -in $userCert
                openssl pkcs12 -clcerts -nokeys -in $userPfx -passin pass:$($JCORGID)
            }
            'UsernameCN' {
                # Create Client cert with email in the subject distinguished name
                openssl genrsa -out $userKey 2048
                openssl req -new -key $userKey -out $userCSR -config $ExtensionPath -subj "$($userCSR)" -subj "/C=$($subj.countryCode)/ST=$($subj.stateCode)/L=$($subj.Locality)/O=$($JCORGID)/OU=$($subj.OrganizationUnit)/CN=$($user.username)"
                openssl x509 -req -in $userCSR -CA $rootCA -CAkey $rootCAKey -days 30 -CAcreateserial -passin pass:$($JCORGID) -out $userCert -extfile $ExtensionPath

                # Combine key and cert to create pfx file
                openssl pkcs12 -export -out $userPfx -inkey $userKey -in $userCert -inkey $userKey -passout pass:$($JCORGID)

                # Output
                openssl x509 -noout -text -in $userCert
                openssl pkcs12 -clcerts -nokeys -in $userPfx -passin pass:$($JCORGID)
            }
        }

    }
    end {
        # Clean Up User Certs Directory remove non .crt files
        $userCertFiles = Get-ChildItem -Path "$PSScriptRoot/UserCerts"
        $userCertFiles | Where-Object { $_.Name -notmatch ".crt" } | ForEach-Object {
            Remove-Item -path $_.fullname
        }

    }
}

# main
################################################################################

# Get user membership of group
$groupMembers = Get-GroupMembership -groupID $JCUSERGROUP
if ($groupMembers) {
    Write-Host "[status] Found $($groupmembers.count) users in Radius User Group"
}
# Get users associated with this system
# $SystemAssociations = Get-systemAssociation -systemID $systemKey

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
    write-host "Generating Cert for user: $($MatchedUser.username)"
    Generate-UserCert -CertType $CertType -user $MatchedUser -rootCAKey "$psscriptroot/Cert/selfsigned-ca-key.pem" -rootCA "$psscriptroot/Cert/selfsigned-ca-cert.pem"
}