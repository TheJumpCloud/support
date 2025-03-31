function Update-JCRModule {
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = 'ByPasses user prompts.')][Switch]$Force,
        [Parameter(HelpMessage = 'Set the PSRepository')][System.String]$Repository = 'PSGallery'

    )
    begin {
        # JumpCloud Module Name
        $ModuleName = 'JumpCloud.Radius'
    }
    process {
        # get the latest module
        $latestModule = Find-Module -Name $ModuleName -Repository $Repository
        # get the currently installed module
        $currentModule = Get-InstalledModule -Name $ModuleName

        # compare the versions
        if ($latestModule.Version -gt $currentModule.Version) {
            Write-Host "A new version of the $ModuleName module is available: $($latestModule.Version) (current version: $($currentModule.Version))."
            Write-Host "You can update the module by running: Update-Module -Name $ModuleName"
        } else {
            Write-Host "You have the latest version of the $ModuleName module: $($currentModule.Version)."
        }

        # prompts to update if force param is not set
        if (-not $Force) {
            Do {
                Write-Host ('Enter ''Y'' to update the ' + $ModuleName + ' PowerShell module to the latest version or enter ''N'' to cancel:')
                Write-Host (' ') -NoNewline
                $UserInput = Read-Host
            }
            Until ($UserInput.ToUpper() -in ('Y', 'N'))
        } Else {
            $UserInput = 'Y'
        }

        # if the user pressed "N" then exit
        if ($UserInput.ToUpper() -eq 'N') {
            Write-Host "Update cancelled."
            continue
        } else {
            # else get the module config from the current module:
            # TODO: get the json config with the private function not created yet
            $savedJCRSettings = Get-JCRConfigFile -raw

            # now, attempt to update the module
            try {
                Update-Module -Name $ModuleName -Force

                # update the settings file config.json
                Update-JCSettingsFile -settings $savedJCSettings
                # re-import the settings file variable
                $global:JCConfig = Get-JCSettingsFile
            } catch {
                Write-Error "Failed to update the module: $_"
            }

            # Get the installed module versions
            $installedModules = Get-InstalledModule -Name $moduleName -AllVersions

            # Remove the modules from the current session
            Get-Module -Name:($ModuleName) -ListAvailable -All | Remove-Module -Force

            # uninstall the older versions
            foreach ($module in $installedModules) {
                if ($module.Version -ne $latestModule.Version) {
                    Uninstall-Module -Name $ModuleName -RequiredVersion $module.Version -Force
                }
            }

            # now validate the modules
            $currentModule = Get-InstalledModule -Name $ModuleName
            if ($currentModule.Version -eq $latestModule.Version) {
                Write-Host "The $ModuleName module has been updated to version $($currentModule.Version)."
            } else {
                Write-Error "Failed to update the module to the latest version."
            }
            Import-module -Name $ModuleName -Force

        }
    }
    end {

    }

}