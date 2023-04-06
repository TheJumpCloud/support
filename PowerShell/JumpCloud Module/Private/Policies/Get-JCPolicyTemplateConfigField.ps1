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
        # $template = Get-JcSdkPolicyTemplate -Id $templateID
        $headers = @{}
        $headers.Add("x-api-key", $env:JCApiKey)
        $headers.Add("x-org-id", $env:JCOrgId)
        $template = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/v2/policytemplates/$templateID" -Method GET -Headers $headers
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
                $validationRows = $field.DisplayOptions.select.Count
                for ($i = 0; $i -lt $validationRows; $i++) {
                    # Get Both Values:
                    $val1 = $field.DisplayOptions.select[$i].text
                    $val2 = $field.DisplayOptions.select[$i].value
                    # Determine which one is an int
                    # TODO: Joe to review here is this necessary for non-sdk calls?
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

            $templateObject = [PSCustomObject]@{
                configFieldID   = $field.Id
                label           = $field.Label
                position        = $field.Position
                configFieldName = $field.Name
                help            = $field.tooltip.variables.message
                type            = "$($configMapping[$field.DisplayType])"
                validation      = if ($Field.DisplayType -eq 'select') {
                    $ValidationObject
                } else {
                    $null
                }
                value           = $null
                defaultValue    = $field.defaultValue
            }
            $objectMap.Add($templateObject) | out-null
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

