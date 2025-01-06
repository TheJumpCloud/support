# JUMPCLOUD USER GROUP ID
$Global:JCR_USER_GROUP = 'your_radius_user_group'
# USER CERT PASSWORD (this password is sent to the devices via JumpCloud Commands)
$Global:JCR_USER_CERT_PASS = 'secret1234!'
# USER CERT Validity Length (days) (default 1 year)
$Global:JCR_USER_CERT_VALIDITY_DAYS = 365
# ROOT CERT Validity Length (days) (default 3 years)
$Global:JCR_ROOT_CERT_VALIDITY_DAYS = 1095
# Days until cert expire warning length (default: 15 days)
# The tool will display certs that are set to expire if the expiration date is
# within this number of days
$Global:JCR_USER_CERT_EXPIRE_WARNING_DAYS = 15
# List Of Radius Network SSID(s)
# For Multiple SSIDs enter as a single string separated by a semicolon  ex:
# "CorpNetwork_Denver;CorpNetwork_Boulder;CorpNetwork_Boulder 5G;Guest Network"
$Global:JCR_NETWORKSSID = "YOUR_SSID"
# JCR_OPENSSL by default this is (openssl)
# NOTE: If openssl does not work, try using the full path to the openssl file
# MacOS HomeBrew Example: '/usr/local/Cellar/openssl@3/3.1.1/bin/openssl'
$Global:JCR_OPENSSL = 'openssl'
# Enter Cert Subject Headers (do not enter strings with spaces)
$Global:JCR_SUBJECT_HEADERS = [PSCustomObject]@{
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
$Global:JCR_CERT_TYPE = "UsernameCn"

################################################################################
# Do not modify below
################################################################################

$UserAgent_ModuleVersion = '2.0.0'
$UserAgent_ModuleName = 'PasswordlessRadiusConfig'
#Build the UserAgent string
$UserAgent_ModuleName = "JumpCloud_$($UserAgent_ModuleName).PowerShellModule"
$Template_UserAgent = "{0}/{1}"
$UserAgent = $Template_UserAgent -f $UserAgent_ModuleName, $UserAgent_ModuleVersion
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
            throw "Something went wrong... Could not find openssl or the path is incorrect. Please update the `$JCR_OPENSSL variable in the config.ps1 file to the correct path"
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
                if ("legacy.dll" -notin $binItems.Name) {
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
Get-OpenSSLVersion -opensslBinary $JCR_OPENSSL

# Validate no spaces in $JCR_SUBJECT_HEADERS
foreach ($JCR_SUBJECT_HEADERSObj in $JCR_SUBJECT_HEADERS.psObject.Properties) {
    if ($JCR_SUBJECT_HEADERSObj.value -match " ") {
        throw "Subject Header: $($JCR_SUBJECT_HEADERSObj.Name):$($JCR_SUBJECT_HEADERSObj.value) Contains a space character. subject headers cannot contain spaces, please remove and re-run"
    }
}
# Validate API KEY, OrgID, SystemGroupID, length
if (($JCAPIKEY).Length -ne 40) {
    throw "The entered JumpCloud Api Key is not the expected length"
}
if (($JCORGID).Length -ne 24) {
    throw "The entered JumpCloud Organization ID is not the expected length"
}
if (($Global:JCR_USER_GROUP).Length -ne 24) {
    throw "The entered JumpCloud UserGroup ID is not the expected length"
}
