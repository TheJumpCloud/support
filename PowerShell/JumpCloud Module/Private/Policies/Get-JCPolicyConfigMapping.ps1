function Enumerate-JCPolicyConfigMapping {

    begin {
        $templates = Get-JcSdkPolicyTemplate
    }

    process {
        $configMapping = @{}
        foreach ($t in $templates) {
            $template = Get-JcSdkPolicyTemplate -id $t.id
            foreach ($fields in $template.ConfigFields) {
                if ($fields.DisplayType -notin $configMapping.Keys) {
                    write-host "new field: $($fields.DisplayType) on $($t.id)"
                    $configMapping.Add($fields.DisplayType, "")
                }
            }
        }

    }

    end {
        return $configMapping
    }
}