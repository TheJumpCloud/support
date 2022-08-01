function Set-JCSettingsFile {
    [CmdletBinding()]
    param (
        [Parameter(
            HelpMessage = 'To Force Re-Creation of the Config file, set the $force parameter to $tru'
        )]
        [bool]
        $force
    )
    DynamicParam {
        $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent.FullName
        $configFilePath = join-path -path $ModuleRoot -childpath 'Config.json'

        if (test-path -path $configFilePath) {
            $config = Get-Content -Path $configFilePath | ConvertFrom-Json -AsHashtable
            # Create the dictionary
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # These params are not exposed as user editable
            $skippedParams = @('updatesLastCheck', 'parallelEligiable')
            # Foreach key in the supplied config file:
            foreach ($key in $config.keys) {
                foreach ($item in $config[$key].keys) {
                    # Set the dynamic parameters' name
                    # write-host "adding dynamic param: $key$($item) $($config[$key][$item].getType().Name)"
                    $ParamName_Filter = "$key$($item)"
                    # Create the collection of attributes
                    $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                    # Skip create dynamic params for these conditions:
                    if (($ParamName_Filter -Match "Validation") -or ($ParamName_Filter -in $skippedParams)) {
                        continue
                    }
                    if ($($config[$key]["$($item)Validation"])) {
                        $arrSet = @($($config[$key]["$($item)Validation"]).split())
                        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
                        $AttributeCollection.Add($ValidateSetAttribute)
                    }
                    # $config[$key][$item].getType()
                    $paramType = $($config[$key][$item].getType().Name)
                    if ($paramType -eq 'boolean') {
                        $arrSet = @("true", "false")
                        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
                        $AttributeCollection.Add($ValidateSetAttribute)
                    }
                    # Create and set the parameters' attributes
                    $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
                    $ParameterAttribute.Mandatory = $false
                    # $ParameterAttribute.HelpMessage = 'todo dynamically add message'
                    # Add the attributes to the attributes collection
                    $AttributeCollection.Add($ParameterAttribute)
                    # Add the param
                    $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParamName_Filter, $paramType, $AttributeCollection)
                    $RuntimeParameterDictionary.Add($ParamName_Filter, $RuntimeParameter)
                }
            }
            # Returns the dictionary
            return $RuntimeParameterDictionary

        }
    }
    begin {
        # Config should be in /PowerShell/JumpCloudModule/Config.json
        $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent.FullName
        $configFilePath = join-path -path $ModuleRoot -childpath 'Config.json'

        if (test-path -path $configFilePath) {
            $config = Get-Content -Path $configFilePath | ConvertFrom-Json -AsHashtable
        } else {
            New-JCSettingsFile
        }
    }

    process {
        $params = $PSBoundParameters
        # update config settings
        foreach ($param in $params.Keys) {
            foreach ($key in $config.keys) {
                if ($param -match $key) {
                    # Split the name
                    $paramKey = $($param.split($key))
                    # assign the first group
                    $config[$key][$paramKey[1]] = $params[$param]
                }
            }
        }

    }

    end {
        # Write out the new settings
        $config | ConvertTo-Json | Out-FIle -path $configFilePath
    }
}