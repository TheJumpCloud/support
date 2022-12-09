# READ ONLY API KEY
$JCAPIKEY = 'yourAPIKey'
$JCORGID = 'yourOrgID'
# JUMPCLOUD USER GROUP
$JCUSERGROUP = '5f808a1bb544064831f7c9fd'

# Cert Type Generation Options:
# Chose One Of:
# EmailSAN
# EmailDn
# UsernameCn (Default)
$CertType = "UsernameCn"

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
        # Specifies a path to one or more locations.
        [Parameter(Mandatory = $true,
            HelpMessage = "Path to one or more locations.")]
        [ValidateNotNullOrEmpty()]
        [string]
        $CertOutputPath,
        # Specifies a path to one or more locations.
        [Parameter(Mandatory = $true,
            HelpMessage = "Path to one or more locations.")]
        [ValidateNotNullOrEmpty()]
        [string]
        $ExtensionPath,
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
        [Parameter(Mandatory = $true)]
        [System.Object]
        $user
    )
    begin {


    }
    process {

        #TODO: variable for OU/subj structure
        $userCSR = "$psscriptroot/UserCerts/$($user.username)-cert-req.csr"
        openssl req -nodes -new -key $rootCAKey -passin pass:$($JCORGID) -out "$($userCSR)" -subj "/C=US/ST=Virginia/L=Leesburg/O=61082856bc4bee4ea56d0dfa/OU=IT Department/CN=MyOrg.com"

        switch ($CertType) {
            'EmailSAN' {
            }
            'EmailDn' {
            }
            'UsernameCN' {
                $userKey = "$psscriptroot/UserCerts/$($user.username)-client-signed.key"
                $userCert = "$psscriptroot/UserCerts/$($user.username)-client-signed-cert.crt"
                $userPfx = "$psscriptroot/UserCerts/$($user.username)-client-signed.pfx"

                openssl genrsa -out $userKey 2048
                openssl req -new -key $userKey -out $userCSR -config $ExtensionPath -subj "/C=US/ST=Virginia/L=Leesburg/O=MyOrg/OU=Sales-Radius-Access/CN=$($user.username)"
                openssl x509 -req -in $userCSR -CA $rootCA -CAkey $rootCAKey -days 30 -CAcreateserial -passin pass:$($JCORGID) -out $userCert -extfile $ExtensionPath

                # Combine key and cert to create pfx file
                # openssl pkcs12 -export -out $userPfx -inkey $userKey -in $userCert -passout pass:$($JCORGID)# -legacy
                openssl pkcs12 -export -out $userPfx -inkey $userKey -in $userCert -inkey $userKey -passout pass:$($JCORGID)
                # -legacy
                # openssl pkcs12 -export -out basicDemo-username-client-signed.pfx -inkey basicDemo-username-client-signed.key -in basicDemo-username-client-signed-cert.crt -passout pass:password
                # Output
                openssl x509 -noout -text -in $userCert

                openssl pkcs12 -clcerts -nokeys -in $userPfx -passin pass:$($JCORGID)




                # openssl x509 -req -in "$($userCSR)" -CA $rootCAK -CAkey $rootCAKey -days 30  -CAcreateserial -out $userCERT -subj "/C=US/ST=Colorado/L=Boulder/O=MyOrg/OU=Unit#1/CN=UserRoger" -extensions v3_req -extfile $ExtensionPath

                # openssl x509 -in $userCERT -noout -text

            }
        }

    }
    end {

    }
}

# main
################################################################################

# Get user membership of group
$groupMembers = Get-GroupMembership -groupID $JCUSERGROUP
# Get users associated with this system
# $SystemAssociations = Get-systemAssociation -systemID $systemKey

# Create UserCerts dir
if (Test-Path "$PSScriptRoot/UserCerts") {
    Write-Host "User Cert Directory Exists"
} else {
    Write-Host "Creating User Cert Directory"
    New-Item -ItemType Directory -Path "$PSScriptRoot/UserCerts"
}

# if user from group is on the system, continue with script:
foreach ($user in $groupMembers) {
    # Create the User Certs
    write-host $user.id
    $MatchedUser = get-webjcuser -userID $user.id
    Generate-UserCert -CertType 'UsernameCN' -CertOutputPath "$psscriptroot/UserCerts" -ExtensionPath "$psscriptroot/Extensions/extensions-usernameCN.cnf" -user $MatchedUser -rootCAKey "$psscriptroot/Cert/selfsigned-ca-key.pem" -rootCA "$psscriptroot/Cert/selfsigned-ca-cert.pem"
}