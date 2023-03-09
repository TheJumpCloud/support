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
        [Parameter(Mandatory = $false)]
        [System.String]
        $policyName,
        # The policy templateID
        [Parameter(Mandatory = $true)]
        [System.String]
        $policyTemplateID,
        # The field to edit
        [Parameter(Mandatory = $false)]
        [System.String]
        $fieldIndex,
        [Parameter(Mandatory = $false)]
        [switch]
        $registry
    )
    begin {
        # TODO: validate templateID
        # TODO: set this globally
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

        # Check to see if policyValues are explicitly stated, if not use the templateObject as current values
        if (!$policyValues) {
            $policyValues = $templateObject
        }
    }
    process {
        # for each field in the object with a null value, prompt to enter the value
        # print policy value
        # if ('table' -in $templateObject.type) {
        #     # If custom registry table, display all rows
        #     $policyValues | Format-Table -Property @{label = "Row"; Expression = { $policyvalues.indexOf($_) } }, * | Out-Host
        # } else {
        #     # If not table, display just the row #, the name and value pairs
        #     $templateobject | Format-Table @{label = "Row"; expression = { $TemplateObject.position -replace '\..+' } }, @{label = "Value"; expression = { $PolicyValues[$($TemplateObject.position) - 1].value } }, Label | Out-Host
        #     # $templateObject | Format-Table @{label = "Row"; expression = { $TemplateObject.indexof($_) } }, @{label = "Value"; expression = { $PolicyValues[$TemplateObject.indexof($_)] } }, Label | Out-Host
        # }

        #TODO: after showing the current values for the policy, prompt user if they want to update JUST one specific field by row:
        # EX: enter the row # you wish to update: 1-9
        if ($fieldIndex) {
            $field = $templateObject[$fieldIndex]
            # $field = $templateObject | Where-Object { $_.position -eq $row }
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
                            Write-Host "enter a boolean you hooligan"
                        }
                        $field.value = $fieldValue
                        ($policyValues | Where-Object { $_.configFieldID -eq $field.configFieldID }).value = $fieldValue
                        break
                    } While (($fieldValue -ne $true) -or ($fieldValue -ne $false))
                }
                'string' {
                    Do {
                        $fieldValue = (Read-Host "Please enter the $($field.type) value for the $($field.configFieldName) setting")
                        $field.value = $fieldValue
                        ($policyValues | Where-Object { $_.configFieldID -eq $field.configFieldID }).value = $fieldValue
                        break
                    } While (([string]::IsNullOrEmpty($fieldValue)))

                }
                'int' {
                    Do {
                        $fieldValue = (Read-Host "Please enter the $($field.type) value for the $($field.configFieldName) setting")
                        $field.value = $fieldValue
                        ($policyValues | Where-Object { $_.configFieldID -eq $field.configFieldID }).value = $fieldValue
                        break
                    } While ($fieldValue -isnot [int])
                }
                'multi' {
                    $field.validation | Format-Table | Out-Host
                    do {
                        $rownum = (Read-Host "Please enter the desired $($field.label) setting value (0 - $($field.validation.length - 1))")
                        $field.value = $rownum
                        ($policyValues | Where-Object { $_.configFieldID -eq $field.configFieldID }).value = $rownum

                    } While (0..[int]($field.validation.values.length - 1) -notcontains $rownum)
                }
                'table' {
                    if ($policyValues) {
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
                                # TODO: is there a better way to do this vs. recursively calling this function?
                                Set-JCPolicyConfigField -templateObject $templateObject -policyValues $policyValues -policyName $policyName -policyTemplateID $policyTemplateID
                            }
                            'A' {
                                # Add new row
                                [System.Collections.ArrayList]$rows = $policyValues
                                $tableRow = New-CustomRegistryTableRow
                                $rows.Add($tableRow) | Out-Null
                                # TODO: is there a better way to do this vs. recursively calling this function?
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
                                Write-Host $rowNum
                                # TODO: is there a better way to do this vs. recursively calling this function?
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
                        $rows.Add($tableRow) | Out-Null
                    }
                    $field.value = $rows
                }
                Default {
                }
            }


        }
        if ($registry) {
            # $field = $templateObject[$fieldIndex]
            if ($policyValues) {
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
                        # TODO: is there a better way to do this vs. recursively calling this function?
                        Set-JCPolicyConfigField -templateObject $templateObject -policyValues $policyValues -policyName $policyName -policyTemplateID $policyTemplateID
                    }
                    'A' {
                        # Add new row
                        $rows = @()
                        $rows += $policyValues.value
                        $tableRow = New-CustomRegistryTableRow
                        $rows += $tableRow
                    }
                    'R' {
                        # modify existing:
                        [System.Collections.Hashtable]$rows = $policyValues
                        do {
                            $rowNum = (Read-Host "Please enter row number you wish to remove: ")
                            break
                        } While ($rowNum -isnot [int])
                        $rows.RemoveAt($rowNum)
                        Write-Host $rowNum
                        $policyValues = $rows
                        # TODO: is there a better way to do this vs. recursively calling this function?
                        Set-JCPolicyConfigField -templateObject $templateObject -policyValues $policyValues -policyName $policyName -policyTemplateID $policyTemplateID

                    }
                    'C' {
                        break
                        # $output = [PSCustomObject]@{
                        #     configFieldID = $templateObject.configFieldID
                        #     value         = $policyValues
                        # }
                        # Write-Host "updating Policy..."
                        # return $output
                    }
                }
            } else {
                # Case for new tables
                $tableRow = New-CustomRegistryTableRow
                $rows = New-Object System.Collections.ArrayList
                $rows.Add($tableRow) | Out-Null
            }
            $policyValues.value += $rows
        }
        # Do {
        #     $rowPrompt = (Read-Host "Please enter the row number for the field you'd like to change")
        #     Set-JCPolicyConfigField -templateObject $templateObject -policyValues $policyValues -policyName $policyName -policyTemplateID $policyTemplateID -row $rowPrompt

        # } Until (($rowPrompt -match 'c'))
        #Then instead of prompting user to update each field in the template object, just update that single field.

        #If no specific row was chosen, update all fields:
        # foreach ($field in $templateObject) {
        #     switch ($field.type) {
        #         'boolean' {
        #             Do {
        #                 $fieldValue = (Read-Host "Please enter the $($field.type) value for the $($field.configFieldName) setting (t/f) (true/false)")
        #                 try {
        #                     if (($fieldValue -eq 't') -or ($fieldValue -eq 'true')) {
        #                         $fieldValue = $true
        #                     } elseif (($fieldValue -eq 'f') -or ($fieldValue -eq 'false')) {
        #                         $fieldValue = $false
        #                     } else {
        #                         $fieldValue = [System.Convert]::ToBoolean($fieldValue)
        #                     }
        #                 } catch {
        #                     Write-Host "enter a boolean you hooligan"
        #                 }
        #                 $field.value = $fieldValue
        #                 break
        #             } While (($fieldValue -ne $true) -or ($fieldValue -ne $false))
        #         }
        #         'string' {
        #             Do {
        #                 $fieldValue = (Read-Host "Please enter the $($field.type) value for the $($field.configFieldName) setting")
        #                 $field.value = $fieldValue
        #                 break
        #             } While (([string]::IsNullOrEmpty($fieldValue)))

        #         }
        #         'int' {
        #             Do {
        #                 $fieldValue = (Read-Host "Please enter the $($field.type) value for the $($field.configFieldName) setting")
        #                 $field.value = $fieldValue
        #                 break
        #             } While ($fieldValue -isnot [int])
        #         }
        #         'multi' {
        #             $field.validation | Format-Table | Out-Host
        #             do {
        #                 $rownum = (Read-Host "Please enter the desired $($field.label) setting value (0 - $($field.validation.length - 1))")
        #                 $field.value = $rownum

        #             } While (0..[int]($field.validation.values.length - 1) -notcontains $rownum)
        #         }
        #         'table' {
        #             if ($policyValues) {
        #                 # Determine action
        #                 $path = (Read-Host "Select an Action:`nModify (M) - edit existing rows`nAdd (A) - add new table rows`nRemove (R) - remove existing rows`nContinue (C) - save/ update policy`nEnter Action Choice: ")
        #                 switch ($path) {
        #                     'M' {
        #                         # modify existing:
        #                         do {
        #                             $rowNum = (Read-Host "Please enter row number you wish to modify (0 - $($policyValues.length - 1)) ")
        #                         } While (0..[int]($policyValues.length - 1) -notcontains $rownum)
        #                         $tableRow = New-CustomRegistryTableRow
        #                         $policyValues[$rowNum] = $tableRow
        #                         # TODO: is there a better way to do this vs. recursively calling this function?
        #                         Set-JCPolicyConfigField -templateObject $templateObject -policyValues $policyValues -policyName $policyName -policyTemplateID $policyTemplateID
        #                     }
        #                     'A' {
        #                         # Add new row
        #                         [System.Collections.ArrayList]$rows = $policyValues
        #                         $tableRow = New-CustomRegistryTableRow
        #                         $rows.Add($tableRow) | Out-Null
        #                         # TODO: is there a better way to do this vs. recursively calling this function?
        #                         Set-JCPolicyConfigField -templateObject $templateObject -policyValues $rows -policyName $policyName -policyTemplateID $policyTemplateID

        #                     }
        #                     'R' {
        #                         # modify existing:
        #                         [System.Collections.ArrayList]$rows = $policyValues
        #                         do {
        #                             $rowNum = (Read-Host "Please enter row number you wish to remove: ")
        #                             break
        #                         } While ($rowNum -isnot [int])
        #                         $rows.RemoveAt($rowNum)
        #                         Write-Host $rowNum
        #                         # TODO: is there a better way to do this vs. recursively calling this function?
        #                         Set-JCPolicyConfigField -templateObject $templateObject -policyValues $rows -policyName $policyName -policyTemplateID $policyTemplateID

        #                     }
        #                     'C' {
        #                         $output = [PSCustomObject]@{
        #                             configFieldID = $templateObject.configFieldID
        #                             value         = $policyValues
        #                         }
        #                         Write-Host "updating Policy..."
        #                         return $output
        #                     }
        #                 }
        #             } else {
        #                 # Case for new tables
        #                 $tableRow = New-CustomRegistryTableRow
        #                 $rows = New-Object System.Collections.ArrayList
        #                 $rows.Add($tableRow) | Out-Null
        #             }
        #             $field.value = $rows
        #         }
        #         Default {
        #         }
        #     }
        # TODO: validate other types (file, singleListBox)
        # TODO: singleListBox templateID 62e2ae60ab9878000167ca7a (encrypted DNS over HTTPS)
        # TODO: font policy, templateID 631f44bc2630c900017ed834
        # TODO: custom MDM policy, templateID 5f21c4d3b544067fd53ba0af
    }
    end {

        return $policyValues
        # TODO: return the new policy values here:
    }
}


. "/Users/gwein/Documents/GitHub/support/PowerShell/JumpCloud Module/Private/Policies/New-CustomRegistryTableRow.ps1"
$templateObject = Get-JCPolicyTemplateConfigField -templateID 5f07273cb544065386e1ce6f
$firstPass = Set-JCPolicyConfigField -templateObject $templateObject -policyTemplateID 5f07273cb544065386e1ce6f -registry
$secondPass = Set-JCPolicyConfigField -templateObject $templateObject -policyValues $firstPass -policyTemplateID 5f07273cb544065386e1ce6f -registry
$secondPass