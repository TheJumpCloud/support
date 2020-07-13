#Requires -PSEdition Core
$GitHubRoot = 'C:/Users/epanipinto/Documents/GitHub' #ex: C:/Users/epanipinto/Documents/GitHub
# $xapikeyPester = ''
# $xapikeyMTP = ''
$env:moduleRootFolder = "$GitHubRoot/support/PowerShell"
$env:deployFolder = "$env:moduleRootFolder/Deploy"
$env:MODULENAME = 'JumpCloud'
$env:MODULEFOLDERNAME = 'JumpCloud Module'
$env:RELEASETYPE = 'Minor'
# # $env:XAPIKEY_PESTER = $xapikeyPester
# # $env:XAPIKEY_MTP = $xapikeyMTP
# ####################################################################################
# ####################################################################################
# $AutoRest_Example = "$GitHubRoot/jcapi-powershell/SDKs/PowerShell/JumpCloud.SDK.DirectoryInsights/examples/Get-JcSdkEvent.md"
# $AutoRest_Function = "$GitHubRoot/jcapi-powershell/SDKs/PowerShell/JumpCloud.SDK.DirectoryInsights/exports/Get-JcSdkEvent.ps1"
# $AutoRest_HelpFile = "$GitHubRoot/jcapi-powershell/SDKs/PowerShell/JumpCloud.SDK.DirectoryInsights/docs/exports/Get-JcSdkEvent.md"
# $AutoRest_Tests = "$GitHubRoot/jcapi-powershell/SDKs/PowerShell/JumpCloud.SDK.DirectoryInsights/test/Get-JcSdkEvent.Tests.ps1"
# $Transformed_Function = "$GitHubRoot/jcapi-powershell/JumpCloud/JumpCloudV2/Get/Get-JCEvent.ps1"
# $JCModule_Function = "$GitHubRoot/support/PowerShell/JumpCloud Module/Public/DirectoryInsights/Get-JCEvent.ps1"
# $JCModule_HelpFile = "$GitHubRoot/support/PowerShell/JumpCloud Module/Docs/Get-JCEvent.md"
# $JCModule_Tests = "$GitHubRoot/support/PowerShell/JumpCloud Module/Tests/Public/DirectoryInsights/Get-JCEvent.Tests.ps1"
# # Invoke-Item -Path:($JCModule_Function)
# ####################################################################################
# ####################################################################################
# .("$GitHubRoot/jcapi-powershell/SetupDependencies.ps1")
# .("$GitHubRoot/jcapi-powershell/BuildAutoRest.ps1")
# ####################################################################################
# # Restart your PowerShell session
# ####################################################################################
# .("$GitHubRoot/jcapi-powershell/JumpCloud/Install-Module.ps1")
# .("$GitHubRoot/jcapi-powershell/JumpCloud/Build-Module.ps1")
# Copy-Item -Path:($Transformed_Function) -Destination:($JCModule_Function) -Force
# Copy-Item -Path:($AutoRest_Tests) -Destination:($JCModule_Tests) -Force
# (Get-Content -Path:($JCModule_Tests) -Raw).Replace('JcSdk', 'JC').Replace('.ToJsonString() | ConvertFrom-Json', '').Replace("Describe 'Get-JCEvent'", "Describe 'Get-JCEvent' -Tag:('JCEvent')").Replace('$loadEnvPath = Join-Path $PSScriptRoot ''loadEnv.ps1''
# if (-Not (Test-Path -Path $loadEnvPath))
# {
#     $loadEnvPath = Join-Path $PSScriptRoot ''..\loadEnv.ps1''
# }
# . ($loadEnvPath)
# $TestRecordingFile = Join-Path $PSScriptRoot ''Get-JCEvent.Recording.json''
# $currentPath = $PSScriptRoot
# while (-not $mockingPath)
# {
#     $mockingPath = Get-ChildItem -Path $currentPath -Recurse -Include ''HttpPipelineMocking.ps1'' -File
#     $currentPath = Split-Path -Path $currentPath -Parent
# }
# . ($mockingPath | Select-Object -First 1).FullName

# ', '') | Set-Content -Path:($JCModule_Tests)
# Remove-Item -Path:($JCModule_HelpFile)
# ####################################################################################
# # Restart your PowerShell session
# ####################################################################################
# # Pipeline Steps
# # .("$env:deployFolder/Build-Module.ps1")
# # .("$env:deployFolder/Build-HelpFiles.ps1")
# # .("$env:deployFolder/Build-PesterTestFiles.ps1")
# # .("$env:moduleRootFolder/JumpCloud Module/Tests/InvokePester.ps1") -TestOrgAPIKey:($env:XAPIKEY_PESTER) -MultiTenantAPIKey:($env:XAPIKEY_MTP) -IncludeTagList:('ModuleValidation')
# # .("$env:moduleRootFolder/JumpCloud Module/Tests/InvokePester.ps1") -TestOrgAPIKey:($env:XAPIKEY_PESTER) -MultiTenantAPIKey:($env:XAPIKEY_MTP) -ExcludeTagList:('ModuleValidation', 'JCAssociation', 'JCUsersFromCSV') # -IncludeTagList:('')
# ####################################################################################
# ####################################################################################

. 'C:\Users\epanipinto\Documents\GitHub\support\PowerShell\Deploy\Setup-Dependencies.ps1'
$ApprovedFunctions = [Ordered]@{
    'JumpCloud.SDK.DirectoryInsights' = @('Get-JcSdkEvent')
}
$Modules = Get-Module -Name:($Psd1.RequiredModules)
ForEach ($Module In $Modules)
{
    $ModuleName = $Module.Name
    $ModulePath = $Module.ModuleBase
    ForEach ($FunctionName In $ApprovedFunctions.$ModuleName)
    {
        $Command = Get-Command -Name:($FunctionName)
        # Get content from sdk function
        $CommandFilePath = $Command.ScriptBlock.File
        $CommandFilePathContent = Get-Content -Path:($CommandFilePath) -Raw
        $FunctionContent = If ($CommandFilePath -like '*ProxyCmdletDefinitions.ps1')
        {
            <# When the autorest generated module has been installed and imported from the PSGallery all the
            cmdlets will exist in a single ProxyCmdletDefinitions.ps1 file. We need to parse
            out the specific function in order to gather the parts we need to copy over. #>
            $CommandFilePathContent.Replace($MSCopyrightHeader, $Divider).Split($Divider).Where( { $_ -like ('*' + "function $CommandName {" + '*') })
        }
        Else
        {
            <# When the autorest generated module has been imported from a local psd1 module the function will
            remain in their individual files. #>
            $CommandFilePathContent
        }
        $Params = $FunctionContent | Select-String -Pattern:('(?s)(    \[Parameter)(.*?)(\})') -AllMatches

    }
    # $ModulePath
    # Copy-Item -Path:($Transformed_Function) -Destination:($JCModule_Function) -Force
    # Copy-Item -Path:($AutoRest_Tests) -Destination:($JCModule_Tests) -Force
    # (Get-Content -Path:($JCModule_Tests) -Raw).Replace('JcSdk', 'JC').Replace('.ToJsonString() | ConvertFrom-Json', '').Replace("Describe 'Get-JCEvent'", "Describe 'Get-JCEvent' -Tag:('JCEvent')").Replace('$loadEnvPath = Join-Path $PSScriptRoot ''loadEnv.ps1''
    # if (-Not (Test-Path -Path $loadEnvPath))
    # {
    #     $loadEnvPath = Join-Path $PSScriptRoot ''..\loadEnv.ps1''
    # }
    # . ($loadEnvPath)
    # $TestRecordingFile = Join-Path $PSScriptRoot ''Get-JCEvent.Recording.json''
    # $currentPath = $PSScriptRoot
    # while (-not $mockingPath)
    # {
    #     $mockingPath = Get-ChildItem -Path $currentPath -Recurse -Include ''HttpPipelineMocking.ps1'' -File
    #     $currentPath = Split-Path -Path $currentPath -Parent
    # }
    # . ($mockingPath | Select-Object -First 1).FullName

    # ', '') | Set-Content -Path:($JCModule_Tests)
    # Remove-Item -Path:($JCModule_HelpFile)

}