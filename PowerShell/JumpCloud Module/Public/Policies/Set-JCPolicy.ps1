function Set-JCPolicy {
    [CmdletBinding(DefaultParameterSetName = 'ByID')]
    param (
        [Parameter(Mandatory = $true,
            ParameterSetName = 'ByID',
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The ID of the existing JumpCloud Policy to modify')]
        [Alias("id")]
        [System.String]
        $PolicyID,
        [Parameter(Mandatory = $true,
            ParameterSetName = 'ByName',
            ValueFromPipelineByPropertyName = $false,
            HelpMessage = 'The name of the existing JumpCloud Policy template to modify')]
        [Alias("name")]
        [System.String]
        $PolicyName,
        [Parameter(Mandatory = $false,
            HelpMessage = 'The new name to set on the existing JumpCloud Policy. If left unspecified, the cmdlet will not rename the existing policy.')]
        [System.String]
        $NewName,
        [Parameter(ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The values object either built manually or passed in through Get-JCPolicy')]
        [System.object[]]
        $Values,
        [Parameter(Mandatory = $false,
            HelpMessage = 'The notes to set on the existing JumpCloud Policy.')]
        [System.String]
        $Notes
    )
    DynamicParam {

        if ($PSBoundParameters["PolicyID"]) {
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Mandatory = $false
            $ParameterAttribute.ParameterSetName = "ByID"
            # Get the policy by ID
            $foundPolicy = Get-JCPolicy -PolicyID $PolicyID
            if ([string]::IsNullOrEmpty($foundPolicy.ID)) {
                throw "Could not find policy by ID"
            }
            if (($foundPolicy.ID).count -gt 1) {
                throw "multiple policies with the same name were found, please specify a policy by ID"
            }

        } elseif ($PSBoundParameters["PolicyName"]) {
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Mandatory = $false
            $ParameterAttribute.ParameterSetName = "ByName"
            # Get the policy by Name
            $foundPolicy = Get-JCPolicy -Name $PolicyName
            if ([string]::IsNullOrEmpty($foundPolicy.ID)) {
                throw "Could not find policy by specified Name"
            }
            if (($foundPolicy.ID).count -gt 1) {
                throw "multiple policies with the same name were found, please specify a policy by ID"
            }
        }
        # If policy is identified, get the dynamic policy set
        if ($foundPolicy.id -And ($PSBoundParameters["PolicyName"] -OR $PSBoundParameters["PolicyID"])) {
            # Set the policy template object based on policy
            $templateObject = Get-JCPolicyTemplateConfigField -templateID $foundPolicy.Template.Id
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
                # Set the help message
                if ([String]::IsNullOrEmpty($($key.help))) {
                    $ParameterAttribute.HelpMessage = "sets the value for the $($key.name) field"
                } else {
                    $ParameterAttribute.HelpMessage = "$($key.help)"
                }
                # Add the attributes to the attributes collection
                $AttributeCollection.Add($ParameterAttribute)
                # Add the param
                $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParamName_Filter, $paramType, $AttributeCollection)
                $RuntimeParameterDictionary.Add($ParamName_Filter, $RuntimeParameter)
                if ($ParamName_Filter -eq "customRegTable") {
                    $RegImport_RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
                    $RegImport_AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                    $RegImport_ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
                    $RegImport_paramType = [System.IO.FileInfo]
                    $RegImport_ParameterAttribute.HelpMessage = 'A .reg file path that will be uploaded into the "Advanced: Custom Registry Keys" Windows Policy template.'
                    $RegImport_AttributeCollection.Add($RegImport_ParameterAttribute)
                    $RegImport_RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter('RegistryFile', $RegImport_paramType, $RegImport_AttributeCollection)
                    $RuntimeParameterDictionary.Add('RegistryFile', $RegImport_RuntimeParameter)
                }
                if ($ParamName_Filter -eq "customRegTable") {
                    $RegImport_RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
                    $RegImport_AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                    $RegImport_ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
                    $RegImport_paramType = [Switch]
                    $RegImport_ParameterAttribute.HelpMessage = 'When specified along with the RegistryFile parameter, existing registry values will be overwritten'
                    $RegImport_AttributeCollection.Add($RegImport_ParameterAttribute)
                    $RegImport_RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter('RegistryOverwrite', $RegImport_paramType, $RegImport_AttributeCollection)
                    $RuntimeParameterDictionary.Add('RegistryOverwrite', $RegImport_RuntimeParameter)
                }
            }
            # Returns the dictionary
            return $RuntimeParameterDictionary
        }
    }
    begin {
        Write-Debug 'Verifying JCAPI Key'
        if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
            Connect-JCOnline
        }
    }
    process {
        # Get Existing Policy Data if not set through dynamic param
        if (([string]::IsNullOrEmpty($foundPolicy.ID)) -And ($policyID)) {
            # Get the policy by ID
            $foundPolicy = Get-JCPolicy -PolicyID $PolicyID
            if ([string]::IsNullOrEmpty($foundPolicy.ID)) {
                throw "Could not find policy by ID"
            }
            if (($foundPolicy.ID).count -gt 1) {
                throw "multiple policies with the same name were found, please specify a policy by ID"
            }
        }
        $templateObject = Get-JCPolicyTemplateConfigField -templateID $foundPolicy.Template.Id
        # First set the name from PSParamSet if set; else set from policy
        $policyNameFromProcess = if ($PSBoundParameters["NewName"]) {
            $NewName
        } else {
            $foundPolicy.name
        }
        $params = $PSBoundParameters
        $paramterSet = $params.keys
        $DynamicParamSet = $false
        $requiredSet = @('PolicyID', 'PolicyName', 'NewName' , 'Values')
        foreach ($parameter in $paramterSet) {
            $parameterComparison = Compare-Object -ReferenceObject $requiredSet -DifferenceObject $parameter
            if ($parameterComparison | Where-Object { ( $_.sideindicator -eq "=>") -And ($_.InputObject -ne "Notes") }) {
                $DynamicParamSet = $true
                break
            }
        }

        # only update newName or Notes:
        if ((("NewName" -in $params.keys) -AND ("Values" -notin $params.Keys)) -OR
            (("Notes" -in $params.keys) -AND ("Values" -notin $params.Keys))) {
            $Values = $foundPolicy.values
        }
        # get the notes if it's not in the param set
        if (-not $PSBoundParameters["Notes"]) {
            $Notes = $foundPolicy.Notes
        }

        if ($DynamicParamSet) {
            # begin dynamic param set
            $newObject = New-Object System.Collections.ArrayList
            for ($i = 0; $i -lt $templateObject.objectMap.count; $i++) {
                # If one of the dynamicParam config fields are passed in and is found in the policy template, set the new value:
                if ($templateObject.objectMap[$i].configFieldName -in $params.keys) {
                    $keyName = $params.keys | Where-Object { $_ -eq $templateObject.objectMap[$i].configFieldName }
                    # write-host "Setting value from $($keyName)"
                    $keyValue = $params.$KeyName
                    switch ($templateObject.objectMap[$i].type) {
                        'multi' {
                            $templateObject.objectMap[$i].value = $(($templateObject.objectMap[$i].validation | Where-Object { $_.Values -eq $keyValue }).keys)
                        }
                        'file' {
                            $path = Test-Path -Path $keyValue
                            if ($path) {
                                # convert file path to base64 string
                                $templateObject.objectMap[$i].value = [convert]::ToBase64String((Get-Content -Path $keyValue -AsByteStream))
                            }
                            #TODO: else we should throw an error here that the file path was not valid
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
                                $regRows.Add($regItem) | Out-Null
                            }
                            $templateObject.objectMap[$i].value = $regRows
                        }
                        Default {
                            $templateObject.objectMap[$i].value = $($keyValue)
                        }
                    }
                    $newObject.Add($templateObject.objectMap[$i]) | Out-Null
                } elseif ('RegistryFile' -in $params.Keys) {
                    try {
                        $regKeys = Convert-RegToPSObject -regFilePath $($params.'RegistryFile')
                    } catch {
                        throw $_
                    }
                    # Set the registryFile as the customRegTable
                    if ('RegistryOverwrite' -in $params.Keys) {
                        $templateObject.objectMap[0].value = $regKeys
                        $newObject.Add($templateObject.objectMap[0]) | Out-Null
                    } else {
                        $registryList = New-Object System.Collections.ArrayList
                        $registryList += $foundPolicy.values.value
                        $registryList += $regKeys
                        $templateObject.objectMap[0].value += $registryList
                        $newObject.Add($templateObject.objectMap[0]) | Out-Null
                    }
                } else {
                    # Else if the dynamicParam for a config field is not specified, set the value from the defaultValue
                    $templateObject.objectMap[$i].value = ($foundPolicy.values | Where-Object { $_.configFieldID -eq $templateObject.objectMap[$i].configFieldID }).value
                    $newObject.Add($templateObject.objectMap[$i]) | Out-Null
                }
            }
            $updatedPolicyObject = $newObject | Select-Object configFieldID, configFieldName, value
            if ($registryFile) {
                try {
                    $regKeys = Convert-RegToPSObject -regFilePath $registryFile
                } catch {
                    throw $_
                }
                $updatedPolicyObject.value += $regKeys
                Write-Debug $updatedPolicyObject
            }
        } elseif ($values) {
            # begin value param set
            $updatedPolicyObject = New-Object System.Collections.ArrayList
            # Add each value into the object to set the policy
            foreach ($value in $values) {
                $updatedPolicyObject.add($value) | Out-Null
            }
            # If only one or a few of the config fields were set, add the remaining items from $foundPolicy.values
            $foundPolicy.values | ForEach-Object {
                if ($_.configFieldID -notin $updatedPolicyObject.configFieldID) {
                    $updatedPolicyObject.Add($_) | Out-Null
                }
            }
        } else {
            if (($templateObject.objectMap).count -gt 0) {
                # Begin user prompt
                $initialUserInput = Show-JCPolicyValues -policyObject $templateObject.objectMap -policyValues $foundPolicy.values
                # User selects edit all fields
                if ($initialUserInput.fieldSelection -eq 'A') {
                    for ($i = 0; $i -le $initialUserInput.fieldCount; $i++) {
                        $updatedPolicyObject = Set-JCPolicyConfigField -templateObject $templateObject.objectMap -fieldIndex $i -policyValues $foundPolicy.values
                    }
                    # Display policy values
                    # Show-JCPolicyValues -policyObject $updatedPolicyObject -ShowTable $true
                }
                # User selects edit individual field
                elseif ($initialUserInput.fieldSelection -ne 'C' -or $initialUserInput.fieldSelection -ne 'A') {
                    $updatedPolicyObject = Set-JCPolicyConfigField -templateObject $templateObject.objectMap -fieldIndex $initialUserInput.fieldSelection -policyValues $foundPolicy.values
                    # For set-jcpolicy, add the help & label options
                    $updatedPolicyObject | ForEach-Object {
                        if ($_.configFieldID -in $templateObject.objectMap.configFieldID) {
                            $_ | Add-Member -MemberType NoteProperty -Name "help" -Value $templateObject.objectMap[$templateObject.objectMap.configFieldID.IndexOf($($_.configFieldID))].help
                            $_ | Add-Member -MemberType NoteProperty -Name "label" -Value $templateObject.objectMap[$templateObject.objectMap.configFieldID.IndexOf($($_.configFieldID))].label
                        }
                    }
                    Do {
                        # Hide option to edit all fields
                        $userInput = Show-JCPolicyValues -policyObject $updatedPolicyObject -HideAll $true -policyValues $foundPolicy.values
                        $updatedPolicyObject = Set-JCPolicyConfigField -templateObject $templateObject.objectMap -fieldIndex $userInput.fieldSelection -policyValues $foundPolicy.values
                    } while ($userInput.fieldSelection -ne 'C')
                }
            }
        }
        if ($updatedPolicyObject) {
            $body = [PSCustomObject]@{
                name     = $policyNameFromProcess
                template = @{id = $foundPolicy.Template.Id }
                values   = @($updatedPolicyObject)
                notes    = $Notes
            } | ConvertTo-Json -Depth 99
        } else {
            $body = [PSCustomObject]@{
                name     = $policyNameFromProcess
                template = @{id = $foundPolicy.Template.Id }
                notes    = $Notes
            } | ConvertTo-Json -Depth 99
        }
        $headers = @{
            'x-api-key'    = $env:JCApiKey
            'x-org-id'     = $env:JCOrgId
            'content-type' = "application/json"
        }
        $response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/v2/policies/$($foundPolicy.id)" -Method PUT -Headers $headers -ContentType 'application/json' -Body $body
        if ($response) {
            $response | Add-Member -MemberType NoteProperty -Name "templateID" -Value $response.template.id
        }
    }
    end {
        return $response | Select-Object -Property "name", "id", "templateID", "values", "template", "notes"
    }
}
