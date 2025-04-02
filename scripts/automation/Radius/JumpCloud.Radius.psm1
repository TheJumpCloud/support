# Load all functions from private folders
$Private = @( Get-ChildItem -Path "$PSScriptRoot/Functions/Private/*.ps1" -Recurse)
Foreach ($Import in $Private) {
    Try {
        . $Import.FullName
    } Catch {
        Write-Error -Message "Failed to import function $($Import.FullName): $_"
    }
}

# Load all public functions:
$Public = @( Get-ChildItem -Path "$PSScriptRoot/Functions/Public/*.ps1" -Recurse)
Foreach ($Import in $Public) {
    Try {
        . $Import.FullName
    } Catch {
        Write-Error -Message "Failed to import function $($Import.FullName): $_"
    }
}

# setup:
# build required users.json file:
# set script root:
$global:JCScriptRoot = "$PSScriptRoot"

# from the settings file we should have a location for the certs and user certs

# if the Certs / UserCerts directories do not exist, create them
if (-Not (Test-Path -Path "$JCScriptRoot/Cert" -PathType Container)) {
    New-Item -Path "$JCScriptRoot/Cert" -ItemType Directory
    New-Item -Path "$JCScriptRoot/Cert/Backups" -ItemType Directory
}
if (-Not (Test-Path -Path "$JCScriptRoot/UserCerts" -PathType Container)) {
    New-Item -Path "$JCScriptRoot/UserCerts" -ItemType Directory
}

# # Get global variables or update if necessary
# Get-JCRGlobalVars
# Export module member
Export-ModuleMember -Function $Public.BaseName -Alias *

# Set the module config
$Module.PrivateData.config = @{
    'userGroup'                         = @{
        value       = $null;
        write       = $true;
        copy        = $true;
        required    = $true;
        placeholder = '<UserGroupID>';
        type        = 'string'
    }
    'certSecretPass'                    = @{
        value       = $null;
        write       = $true;
        copy        = $true;
        required    = $true;
        placeholder = '<CertPassword>';
        type        = 'string'
    }
    'userCertValidityDays'              = @{
        value       = 365;
        write       = $true;
        copy        = $true;
        required    = $true;
        placeholder = '<365>';
        type        = 'int'
    }
    'caCertValidityDays'                = @{
        value       = 1095;
        write       = $true;
        copy        = $true;
        required    = $true;
        placeholder = '<1095>';
        type        = 'int'
    }
    'certExpirationWarningDays'         = @{
        value       = 15;
        write       = $true;
        copy        = $true;
        required    = $true;
        placeholder = '<15>';
        type        = 'int'
    }
    'networkSSID'                       = @{
        value       = $null;
        write       = $true;
        copy        = $true;
        required    = $true;
        placeholder = '<networkSSID>';
        type        = 'string'
    }
    'certSubjectHeaderCountryCode'      = @{
        value       = $null;
        write       = $true;
        copy        = $true;
        required    = $true;
        placeholder = '<US>';
        type        = 'string'
    }
    'certSubjectHeaderStateCode'        = @{
        value       = $null;
        write       = $true;
        copy        = $true;
        required    = $true;
        placeholder = '<CO>';
        type        = 'string'
    }
    'certSubjectHeaderLocality'         = @{
        value       = $null;
        write       = $true;
        copy        = $true;
        required    = $true;
        placeholder = '<Boulder>';
        type        = 'string'
    }
    'certSubjectHeaderOrganization'     = @{
        value       = $null;
        write       = $true;
        copy        = $true;
        required    = $true;
        placeholder = '<JumpCloud>';
        type        = 'string'
    }
    'certSubjectHeaderOrganizationUnit' = @{
        value       = $null;
        write       = $true;
        copy        = $true;
        required    = $true;
        placeholder = '<Customer_Tools>';
        type        = 'string'
    }
    'certSubjectHeaderCommonName'       = @{
        value       = $null;
        write       = $true;
        copy        = $true;
        required    = $true;
        placeholder = '<JumpCloud.com>';
        type        = 'string'
    }
    'certType'                          = @{
        value       = $null;
        write       = $true;
        copy        = $true;
        required    = $true;
        placeholder = '<EmailSAN/EmailDN/UsernameCn>';
        type        = 'string'
    }
    'radiusDirectory'                   = @{
        value       = $null;
        write       = $true;
        copy        = $true;
        required    = $true;
        placeholder = '<Path/To/radiusDirectory>';
        type        = 'string'
    }
    'lastUpdate'                        = @{
        value       = $null;
        write       = $true;
        copy        = $true;
        required    = $false;
        placeholder = $null;
        type        = 'string'
    }
}

# Set the module non-configurable settings
$Module.PrivateData.settings = @{
    'userAgent' = Get-JCRUserAgent
}

# From the saved config file, get the settings and set them in the module
Get-JCRConfig -FilePath "$JCScriptRoot/Config.json"

# validate the config settings
Confirm-JCRConfigFile -loadModule

# print the config:
# foreach ($item in $module.PrivateData.config.keys) {
#     write-host "$item | $($module.PrivateData.config[$($item)].value)"
# }