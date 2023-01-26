function Set-JCPolicyConfigField {
    [CmdletBinding()]
    param (
        # Template Object
        [Parameter()]
        [System.Object]
        $templateObject
    )
    begin {
        # TODO: validate templateID
        # TODO: set this globablly
        $configMapping = @{
            checkbox      = 'boolean'
            singlelistbox = 'exclude'
            table         = 'exclude'
            textarea      = 'string'
            text          = 'string'
            file          = 'exclude'
            select        = 'multi'
            number        = 'int'
        }
    }
    process {
        # for each field in the object with a null value, prompt to enter the value
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
                Default {
                }
            }
            #TODO: validate other types
        }
    }
    end {
        # Return template config field
        return $templateObject
    }
}

