Describe -Tag:('JCDeviceFromCSV') 'New-JCDeviceUpdateTemplate' {
    BeforeAll {  }
    It "Forcefully creates a CSV Import Template" {
        New-JCDeviceUpdateTemplate -Force
        $items = Get-ChildItem -Path $PWD | Where-Object { $_.FullName -Match "JCDeviceUpdateImport*" }
        $items | Should -Exist
        $items | ForEach-Object { Remove-Item -Path $_.FullName }
    It "Creates a CSV Import Template with custom attributes" {
        New-JCDeviceUpdateTemplate -NumberOfCustomAttributes 1 -Attribute1_name "TemplateAttrKey" -Attribute1_value "TemplateAttrValue" -Force

        $items = Get-ChildItem -Path $PWD | Where-Object { $_.FullName -Match "JCDeviceUpdateImport*" }
        $items | Should -Exist

        $items | ForEach-Object { Remove-Item -Path $_.FullName }
    }
    }
}