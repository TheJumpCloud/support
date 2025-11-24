function New-JCSettingsFile {
    [CmdletBinding()]
    param (
        [Parameter(
            HelpMessage = 'To Force Re-Creation of the Config file, set the $force parameter to $true'
        )]
        [switch]
        $force
    )

    begin {
        # Config should be in /PowerShell/JumpCloudModule/Config.json
        $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent.FullName
        $configFilePath = Join-Path -Path $ModuleRoot -ChildPath 'Config.json'

        # Define Default Settings for the Config file
        $config = @{
            'moduleBanner'  = @{
                'Message'      = @{value = 'JumpCloud PowerShell Module now supports EU based organizations. Use `Set-JCSettingsFile -JCEnvironmentLocation "EU"` or `Connect-JCOnline -JumpCloudAPIKey "APIKEY" -JCEnvironment "EU"` to update'; write = $false; copy = $false };
                'MessageCount' = @{value = 0; write = $true; copy = $false }
            }
            'parallel'      = @{
                'Eligible'   = @{value = Get-JCParallelValidation; write = $false; copy = $true }
                'Override'   = @{value = $false; write = $true; copy = $true }
                'Calculated' = @{value = $false; write = $false; copy = $true }
            }
            'JCEnvironment' = @{
                'Location' = @{value = 'STANDARD'; write = $true; copy = $true }
            }
            # TODO: in future version, add the updates hash and limit update frequency
            # 'updates'  = @{
            #     'Frequency' = @{value = 'day'; write = $true; copy = $true; validateSet = 'day week month' }
            #     'LastCheck' = @{value = Get-Date; write = $false; copy = $true };
            # }
        }
    }

    process {
        # Calculate the Parallel Setting Field:
        if (($config.parallel.Override.value -eq $true) -and ($config.parallel.Eligible.value -eq $true)) {
            $config.parallel.Calculated.value = $false
        } elseif (($config.parallel.Override.value -eq $false) -and ($config.parallel.Eligible.value -eq $true)) {
            $config.parallel.Calculated.value = $true
        } else {
            $config.parallel.Calculated.value = $false
        }
        # TODO: implement update frequency checks
        # $next = if ($config.updates.Frequency -eq 'day') {
        #     $config.updates.lastCheck.addDays(1)
        # } elseif ($config.updates.Frequency -eq 'week') {
        #     $config.updates.lastCheck.addDays(7)

        # } elseif ($config.updates.Frequency -eq 'month') {
        #     $config.updates.lastCheck.addMonths(1)
        # }
        # $config.updates.NextCheck = $next
    }

    end {
        if ((Test-Path -Path $configFilePath) -and ($force)) {
            $config | ConvertTo-Json | Out-File -FilePath $configFilePath
        } else {
            $config | ConvertTo-Json | Out-File -FilePath $configFilePath
        }
    }
}