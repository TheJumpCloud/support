function New-JCPolicy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The ID of the policy template to create as a new JumpCloud Policy')]
        [System.String]
        $TemplateID,
        [Parameter(Mandatory = $false,
            HelpMessage = 'The Name of the policy template to create as a new JumpCloud Policy')]
        [System.String]
        $TemplateName,
        [Parameter(Mandatory = $false,
            HelpMessage = 'The name of the policy to create')]
        [System.String]
        $Name,
        [Parameter(ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The values object either built manually or passed in through Get-JCPolicy')]
        [System.object[]]
        $Values
    )
    DynamicParam {
        if ($templateID) {
            $templateObject = Get-JCPolicyTemplateConfigField -templateID $templateID
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # Foreach key in the supplied config file:
            foreach ($key in $templateObject.objectMap) {
                # Set the dynamic parameters' name
                $ParamName_Filter = "$($key.configFieldName)"
                # Create the collection of attributes
                $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                # If ValidateSet is specified in the config file, set the value here:
                # If the type of value is a bool, create a custom validateSet attribute here:
                $paramType = $($key.type)
                switch ($paramType) {
                    'boolean' {
                        $arrSet = @("true", "false")
                        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
                        $AttributeCollection.Add($ValidateSetAttribute)
                    }
                    'multi' {
                        $paramType = 'string'
                        $arrSet = $key.validation.values
                        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
                        $AttributeCollection.Add($ValidateSetAttribute)
                    }
                    'file' {
                        $paramType = 'string'
                    }
                    'listbox' {
                        $paramType = [system.string[]]
                    }
                    'table' {
                        $paramType = [system.object[]]
                    }
                    'exclude' {
                        Continue
                    }
                    Default {
                        $paramType = 'string'
                    }
                }
                # TODO: case for string types
                # TODO: case for registry table types/ skip this param set
                # Create and set the parameters' attributes
                $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
                $ParameterAttribute.Mandatory = $false
                $ParameterAttribute.ParameterSetName = 'DynamicParam'
                if ([String]::isNullorEmpty($($key.help))) {
                    $ParameterAttribute.HelpMessage = "sets the value for the $($key.name) field"
                } else {
                    $ParameterAttribute.HelpMessage = "$($key.help)"
                }
                # Add the attributes to the attributes collection
                $AttributeCollection.Add($ParameterAttribute)
                # Add the param
                $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParamName_Filter, $paramType, $AttributeCollection)
                $RuntimeParameterDictionary.Add($ParamName_Filter, $RuntimeParameter)
            }
            # Returns the dictionary
            return $RuntimeParameterDictionary
        }
    }
    begin {
        $headers = @{}
    }
    process {
        # If TemplateName was specified get ID from hashed table
        if ($TemplateName) {
            $TemplateID = $templateNameList[$templateNameList.Name.IndexOf($TemplateName)].id
        }
        $templateObject = Get-JCPolicyTemplateConfigField -templateID $templateID
        $policyName = if ($PSBoundParameters["name"]) {
            $Name
        } else {
            $templateObject.defaultName
        }
        if ($PSCmdlet.ParameterSetName -eq "DynamicParam") {
            $params = $PSBoundParameters

            $newObject = New-Object System.Collections.ArrayList
            for ($i = 0; $i -lt $templateObject.objectMap.count; $i++) {
                # If one of the dynamicParam config fields are passed in and is found in the policy template, set the new value:
                if ($templateObject.objectMap[$i].configFieldName -in $params.keys) {
                    $keyName = $params.keys | Where-Object { $_ -eq $templateObject.objectMap[$i].configFieldName }
                    $keyValue = $params.$KeyName
                    # write-host "Setting value from $($keyName) $($KeyValue)"
                    switch ($templateObject.objectMap[$i].type) {
                        'multi' {
                            $templateObject.objectMap[$i].value = $(($templateObject.objectMap[$i].validation | Where-Object { $_.Values -eq $keyValue }).keys)
                            $templateObject.objectMap[$i].value = $(($templateObject.objectMap[$i].validation | Where-Object { $_.Values -eq $keyValue }).keys)
                        }
                        'file' {
                            $path = Test-Path -Path $keyValue
                            if ($path) {
                                # convert file path to base64 string
                                $templateObject.objectMap[$i].value = [convert]::ToBase64String((Get-Content -Path $keyValue -AsByteStream))
                            }
                        }
                        'table' {
                            $regRows = New-Object System.Collections.ArrayList
                            foreach ($regItem in $keyValue) {
                                $regRows.Add($regItem)
                            }
                            $templateObject.objectMap[$i].value = $regRows
                        }
                        Default {
                            $templateObject.objectMap[$i].value = $($keyValue)
                        }
                    }
                    $newObject.Add($templateObject.objectMap[$i]) | Out-Null
                } else {
                    # Else if the dynamicParam for a config field is not specified, set the value from the defaultValue
                    $templateObject.objectMap[$i].value = $templateObject.objectMap[$i].defaultValue
                    $newObject.Add($templateObject.objectMap[$i]) | Out-Null
                }
            }
            $updatedPolicyObject = $newObject | Select-Object configFieldID, configFieldName, value
            # write-host $updatedPolicyObject
            #TODO: Create object containing values set using dynamicParams
            #TODO: Pass object into policies endpoint to create new policy
        } elseif ($values) {
            $updatedPolicyObject = $values
        } else {
            $initialUserInput = Show-JCPolicyValues -policyObject $templateObject.objectMap
            # User selects edit all fields
            if ($initialUserInput.fieldSelection -eq 'A') {
                for ($i = 0; $i -le $initialUserInput.fieldCount; $i++) {
                    $updatedPolicyObject = Set-JCPolicyConfigField -templateObject $templateObject.objectMap -fieldIndex $i
                }
                # Display policy values
                Show-JCPolicyValues -policyObject $updatedPolicyObject -ShowTable $true
            }
            # User selects edit individual field
            elseif ($initialUserInput.fieldSelection -ne 'C' -or $initialUserInput.fieldSelection -ne 'A') {
                $updatedPolicyObject = Set-JCPolicyConfigField -templateObject $templateObject.objectMap -fieldIndex $initialUserInput.fieldSelection
                Do {
                    # Hide option to edit all fields
                    $userInput = Show-JCPolicyValues -policyObject $updatedPolicyObject -HideAll $true
                    $updatedPolicyObject = Set-JCPolicyConfigField -templateObject $templateObject.objectMap -fieldIndex $userInput.fieldSelection
                } while ($userInput.fieldSelection -ne 'C')
            }
        }

        # Validate PolicyObject
        $updatedPolicyObject | ForEach-Object {
            # Check to see if value property is set, if not set to defaultValue
            if ($_.value -eq $null) {
                $_.value = $_.defaultValue
            }
        }
        $headers.Add("x-api-key", $env:JCApiKey)
        $headers.Add("x-org-id", $env:JCOrgId)
        $headers.Add("content-type", "application/json")
        $body = [PSCustomObject]@{
            name     = $policyName
            template = @{id = $templateID }
            values   = @($updatedPolicyObject)
        } | ConvertTo-Json -Depth 99
        $response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/v2/policies/" -Method POST -Headers $headers -ContentType 'application/json' -Body $body
    }
    end {
        return $response | Select-Object -Property "name", "id", "templateID", "values", "template"
    }
}