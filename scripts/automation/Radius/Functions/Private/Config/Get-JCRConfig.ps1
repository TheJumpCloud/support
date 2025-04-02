function Get-JCRConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$FilePath
    )

    if (Test-Path -Path $FilePath) {
        try {
            $savedConfig = (Get-Content -Path $FilePath -Raw | ConvertFrom-Json)
            # Merge loaded settings with the module's default configuration
            foreach ($settingName in $savedConfig.PSObject.Properties.Name) {
                if ($Module.privateData.config.containsKey($settingName)) {
                    $Module.privateData.config[$settingName].value = $savedConfig.$settingName.value
                } else {
                    Write-Warning "Loaded config contains unknown setting: '$settingName'. It will be ignored."
                }
            }
        } catch {
            Write-Warning "Failed to load config from '$FilePath'. Using default configuration."
        }
    } else {
        Write-Warning "Config file '$FilePath' not found. Using default configuration."
    }
}