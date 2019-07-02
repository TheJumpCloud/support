Describe -Tag:('ModuleValidation') 'Pester Files Tests' {
    $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent.FullName
    $FolderTests = ($ModuleRoot + '/Tests')
    $FolderPublic = ($ModuleRoot + '/Public')
    Context 'Pester Test Files Validation' {
        Get-ChildItem -Path:($FolderPublic + '/*.ps1') -Recurse -File | ForEach-Object {
            $PesterTestFilePath = ($_.FullName).Replace($ModuleRoot, $FolderTests).Replace($_.Extension, '.Tests' + $_.Extension)
            It ('Validating Pester test file exists for "' + $PesterTestFilePath + '"') {
                Test-Path -Path:($PesterTestFilePath) | Should -Be $true
            }
            It ('Validating Pester test file has been populated for "' + $PesterTestFilePath + '"') {
                $PesterTestFilePath | Should -FileContentMatch '.*?'
            }
        }
    }
}