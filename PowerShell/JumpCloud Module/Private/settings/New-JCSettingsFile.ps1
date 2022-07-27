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
        $ModulePsd1 = join-path -path $ModuleRoot -childpath 'Config.json'

        # Define Default Settings for the Config file
        $config = @{
            'parallel' = @{
                'Eligible'         = $false;
                'Override'         = $false;
                'MessageDismissed' = $false;
            }
            'updates'  = @{
                'Frequency'           = 'week';
                'FrequencyValidation' = 'day week month';
                'LastCheck'           = (Get-Date);
                'NextCheck'           = '';
            }
        }
    }

    process {
        $next = if ($config.updates.Frequency -eq 'day') {
            $config.updates.lastCheck.addDays(1)
        } elseif ($config.updates.Frequency -eq 'week') {
            $config.updates.lastCheck.addDays(7)

        } elseif ($config.updates.Frequency -eq 'month') {
            $config.updates.lastCheck.addMonths(1)
        }
        $config.updates.NextCheck = $next
        if ((test-path -path $ModulePsd1) -And ($force)) {
            "Found config"
            $config | ConvertTo-Json | Out-FIle -path $ModulePsd1
        } else {
            "missing config $ModulePsd1"
            $config | ConvertTo-Json | Out-FIle -path $ModulePsd1
        }
    }

    end {

    }
}
New-JCSettingsFile -Force