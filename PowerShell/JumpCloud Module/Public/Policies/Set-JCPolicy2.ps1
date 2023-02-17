function Set-JCPolicy2 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        # Specifies the PolicyID for the policy to be edited
        $policyID,
        [Parameter()]
        [System.object[]]
        # Specifies the policy config fields to be passed into the policy (optional).
        $policyObject
    )
    DynamicParam {
        if ($policyID) {
            $policy = Get-JcPolicy -Id $policyID
            $object = Get-JCPolicyTemplateConfigField -templateID $policy.Template.Id
            # $paramObject
            $paramObject = Get-JCPolicyConfigField -templateObject $object -policyValues $policy.values.value
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            # Foreach key in the supplied config file:
            foreach ($key in $object) {
                # Set the dynamic parameters' name
                write-host "adding dynamic param: $key$($item)"
                $ParamName_Filter = "$($key.configFieldName)"
                # Create the collection of attributes
                $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                # If ValidateSet is specified in the config file, set the value here:
                # If the type of value is a bool, create a custom validateSet attribute here:
                # TODO: this should be a case statement list
                write-host "$($key.type)"
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
        # params used for dynamic param value setting
        $params = $PSBoundParameters
        # TODO: can we use object from dynamicParam here instead?
        $policy = Get-JcPolicy -Id $policyID
        # write-host $params
        # If the policyObject from Get-JCPolicy/ Custom PSObject is not passed in, begin steps to ask user how to edit the policy
        if ('policyObject' -notin $params.keys) {
            #Get stuff
            $object = Get-JCPolicyTemplateConfigField -templateID $policy.Template.Id
            if ($policy.values) {
                $policyObjectshort = Dispatch-JCPolicyConfigField -templateObject $object -policyValues $policy.values -PolicyName $policy.name -PolicyTemplateID $policy.Template.Id
            } else {
                # $policyObjectshort = Set-JCPolicyConfigField -templateObject $object | select configFieldID, configFieldName, value
                $policyObjectshort = Dispatch-JCPolicyConfigField -templateObject $object -PolicyName $policy.name -PolicyTemplateID $policy.Template.Id
            }

        } else {
            # Given this case, we assume that the dynamic parameter set was selected
            $newObject = New-Object System.Collections.ArrayList
            for ($i = 0; $i -lt $object.length; $i++) {
                # If one of the dynamicParam config fields are passed in and is found in the policy template, set the new value:
                if ($object[$i].configFieldName -in $params.keys) {
                    $keyName = $params.keys | where-object { $_ -eq $object[$i].configFieldName }
                    write-host "Setting value from $($keyName)"
                    $keyValue = $params.$KeyName
                    if ($object[$i].type -eq 'multi') {
                        $object[$i].value = $(($object[$i].validation | Where-Object { $_.Values -eq $keyValue }).keys)
                    } else {
                        # TODO: cast as boolean if just "fasle/true"
                        $object[$i].value = $($keyValue)
                    }
                    $newObject.Add($object[$i])
                } else {
                    # Else if the dynamicParam for a config field is not specified, set the value from the existing policy value:
                    write-host "$($object[$i].configFieldName)"
                    $object[$i].value = ($policy.values | Where-Object { $_.configFieldName -eq $object[$i].configFieldName }).value
                    $newObject.Add($object[$i])
                }
            }
            # Set the policy value body
            $policyObjectshort = $newObject | select configFieldID, configFieldName, value
        }
        # TODO: if policyObject is not specified or if it isn't complete, go get the template and rebuild
        # $policyTemplate = Get-JCPolicyTemplateConfigField -templateID $policy.TemplateId
        # TODO: validate policy by ID

        # TODO: validate policyObject is not missing values, name, id fields


    }
    process {
        $headers = @{}
        $headers.Add("x-api-key", $env:JCApiKey)
        $headers.Add("x-org-id", $env:JCOrgId)
        $headers.Add("content-type", "application/json")
        # Name, TemplateID and Policy Values compose body
        # Values object must contain all config fields
        $body = [PSCustomObject]@{
            name     = $policy.Name
            template = @{id = $policy.Template.Id }
            values   = @($policyObjectshort)
        } | ConvertTo-Json -Depth 99
        $response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/v2/policies/$policyID" -Method PUT -Headers $headers -ContentType 'application/json' -Body $body
        $response
    }
    end {

    }
}

. "/Users/jworkman/Documents/GitHub/support/PowerShell/JumpCloud Module/Private/Policies/Get-JCPolicyTemplateConfigField.ps1"
. "/Users/jworkman/Documents/GitHub/support/PowerShell/JumpCloud Module/Private/Policies/Set-JCPolicyConfigField.ps1"
. "/Users/jworkman/Documents/GitHub/support/PowerShell/JumpCloud Module/Private/Policies/Dispatch-JCPolicyConfigFiels.ps1"
. "/Users/jworkman/Documents/GitHub/support/PowerShell/JumpCloud Module/Private/Policies/Get-JCPolicyConfigField.ps1"
# $object = Get-JCPolicyTemplateConfigField -templateID 5e7d1d061f247572d6e777c6
# $policyValues = Set-JCPolicyConfigField -templateObject $object
# $policy = get-jcpolicy 5dd30d451f2475047185dc65

# $policy.values[1].value = 66
# $policy.values


# # Test with poilcy for registry settings
Set-JCPolicy2 -policyID 617086d01f2475214da91255

# Test with policy for multiple policy types
# Set-JCPolicy2 -policyID 5d681db345886d6f6267a656

# Notification Policy
# Set-JCPolicy2 -policyID 6390c9107a57de0001bbe1b9 #-AlertType None

# set-JCPolicy2 -policyId 604685fb1f24750bb5f9ab28 # screen recording
# set-JCPolicy2 -policyId 6390c9e67a57de0001bbe1ba # camera
# $objectMap = New-Object System.Collections.IDictionary
# $objectMap.Add(    @{configFieldID = '5c099e4c232e1109300e8e79'; configFieldName = 'forceDelayedSoftwareUpdates'; sensitive = False; value = True }
# )
# $objectMap.Add(    @{configFieldID = '5c099e4c232e1109300e8e7a'; configFieldName = 'enforcedSoftwareUpdateDelay'; sensitive = False; value = 66 }
# )
# # $body = @(
# #     @{configFieldID = '5c099e4c232e1109300e8e79'; configFieldName = 'forceDelayedSoftwareUpdates'; sensitive = False; value = True }
# #     @{configFieldID = '5c099e4c232e1109300e8e7a'; configFieldName = 'enforcedSoftwareUpdateDelay'; sensitive = False; value = 66 }
# # )

# $policyV = [JumpCloud.SDK.V2.Models.PolicyValue]::DeserializeFromPSObject($objectMap)
