function New-JCSettingsFile {
    [CmdletBinding()]
    param (
        [Parameter(
            HelpMessage = 'To Force Re-Creation of the Config file, set the $force parameter to $tru'
        )]
        [switch]
        $force
    )

    begin {
        # Config should be in /PowerShell/JumpCloudModule/Config.json
        $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent.FullName
        $configFilePath = join-path -path $ModuleRoot -childpath 'Config.json'

        # Define Default Settings for the Config file
        $config = @{
            'parallel' = @{
                'Eligible'     = @{value = Get-JCParallelValidation; write = $false; copy = $true }
                'Override'     = @{value = $false; write = $true; copy = $true }
                'MessageCount' = @{value = 0; write = $true; copy = $true }
                'HelpMessage'  = @{value = 'JumpCloud PowerShell Module now processes Get requests in parallel, to disable this functionailty run: Set-JCSettingsFile -parallelOverride $true'; write = $false; copy = $false };
                'Calculated'   = @{value = $false; write = $false; copy = $true }
            }
            'updates'  = @{
                'Frequency' = @{value = 'day'; write = $true; copy = $true; validateSet = 'day week month' }
                'LastCheck' = @{value = Get-Date; write = $false; copy = $true };
                'NextCheck' = '';
            }
        }
    }

    process {
        # Calculate the Parallel Setting Field:
        if (($config.parallel.Override.value -eq $true) -And ($config.parallel.Eligible.value -eq $true)) {
            $config.parallel.Calculated.value = $false
        } elseif (($config.parallel.Override.value -eq $false) -And ($config.parallel.Eligible.value -eq $true)) {
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
        if ((test-path -path $configFilePath) -And ($force)) {
            $config | ConvertTo-Json | Out-FIle -path $configFilePath
        } else {
            $config | ConvertTo-Json | Out-FIle -path $configFilePath
        }
    }
}