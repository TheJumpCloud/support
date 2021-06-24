Describe -Tag:('ModuleValidation') 'Function Format Tests' {
    Function Get-FunctionReportTestCases
    {
        $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent.FullName
        $FunctionList = Get-FunctionReport -Folder:(("$ModuleRoot/Public"), ("$ModuleRoot/Private")) | Where-Object { $_.FileName -notlike 'ScriptBlock_*' }
        $FunctionListTestCases = $FunctionList | ForEach-Object {
            @{
                Content        = $_.Content
                FileBaseName   = $_.FileBaseName
                Function       = $_.Function
                MatchValue     = $_.MatchValue
                FileName       = $_.FileName
                FolderLocation = $_.FolderLocation
            }
        }
        Return $FunctionListTestCases;
    }
    Context ('Test that the file name matches the function name') {
        It ('When FileBaseName "<FileBaseName>" equal Function "<Function>" for file "<FileName>"') -TestCases:(Get-FunctionReportTestCases) {
            $Function | Should -BeExactly $FileBaseName
        }
        It ('When FileBaseName "<FileBaseName>" equal MatchValue "<MatchValue>" for file "<FileName>"') -TestCases:(Get-FunctionReportTestCases) {
            $MatchValue | Should -BeExactly $FileBaseName
        }
    }
    Context ('Test for missing information') {
        It ('When FileName "<FileName>" does not contain any functions') -TestCases:(Get-FunctionReportTestCases) {
            $Function | Should -Not -BeNullOrEmpty
        }
    }
    Context ('Test for multiple functions per file') {
        It ('When FileName "<FileName>" has exactly 1 function') -TestCases:(Get-FunctionReportTestCases) {
            ($Function | Measure-Object).Count | Should -BeExactly 1
            ($MatchValue | Measure-Object).Count | Should -BeExactly 1
        }
    }
    Context ('Test that Connect-JCOnline exists in each Public function') {
        It ('When FileName "<FileName>" does not contain "Connect-JCOnline"') -TestCases:(Get-FunctionReportTestCases) {
            If ($FolderLocation -eq 'Public' -and $FileName -notin ('New-JCDeploymentTemplate.ps1', 'Update-JCModule.ps1'))
            {
                ($Content | Select-String -Pattern:('(?i)(Connect-JCOnline)')) | Should -Not -BeNullOrEmpty
            }
        }
    }
    Context ('Test for duplicate functions') {
        It ('When multiple files with the same name exist for "<Name>"') -TestCases:(Get-FunctionReportTestCases) {
            ($FileBaseName | Group-Object).Count | Should -Be 1
        }
        It ('When multiple functions with the same name exist for "<Name>"') -TestCases:(Get-FunctionReportTestCases) {
            ($Function | Group-Object).Count | Should -Be 1
        }
        It ('When multiple MatchValues of functions with the same name exist for "<Name>"')  -TestCases:(Get-FunctionReportTestCases) {
            ($MatchValue | Group-Object).Count | Should -Be 1
        }
    }
}


# $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent.FullName
# $FunctionList = Get-FunctionReport -Folder:(("$ModuleRoot/Public"), ("$ModuleRoot/Private")) | Where-Object { $_.FileName -notlike 'ScriptBlock_*' }
# $FunctionListTestCases = $FunctionList | ForEach-Object {
#     @{
#         Content        = $_.Content
#         FileBaseName   = $_.FileBaseName
#         Function       = $_.Function
#         MatchValue     = $_.MatchValue
#         FileName       = $_.FileName
#         FolderLocation = $_.FolderLocation
#     }
# }
# $FunctionListTestCases | Select-Object FileName, function