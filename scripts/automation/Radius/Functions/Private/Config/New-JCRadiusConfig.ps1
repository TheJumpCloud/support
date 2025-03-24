function New-JCRadiusConfig {
    [CmdletBinding()]
    param()

    $ModulePath = "$env:PSModulePath/JCRadius"
    $ConfigFilePath = "$ModulePath/config.json"

    if (-not (Test-Path -Path $ConfigFilePath)) {
        try {
            # Create the directory if it doesn't exist
            if (-not (Test-Path -Path $ModulePath)) {
                New-Item -ItemType Directory -Path $ModulePath -Force | Out-Null
            }

            # Create the blank JSON file
            @{} | ConvertTo-Json | Out-File -FilePath $ConfigFilePath -Force

            Write-Verbose "[status] Created blank config.json at $ConfigFilePath"
        } catch {
            Write-Error "[error] Failed to create config.json: $($_.Exception.Message)"
        }
    } else {
        Write-Verbose "[status] config.json already exists at $ConfigFilePath"
    }
}