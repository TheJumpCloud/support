# READ ONLY API KEY
$JCAPIKEY = 'yourApiKey'
# JUMPCLOUD ORGID
$JCORGID = 'yourOrgId'
# JUMPCLOUD USER GROUP
$JCUSERGROUP = '635079e21490b90001eb275b'
# USER CERT PASSWORD (user must enter this when importing cert)
$JCUSERCERTPASS = 'secret1234!'
# USER CERT Validity Length (days)
$JCUSERCERTVALIDITY = 90
# OpenSSLBinary by default this is (openssl)
# NOTE: If openssl does not work, try using the full path to the openssl file
# Windows Example: C:\Program Files\OpenSSL-Win64\bin\openssl.exe
# MacOS HomeBrew Example: '/usr/local/Cellar/openssl@3/3.0.7/bin/openssl'
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
$CertType = "UsernameCn"

################################################################################
# Do not modify below
################################################################################

# When we import this config, this function will run and validate the openSSL binary location
function Get-OpenSSLVersion {
    [CmdletBinding()]
    param (
        [Parameter()]
        [system.string]
        $opensslBinary
    )
    begin {
        try {
            $version = Invoke-Expression "$opensslBinary version"
        } catch {
            throw "Something went wrong... Could not find openssl or the path is incorrect. Please update the `$opensslBinary variable in the config.ps1 file to the correct path"
        }

        # Required OpenSSL Version
        $OpenSSLVersion = [version]"3.0.0"

        # Determine Libre or Open SSL:
        if ($version -match "LibreSSL") {
            Throw "LibreSSL does not meet the requirements of this application, please install OpenSSL v3.0.0 or later"
        } else {
            [version]$Version = (Select-String -InputObject $version -Pattern "([0-9]+)\.([0-9]+)\.([0-9]+)").matches.value
        }
    }
    process {
        if ($version -lt $OpenSSLVersion) {
            Throw "The installed version of OpenSSL: OpenSSL $Version, does not meet the requirements of this application, please install a later version of at least $Type $Version"
            exit 1
        } else {
            Write-Host "OpenSSL $Version is installed and meets required version for this application"
        }
    }
}
Get-OpenSSLVersion -opensslBinary $opensslBinary