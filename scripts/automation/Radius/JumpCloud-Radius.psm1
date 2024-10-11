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

# import config:
. "$JCScriptRoot/Config.ps1"
# try to get the settings file, create new one if it does not exist:
$global:JCRConfig = Get-JCRSettingsFile

# if the Certs / UserCerts directories do not exist, create them
if (-Not (Test-Path -Path "$JCScriptRoot/Cert" -PathType Container)) {
    New-Item -Path "$JCScriptRoot/Cert" -ItemType Directory
}
if (-Not (Test-Path -Path "$JCScriptRoot/UserCerts" -PathType Container)) {
    New-Item -Path "$JCScriptRoot/UserCerts" -ItemType Directory
}

# Get global variables or update if necessary
Get-JCRGlobalVars
