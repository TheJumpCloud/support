function Update-JCSettingsFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [object]
        $settings
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
        foreach ($newSetting in $config.psobject.properties) {
            foreach ($copiedSetting in $settings.psobject.properties) {
                if ($newSetting.name -eq $copiedSetting.name) {
                    # Write-Host "found match $($newSetting.name) -- $($copiedSetting.name)"
                    foreach ($newProperty in $newSetting.value.psobject.properties) {
                        foreach ($copiedProperty in $copiedSetting.value.psobject.properties) {
                            if ( $newProperty.name -eq $copiedProperty.name) {
                                # Write-Host $property.value $property2.value
                                # Compare-Object -ReferenceObject $newProperty.value -DifferenceObject $copiedProperty.value -Property $newProperty.name
                                if ( $newProperty.value -eq $copiedProperty.value) {
                                } else {
                                    $config.$($newsetting.name).$($newProperty.name) = $settings.$($copiedSetting.name).$($copiedProperty.name)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    end {
        $config | ConvertTo-Json | Out-FIle -path $configFilePath
    }
}
