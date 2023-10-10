Describe -Tag:('MSP') 'New-JCMSPImportTemplate' {
    It "Forcefully creates a CSV Import Template" {
        New-JCMSPImportTemplate -Force -Type "Import"
        $items = Get-ChildItem -Path $PWD | Where-Object { $_.FullName -Match "JCMSPImport*" }
        $items | Should -Exist
        $items | ForEach-Object { Remove-Item -Path $_.FullName }
    }
    It "Forcefully creates a CSV Update Template" {
        New-JCMSPImportTemplate -Force -Type "Update"
        $items = Get-ChildItem -Path $PWD | Where-Object { $_.FullName -Match "JCMSPUpdateImport*" }
        $items | Should -Exist
        $items | ForEach-Object { Remove-Item -Path $_.FullName }
    }
}
