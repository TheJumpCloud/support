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
        $fieldIndex
    )
    begin {
        # TODO: validate templateID
        # TODO: set this globally
        $configMapping = @{
            checkbox       = 'boolean'
            singlelistbox  = 'listbox'
            table          = 'exclude'
            customRegTable = 'table'
            textarea       = 'string'
            text           = 'string'
            file           = 'file'
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
                'listbox' {
                    # List current values if they existing
                    do {
                        if ($policyValues[$fieldIndex].value) {
                            if ($ValueObject) {
                                $valueDisplay = New-Object System.Collections.ArrayList
                                for ($i = 0; $i -lt $ValueObject.Count; $i++) {
                                    $valueDisplay.Add([PSCustomObject]@{
                                            row   = $i
                                            value = $ValueObject[$i]
                                        })
                                }
                                $valueDisplay | Out-Host
                            } else {
                                # If values, populate value display
                                $ValueObject = New-Object System.Collections.ArrayList
                                $valueDisplay = New-Object System.Collections.ArrayList
                                for ($i = 0; $i -lt $policyValues[$fieldIndex].value.Count; $i++) {
                                    $valueDisplay.Add([PSCustomObject]@{
                                            row   = $i
                                            value = $policyValues[$fieldIndex].value[$i]
                                        })
                                    $ValueObject.Add($policyValues[$fieldIndex].value[$i])
                                }
                                $valueDisplay | Out-Host
                            }
                            $userChoice = (Read-Host "Select an Action:`nModify (M) - edit existing rows`nAdd (A) - add new table rows`nRemove (R) - remove existing rows`nContinue (C) - save/ update policy`nEnter Action Choice: ")
                        } else {
                            $values = @()
                            if ($ValueObject) {
                                $valueDisplay = New-Object System.Collections.ArrayList
                                for ($i = 0; $i -lt $ValueObject.Count; $i++) {
                                    $valueDisplay.Add([PSCustomObject]@{
                                            row   = $i
                                            value = $ValueObject[$i]
                                        })
                                }
                                $valueDisplay | Out-Host
                                $userChoice = (Read-Host "Select an Action:`nModify (M) - edit existing rows`nAdd (A) - add new table rows`nRemove (R) - remove existing rows`nContinue (C) - save/ update policy`nEnter Action Choice: ")
                            } else {
                                # No values, just prompt to enter new value (todo, skip to enterting new value)
                                $userChoice = (Read-Host "Select an Action:`nAdd (A) - add new table rows`nContinue (C) - save/ update policy`nEnter Action Choice: ")
                                $ValueObject = New-Object System.Collections.ArrayList
                            }
                        }
                        switch ($userChoice) {
                            'M' {
                                # modify existing:
                                do {
                                    $rowNum = (Read-Host "Please enter row number you wish to modify (0 - $($ValueObject.count - 1)): ")
                                } While (0..[int]($policyValues.count - 1) -notcontains $rownum)
                                $singleListBoxValue = Read-Host "Please enter a text value: "
                                $ValueObject[$rowNum] = $singleListBoxValue
                            }
                            'A' {
                                # Add new row
                                $singleListBoxValue = Read-Host "Please enter a text value: "
                                $ValueObject.add($singleListBoxValue)
                            }
                            'R' {
                                # remove existing:
                                [System.Collections.ARRAYList]$ValueObjectCopy = $ValueObject
                                do {
                                    $rowNum = (Read-Host "Please enter row number you wish to remove (0 - $($ValueObject.count - 1)): ")
                                } While (0..[int]($policyValues.count - 1) -notcontains $rownum)
                                $ValueObjectCopy.RemoveAt($rowNum)
                                $ValueObject = $ValueObjectCopy
                            }
                            'C' {
                                break
                            }

                        }
                    } While ($userChoice -ne 'C')
                    # finally update values
                    $policyValues[$fieldIndex].value = $ValueObject
                }
                'file' {
                    do {
                        $filePath = Read-Host "Enter the file path location of the file for this policy"
                        # write-host "testing pasth:$($filePath):"
                        $path = Test-Path -path $filePath
                        if ($path) {
                            # convert file path to base64 string
                            $base64File = [convert]::ToBase64String((Get-Content -Path $filePath -AsByteStream))
                        }
                        if ($path -and (-not [string]::IsNullOrEmpty(($base64File)))) {
                            $fileValidated = $true
                        } else {
                            $fileValidated = $false
                        }
                    } Until ($fileValidated)
                    # Return the policy value here:
                    $policyValues[$fieldIndex].value = $base64File
                }
                'table' {
                    Do {
                        if ($policyValues[$fieldIndex].value) {
                            if ($ValueObject) {
                                $valueDisplay = New-Object System.Collections.ArrayList
                                for ($i = 0; $i -lt $ValueObject.Count; $i++) {
                                    $valueDisplay.Add([PSCustomObject]@{
                                            row   = $i
                                            value = $ValueObject[$i]
                                        })
                                }
                                $valueDisplay | Out-Host
                            } else {
                                # If values, populate value display
                                $ValueObject = New-Object System.Collections.ArrayList
                                $valueDisplay = New-Object System.Collections.ArrayList
                                for ($i = 0; $i -lt $policyValues[$fieldIndex].value.Count; $i++) {
                                    $valueDisplay.Add([PSCustomObject]@{
                                            row   = $i
                                            value = $policyValues[$fieldIndex].value[$i]
                                        })
                                    $ValueObject.Add($policyValues[$fieldIndex].value[$i])
                                }
                                $valueDisplay | Out-Host
                            }
                            $userChoice = (Read-Host "Select an Action:`nModify (M) - edit existing rows`nAdd (A) - add new table rows`nRemove (R) - remove existing rows`nContinue (C) - save/ update policy`nEnter Action Choice: ")
                        } else {
                            $values = @()
                            if ($ValueObject) {
                                $valueDisplay = New-Object System.Collections.ArrayList
                                for ($i = 0; $i -lt $ValueObject.Count; $i++) {
                                    $valueDisplay.Add([PSCustomObject]@{
                                            row   = $i
                                            value = $ValueObject[$i]
                                        })
                                }
                                $valueDisplay | Out-Host
                                $userChoice = (Read-Host "Select an Action:`nModify (M) - edit existing rows`nAdd (A) - add new table rows`nRemove (R) - remove existing rows`nContinue (C) - save/ update policy`nEnter Action Choice: ")
                            } else {
                                # No values, just prompt to enter new value (todo, skip to enterting new value)
                                # Case for new tables
                                $tableRow = New-CustomRegistryTableRow
                                $ValueObject = New-Object System.Collections.ArrayList
                                $ValueObject.Add($tableRow) | Out-Null
                            }
                        }
                        switch ($userChoice) {
                            'M' {
                                # Modify existing:
                                do {
                                    $rowNum = (Read-Host "Please enter row number you wish to modify (0 - $($ValueObject.count - 1)) ")
                                } While (0..[int](($ValueObject.value).Count - 1) -notcontains $rownum)
                                $tableRow = New-CustomRegistryTableRow
                                $ValueObject[$rowNum] = $tableRow
                            }
                            'A' {
                                # Add new row
                                $tableRow = New-CustomRegistryTableRow
                                $ValueObject.add($tableRow)
                            }
                            'R' {
                                # Remove existing:
                                [System.Collections.ARRAYList]$ValueObjectCopy = $ValueObject
                                do {
                                    $rowNum = (Read-Host "Please enter row number you wish to remove (0 - $($ValueObject.count - 1)): ")
                                } While (0..[int]($policyValues.count - 1) -notcontains $rownum)
                                $ValueObjectCopy.RemoveAt($rowNum)
                                $ValueObject = $ValueObjectCopy
                            }
                            'C' {
                                break
                            }
                        }
                    } While ($userChoice -ne 'C')
                    # finally update values
                    $policyValues[$fieldIndex].value = $ValueObject
                }
            }
        }
    }
    end {

        return $policyValues
    }
}


. "/Users/gwein/Documents/GitHub/support/PowerShell/JumpCloud Module/Private/Policies/New-CustomRegistryTableRow.ps1"
$templateObject = Get-JCPolicyTemplateConfigField -templateID 5f07273cb544065386e1ce6f
$firstPass = Set-JCPolicyConfigField -templateObject $templateObject -policyTemplateID 5f07273cb544065386e1ce6f -registry
$secondPass = Set-JCPolicyConfigField -templateObject $templateObject -policyValues $firstPass -policyTemplateID 5f07273cb544065386e1ce6f -registry
$secondPass