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
$Private = @( Get-ChildItem -Path "$PSScriptRoot/Functions/Public/*.ps1" -Recurse)
Foreach ($Import in $Private) {
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
. "$JCScriptRoot/config.ps1"
# try to get the settings file, create new one if it does not exist:
$global:JCRConfig = Get-JCRSettingsFile

# Get global variables or update if necessary
Get-JCRGlobalVars
# Update Users Json if there's a change
Update-JCRUsersJson
