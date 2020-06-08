Describe -Tag:('ModuleValidation') 'Function Format Tests' {
    $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent.FullName
    $FunctionList = Get-FunctionReport -Folder:(($ModuleRoot + '/Public'), ($ModuleRoot + '/Private')) | Where-Object { $_.FileName -notlike 'ScriptBlock_*' }
    $FunctionList | ForEach-Object {
        Context ('Test that the file name matches the function name') {
            It ('When FileBaseName "' + $_.FileBaseName + '" equal Function "' + $_.Function + '" for file "' + $_.FileName + '"') {
                $_.Function | Should -BeExactly $_.FileBaseName
            }
            It ('When FileBaseName "' + $_.FileBaseName + '" equal MatchValue "' + $_.MatchValue + '" for file "' + $_.FileName + '"') {
                $_.MatchValue | Should -BeExactly $_.FileBaseName
            }
        }
        Context ('Test for missing information') {
            It ('When FileName "' + $_.FileName + '" does not contain any functions') {
                $_.Function | Should -Not -BeNullOrEmpty
            }
        }
        Context ('Test for multiple functions per file') {
            It ('When FileName "' + $_.FileName + '" has exactly 1 function') {
                ($_.Function | Measure-Object).Count | Should -BeExactly 1
                ($_.MatchValue | Measure-Object).Count | Should -BeExactly 1
            }
        }
        If ($_.FolderLocation -eq 'Public' -and $_.FileName -notin ('New-JCDeploymentTemplate.ps1', 'Update-JCModule.ps1'))
        {
            Context ('Test that Connect-JCOnline exists in each Public function') {
                It ('When FileName "' + $_.FileName + '" does not contain "Connect-JCOnline"') {
                    $_ | Where-Object { !( $_.Content | Select-String -Pattern:('(?i)(Connect-JCOnline)')) } | Should -BeNullOrEmpty
                }
            }
        }
    }
    Context ('Test for duplicate functions') {
        ($FunctionList.FileBaseName | Group-Object) | ForEach-Object {
            It ('When multiple files with the same name exist for "' + $_.Name + '"') {
                $_.Count | Should -Be 1
            }
        }
        ($FunctionList.Function | Group-Object) | ForEach-Object {
            It ('When multiple functions with the same name exist for "' + $_.Name + '"') {
                $_.Count | Should -Be 1
            }
        }
        ($FunctionList.MatchValue | Group-Object) | ForEach-Object {
            It ('When multiple MatchValues of functions with the same name exist for "' + $_.Name + '"') {
                $_.Count | Should -Be 1
            }
        }
    }
}
