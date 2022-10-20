function Get-JCSmartGroup () {
    [CmdletBinding(DefaultParameterSetName = 'ByGroup')]
    param (
        [Parameter(ParameterSetName = 'ByGroup', HelpMessage = 'Group Type you want to return')]
        [ValidateSet('User', 'System')]
        [String]$GroupType,
        [Parameter(HelpMessage = 'The ID of the JumpCloud Group you want to return.')]
        [String]$ByID,
        [Parameter(HelpMessage = 'The name of the JumpCloud Group you want to return.')]
        [String]$GroupName,
        [Parameter(ParameterSetName = 'All', HelpMessage = 'Return all JumpCloud Smart Groups')]
        [switch]$All
    )

    begin {

        # Load JSON File
        # Config should be in /PowerShell/JumpCloudModule/Config.json
        $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent.FullName
        $configFilePath = join-path -path $ModuleRoot -childpath 'Config.json'

        if (test-path -path $configFilePath) {
            $config = Get-Content -Path $configFilePath  | ConvertFrom-Json

        } else {
            Write-Error "Config not located"
        }
        $resultsArray = [System.Collections.Generic.List[PSObject]]::new()

    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            ByGroup {
                #Write-Host "$($config.SmartGroups."$($GroupType)Groups".PSObject.Properties)"
                if ($ById) {
                    $config.SmartGroups."$($GroupType)Groups".PSObject.Properties | foreach {
                        if ($_.Value.ID -eq $ById) {
                            $resultsArray.Add($_.Value)
                        }
                    }
                } elseif ($GroupName) {
                    $config.SmartGroups."$($GroupType)Groups".PSObject.Properties | foreach {
                        if ($_.Value.Name -eq $GroupName) {
                            $resultsArray.Add($_.Value)
                        }
                    }
                } else {
                    $config.SmartGroups."$($GroupType)Groups".PSObject.Properties | foreach {
                        $resultsArray.Add($_.Value)
                    }
                }
            }
            All {
                $UserGroups = Get-JCSmartGroup -GroupType User
                $SystemGroups = Get-JCSmartGroup -GroupType System
                $resultsArray.Add($UserGroups)
                $resultsArray.Add($SystemGroups)
            }
        }
    } end {
        return $resultsArray
    }
}