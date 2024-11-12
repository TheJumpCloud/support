Function Set-JCPolicyGroup {
    [CmdletBinding()]
    param (
        [Parameter(
            ParameterSetName = 'ByName',
            ValueFromPipelineByPropertyName,
            Mandatory = $true,
            HelpMessage = 'The Name of the JumpCloud policy group you wish to set.')]
        [System.String]$Name,
        [Parameter(
            ParameterSetName = 'ByID',
            ValueFromPipelineByPropertyName,
            Mandatory = $true,
            HelpMessage = 'The Id of the JumpCloud policy group you wish to set.')]
        [Alias('_id', 'id')]
        [System.String]$PolicyGroupID,
        [Parameter(Mandatory = $false,
            HelpMessage = 'The new name to set on the existing JumpCloud policy group. If left unspecified, the cmdlet will not rename the existing policy group.')]
        [System.String]
        $NewName,
        [Parameter(
            ValueFromPipelineByPropertyName,
            Mandatory = $false,
            HelpMessage = 'The Description of the JumpCloud policy group you wish to set.')]
        [System.String]$Description
    )
    # DynamicParam {

    #     if ($PSBoundParameters["PolicyGroupID"]) {
    #         $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
    #         $ParameterAttribute.Mandatory = $false
    #         $ParameterAttribute.ParameterSetName = "ByID"
    #         $ParamName_Filter = "PolicyGroupId"
    #         $paramType = 'string'
    #         # Get the policy by ID
    #         $foundPolicyGroup = Get-JCPolicyGroup -PolicyGroupID $PolicyGroupID
    #         if ([string]::IsNullOrEmpty($foundPolicyGroup.ID)) {
    #             throw "Could not find policy group by ID"
    #         }

    #     } elseif ($PSBoundParameters["Name"]) {
    #         $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
    #         $ParameterAttribute.Mandatory = $false
    #         $ParameterAttribute.ParameterSetName = "Name"
    #         $ParamName_Filter = "Name"
    #         $paramType = 'string'
    #         # Get the policy by Name
    #         $foundPolicyGroup = Get-JCPolicyGroup -Name $Name
    #         if ([string]::IsNullOrEmpty($foundPolicyGroup.ID)) {
    #             throw "Could not find policy group by specified Name"
    #         }
    #     }
    #     # If policy is identified, get the dynamic policy set
    #     if ($foundPolicyGroup.id -And ($PSBoundParameters["Name"] -OR $PSBoundParameters["PolicyGroupID"])) {
    #         $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
    #         # Add the attributes to the attributes collection
    #         $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
    #         $AttributeCollection.Add($ParameterAttribute)
    #         # Add the param
    #         $ParamName_Filter
    #         $paramType
    #         $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParamName_Filter, $paramType, $AttributeCollection)
    #         $RuntimeParameterDictionary.Add($ParamName_Filter, $RuntimeParameter)
    #         # Returns the dictionary
    #         return $RuntimeParameterDictionary
    #     }
    # }
    begin {
        if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
            Connect-JCOnline
        }
        if ($PSBoundParameters["PolicyGroupID"]) {
            # Get the policy by ID
            $foundPolicyGroup = Get-JCPolicyGroup -PolicyGroupID $PolicyGroupID
            if ([string]::IsNullOrEmpty($foundPolicyGroup.ID)) {
                throw "Could not find policy group by ID"
            }

        } elseif ($PSBoundParameters["Name"]) {
            # Get the policy by Name
            $foundPolicyGroup = Get-JCPolicyGroup -Name $Name
            if ([string]::IsNullOrEmpty($foundPolicyGroup.ID)) {
                throw "Could not find policy group by specified Name"
            }
        }
        # if ($PSCmdlet.ParameterSetName -eq "ByName") {

        #     $foundPolicy = Get-JCPolicyGroup -Name $Name
        #     if ($foundPolicy) {
        #         $PolicyGroupID = $foundPolicy.ID
        #     }
        # }
    }
    process {

        # First set the name from PSParamSet if set; else set from policy
        $NameFromProcess = if ($PSBoundParameters["NewName"]) {
            $NewName
        } else {
            $foundPolicyGroup.name
        }
        $DescriptionFromProcess = if ($PSBoundParameters["Description"]) {
            $Description
        } else {
            $foundPolicyGroup.Description
        }

        $URL = "https://console.jumpcloud.com/api/v2/policygroups/$($foundPolicyGroup.id)"
        $BODY = @{
            name        = "$NameFromProcess"
            description = "$DescriptionFromProcess"
        } | ConvertTo-Json
        $Result = Invoke-JCApi -Method:('PUT') -Url:($URL) -Body:($BODY)
    }
    end {
        return $Result
    }
}

