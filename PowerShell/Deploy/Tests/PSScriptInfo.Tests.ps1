. ((Get-Item -Path:($PSScriptRoot)).Parent.FullName + '/' + 'Get-Config.ps1')
###########################################################################
# # Describe "ScriptInfo Tests" {
# #     BeforeAll {
# #         # $DebugPreference = 'Continue'
# #         # $VerbosePreference = 'Continue'
# #         $ErrorActionPreference = 'Stop'
# #     }
# #     AfterAll {
# #         # $DebugPreference = 'SilentlyContinue'
# #         # $VerbosePreference = 'SilentlyContinue'
# #         $ErrorActionPreference = 'Continue'
# #     }
# #     Context 'ScriptInfo Tests' {
# #         It 'Passes Test-ScriptFileInfo' {
$ScriptFileInfoResults = Get-ChildItem -Path:($FolderPath_Public) -Recurse -File | ForEach-Object { Test-ScriptFileInfo -Path:($_.FullName) -ErrorAction:('Ignore') }
# #     $ScriptFileInfoResults | Should BeNullOrEmpty
# #     $? | Should Be $true
# # }
If ($ScriptFileInfoResults)
{
    $ScriptFileInfoResults
    Write-Error ('Go fix the ScriptFileInfo results!')
}
Else
{
    Write-Host ('[success]ScriptFileInfo returned no results')
}
# #     }
# # }

# Test-ScriptFileInfo -Path:('')

# New-ScriptFileInfo -Path:('') `
#     -Description:('') `
#     -Version:('') `
#     -Guid:('') `
#     -Author:('') `
#     -CompanyName:('') `
#     -Copyright:('') `
#     -RequiredModules:('') `
#     -ExternalModuleDependencies:('') `
#     -RequiredScripts:('') `
#     -ExternalScriptDependencies:('') `
#     -Tags:('') `
#     -ProjectUri:('') `
#     -LicenseUri:('') `
#     -IconUri:('') `
#     -ReleaseNotes:('') `
#     -PrivateData:('')

# Update-ScriptFileInfo  -Path:('') `
#     -Description:('') `
#     -Version:('') `
#     -Guid:('') `
#     -Author:('') `
#     -CompanyName:('') `
#     -Copyright:('') `
#     -RequiredModules:('') `
#     -ExternalModuleDependencies:('') `
#     -RequiredScripts:('') `
#     -ExternalScriptDependencies:('') `
#     -Tags:('') `
#     -ProjectUri:('') `
#     -LicenseUri:('') `
#     -IconUri:('') `
#     -ReleaseNotes:('') `
#     -PrivateData:('')
