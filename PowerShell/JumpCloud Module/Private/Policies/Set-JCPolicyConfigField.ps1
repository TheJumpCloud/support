function Set-JCPolicyConfigField {
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
            $templateObject | Format-Table @{label = "Row"; expression = { $TemplateObject.indexof($_) } }, @{label = "Value"; expression = { $PolicyValues[$TemplateObject.indexof($_)] } }, Label | Out-Host
        }
        # if ($policyValues) {
        # }

        foreach ($field in $templateObject) {
            switch ($field.type) {
                'boolean' {
                    Do {
                        $fieldValue = (Read-Host "Please enter the $($field.type) value for the $($field.configFieldName) setting (t/f) (true/false)")
                        try {
                            if (($fieldValue -eq 't') -or ($fieldValue -eq 'true')) {
                                $fieldValue = $true
                            } elseif (($fieldValue -eq 'f') -or ($fieldValue -eq 'false')) {
                                $fieldValue = $false
                            } else {
                                $fieldValue = [System.Convert]::ToBoolean($fieldValue)
                            }
                        } catch {
                            write-host "enter a boolean you hooligan"
                        }
                        $field.value = $fieldValue
                        break
                    } While (($fieldValue -ne $true) -or ($fieldValue -ne $false))
                }
                'string' {
                    Do {
                        $fieldValue = (Read-Host "Please enter the $($field.type) value for the $($field.configFieldName) setting")
                        $field.value = $fieldValue
                        break
                    } While (([string]::IsNullOrEmpty($fieldValue)))

                }
                'int' {
                    Do {
                        $fieldValue = (Read-Host "Please enter the $($field.type) value for the $($field.configFieldName) setting")
                        $field.value = $fieldValue
                        break
                    } While ($fieldValue -isnot [int])
                }
                'multi' {
                    Write-Host 'yre'
                    $field.validation | FT | out-host
                    do {
                        $rownum = (Read-Host "Please enter the desired $($field.label) setting value (0 - $($field.validation.length - 1))")
                        $field.value = $rownum

                    } While (0..[int]($field.validation.values.length -1) -notcontains $rownum)
                }
                'table' {
                    if ($policyValues) {
                        # TODO: Validate TYPE/ enum
                        # Determine action
                        $path = (Read-Host "Select an Action:`nModify (M) - edit existing rows`nAdd (A) - add new table rows`nRemove (R) - remove existing rows`nContinue (C) - save/ update policy`nEnter Action Choice: ")
                        switch ($path) {
                            'M' {
                                # modify existing:
                                do {
                                    $rowNum = (Read-Host "Please enter row number you wish to modify (0 - $($policyValues.length - 1)) ")
                                } While (0..[int]($policyValues.length - 1) -notcontains $rownum)
                                $tableRow = New-CustomRegistryTableRow
                                $policyValues[$rowNum] = $tableRow
                                Set-JCPolicyConfigField -templateObject $templateObject -policyValues $policyValues -policyName $policyName -policyTemplateID $policyTemplateID
                            }
                            'A' {
                                # Add new row
                                [System.Collections.ArrayList]$rows = $policyValues
                                $tableRow = New-CustomRegistryTableRow
                                $rows.Add($tableRow) | out-null
                                Set-JCPolicyConfigField -templateObject $templateObject -policyValues $rows -policyName $policyName -policyTemplateID $policyTemplateID

                            }
                            'R' {
                                # modify existing:
                                [System.Collections.ArrayList]$rows = $policyValues
                                do {
                                    $rowNum = (Read-Host "Please enter row number you wish to remove: ")
                                    break
                                } While ($rowNum -isnot [int])
                                $rows.RemoveAt($rowNum)
                                write-host $rowNum
                                Set-JCPolicyConfigField -templateObject $templateObject -policyValues $rows -policyName $policyName -policyTemplateID $policyTemplateID

                            }
                            'C' {
                                $output = [PSCustomObject]@{
                                    configFieldID = $templateObject.configFieldID
                                    value         = $policyValues
                                }
                                Write-Host "updating Policy..."
                                return $output
                            }
                        }
                    } else {
                        # Case for new tables
                        $tableRow = New-CustomRegistryTableRow
                        $rows = New-Object System.Collections.ArrayList
                        $rows.Add($tableRow) | out-null
                    }
                    $field.value = $rows
                }
                Default {
                }
            }
            #TODO: validate other types
        }
    }
    end {
        # Return template config field

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