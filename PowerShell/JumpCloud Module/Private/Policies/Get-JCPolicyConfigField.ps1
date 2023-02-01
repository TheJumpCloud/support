function Get-JCPolicyConfigField {
    [CmdletBinding()]
    param (
        # Template Object
        [Parameter(Mandatory = $true)]
        [System.Object]
        $templateObject,
        # The existing value body for policies
        [Parameter(Mandatory = $false)]
        [System.Object]
        $policyValues
    )
    begin {
        # TODO: validate templateID
        # TODO: set this globablly
        $configMapping = @{
            checkbox       = 'boolean'
            singlelistbox  = 'exclude'
            table          = 'exclude'
            customRegTable = 'table'
            textarea       = 'string'
            text           = 'string'
            file           = 'exclude'
            select         = 'multi'
            number         = 'int'
        }
    }
    process {
        # for each field in the object with a null value, prompt to enter the value
        # print policy value
        if ('table' -in $templateObject.type) {

            $policyValues | Format-Table -Property @{label = "Row"; Expression = { $policyvalues.indexOf($_) } }, * | Out-Host
        } else {
            $returnObject = $templateObject | Select-Object @{label = "Value"; expression = { $PolicyValues[$TemplateObject.indexof($_)] } }, Label, configFieldName, type
        }
        # if ($policyValues) {
        # }


    }
    end {
        # Return template config field
        return $returnObject
        # TODO: return the whole enchilada

        # $body = [PSCustomObject]@{
        #     name     = $policyName
        #     template = $policyTemplateID
        #     values   = @($policyValues)
        # } | ConvertTo-Json -Depth 99
        # return
    }
}



. "/Users/jworkman/Documents/GitHub/support/PowerShell/JumpCloud Module/Private/Policies/New-CustomRegistryTableRow.ps1"