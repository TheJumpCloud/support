function Set-JCSettings {
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
        $ModulePsd1 = join-path -path $ModuleRoot -childpath 'Config.json'

        if (test-path -path $ModulePsd1) {
            # "Found config"
            $config = Get-Content -Path $ModulePsd1 | ConvertFrom-Json -AsHashtable
            # Create the dictionary
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # # foreach ($key in $config.keys) {
            # #     <# $key is the current item #>
            # #     $arrSet += @($key)
            # # }

            # # # Create and return the dynamic parameter
            # # foreach ($key in $config.keys) {
            # #     <# $key is the current item #>
            # }
            foreach ($key in $config.keys) {
                foreach ($item in $config[$key].keys) {
                    # Set the dynamic parameters' name
                    # write-host "adding dynamic param: $key$($item) $($config[$key][$item].getType().Name)"
                    $ParamName_Filter = "$key$($item)"
                    # Create the collection of attributes
                    $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                    # Skip create dynamic params for these conditions:
                    if (($ParamName_Filter -Match "Validation") -or ($ParamName_Filter -eq 'updatesLastCheck')) {
                        continue
                    }
                    if ($($config[$key]["$($item)Validation"])) {
                        # write-host "found validati"
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
                    $ParameterAttribute.HelpMessage = 'Condition to filter date on.'
                    # Generate and set the ValidateSet
                    # $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
                    # Add the ValidateSet to the attributes collection
                    # $AttributeCollection.Add($ValidateSetAttribute)
                    # Add the attributes to the attributes collection
                    $AttributeCollection.Add($ParameterAttribute)

                    <# $item is the current item #>
                    # "$key$($item)"
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
        $ModulePsd1 = join-path -path $ModuleRoot -childpath 'Config.json'

        if (test-path -path $ModulePsd1) {
            "Found config"
            $config = Get-Content -Path $ModulePsd1 | ConvertFrom-Json -AsHashtable
        } else {
            "missing config $ModulePsd1"
            New-JCSettingsFile
        }
    }

    process {
        # $config['updates']
        $params = $PSBoundParameters
        foreach ($param in $params.Keys) {
            foreach ($key in $config.keys) {
                # write-host "$key"
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
        $config | ConvertTo-Json | Out-FIle -path $ModulePsd1
    }
}
# Set-JCSettings -updatesFrequency day -parallelMessageDismissed $false