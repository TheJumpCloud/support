function Get-JCPolicyTemplateConfigField {
    # TemplateID of the policy to be modified
    [CmdletBinding()]
    param (
        [Parameter(mandatory = $true)]
        [System.String]
        $templateID
    )
    begin {
        # TODO: validate templateID
        $template = Get-JcSdkPolicyTemplate -Id $templateID
        # TODO: set this globally
        $configMapping = @{
            checkbox       = 'boolean'
            singlelistbox  = 'listbox'
            table          = 'table'
            customRegTable = 'table'
            textarea       = 'string'
            text           = 'string'
            file           = 'file'
            select         = 'multi'
            number         = 'int'
        }
    }
    process {
        # build object for templateID with validation of types
        $objectMap = New-Object System.Collections.ArrayList
        foreach ($field in $template.ConfigFields) {
            # Write-Host "$($field.Name) accepts $($configMapping[$field.DisplayType]) input"
            # if ($field.DisplayOptions.Values.values)
            if ($Field.DisplayType -eq 'select') {
                $ValidationObject = @()
                $validationRows = $field.DisplayOptions.Values.Values.Count / 2
                for ($i = 0; $i -lt $validationRows; $i++) {
                    # Get Both Values:
                    $val1 = $field.DisplayOptions.Values.values[$i + $i]
                    $val2 = $field.DisplayOptions.Values.values[$i + $i + 1]
                    # Determine which one is an int
                    try {
                        [int]$val1 | Out-Null
                        # "$($val1) is an int in first position"
                        $validationObject += @{$field.DisplayOptions.Values.values[$i + $i] = $field.DisplayOptions.Values.values[$i + $i + 1] }
                    } catch {
                        [int]$val2 | Out-Null
                        # "$($val2) is an int in second position"
                        $validationObject += @{$field.DisplayOptions.Values.values[$i + $i + 1] = $field.DisplayOptions.Values.values[$i + $i] }
                    }
                }
            }

            $templateObject = [PSCustomObject]@{
                configFieldID   = $field.Id
                label           = $field.Label
                position        = $field.Position
                configFieldName = $field.Name
                type            = "$($configMapping[$field.DisplayType])"
                validation      = if ($Field.DisplayType -eq 'select') {
                    $ValidationObject
                } else {
                    $null
                }
                value           = $null
            }
            $objectMap.Add($templateObject) | out-null
        }

    }
    end {
        # Return template config field
        return $objectMap
    }
}

