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
        # build object for templateID with validation of types
        $objectMap = New-Object System.Collections.ArrayList
        foreach ($field in $template.ConfigFields) {
            # Write-Host "$($field.Name) accepts $($configMapping[$field.DisplayType]) input"

            $templateObject = [PSCustomObject]@{
                configFieldID   = $field.Id
                label           = $field.Label
                position        = $field.Position
                configFieldName = $field.Name
                type            = "$($configMapping[$field.DisplayType])"
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

