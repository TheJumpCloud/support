function Get-JCSettingsFile {
    [CmdletBinding()]
    param (
        [Parameter(
            HelpMessage = 'To Force Re-Creation of the Config file, set the $force parameter to $tru'
        )]
        [bool]
        $force
    )

    begin {
        # Config should be in /PowerShell/JumpCloudModule/Config.json
        $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent.FullName
        $configFilePath = join-path -path $ModuleRoot -childpath 'Config.json'

        if (test-path -path $configFilePath) {
            # Get Contents
            $config = Get-Content -Path $configFilePath | ConvertFrom-Json
        } else {
            # Create new file with default settings
            New-JCSettingsFile
        }
    }

    process {
    }

    end {
        return $config
    }
}
