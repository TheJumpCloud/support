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
        $ModulePsd1 = join-path -path $ModuleRoot -childpath 'Config.json'

        if (test-path -path $ModulePsd1) {
            "Found config"
            $config = Get-Content -Path $ModulePsd1 | ConvertFrom-Json
        } else {
            "missing config $ModulePsd1"
            New-JCSettingsFile
        }
    }

    process {
    }

    end {
        return $config
    }
}
