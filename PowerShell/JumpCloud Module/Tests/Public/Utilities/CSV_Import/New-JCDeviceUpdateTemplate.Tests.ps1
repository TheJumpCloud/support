Describe -Tag:('JCDeviceFromCSV') 'New-JCDeviceUpdateTemplate' {
    BeforeAll {  }
    It "Forcefully creates a CSV Import Template" {
        New-JCDeviceUpdateTemplate -Force
        $items = Get-ChildItem -Path $PWD | Where-Object { $_.FullName -Match "JCDeviceUpdateImport*" }
        $items | Should -Exist
        $items | ForEach-Object { Remove-Item -Path $_.FullName }
    }
}