# READ ONLY API KEY
$JCAPIKEY = 'yourApiKey'
# JUMPCLOUD ORGID
$JCORGID = 'yourOrgId'
# JUMPCLOUD USER GROUP
$JCUSERGROUP = '635079e21490b90001eb275b'
# USER CERT PASSWORD (user must enter this when importing cert)
$JCUSERCERTPASS = 'secret1234!'
# USER CERT Validity Length (days)
$JCUSERCERTVALIDITY = 365
# OpenSSLBinary by default this is (openssl)
$opensslBinary = 'openssl'
# Enter Cert Subject Headers (do not enter strings with spaces)
$Subj = [PSCustomObject]@{
    countryCode      = "US"
    stateCode        = "CO"
    Locality         = "Boulder"
    Organization     = "JumpCloud"
    OrganizationUnit = "Solutions_Architecture"
    CommonName       = "JumpCloud.com"
}

# Cert Type Generation Options:
# Chose One Of:
# EmailSAN
# EmailDN
# UsernameCn (Default)
$CertType = "EmailSAN"

# When we import this config, this function will run and validate the openSSL binary location
function Get-OpenSSLVerion {
    [CmdletBinding()]
    param (
        [Parameter()]
        [system.string]
        $opensslBinary
    )
    begin {
        $version = openssl version
        $dictionary = @{
            # LibreSSL = [version]"2.8.3"
            OpenSSL = [version]"3.0.0"
        }
        # Determine Libre or Open SSL:
        if ($version -match "LibreSSL|OpenSSL") {
            $Type = $Matches[0]
            [version]$Version = (Select-String -InputObject $version -Pattern "([0-9]+)\.([0-9]+)\.([0-9]+)").matches.value
        }
    }
    process {
        if ($version -lt $dictionary[$Type]) {
            Throw "The installed version of OpenSSL: $Type $Version, does not meet the requirements of this application, please install a later version of at least $Type $Version"
            exit 1
        } else {
            Write-Host "$Type $Version is installed and meets required version for this application"
        }
    }
}
Get-OpenSSLVerion -opensslBinary $opensslBinary