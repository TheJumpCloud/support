Describe -Tag:('JCDeviceFromCSV') 'New-JCDeviceUpdateTemplate' {
    BeforeAll {  }
    It "Forcefully creates a CSV Import Template" {
        New-JCDeviceUpdateTemplate -Force
        $items = Get-ChildItem -Path $PWD | Where-Object { $_.FullName -Match "JCDeviceUpdateImport*" }
        $items | Should -Exist
        $items | ForEach-Object { Remove-Item -Path $_.FullName }
    It "Creates a CSV Import Template with custom attributes" {
        New-JCDeviceUpdateTemplate -Force

        $items = Get-ChildItem -Path $PWD | Where-Object { $_.FullName -Match "JCDeviceUpdateImport*" }
        $items | Should -Exist

        $templateContent = Import-Csv -Path $items[0].FullName
        $templateContent | Get-Member -Name "NumberOfCustomAttributes" | Should -Not -BeNullOrEmpty

        $items | ForEach-Object { Remove-Item -Path $_.FullName }
    }
    }
}