function Get-JCSmartGroup () {
    [CmdletBinding(DefaultParameterSetName = 'ByGroup')]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ByGroup', Position = 0, HelpMessage = 'Group Type you want to return')]
        [ValidateSet('User', 'System')]
        [String]$GroupType,
        [Parameter(ValueFromPipelineByPropertyName, HelpMessage = 'The name of the JumpCloud Group you want to return.')]
        [String]$GroupName,
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ById', HelpMessage = 'The ID of the JumpCloud Group you want to return.')]
        [Alias('_id', 'id')][String]$ByID
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
        #TODO: ForEach parameters
        #TODO: Parameters
        foreach ($param in $PSBoundParameters.GetEnumerator()) {

        }

        if ($PSCmdlet.ParameterSetName -eq 'ByGroup') {
            #Write-Host "$($config.SmartGroups."$($GroupType)Groups".PSObject.Properties)"
            $config.SmartGroups."$($GroupType)Groups".PSObject.Properties | foreach {
                $resultsArray.Add($_.Value)
            }
        }
    }end {
        $resultsArray
    }

}