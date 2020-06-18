Describe -Tag:('ModuleValidation') 'Pester Files Tests' {
    BeforeEach {
        $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent.FullName
        $FolderTests = "$ModuleRoot/Tests"
        $FolderPublic = "$ModuleRoot/Public"
        $PesterTestFilePath = Get-ChildItem -Path:("$FolderPublic/*.ps1") -Recurse -File | ForEach-Object {
            @{
                FilePath = ($_.FullName).Replace($ModuleRoot, $FolderTests).Replace($_.Extension, ".Tests$($_.Extension)")
            }
        }
    }
    Context 'Pester Test Files Validation' {
        It ('Validating Pester test file exists for "<FilePath>"') -TestCases:($PesterTestFilePath) {
            Test-Path -Path:($FilePath) | Should -Be $true
        }
        It ('Validating Pester test file has been populated for "<FilePath>"') -TestCases:($PesterTestFilePath) {
            $FilePath | Should -FileContentMatch '.*?'
        }
    }
}
