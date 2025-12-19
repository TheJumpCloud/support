# Load all functions from private folders
$Private = @( Get-ChildItem -Path "$PSScriptRoot/Functions/Private/*.ps1" -Recurse)
foreach ($Import in $Private) {
    try {
        . $Import.FullName
    } catch {
        Write-Error -Message "Failed to import function $($Import.FullName): $_"
    }
}

# Load all public functions:
$Public = @( Get-ChildItem -Path "$PSScriptRoot/Functions/Public/*.ps1" -Recurse)
foreach ($Import in $Public) {
    try {
        . $Import.FullName
    } catch {
        Write-Error -Message "Failed to import function $($Import.FullName): $_"
    }
}

# setup:
$PSDefaultParameterValues = $global:PSDefaultParameterValues.Clone()

# build required users.json file:
# set script root:
$global:JCRScriptRoot = "$PSScriptRoot"

# from the settings file we should have a location for the certs and user certs



# Export module member
Export-ModuleMember -Function $Public.BaseName -Alias *

# Set the module config
$global:JCRConfigTemplate = @{
    'userGroup'                 = @{
        value       = $null;
        write       = $true;
        copy        = $true;
        required    = $true;
        placeholder = '<UserGroupID>';
        type        = 'string'
    }
    'certSecretPass'            = @{
        value       = $null;
        write       = $true;
        copy        = $true;
        required    = $true;
        placeholder = '<CertPassword>';
        type        = 'string'
    }
    'userCertValidityDays'      = @{
        value       = 365;
        write       = $true;
        copy        = $true;
        required    = $true;
        placeholder = '<365>';
        type        = 'int'
    }
    'caCertValidityDays'        = @{
        value       = 1095;
        write       = $true;
        copy        = $true;
        required    = $true;
        placeholder = '<1095>';
        type        = 'int'
    }
    'certExpirationWarningDays' = @{
        value       = 15;
        write       = $true;
        copy        = $true;
        required    = $true;
        placeholder = '<15>';
        type        = 'int'
    }
    'networkSSID'               = @{
        value       = $null;
        write       = $true;
        copy        = $true;
        required    = $true;
        placeholder = '<networkSSID>';
        type        = 'string'
    }
    'certType'                  = @{
        value       = $null;
        write       = $true;
        copy        = $true;
        required    = $true;
        placeholder = '<EmailSAN/EmailDN/UsernameCn>';
        type        = 'string'
    }
    'radiusDirectory'           = @{
        value       = $null;
        write       = $true;
        copy        = $true;
        required    = $true;
        placeholder = '<Path/To/radiusDirectory>';
        type        = 'string'
    }
    'lastUpdate'                = @{
        value       = $null;
        write       = $true;
        copy        = $true;
        required    = $false;
        placeholder = $null;
        type        = 'string'
    }
    'openSSLBinary'             = @{
        value       = $null;
        write       = $true;
        copy        = $true;
        required    = $true;
        placeholder = '<Path/To/OpenSSL>';
        type        = 'string'
    }
    'certSubjectHeader'         = @{
        value       = @{
            CountryCode      = $null
            StateCode        = $null
            Locality         = $null
            Organization     = $null
            OrganizationUnit = $null
            CommonName       = $null
        }
        write       = $true
        copy        = $true
        required    = $true
        placeholder = '@{
            CountryCode      = "<CountryCode>"
            StateCode        = "<StateCode>"
            Locality         = "<Locality>"
            Organization     = "<Organization>"
            OrganizationUnit = "<OrganizationUnit>"
            CommonName       = "<CommonName>"
        }';
        type        = 'hashtable'
    }
}

# # Set the module non-configurable settings
$global:JCRSettings = @{
    'userAgent'     = Get-JCRUserAgent;
    'sessionImport' = $false;
}

# From the saved config file, get the settings and set them in the module as $config
$global:JCRConfig = Get-JCRConfig -asObject
# Get-JCRConfig

# validate the config settings (skip throw on first load with 'loadModule' param)
Confirm-JCRConfig -loadModule

# TODO: Check the OpenSSL version
# Get-OpenSSLVersion -opensslBinary $global:JCRConfig.openSSLBinary.value