function Set-JCSettingsFile {
    [CmdletBinding()]
    param (
    )
    DynamicParam {
        $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent.FullName
        $configFilePath = join-path -path $ModuleRoot -childpath 'Config.json'

        if (test-path -path $configFilePath) {
            $config = Get-Content -Path $configFilePath | ConvertFrom-Json -AsHashtable
            # Create the dictionary
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # Foreach key in the supplied config file:
            foreach ($key in $config.keys) {
                foreach ($item in $config[$key].keys) {
                    # Skip create dynamic params for these not-writable properties:
                    if (($config[$key][$item]['write'] -eq $false)) {
                        continue
                    }
                    # Set the dynamic parameters' name
                    # write-host "adding dynamic param: $key$($item) $($config[$key][$item]['value'].getType().Name)"
                    $ParamName_Filter = "$key$($item)"
                    # Create the collection of attributes
                    $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                    if ($($config[$key]["$($item)Validation"])) {
                        $arrSet = @($($config[$key]["$($item)Validation"]).split())
                        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
                        $AttributeCollection.Add($ValidateSetAttribute)
                    }
                    # $config[$key][$item].getType()
                    $paramType = $($config[$key][$item]['value'].getType().Name)
                    if ($paramType -eq 'boolean') {
                        $arrSet = @("true", "false")
                        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
                        $AttributeCollection.Add($ValidateSetAttribute)
                    }
                    # Create and set the parameters' attributes
                    $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
                    $ParameterAttribute.Mandatory = $false
                    $ParameterAttribute.HelpMessage = "sets the $($item) settings for the $($key) feature"
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
        if ($JCAPIKEY.length -ne 40) {
            Connect-JCOnline | Out-Null
        }

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
                    $config[$key][$paramKey[1]]['value'] = $params[$param]
                }
            }
        }
        # Re-Calculate parallel settings:
        if (($config['parallel']['Override']['value'] -eq $true) -And (($config['parallel']['Eligible']['value'] -eq $true))) {
            $config['parallel']['Calculated']['value'] = $false
        } elseif (($config['parallel']['Override']['value'] -eq $false) -And (($config['parallel']['Eligible']['value'] -eq $true))) {
            $config['parallel']['Calculated']['value'] = $true
        } else {
            $config['parallel']['Calculated']['value'] = $false
        }
    }

    end {
        # Write out the new settings
        $config | ConvertTo-Json | Out-File -path $configFilePath
        # Update Global Variable
        $Global:JCConfig = Get-JCSettingsFile
    }
}