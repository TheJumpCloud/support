function Set-JCRConfigFile {
    [CmdletBinding()]
    param (
    )
    DynamicParam {
        $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent.Parent.FullName
        $configFilePath = Join-Path -Path $ModuleRoot -ChildPath 'Config.json'

        if (Test-Path -Path $configFilePath) {
            $config = Get-Content -Path $configFilePath | ConvertFrom-Json
            # Create the dictionary
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # Foreach key in the supplied config file:
            foreach ($key in $config.PSObject.Properties) {
                foreach ($item in $config.($key.Name).PSObject.Properties) {
                    # Skip create dynamic params for these not-writable properties:
                    if (($config.($key.Name).($item.Name).Write -eq $false)) {
                        continue
                    }
                    # Set the dynamic parameters' name
                    # write-host "adding dynamic param: $key$($item) $($config[$key][$item]['value'].getType().Name)"
                    $ParamName_Filter = "$($item.Name)"
                    # Create the collection of attributes
                    $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                    # If ValidateSet is specificed in the config file, set the value here:
                    if ($config.($key.Name).($item.Name).validateSet) {
                        $arrSet = @($($config.($key.Name).($item.Name).'validateSet').split())
                        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
                        $AttributeCollection.Add($ValidateSetAttribute)
                    }
                    # If the type of value is a bool, create a custom validateSet attribute here:
                    $paramType = $($config.($key.Name).($item.Name)).getType().Name
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
            Connect-JCOnline -force | Out-Null
        }

        # Config should be in /PowerShell/JumpCloudModule/Config.json
        $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent.Parent.FullName
        $configFilePath = Join-Path -Path $ModuleRoot -ChildPath 'Config.json'

        if (Test-Path -Path $configFilePath) {
            $config = Get-Content -Path $configFilePath | ConvertFrom-Json
        } else {
            New-JCRConfigFile
            $config = Get-Content -Path $configFilePath | ConvertFrom-Json
        }
    }

    process {
        $params = $PSBoundParameters
        # update config settings
        foreach ($param in $params.Keys) {
            foreach ($key in $config.PSObject.Properties) {
                # assign the first group
                $config.($($key.Name)).$param.value = $params[$param]
            }
        }
    }

    end {
        # Write out the new settings
        $config | ConvertTo-Json | Out-File -FilePath $configFilePath
        # Update Global Variable
        $Global:JCConfig = Get-JCRConfigFile
    }
}