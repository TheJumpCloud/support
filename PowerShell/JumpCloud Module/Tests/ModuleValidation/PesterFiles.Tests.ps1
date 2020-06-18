Describe -Tag:('ModuleValidation') 'Pester Files Tests' {
    Function Get-PesterFilesTestCases
    {
        $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent.FullName
        $FolderTests = "$ModuleRoot/Tests"
        $FolderPublic = "$ModuleRoot/Public"
        $PesterTestFilePath = Get-ChildItem -Path:("$FolderPublic/*.ps1") -Recurse -File | ForEach-Object {
            @{
                FilePath = ($_.FullName).Replace($ModuleRoot, $FolderTests).Replace($_.Extension, ".Tests$($_.Extension)")
            }
        }
        Return $PesterTestFilePath
    }
    Context 'Pester Test Files Validation' {
        It ('Validating Pester test file exists for "<FilePath>"') -TestCases:(Get-PesterFilesTestCases) {
            Test-Path -Path:($FilePath) | Should -Be $true
        }
        It ('Validating Pester test file has been populated for "<FilePath>"') -TestCases:(Get-PesterFilesTestCases) {
            $FilePath | Should -FileContentMatch '.*?'
        }
    }
}
