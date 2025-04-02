function New-JCRConfigFile {
    [CmdletBinding()]
    param (
        [Parameter(
            HelpMessage = 'To Force Re-Creation of the Config file, set the $force parameter to $true'
        )]
        [switch]
        $force
    )

    begin {
        $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent.Parent.FullName
        $configFilePath = Join-Path -Path $ModuleRoot -ChildPath 'config.json'
        $date = (Get-Date).ToUniversalTime()
    }
    process {
        # Define Default Settings for the Config file
        $config = $module.privateData.config
    }
    end {
        if ((Test-Path -Path $configFilePath) -And ($force)) {
            $config | ConvertTo-Json | Out-File -FilePath $configFilePath
        } else {
            $config | ConvertTo-Json | Out-File -FilePath $configFilePath
        }
    }
}