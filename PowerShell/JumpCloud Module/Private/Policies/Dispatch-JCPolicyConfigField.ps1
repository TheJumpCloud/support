function Dispatch-JCPolicyConfigField {
    [CmdletBinding()]
    param (
        # Template Object
        [Parameter(Mandatory = $true)]
        [System.Object]
        $templateObject,
        # The existing value body for policies
        [Parameter(Mandatory = $false)]
        [System.Object]
        $policyValues,
        # The policy name
        [Parameter(Mandatory = $true)]
        [System.String]
        $policyName,
        # The policy templateID
        [Parameter(Mandatory = $true)]
        [System.String]
        $policyTemplateID
    )
    begin {
        # TODO: set this globally?
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
        Do {
            if ('table' -in $templateObject.type) {
                # If custom registry table, display all rows
                $policyValues | Format-Table -Property @{label = "Row"; Expression = { $policyvalues.indexOf($_) } }, * | Out-Host
                $rowPrompt = (Read-Host "Please enter the row number for the field you'd like to change")
                $templateObject, $policyValues = Set-JCPolicyConfigField -templateObject $templateObject -policyValues $policyValues -policyName $policyName-registry

            } else {
                # If not table, display just the row #, the name and value pairs
                $templateObject | Format-Table @{label = "Row"; expression = { $templateObject.indexof($_) } }, @{label = "Label"; expression = { $templateObject[$templateObject.indexof($_)].Label } }, @{label = "Value"; expression = {
                        $cfield = $templateObject[$templateObject.indexof($_)].configFieldID;
                        if ($templateObject[$templateObject.indexof($_)].Validation) {
                            $_.validation[($policyValues | Where-Object { $_.configFieldId -eq $cfield }).value].values

                        } else {
                            ($policyValues | Where-Object { $_.configFieldId -eq $cfield }).value
                        }
                    }
                }  | Out-Host
                $rowPrompt = (Read-Host "Please enter the row number for the field you'd like to change")
                try {
                    $rowPrompt = [int]$rowPrompt
                    $templateObject, $policyValues = Set-JCPolicyConfigField -templateObject $templateObject -policyValues $policyValues -policyName $policyName -row $rowPrompt
                } catch {
                    Throw "Could not convert $rowPrompt to int"
                }
            }

        } until (($rowPrompt -eq 'c'))
    }
    end {
        return $policyValues
    }
}