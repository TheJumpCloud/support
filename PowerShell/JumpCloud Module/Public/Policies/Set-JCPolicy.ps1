function Set-JCPolicy {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.String]
        $policyID,
        [Parameter()]
        [System.object[]]
        $policyObject
    )
    begin {
        $policy = Get-JcPolicy -Id $policyID

        if (!$policyObject) {
            #Get stuff
            $object = Get-JCPolicyTemplateConfigField -templateID $policy.Template.Id
            if ($policy.values.value) {
                $policyObjectshort = Set-JCPolicyConfigField -templateObject $object -policyValues $policy.values.value -PolicyName $policy.name -PolicyTemplateID $policy.Template.Id
            } else {
                $policyObjectshort = Set-JCPolicyConfigField -templateObject $object | select configFieldID, configFieldName, value
            }

        } else {
            $policyObjectshort = $policyObject | select configFieldID, configFieldName, value

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
# $object = Get-JCPolicyTemplateConfigField -templateID 5e7d1d061f247572d6e777c6
# $policyValues = Set-JCPolicyConfigField -templateObject $object
# $policy = get-jcpolicy 5dd30d451f2475047185dc65

# $policy.values[1].value = 66
# $policy.values


# Test with poilcy for registry settings
Set-JCPolicy -policyID 617086d01f2475214da91255

# Test with policy for multiple policy types
# Set-JCPolicy -policyID 6390c9107a57de0001bbe1b9


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
