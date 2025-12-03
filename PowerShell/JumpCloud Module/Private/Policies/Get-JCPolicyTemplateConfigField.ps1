function Get-JCPolicyTemplateConfigField {
    # TemplateID of the policy to be modified
    [CmdletBinding()]
    param (
        [Parameter(mandatory = $true)]
        [System.String]
        $templateID
    )
    begin {
        $headers = @{}
        $headers.Add("x-api-key", $env:JCApiKey)
        $headers.Add("x-org-id", $env:JCOrgId)
        $template = Invoke-RestMethod -Uri "$global:JCUrlBasePath/api/v2/policytemplates/$templateID" -Method GET -Headers $headers
        # define policy config field mapping
        $PolicyConfigMapping = @{
            checkbox       = 'boolean'
            singlelistbox  = 'listbox'
            table          = 'table'
            customRegTable = 'table'
            textarea       = 'string'
            text           = 'string'
            file           = 'file'
            select         = 'multi'
            number         = 'int'
            multiList      = 'multilist'
        }
    }
    process {
        # build object for templateID with validation of types
        $objectMap = New-Object System.Collections.ArrayList
        foreach ($field in $template.ConfigFields) {
            # Write-Host "$($field.Name) accepts $($PolicyConfigMapping[$field.DisplayType]) input"
            if ($Field.DisplayType -eq 'select') {
                $ValidationObject = @()
                $validationRows = $field.DisplayOptions.select.Count
                for ($i = 0; $i -lt $validationRows; $i++) {
                    # Get Both Values:
                    $val1 = $field.DisplayOptions.select[$i].text
                    $val2 = $field.DisplayOptions.select[$i].value

                    # Check if the val2 is a string or int
                    if (-not ([int]::TryParse($val2, [ref]$null))) {
                        $validationObject += @{$val2 = $val2 }
                        #Write-Error "$($val2) is a string in first position"
                    } else {
                        try {
                            [int]$val1 | Out-Null
                            # write-host "$($val1) is an int in first position"
                            $validationObject += @{$val1 = $val2 }
                        } catch {
                            [int]$val2 | Out-Null
                            # write-host "$($val2) is an int in second position"
                            $validationObject += @{$val2 = $val1 }
                        }
                    }
                }
            }

            $templateObject = [PSCustomObject]@{
                configFieldID   = $field.Id
                label           = $field.Label
                position        = $field.Position
                configFieldName = $field.Name
                help            = $field.tooltip.variables.message
                type            = "$($PolicyConfigMapping[$field.DisplayType])"
                validation      = if ($Field.DisplayType -eq 'select') {
                    $ValidationObject
                } else {
                    $null
                }
                value           = $null
                defaultValue    = $field.defaultValue
            }
            $objectMap.Add($templateObject) | Out-Null
        }
        # Build object to return, including template displayname
        $templateObject = [PSCustomObject]@{
            defaultName = $template.displayName
            objectMap   = $objectMap
        }
    }
    end {
        # Return template config field
        return $templateObject
    }
}