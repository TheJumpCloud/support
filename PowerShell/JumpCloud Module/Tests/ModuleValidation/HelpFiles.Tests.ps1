Describe -Tag:('ModuleValidation') 'Help File Tests' {
    function Get-HelpFilesTestCases {
        $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent
        $ModuleRootFullName = $ModuleRoot.FullName
        $Regex_FillInThe = '(\{\{)(.*?)(\}\})'
        $Regex_FillInThePester = [regex]('{{.*?}}')
        $HelpFilePopulation = Get-ChildItem -Path:($ModuleRootFullName + '/Docs/*.md') -Recurse | Select-String -Pattern:($Regex_FillInThe)
        $ModuleFilesPopulation = Get-ChildItem -Path:($ModuleRoot.Parent.FullName + '/*.md') | Select-String -Pattern:($Regex_FillInThe)
        $HelpFilesTestCases = ($HelpFilePopulation + $ModuleFilesPopulation) | ForEach-Object {
            @{
                Path                  = $_.Path
                LineNumber            = $_.LineNumber
                Line                  = $_.Line
                Regex_FillInThePester = $Regex_FillInThePester
            }
        }
        return $HelpFilesTestCases
    }
    Context ('Validating help file fields have been populated') {
        It ('The file "<Path>" needs to be populated on line number "<LineNumber>" where "<Line>" exists.') -TestCases:(Get-HelpFilesTestCases) {
            if ($Path) {
                $Path | Should -Not -FileContentMatch ($Regex_FillInThePester)
            }
        }
    }

    Context ('Validating that HelpFiles are up to date') {
        It 'Check to see if there is a git diff for HelpFiles' {
            $BuildHelpFilesLocation = "$PSScriptRoot/../../../Deploy/Build-HelpFiles.ps1"
            $ModulePathLocation = "$PSScriptRoot/../../../JumpCloud Module"
            # run the Build-HelpFiles function to generate new docs:
            Start-Job -Name BuildHelpFiles -ScriptBlock { . $using:BuildHelpFilesLocation -ModuleName "JumpCloud" -ModulePath $using:ModulePathLocation }
            Wait-Job -Name BuildHelpFiles
            # validate that there's no changes to git diff

            $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent
            $ModuleRootFullName = $ModuleRoot.FullName
            $excludeFunctions = @(
                'Set-JCSettingsFile.md'
                'Connect-JCOnline.md'
            )
            $HelpFilePopulation = Get-ChildItem -Path:($ModuleRootFullName + '/Docs/*.md') -Recurse -Exclude $excludeFunctions

            $HelpFilePopulation | ForEach-Object {
                # File should exist
                Test-Path -Path $_.FullName | Should -Be $true

                # Git Diff for the file should not exist
                $diff = git diff --ignore-cr-at-eol -- $_.FullName
                if ($diff) {
                    Write-Warning "Diff found in the file $($_.FullName) when we expected none to exist; Please run Build-HelpFiles and commit the results"
                }
                $diff | Should -BeNullOrEmpty
            }
        }
    }
}