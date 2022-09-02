################################################################################
# Rules Skipped:
# 'PSUseDeclaredVarsMoreThanAssignments',
# 'PSAvoidUsingWriteHost',
# 'PSAvoidUsingInvokeExpression',
# 'PSUseLiteralInitializerForHashtable',
# 'PSUseProcessBlockForPipelineCommand',
# 'PSUseShouldProcessForStateChangingFunctions',
# 'PSAvoidGlobalVars',
# 'PSAvoidUsingUsernameAndPasswordParams',
# 'PSPossibleIncorrectComparisonWithNull',
# 'PSAvoidUsingConvertToSecureStringWithPlainText',
# 'PSAvoidUsingPlainTextForPassword',
# 'PSAvoidUsingEmptyCatchBlock',
# 'PSAvoidUsingCmdletAliases',
# 'PSShouldProcess'
################################################################################

Describe -Tag:('ModuleValidation') 'PSScriptAnalyzer Test Suite' {
    Context 'PSScriptAnalyzer Tests' {
        BeforeAll {
            ### SET UP ###
            $FolderPath_Module = (Get-Item -Path("$PSScriptRoot/../../")).FullName
            $SettingsFile = "$PSScriptRoot/PSScriptAnalyzerSettings.psd1"
            # Import Settings:
            $SettingsFromFile = Import-PowerShellDataFile $SettingsFile
            $settingsObject = @{
                Severity     = $SettingsFromFile.Severity
                ExcludeRules = $SettingsFromFile.ExcludeRules
                IncludeRules = $SettingsFromFile.IncludeRules
                Rules        = $SettingsFromFile.Rules
            }
            ##############
            Write-Host ('[status]Running PSScriptAnalyzer on: ' + $FolderPath_Module)
            Write-Host ('[status]PSScriptAnalyzer Settings File: ' + $SettingsFile)
            $event_get = ".ps1"
            # $ScriptAnalyzerResults = Invoke-ScriptAnalyzer -Path:("$FolderPath_Module") -Recurse -Exclude $event_get -Settings $settingsObject -ReportSummary
            $excludeFolder = "PowerShell/JumpCloud Module/Public/DirectoryInsights/Get-JCEvent.ps1"
            $ScriptAnalyzerResults = Get-ChildItem -Path:("$FolderPath_Module") -Recurse |
            ? { $_.PsIsContainer -and $_.FullName -notmatch 'DirectoryInsights' } | Out-Null | Invoke-ScriptAnalyzer -Settings $settingsObject -ReportSummary
            If (-not [System.String]::IsNullOrEmpty($ScriptAnalyzerResults)) {
                $tester  | ForEach-Object {
                    Write-Error ('[PSScriptAnalyzer][' + $_.Severity + '][' + $_.RuleName + '] ' + $_.Message + ' found in "' + $_.ScriptPath + '" at line ' + $_.Line + ':' + $_.Column)
                }
            } Else {
                Write-Host ('[success]ScriptAnalyzer returned no results')
            }
        }
        It 'PSScriptAnalyzer Results should be null' {
            $ScriptAnalyzerResults | Should -BeNullOrEmpty
        }
        It 'PSScriptAnalyzer SettingsFile should exist' {
            test-path $SettingsFile | Should -Be $true
        }
        It 'PSScriptAnalyzer SettingsObject Should Not Be Null or Empty' {
            $SettingsFromFile | Should -Not -BeNullOrEmpty
            $settingsObject | Should -Not -BeNullOrEmpty
        }

    }
}