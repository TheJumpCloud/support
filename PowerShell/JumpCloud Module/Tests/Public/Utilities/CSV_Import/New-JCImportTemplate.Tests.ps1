Describe -Tag:('JCUsersFromCSV') 'New-JCImportTemplate' {
    BeforeAll {  }
    It "Forcefully creates a CSV Import Template" {
        New-JCImportTemplate -Force -Type "Import"
        $items = Get-ChildItem -Path $PWD | Where-Object { $_.FullName -Match "JCUserUpdateImport*" }
        $items | Should -Exist
        $items | ForEach-Object { Remove-Item -Path $_.FullName }
    }
    It "Forcefully creates a CSV Update Template" {
        New-JCImportTemplate -Force -Type "Update"
        $items = Get-ChildItem -Path $PWD | Where-Object { $_.FullName -Match "JCUserUpdateImport*" }
        $items | Should -Exist
        $items | ForEach-Object { Remove-Item -Path $_.FullName }
    }
}
