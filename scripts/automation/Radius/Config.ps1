# READ/ WRITE API KEY
$JCAPIKEY = 'YOURAPIKEY'
# JUMPCLOUD ORGID
$JCORGID = 'YOURORGID'
# JUMPCLOUD USER GROUP
$JCUSERGROUP = 'YOURJCUSERGROUP'
# USER CERT PASSWORD (user must enter this when importing cert)
$JCUSERCERTPASS = 'secret1234!'
# USER CERT Validity Length (days)
$JCUSERCERTVALIDITY = 90
# OpenSSLBinary by default this is (openssl)
# NOTE: If openssl does not work, try using the full path to the openssl file
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
            $version = Invoke-Expression "& '$opensslBinary' version"
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

        # Determine if windows:
        if ([System.Environment]::OSVersion.Platform -match "Win") {
            # If env variable exists, skip check for subsequent runs of ./config.ps1
            if ($env:OPENSSL_MODULES) {
                $binItems = Get-ChildItem -Path $env:OPENSSL_MODULES
                if ("legacy.dll" -in $binItems.Name) {
                    Write-Host "legacy.dll module set through environment variable"
                } else {
                    Throw "The required OpenSSL 'legacy.dll' file was not found in the bin path $PathDirectory. This is required to create certificates. `nIf this module file is located elsewhere, you may specify the path to that directory in this powershell session using this command: '`$env:OPENSSL_MODULES = C:/Path/To/Directory' "
                }
            } else {
                # Try to point to the Legacy.dll file
                Throw "The required OpenSSL 'legacy.dll' file is required for this project. This module file is required to create certificates. `nIf this module file is located elsewhere, you may specify the path to that directory in this powershell session using this command: '`$env:OPENSSL_MODULES = C:/Path/To/openSSL_Directory/' Where the legacy.dll file is in openSSL_Directory "

            }

        }
    }
    process {
        if ($version -lt $OpenSSLVersion) {
            Throw "The installed version of OpenSSL: OpenSSL $Version, does not meet the requirements of this application, please install a later version of at least $Type $Version"
            exit 1
        }
    }
}
Get-OpenSSLVersion -opensslBinary $opensslBinary

# Validate no spaces in $Subj
foreach ($subjObj in $subj.psObject.Properties) {
    if ($subjObj.value -match " ") {
        throw "Subject Header: $($subjObj.Name):$($subjObj.value) Contains a space character. subject headers cannot contain spaces, please remove and re-run"
    }
}
