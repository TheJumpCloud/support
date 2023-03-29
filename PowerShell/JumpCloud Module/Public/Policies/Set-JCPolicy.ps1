function Set-JCPolicy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.String]
        $policyID,
        [Parameter()]
        [System.String]
        $Name,
        [Parameter()]
        [System.object[]]
        $policyObject
    )
    DynamicParam {
        if ($policyID) {
            $policy = Get-JcPolicy -Id $policyID
            $object = Get-JCPolicyTemplateConfigField -templateID $policy.Template.Id
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # Foreach key in the supplied config file:
            foreach ($key in $object) {
                # Set the dynamic parameters' name
                $ParamName_Filter = "$($key.configFieldName)"
                # Create the collection of attributes
                $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                # If ValidateSet is specified in the config file, set the value here:
                # If the type of value is a bool, create a custom validateSet attribute here:
                # TODO: this should be a case statement list
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
                        Continue
                    }
                    'customRegTable' {
                        Continue
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
                $ParameterAttribute.HelpMessage = "sets the $($key.label) settings"
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
        $policy = Get-JcPolicy -Id $policyID
        $templateObject = Get-JCPolicyTemplateConfigField -templateID $policy.Template.Id
    }
    process {
        if ($PSCmdlet.ParameterSetName -eq "DynamicParam") {
            $params = $PSBoundParameters

            $newObject = New-Object System.Collections.ArrayList
            for ($i = 0; $i -lt $templateObject.length; $i++) {
                # If one of the dynamicParam config fields are passed in and is found in the policy template, set the new value:
                if ($templateObject[$i].configFieldName -in $params.keys) {
                    $keyName = $params.keys | where-object { $_ -eq $templateObject[$i].configFieldName }
                    # write-host "Setting value from $($keyName)"
                    $keyValue = $params.$KeyName
                    if ($templateObject[$i].type -eq 'multi') {
                        $templateObject[$i].value = $(($templateObject[$i].validation | Where-Object { $_.Values -eq $keyValue }).keys)
                    } else {
                        # TODO: cast as boolean if just "fasle/true"
                        $templateObject[$i].value = $($keyValue)
                    }
                    $newObject.Add($templateObject[$i]) | Out-Null
                } else {
                    # Else if the dynamicParam for a config field is not specified, set the value from the defaultValue
                    $templateObject[$i].value = ($policy.values | Where-Object { $_.configFieldName -eq $object[$i].configFieldName }).value
                    $newObject.Add($templateObject[$i]) | Out-Null
                }
            }
            $updatedPolicyObject = $newObject | select configFieldID, configFieldName, value
            # write-host $updatedPolicyObject
            #TODO: Create object containing values set using dynamicParams
            #TODO: Pass object into policies endpoint to create new policy
        } else {
            $initialUserInput = Show-JCPolicyValues -policyObject $templateObject -policyValues $policy.values
            if ($initialUserInput -ne 'C') {
                $updatedPolicyObject = Set-JCPolicyConfigField -templateObject $templateObject -fieldIndex $initialUserInput -policyValues $policy.values
                Do {
                    $userInput = Show-JCPolicyValues -policyObject $templateObject -policyValues $policy.values
                    $updatedPolicyObject = Set-JCPolicyConfigField -templateObject $templateObject -fieldIndex $userInput -policyValues $policy.values
                } while ($userInput -ne 'C')
            }
        }
        $headers = @{}
        $headers.Add("x-api-key", $env:JCApiKey)
        $headers.Add("x-org-id", $env:JCOrgId)
        $headers.Add("content-type", "application/json")
        $body = [PSCustomObject]@{
            name     = $policy.Name
            template = @{id = $policy.Template.Id }
            values   = @($updatedPolicyObject)
        } | ConvertTo-Json -Depth 99
        $response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/v2/policies/$policyID" -Method PUT -Headers $headers -ContentType 'application/json' -Body $body
    }
    end {
        return $response.Template
    }
}