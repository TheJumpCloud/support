function New-JCPolicy {
    [CmdletBinding(DefaultParameterSetName = 'ByID')]
    param (
        [Parameter(Mandatory = $true,
            ParameterSetName = 'ByID',
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The ID of the policy template to create as a new JumpCloud Policy')]
        [System.String]
        $TemplateID,
        [Parameter(Mandatory = $true,
            ParameterSetName = 'ByName',
            HelpMessage = 'The Name of the policy template to create as a new JumpCloud Policy')]
        [System.String]
        $TemplateName,
        [Parameter(Mandatory = $false,
            HelpMessage = 'The name of the policy to create. If left unspecified, the cmdlet will attempt to create the policy with the default name defined by the selected policy template.')]
        [System.String]
        $Name,
        [Parameter(ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The values object either built manually or passed in through Get-JCPolicy')]
        [System.object[]]
        $Values
    )
    DynamicParam {
        if ($PSBoundParameters["TemplateID"]) {
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Mandatory = $false
            $ParameterAttribute.ParameterSetName = "ByID"
            # Get the policy template by ID
            $templateObject = Get-JCPolicyTemplateConfigField -templateID $templateID
            if ([String]::IsNullOrEmpty($templateObject.defaultName)) {
                throw "Could not find policy template by ID"
            }

        } elseif ($PSBoundParameters["TemplateName"]) {
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Mandatory = $false
            $ParameterAttribute.ParameterSetName = "ByName"
            # Get the policy by Name
            if ($TemplateName -in $global:TemplateNameList.Name) {
                $matchedTemplate = $templateNameList[$templateNameList.Name.IndexOf($TemplateName)].id
            } else {
                throw "template list missing; have you run Connect-JCOnline"
            }
            $templateObject = Get-JCPolicyTemplateConfigField -templateID $matchedTemplate
            if ([String]::IsNullOrEmpty($templateObject.defaultName)) {
                throw "Could not find policy template by specified Name"
            }
        }

        if ($templateObject.objectMap -And ($PSBoundParameters["TemplateName"] -OR $PSBoundParameters["TemplateID"])) {
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
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {
            Connect-JCOnline
        }
    }
    process {
        $params = $PSBoundParameters
        $paramterSet = $params.keys
        $DynamicParamSet = $false
        $requiredSet = @('TemplateID', 'TemplateName', 'Name' , 'Values')
        foreach ($parameter in $paramterSet) {
            $parameterComparison = Compare-Object -ReferenceObject $requiredSet -DifferenceObject $parameter
            if ($parameterComparison | Where-Object { $_.sideindicator -eq "=>" }) {
                $DynamicParamSet = $true
                break
            }
        }
        # If TemplateName was specified get ID from hashed table
        if ($PSBoundParameters["TemplateName"]) {
            if ($TemplateName -in $templateNameList.Name) {
                $TemplateID = $templateNameList[$templateNameList.Name.IndexOf($TemplateName)].id
            } else {
                throw "The template name: `"$templateName`" was not found in the list of available template names. To find the list of avaiable template names, type `"New-JCPolcy -TemplateName ` and press the tab key. If prompted, press `"y`" to view all availbale templates. Templates start with os type. To find the list of avaiable windows template names, type `"New-JCPolcy -TemplateName windows`" and press the tab key. To find the list of avaiable darwin template names, type `"New-JCPolcy -TemplateName darwin`" and press the tab key. To find the list of avaiable linux template names, type `"New-JCPolcy -TemplateName linux`" and press the tab key."
            }
        }
        $templateObject = Get-JCPolicyTemplateConfigField -templateID $templateID
        $policyName = if ($PSBoundParameters["name"]) {
            $Name
        } else {
            $templateObject.defaultName
        }
        if ($DynamicParamSet) {
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
                        'listbox' {
                            if ($($keyValue).getType().name -eq 'String') {
                                # Given case for single string passed in as dynamic input, convert to a list
                                $listRows = New-Object System.Collections.ArrayList
                                foreach ($regItem in $keyValue) {
                                    $listRows.Add($regItem)
                                }
                                $templateObject.objectMap[$i].value = $listRows
                            } elseif ($($keyValue).getType().name -eq 'Object[]') {
                                # else if the object passed in is a list already, pass in list
                                $templateObject.objectMap[$i].value = $($keyValue)
                            }
                        }
                        'table' {
                            # For custom registry table, validate the object
                            if ($templateObject.objectMap[$i].configFieldName -eq "customRegTable") {
                                # get default value properties
                                $RegProperties = $templateObject.objectMap[$i].defaultValue | Get-Member -MemberType NoteProperty
                                # get passed in object properties
                                $ObjectProperties = if ($keyValue | Get-Member -MemberType NoteProperty) {
                                    # for lists get note properties
                                    ($keyValue | Get-Member -MemberType NoteProperty).Name
                                } else {
                                    # for single objects, get keys
                                    $keyValue.keys
                                }
                                $RegProperties | ForEach-Object {
                                    if ($_.Name -notin $ObjectProperties) {
                                        Throw "Custom Registry Tables require a `"$($_.Name)`" data string. The following data types were found: $($ObjectProperties)"
                                    }
                                }
                                # reg type validation
                                $validRegTypes = @('DWORD', 'expandString', 'multiString', 'QWORD', 'String')
                                $($keyValue).customRegType | ForEach-Object {
                                    if ($_ -notin $validRegTypes) {
                                        throw "Custom Registry Tables require the `"customRegType`" data string to be one of: $validRegTypes, found: $_"
                                    }
                                }
                            }
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
        } elseif ($values) {
            $updatedPolicyObject = $values
        } else {
            if (($templateObject.objectMap).count -gt 0) {
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
                $updatedPolicyObject = $updatedPolicyObject | Select-Object configFieldID, configFieldName, value
            }
        }

        # Validate PolicyObject
        if ($updatedPolicyObject) {
            $updatedPolicyObject | ForEach-Object {
                # Check to see if value property is set, if not set to defaultValue
                if ($_.value -eq $null) {
                    $_.value = $_.defaultValue
                }
            }
            $body = [PSCustomObject]@{
                name     = $policyName
                template = @{id = $templateID }
                values   = @($updatedPolicyObject)
            } | ConvertTo-Json -Depth 99
        } else {
            # for policies w/o payloads, just pass in the name & template
            $body = [PSCustomObject]@{
                name     = $policyName
                template = @{id = $templateID }
            } | ConvertTo-Json -Depth 99

        }
        $headers = @{
            'x-api-key'    = $env:JCApiKey
            'x-org-id'     = $env:JCOrgId
            'content-type' = "application/json"
        }
        $response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/v2/policies/" -Method POST -Headers $headers -ContentType 'application/json' -Body $body
        if ($response) {
            $response | Add-Member -MemberType NoteProperty -Name "templateID" -Value $response.template.id
        }

    }
    end {
        return $response | Select-Object -Property "name", "id", "templateID", "values", "template"
    }
}