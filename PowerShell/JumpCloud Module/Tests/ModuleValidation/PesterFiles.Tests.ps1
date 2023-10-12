Describe -Tag:('ModuleValidation') 'Pester Files Tests' {
    Function Get-PesterFilesTestCases {
        $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent
        $FolderTests = "$FolderPath_Tests"
        $FolderPublic = "$FolderPath_Public"
        $PesterTestFilePath = Get-ChildItem -Path:("$FolderPublic/*.ps1") -Recurse -File | ForEach-Object {
            @{
                FilePath = ($_.FullName).Replace($ModuleRoot, $FolderTests).Replace($_.Extension, ".Tests$($_.Extension)")
            }
        }
        Return $PesterTestFilePath
    }
    Context 'Pester Test Files Validation' {
        It ('Validates that test files found in the test path have the correct "Test" casing') {
            # validate case sensitive filename for ubuntu-latest ci workflow:
            $tests = Get-ChildItem -Path $FolderPath_Tests -Filter "*Tests*" -Recurse
            foreach ($testFile in $tests.FullName) {
                if ($testFile -cmatch "tests") {
                    Write-Warning "The $testFile file contains a pester 'tests' declartion with a lowercase 'tests' filetype, this should be 'Tests' "
                    $testFile | Should -Not -MatchExactly "tests"
                }
            }
        }
        It ('Validating Pester test file exists for "<FilePath>"') -TestCases:(Get-PesterFilesTestCases) {
            Test-Path -Path:($FilePath) | Should -Be $true
        }
        It ('Validating Pester test file has been populated for "<FilePath>"') -TestCases:(Get-PesterFilesTestCases) {
            # $FilePath | Should -FileContentMatch '.*?'
            $FileContent = Get-Content -Path:($FilePath) -Raw
            If ([System.String]::IsNullOrEmpty($FileContent)) {
                Write-Host("[task.logissue type=warning;]" + 'The test file "' + $FilePath + '" has not been populated.')
                Write-Warning ('The test file "' + $FilePath + '" has not been populated.')
            }
        }
    }
}
