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
            HelpMessage = 'The name of the existing JumpCloud Poliicy template to modify')]
        [System.String]
        $PolicyName,
        [Parameter(Mandatory = $false,
            HelpMessage = 'The new name to set on the existing JumpCloud Policy')]
        [System.String]
        $NewName,
        [Parameter(ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The values object either built manually or passed in through Get-JCPolicy')]
        [System.object[]]
        $Values
    )
    DynamicParam {

        if ($PolicyID) {
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Mandatory = $false
            $ParameterAttribute.ParameterSetName = "ByID"
            # Get the policy by ID
            $policy = Get-JCPolicy -PolicyID $PolicyID
            if ([string]::IsNullOrEmpty($policy.ID)) {
                throw "Could not find policy by ID"
            }

        } elseif ($PolicyName) {
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Mandatory = $false
            $ParameterAttribute.ParameterSetName = "ByName"
            # Get the policy by Name
            $policy = Get-JCPolicy -Name $PolicyName
            if ([string]::IsNullOrEmpty($policy.ID)) {
                throw "Could not find policy by specified Name"
            }
        }
        # If policy is identified, get the dynamic policy set
        if ($policy.id -And ($policyName -OR $policyID)) {
            # Set the policy template object based on policy
            $templateObject = Get-JCPolicyTemplateConfigField -templateID $policy.Template.Id
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
                        $paramType = [system.string[]]
                    }
                    'exclude' {
                        Continue
                    }
                    Default {
                        $paramType = 'string'
                    }
                }
                # Set the help message
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
    }
    process {
        # Get Existing Policy Data if not set through dynamic param
        if (([string]::IsNullOrEmpty($policy.ID)) -And ($policyID)) {
            # Get the policy by ID
            $policy = Get-JCPolicy -PolicyID $PolicyID
            if ([string]::IsNullOrEmpty($policy.ID)) {
                throw "Could not find policy by ID"
            }
        }
        # Get Config Field Values #TODO: no need to do this if we specify values
        $templateObject = Get-JCPolicyTemplateConfigField -templateID $policy.Template.Id
        # First set the name from PSParamSet if set; else set from policy
        $policyName = if ($PSBoundParameters["NewName"]) {
            $NewName
        } else {
            $policy.name
        }
        $params = $PSBoundParameters
        $paramterSet = $params.keys
        $DynamicParamSet = $false
        $requiredSet = @('PolicyID', 'PolicyName', 'NewName' , 'Values')
        foreach ($parameter in $paramterSet) {
            $parameterComparison = Compare-Object -ReferenceObject $requiredSet -DifferenceObject $parameter
            if ($parameterComparison | Where-Object { $_.sideindicator -eq "=>" }) {
                $DynamicParamSet = $true
                break
            }
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
                        }
                        Default {
                            $templateObject.objectMap[$i].value = $($keyValue)
                        }
                    }
                    $newObject.Add($templateObject.objectMap[$i]) | Out-Null
                } else {
                    # Else if the dynamicParam for a config field is not specified, set the value from the defaultValue
                    $templateObject.objectMap[$i].value = ($policy.values | Where-Object { $_.configFieldID -eq $templateObject.objectMap[$i].configFieldID }).value
                    $newObject.Add($templateObject.objectMap[$i]) | Out-Null
                }
            }
            $updatedPolicyObject = $newObject | Select-Object configFieldID, configFieldName, value
        } elseif ($values) {
            # begin value param set
            $updatedPolicyObject = New-Object System.Collections.ArrayList
            # Add each value into the object to set the policy
            foreach ($value in $values) {
                $updatedPolicyObject.add($value)
            }
            # If only one or a few of the config fields were set, add the remaining items from $policy.values
            $policy.values | ForEach-Object {
                if ($_.configFieldID -notin $updatedPolicyObject.configFieldID) {
                    $updatedPolicyObject.Add($_) | Out-Null
                }
            }
        } else {
            if (($templateObject.objectMap).count -gt 0) {
                # Begin user prompt
                $initialUserInput = Show-JCPolicyValues -policyObject $templateObject.objectMap -policyValues $policy.values
                # User selects edit all fields
                if ($initialUserInput.fieldSelection -eq 'A') {
                    for ($i = 0; $i -le $initialUserInput.fieldCount; $i++) {
                        $updatedPolicyObject = Set-JCPolicyConfigField -templateObject $templateObject.objectMap -fieldIndex $i -policyValues $policy.values
                    }
                    # Display policy values
                    # Show-JCPolicyValues -policyObject $updatedPolicyObject -ShowTable $true
                }
                # User selects edit individual field
                elseif ($initialUserInput.fieldSelection -ne 'C' -or $initialUserInput.fieldSelection -ne 'A') {
                    $updatedPolicyObject = Set-JCPolicyConfigField -templateObject $templateObject.objectMap -fieldIndex $initialUserInput.fieldSelection -policyValues $policy.values
                    # For set-jcpolicy, add the help & label options
                    $updatedPolicyObject | ForEach-Object {
                        if ($_.configFieldID -in $templateObject.objectMap.configFieldID) {
                            $_ | Add-Member -MemberType NoteProperty -Name "help" -Value $templateObject.objectMap[$templateObject.objectMap.configFieldID.IndexOf($($_.configFieldID))].help
                            $_ | Add-Member -MemberType NoteProperty -Name "label" -Value $templateObject.objectMap[$templateObject.objectMap.configFieldID.IndexOf($($_.configFieldID))].label
                        }
                    }
                    Do {
                        # Hide option to edit all fields
                        $userInput = Show-JCPolicyValues -policyObject $updatedPolicyObject -HideAll $true -policyValues $policy.values
                        $updatedPolicyObject = Set-JCPolicyConfigField -templateObject $templateObject.objectMap -fieldIndex $userInput.fieldSelection -policyValues $policy.values
                    } while ($userInput.fieldSelection -ne 'C')
                }
            }
        }
        if ($updatedPolicyObject) {
            $body = [PSCustomObject]@{
                name     = $policyName
                template = @{id = $policy.Template.Id }
                values   = @($updatedPolicyObject)
            } | ConvertTo-Json -Depth 99
        } else {
            $body = [PSCustomObject]@{
                name     = $policyName
                template = @{id = $policy.Template.Id }
            } | ConvertTo-Json -Depth 99
        }
        $headers = @{
            'x-api-key'    = $env:JCApiKey
            'x-org-id'     = $env:JCOrgId
            'content-type' = "application/json"
        }
        $response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/v2/policies/$($policy.id)" -Method PUT -Headers $headers -ContentType 'application/json' -Body $body
    }
    end {
        return $response | Select-Object -Property "name", "id", "templateID", "values", "template"
    }
}
