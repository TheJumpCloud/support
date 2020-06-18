Describe -Tag:('ModuleValidation') 'Help File Tests' {
    Function Get-HelpFilesTestCases
    {
        $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent
        $ModuleRootFullName = $ModuleRoot.FullName
        $Regex_FillInThe = '(\{\{)(.*?)(\}\})'
        $Regex_FillInThePester = [regex]('{{.*?}}')
        $HelpFilePopulation = Get-ChildItem -Path:($ModuleRootFullName + '/Docs/*.md') -Recurse | Select-String -Pattern:($Regex_FillInThe) | ForEach-Object {
            @{
                Path                  = $_.Path
                LineNumber            = $_.LineNumber
                Line                  = $_.Line
                Regex_FillInThePester = $Regex_FillInThePester
            }
        }
        $ModuleFilesPopulation = Get-ChildItem -Path:($ModuleRoot.Parent.FullName + '/*.md') | Select-String -Pattern:($Regex_FillInThe) | ForEach-Object {
            @{
                Path                  = $_.Path
                LineNumber            = $_.LineNumber
                Line                  = $_.Line
                Regex_FillInThePester = $Regex_FillInThePester
            }
        }
        Return ($HelpFilePopulation + $ModuleFilesPopulation)
    }
    Context ('Validating help file fields have been populated') {
        It ('The file "<Path>" needs to be populated on line number "<LineNumber>" where "<Line>" exists.') -TestCases:(Get-HelpFilesTestCases) {
            $Path | Should -Not -FileContentMatch ($Regex_FillInThePester)
        }
    }
}