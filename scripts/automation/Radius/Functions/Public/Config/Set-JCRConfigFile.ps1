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
        foreach ($setting in $global:JCRConfigTemplate.keys) {
            $settingName = $setting
            $settingValue = $global:JCRConfigTemplate[$setting]
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
            # validate the parameters
            switch ($param) {
                'radiusDirectory' {
                    # validate the directory
                    Test-JCRRadiusDirectory -Path $params[$param]
                }
            }
            # set the value of the config setting to the value passed into this function
            if ($global:JCRConfig.PSObject.Properties.Name -contains $param) {
                $global:JCRConfig.$param.value = $params[$param]
            } else {
                # Add the property with a hashtable structure (assuming you want to match existing pattern)
                $global:JCRConfig | Add-Member -MemberType NoteProperty -Name $param -Value $global:JCRConfigTemplate[$param]
                # now update the value:
                $global:JCRConfig.$param.value = $params[$param]
            }
        }
        # validate the config settings
    }

    end {
        # Write out the new settings
        Write-Host "---------Updated settings--------------"
        Write-Host "[status] Module Path : $($ModuleRoot)"
        Write-Host "[Status] JCRConfig Settings:"
        foreach ($setting in $global:JCRConfig.PSObject.Properties) {
            Write-Host ("$($setting.Name): $($setting.Value.value)")
        }
        Write-Host "-----------------------"
        $global:JCRConfig | ConvertTo-Json -Depth 10 | Out-File -FilePath $configFilePath
        Confirm-JCRConfigFile
    }
}