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
        # The field to edit
        [Parameter(Mandatory = $true)]
        [System.String]
        $fieldIndex
    )
    begin {
        # Check to see if policyValues are explicitly stated, if not use the templateObject as current values
        if (!$policyValues) {
            $policyValues = $templateObject
        }
    }
    process {

        if ($fieldIndex) {
            $field = $templateObject[$fieldIndex]
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
                            Write-Warning "$fieldValue is not a boolean; please enter a boolean value: (t/f) (true/false)"
                        }
                        $field.value = $fieldValue
                        ($policyValues | Where-Object { $_.configFieldID -eq $field.configFieldID }).value = $fieldValue
                    } Until (($fieldValue -eq $true) -or ($fieldValue -eq $false))
                }
                'string' {
                    Do {
                        $fieldValue = (Read-Host "Please enter the $($field.type) value for the $($field.configFieldName) setting")
                        $field.value = $fieldValue
                        ($policyValues | Where-Object { $_.configFieldID -eq $field.configFieldID }).value = $fieldValue
                    } While (([string]::IsNullOrEmpty($fieldValue)))

                }
                'int' {
                    Do {
                        $fieldValue = (Read-Host "Please enter the $($field.type) value for the $($field.configFieldName) setting")
                        try {
                            $fieldValue = [int]$fieldValue
                        } catch {
                            Write-Warning "$fieldValue is not a int; please enter a int"
                        }
                        $field.value = $fieldValue
                        ($policyValues | Where-Object { $_.configFieldID -eq $field.configFieldID }).value = $fieldValue
                    } until ($fieldValue -is [int])
                }
                'multi' {
                    $field.validation | Format-Table | Out-Host
                    do {
                        $rownum = (Read-Host "Please enter the desired $($field.label) setting value (0 - $($field.validation.length - 1))")
                        try {
                            $rownum = [int]$rownum
                        } catch {
                            Write-Warning "$rownum is not a int; please enter a int"
                        }
                        $field.value = $rownum
                        ($policyValues | Where-Object { $_.configFieldID -eq $field.configFieldID }).value = $rownum

                    } While (0..[int]($field.validation.values.length - 1) -notcontains $rownum)
                }
                'listbox' {
                    $Title = "JumpCloud Policy Field Editor"
                    $Message = "Select an Action:"
                    $Modify = New-Object System.Management.Automation.Host.ChoiceDescription "&Modify", "Modify - edit existing rows"
                    $Add = New-Object System.Management.Automation.Host.ChoiceDescription "&Add", "Add - add new table rows"
                    $Remove = New-Object System.Management.Automation.Host.ChoiceDescription "&Remove", "Remove - remove existing rows"
                    $Continue = New-Object System.Management.Automation.Host.ChoiceDescription "&Continue", "Continue - save/ update policy"
                    $Options = [System.Management.Automation.Host.ChoiceDescription[]]($Modify, $Add, $Remove, $Continue)
                    # List current values if they existing
                    do {
                        if ($policyValues[$fieldIndex].value) {
                            if ($ValueObject) {
                                $valueDisplay = New-Object System.Collections.ArrayList
                                for ($i = 0; $i -lt $ValueObject.Count; $i++) {
                                    $valueDisplay.Add([PSCustomObject]@{
                                            row   = $i
                                            value = $ValueObject[$i]
                                        }) | Out-Null
                                }
                                $valueDisplay | Format-Table row, value | Out-Host
                            } else {
                                # If values, populate value display
                                $ValueObject = New-Object System.Collections.ArrayList
                                $valueDisplay = New-Object System.Collections.ArrayList
                                for ($i = 0; $i -lt $policyValues[$fieldIndex].value.Count; $i++) {
                                    $valueDisplay.Add([PSCustomObject]@{
                                            row   = $i
                                            value = $policyValues[$fieldIndex].value[$i]
                                        }) | Out-Null
                                    $ValueObject.Add($policyValues[$fieldIndex].value[$i]) | Out-Null
                                }
                                $valueDisplay | Format-Table row, value | Out-Host
                            }
                            $userChoice = $host.ui.PromptForChoice($title, $message, $options, 0)
                        } else {
                            $values = @()
                            if ($ValueObject) {
                                $valueDisplay = New-Object System.Collections.ArrayList
                                for ($i = 0; $i -lt $ValueObject.Count; $i++) {
                                    $valueDisplay.Add([PSCustomObject]@{
                                            row   = $i
                                            value = $ValueObject[$i]
                                        }) | Out-Null
                                }
                                $valueDisplay | Format-Table row, value | Out-Host
                                $userChoice = $host.ui.PromptForChoice($title, $message, $options, 0)
                            } else {
                                # No values, just prompt to enter new value (todo, skip to entering new value)
                                $ValueObject = New-Object System.Collections.ArrayList
                                $userChoice = 1
                            }
                        }
                        switch ($userChoice) {
                            0 {
                                # modify existing:
                                do {
                                    $rowNum = (Read-Host "Please enter row number you wish to modify (0 - $($ValueObject.count - 1)) ")
                                } While (0..[int](($ValueObject).Count - 1) -notcontains $rownum -or '' -eq $rowNum)
                                $singleListBoxValue = Read-Host "Please enter a text value for $($field.configFieldName)"
                                $ValueObject[$rowNum] = $singleListBoxValue
                            }
                            1 {
                                # Add new row
                                $singleListBoxValue = Read-Host "Please enter a text value for $($field.configFieldName)"
                                $ValueObject.add($singleListBoxValue) | Out-Null
                            }
                            2 {
                                # remove existing:
                                [System.Collections.ARRAYList]$ValueObjectCopy = $ValueObject
                                do {
                                    $rowNum = (Read-Host "Please enter row number you wish to remove (0 - $($ValueObject.count - 1)) ")
                                } While (0..[int](($ValueObject).Count - 1) -notcontains $rownum -or '' -eq $rowNum)
                                $ValueObjectCopy.RemoveAt($rowNum)
                                $ValueObject = $ValueObjectCopy
                            }
                            3 {
                                break
                            }

                        }
                    } While ($userChoice -ne 3)
                    # finally update values
                    $policyValues[$fieldIndex].value = $ValueObject
                }
                'file' {
                    do {
                        $filePath = Read-Host "Enter the file path location of the file for this policy"
                        $path = Test-Path -Path $filePath
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
                    $Title = "JumpCloud Policy Field Editor"
                    $Message = "Select an Action:"
                    $Modify = New-Object System.Management.Automation.Host.ChoiceDescription "&Modify", "Modify - edit existing rows"
                    $Add = New-Object System.Management.Automation.Host.ChoiceDescription "&Add", "Add - add new table rows"
                    $Remove = New-Object System.Management.Automation.Host.ChoiceDescription "&Remove", "Remove - remove existing rows"
                    $Continue = New-Object System.Management.Automation.Host.ChoiceDescription "&Continue", "Continue - save/ update policy"
                    $Options = [System.Management.Automation.Host.ChoiceDescription[]]($Modify, $Add, $Remove, $Continue)
                    Do {
                        if ($policyValues[$fieldIndex].value) {
                            if ($ValueObject) {
                                $valueDisplay = New-Object System.Collections.ArrayList
                                for ($i = 0; $i -lt $ValueObject.Count; $i++) {
                                    $valueDisplay.Add([PSCustomObject]@{
                                            row   = $i
                                            value = $ValueObject[$i]
                                        }) | Out-Null
                                }
                                $valueDisplay | Format-Table row, @{Label = "customData"; Expression = { $_.value | Select-Object -ExpandProperty customData } }, @{Label = "customRegType"; Expression = { $_.value | Select-Object -ExpandProperty customRegType } }, @{Label = "customLocation"; Expression = { $_.value | Select-Object -ExpandProperty customLocation } }, @{Label = "customValueName"; Expression = { $_.value | Select-Object -ExpandProperty customValueName } } | Out-Host
                            } else {
                                # If values, populate value display
                                $ValueObject = New-Object System.Collections.ArrayList
                                $valueDisplay = New-Object System.Collections.ArrayList
                                for ($i = 0; $i -lt $policyValues[$fieldIndex].value.Count; $i++) {
                                    $valueDisplay.Add([PSCustomObject]@{
                                            row   = $i
                                            value = $policyValues[$fieldIndex].value[$i]
                                        }) | Out-Null
                                    $ValueObject.Add($policyValues[$fieldIndex].value[$i]) | Out-Null
                                }
                                $valueDisplay | Format-Table row, @{Label = "customData"; Expression = { $_.value | Select-Object -ExpandProperty customData } }, @{Label = "customRegType"; Expression = { $_.value | Select-Object -ExpandProperty customRegType } }, @{Label = "customLocation"; Expression = { $_.value | Select-Object -ExpandProperty customLocation } }, @{Label = "customValueName"; Expression = { $_.value | Select-Object -ExpandProperty customValueName } } | Out-Host
                            }
                            $userChoice = $host.ui.PromptForChoice($title, $message, $options, 0)
                        } else {
                            $values = @()
                            if ($ValueObject) {
                                $valueDisplay = New-Object System.Collections.ArrayList
                                for ($i = 0; $i -lt $ValueObject.Count; $i++) {
                                    $valueDisplay.Add([PSCustomObject]@{
                                            row   = $i
                                            value = $ValueObject[$i]
                                        }) | Out-Null
                                }
                                $valueDisplay | Format-Table row, @{Label = "customData"; Expression = { $_.value | Select-Object -ExpandProperty customData } }, @{Label = "customRegType"; Expression = { $_.value | Select-Object -ExpandProperty customRegType } }, @{Label = "customLocation"; Expression = { $_.value | Select-Object -ExpandProperty customLocation } }, @{Label = "customValueName"; Expression = { $_.value | Select-Object -ExpandProperty customValueName } } | Out-Host
                                $userChoice = $host.ui.PromptForChoice($title, $message, $options, 0)
                            } else {
                                # Case for new tables
                                $ValueObject = New-Object System.Collections.ArrayList
                                $userChoice = 1
                            }
                        }
                        switch ($userChoice) {
                            0 {
                                # Modify existing:
                                do {
                                    $rowNum = (Read-Host "Please enter row number you wish to modify (0 - $($ValueObject.count - 1)) ")
                                } While (0..[int](($ValueObject.value).Count - 1) -notcontains $rownum -or '' -eq $rowNum)
                                $tableRow = New-CustomRegistryTableRow
                                $ValueObject[$rowNum] = $tableRow
                            }
                            1 {
                                # Add new row
                                $tableRow = New-CustomRegistryTableRow
                                $ValueObject.add($tableRow) | Out-Null
                            }
                            2 {
                                # Remove existing:
                                [System.Collections.ARRAYList]$ValueObjectCopy = $ValueObject
                                do {
                                    $rowNum = (Read-Host "Please enter row number you wish to remove (0 - $($ValueObject.count - 1)) ")
                                } While (0..[int](($ValueObject.value).Count - 1) -notcontains $rownum -or '' -eq $rowNum)
                                $ValueObjectCopy.RemoveAt($rowNum) | Out-Null
                                $ValueObject = $ValueObjectCopy
                            }
                            3 {
                                break
                            }
                        }
                    } While ($userChoice -ne 3)
                    # finally update values
                    $policyValues[$fieldIndex].value = $ValueObject
                }
                'multilist' {
                    # Test
                    # $policyValues[$fieldIndex].value = @(
                    #     @{ format = "int"; uri = "a"; value = "2" },
                    #     @{ format = "string"; uri = "b"; value = "test" },
                    #     @{ format = "bool"; uri = "c"; value = "true" }
                    # )
                    $Title = "JumpCloud Policy Field Editor"
                    $Message = "Select an Action:"
                    $Modify = New-Object System.Management.Automation.Host.ChoiceDescription "&Modify", "Modify - edit existing rows"
                    $Add = New-Object System.Management.Automation.Host.ChoiceDescription "&Add", "Add - add new table rows"
                    $Remove = New-Object System.Management.Automation.Host.ChoiceDescription "&Remove", "Remove - remove existing rows"
                    $Continue = New-Object System.Management.Automation.Host.ChoiceDescription "&Continue", "Continue - save/ update policy"
                    $Options = [System.Management.Automation.Host.ChoiceDescription[]]($Modify, $Add, $Remove, $Continue)
                    $multiListValues = New-Object System.Collections.ArrayList
                    $ValueObject = New-Object System.Collections.ArrayList
                    if ($policyValues[$fieldIndex].value) {
                        # Create a table to view
                        if ($ValueObject) {
                            $valueDisplay = New-Object System.Collections.ArrayList
                            for ($i = 0; $i -lt $ValueObject.Count; $i++) {
                                $valueDisplay.Add([PSCustomObject]@{
                                        row   = $i
                                        value = $ValueObject[$i]
                                    }) | Out-Null
                            }
                            $valueDisplay | Format-Table row, @{Label = "format"; Expression = { $_.value | Select-Object -ExpandProperty format } }, @{Label = "uri"; Expression = { $_.value | Select-Object -ExpandProperty uri } }, @{Label = "value"; Expression = { $_.value | Select-Object -ExpandProperty value } } | Out-Host
                        } else {
                            # If values, populate value display
                            $ValueObject = New-Object System.Collections.ArrayList
                            $valueDisplay = New-Object System.Collections.ArrayList
                            for ($i = 0; $i -lt $policyValues[$fieldIndex].value.Count; $i++) {
                                $valueDisplay.Add([PSCustomObject]@{
                                        row   = $i
                                        value = $policyValues[$fieldIndex].value[$i]
                                    }) | Out-Null
                                $ValueObject.Add($policyValues[$fieldIndex].value[$i]) | Out-Null
                            }
                            $valueDisplay | Format-Table row, @{Label = "format"; Expression = { $_.value | Select-Object -ExpandProperty format } }, @{Label = "uri"; Expression = { $_.value | Select-Object -ExpandProperty uri } }, @{Label = "value"; Expression = { $_.value | Select-Object -ExpandProperty value } } | Out-Host
                            $userChoice = $host.ui.PromptForChoice($title, $message, $options, 0)
                        }

                        switch ($userChoice) {
                            0 {
                                # Modify existing:
                                do {
                                    $rowNum = (Read-Host "Please enter row number you wish to modify (0 - $($ValueObject.count - 1)) ")
                                } While (0..[int](($ValueObject).Count - 1) -notcontains $rownum -or '' -eq $rowNum)
                                # Get the row value
                                $multListRow = New-UriListItem
                                $ValueObject[$rowNum] = $multListRow
                            }
                            1 {
                                # Add new row
                                $multiListValue = New-UriListItem
                                # Convert to a custom object
                                #$test = @( @{format = "int"; uri = "aasdadsdas"; value = "5" }, @{format = "string"; uri = "b"; value = "test" }, @{format = "bool"; uri = "c"; value = "true" } )
                                $ValueObject.Add($multiListValue) | Out-Null
                                # Output the object
                                #$ValueObject | Format-Table
                            }
                            2 {
                                # Remove existing:
                                [System.Collections.ARRAYLIST]$ValueObjectCopy = $ValueObject
                                do {
                                    $rowNum = (Read-Host "Please enter row number you wish to remove (0 - $($ValueObject.count - 1)) ")
                                } While (0..[int](($ValueObject).Count - 1) -notcontains $rownum -or '' -eq $rowNum)
                                $ValueObjectCopy.RemoveAt($rowNum) | Out-Null
                                $ValueObject = $ValueObjectCopy
                            }
                            3 {
                                break
                            }
                        }
                    } else {
                        do {
                            $validFormat = $false # Initialize to false for the while loop

                            do {
                                Write-Host "Please enter the format and value for the new entry."
                                $format = Read-Host "Enter the format (int, string, float, xml, boolean, base64) for the value"
                                $value = Read-Host "Enter the value"

                                # Validate format and value
                                switch ($format) {
                                    'int' {
                                        try {
                                            $value = [int]$value
                                            $validFormat = $true
                                        } catch {
                                            Write-Warning "Invalid integer value. Please try again."
                                        }
                                    }
                                    'float' {
                                        try {
                                            $value = [double]$value
                                            $validFormat = $true
                                        } catch {
                                            Write-Warning "Invalid float value. Please try again."
                                        }
                                    }
                                    'boolean' {
                                        try {
                                            $value = [System.Convert]::ToBoolean($value) # Attempt to convert to boolean
                                            $validFormat = $true
                                            $format = 'bool' # API expects boolean to be passed as bool
                                        } catch {
                                            Write-Warning "Invalid boolean value. Please enter 'true' or 'false'."
                                        }
                                    }
                                    'string' {
                                        $validFormat = $true
                                        $format = 'chr'
                                    } # String always valid
                                    'xml' {
                                        try {
                                            $validateXml = [xml]$value #attempt xml conversion.
                                            $validFormat = $true
                                        } catch {
                                            write-warning "Invalid xml. Please try again."
                                        }
                                    }
                                    'base64' {
                                        try {
                                            $testValue = [convert]::FromBase64String($value)
                                            $validFormat = $true
                                            $format = 'b64' # API expects base64 to be passed as b64
                                        } catch {
                                            write-warning "Invalid base64 string. please try again."
                                        }

                                    }
                                    default {
                                        Write-Warning "Invalid format. Please enter int, string, float, xml, boolean, or base64."
                                    }
                                }
                            } while (!$validFormat)

                            $uri = Read-Host "Enter the URI for the value"
                            $multiListValues = [PSCustomObject]@{
                                uri    = $uri
                                value  = $value # This will be the validated value based on the format
                                format = $format
                            }

                            $ValueObject.Add($multiListValues) | Out-Null

                            $addMore = Read-Host "Add another value? (y/n)"
                        } while ($addMore -eq 'y')
                    }

                    $policyValues[$fieldIndex].value = $ValueObject
                }
            }
        }
    }
    end {
        return $policyValues
    }
}

