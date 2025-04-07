function Set-JCRConfigFile {
    [CmdletBinding()]
    param (
    )
    DynamicParam {
        # $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent.Parent.FullName
        # $configFilePath = Join-Path -Path $ModuleRoot -ChildPath 'Config.json'

        # if (Test-Path -Path $configFilePath) {
        # Create the dictionary
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        # Foreach key in the supplied config file:
        foreach ($setting in $global:JCRConfig.PSObject.Properties) {
            $settingName = $setting.Name
            $settingValue = $setting.Value
            # Skip create dynamic params for these not-writable properties:
            if ($settingValue.Write -eq $false) {
                continue
            }
            # Set the dynamic parameters' name
            # write-host "adding dynamic param: $key$($item) $($config[$key][$item]['value'].getType().Name)"
            $ParamName_Filter = "$($settingName)"
            # Create the collection of attributes
            $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]

            # Set the type of the parameter
            $paramType = $settingValue.type

            # Create and set the parameters' attributes
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Mandatory = $false
            $ParameterAttribute.HelpMessage = "sets the $($settingName) config for the module"
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

        if (-NOT $global:JCRConfig) {
            # create the config file from template
            New-JCRConfigFile
            # set the variable
            $global:JCRConfig = Get-JCRConfigFile -asObject
        }
    }

    process {
        $params = $PSBoundParameters
        # update config settings
        foreach ($param in $params.Keys) {
            # set the value of the config setting to the value passed into this function
            $global:JCRConfig.$param.value = $params[$param]

        }
    }

    end {
        # Write out the new settings
        $global:JCRConfig | ConvertTo-Json | Out-File -FilePath $configFilePath
    }
}