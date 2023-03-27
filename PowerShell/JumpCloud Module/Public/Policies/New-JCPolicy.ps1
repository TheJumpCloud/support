function New-JCPolicy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.String]
        $templateID,
        [Parameter(Mandatory)]
        [System.String]
        $Name,
        [Parameter()]
        [System.object[]]
        $policyObject
    )
    DynamicParam {
        if ($templateID) {
            $object = Get-JCPolicyTemplateConfigField -templateID $templateID
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
        $templateObject = Get-JCPolicyTemplateConfigField -templateID $templateID
    }
    process {
        if ($PSCmdlet.ParameterSetName -eq "DynamicParam") {
            #TODO: Create object containing values set using dynamicParams
            #TODO: Pass object into policies endpoint to create new policy
        } else {
            $initialUserInput = Show-JCPolicyValues -policyObject $templateObject
            if ($initialUserInput -ne 'C') {
                $updatedPolicyObject = Set-JCPolicyConfigField -templateObject $templateObject -fieldIndex $initialUserInput
                Do {
                    $userInput = Show-JCPolicyValues -policyObject $updatedPolicyObject
                    $updatedPolicyObject = Set-JCPolicyConfigField -templateObject $templateObject -fieldIndex $userInput
                } while ($userInput -ne 'C')
            }
            $headers = @{}
            $headers.Add("x-api-key", $env:JCApiKey)
            $headers.Add("x-org-id", $env:JCOrgId)
            $headers.Add("content-type", "application/json")
            $body = [PSCustomObject]@{
                name     = $Name
                template = @{id = $templateID}
                values   = @($updatedPolicyObject)
            } | ConvertTo-Json -Depth 99
            $response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/v2/policies/" -Method POST -Headers $headers -ContentType 'application/json' -Body $body
        }
    }
    end {
        return $response.Template
    }
}