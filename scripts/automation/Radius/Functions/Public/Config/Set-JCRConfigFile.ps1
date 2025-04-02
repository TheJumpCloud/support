function Set-JCRConfigFile {
    [CmdletBinding()]
    param (
    )
    DynamicParam {
        # $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent.Parent.FullName
        # $configFilePath = Join-Path -Path $ModuleRoot -ChildPath 'Config.json'

        # if (Test-Path -Path $configFilePath) {
        $config = $module.PrivateData.config
        # Create the dictionary
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        # Foreach key in the supplied config file:
        foreach ($key in $config.keys) {
            $setting = $config[$key]
            # Skip create dynamic params for these not-writable properties:
            if (($setting.Write -eq $false)) {
                continue
            }
            # Set the dynamic parameters' name
            # write-host "adding dynamic param: $key$($item) $($config[$key][$item]['value'].getType().Name)"
            $ParamName_Filter = "$($key)"
            # Create the collection of attributes
            $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]

            # Set the type of the parameter
            $paramType = $setting.type

            # Create and set the parameters' attributes
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Mandatory = $false
            $ParameterAttribute.HelpMessage = "sets the $($key) config for the module"
            # Add the attributes to the attributes collection
            $AttributeCollection.Add($ParameterAttribute)
            # Add the param
            $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParamName_Filter, $paramType, $AttributeCollection)
            $RuntimeParameterDictionary.Add($ParamName_Filter, $RuntimeParameter)

        }
        # Returns the dictionary
        return $RuntimeParameterDictionary
        # }
    }
    begin {
        # Config should be in /PowerShell/JumpCloudModule/Config.json
        $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent.Parent.FullName
        $configFilePath = Join-Path -Path $ModuleRoot -ChildPath 'Config.json'
        # config should be loaded from the module
        $config = $module.PrivateData.config

        # if (-NOT $config) {

        #     New-JCRConfigFile
        # }
    }

    process {
        $params = $PSBoundParameters
        # update config settings
        foreach ($param in $params.Keys) {
            # assign the first group
            $config[$param].value = $params[$param]

        }
    }

    end {
        # Write out the new settings
        $config | ConvertTo-Json | Out-File -FilePath $configFilePath
        # Update Module Config
        Get-JCRConfig -FilePath $configFilePath
    }
}