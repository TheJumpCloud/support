[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $ReleaseType,
    [Parameter()]
    [String]
    $ModuleName = "JumpCloud",
    [Parameter()]
    [string]
    $RequiredModulesRepo,
    [Parameter()]
    [Boolean]
    $ManualModuleVersion
)
# Region: Load Configuration
# Manually define variables to ensure they are passed correctly to the child script on all platforms
$ModuleFolderName = "JumpCloud Module"
$DeployFolder = "/PowerShell/Deploy"

# Resolve the path to Get-Config.ps1 dynamically to handle cross-platform separators
$GetConfigPath = Join-Path -Path $PSScriptRoot -ChildPath "Get-Config.ps1"

# Dot-source the config script with explicit parameters to initialize global variables
. $GetConfigPath -ModuleName $ModuleName -ModuleFolderName $ModuleFolderName -DeployFolder $DeployFolder
# EndRegion: Load Configuration
# Region Checking PowerShell Gallery module version
Write-Host ('[status]Check PowerShell Gallery for module version info')
$PSGalleryInfo = Get-PSGalleryModuleVersion -Name:($ModuleName) -ReleaseType:($RELEASETYPE) #('Major', 'Minor', 'Patch')
# Check to see if ManualModuleVersion parameter is set to true
if ($ManualModuleVersion) {
    $ManualModuleVersionRetrieval = Get-Content -Path:($FilePath_psd1) | Where-Object { $_ -like '*ModuleVersion*' }
    $SemanticRegex = [Regex]"[0-9]+.[0-9]+.[0-9]+"
    $SemeanticVersion = Select-String -InputObject $ManualModuleVersionRetrieval -Pattern ($SemanticRegex)
    $ModuleVersion = $SemeanticVersion[0].Matches.Value
} else {
    $ModuleVersion = $PSGalleryInfo.NextVersion
}
Write-Host ('[status]PowerShell Gallery Name:' + $PSGalleryInfo.Name + ';CurrentVersion:' + $PSGalleryInfo.Version + '; NextVersion:' + $ModuleVersion )
# EndRegion Checking PowerShell Gallery module version
# Region Building New-JCModuleManifest
Write-Host ('[status]Building New-JCModuleManifest')
New-JCModuleManifest -Path:($FilePath_psd1) `
    -FunctionsToExport:($Functions_Public.BaseName | Sort-Object) `
    -RootModule:((Get-Item -Path:($FilePath_psm1)).Name) `
    -ModuleVersion:($ModuleVersion)
# EndRegion Building New-JCModuleManifest
# Region Updating module change log
Write-Host ('[status]Updating module change log: "' + $FilePath_ModuleChangelog + '"')
$ModuleChangelog = Get-Content -Path:($FilePath_ModuleChangelog)
$NewModuleChangelogRecord = New-ModuleChangelog -LatestVersion:($ModuleVersion) -ReleaseNotes:('{{Fill in the Release Notes}}') -Features:('{{Fill in the Features}}') -Improvements:('{{Fill in the Improvements}}') -BugFixes('{{Fill in the Bug Fixes}}')
if (!(($ModuleChangelog | Select-Object -First 1) -match $ModuleVersion)) {
    ($NewModuleChangelogRecord + ($ModuleChangelog | Out-String)).Trim() | Set-Content -Path:($FilePath_ModuleChangelog) -Force
}
# EndRegion Updating module change log

# ====================================================================
# Region: Orchestrating Required Build Functions (Joe's Feedback)
# ====================================================================

# Security guarantee: if the parameter is empty, the default is set.
if (-not $ModuleName) {
    $ModuleName = "JumpCloud"
}

Write-Host ('[status] Running synchronized SDK endpoints sync...')
$SdkSyncPath = Join-Path -Path $PSScriptRoot -ChildPath "SdkSync"
$SdkScriptPath = Join-Path -Path $SdkSyncPath -ChildPath "jcapiToSupportSync.ps1"
if (Test-Path $SdkScriptPath) {
    & $SdkScriptPath
} else {
    Write-Warning "SdkSync script not found at $SdkScriptPath"
}

Write-Host ('[status] Generating Module Help Files...')
$BuildHelpPath = Join-Path -Path $PSScriptRoot -ChildPath "Build-HelpFiles.ps1"
if (Test-Path $BuildHelpPath) {
    $ModuleFolder = Split-Path -Parent $FilePath_psd1

    $PreviousLocation = Get-Location

    Set-Location -Path (Join-Path -Path $ModuleFolder -ChildPath "Docs")

    & $BuildHelpPath -ModuleName $ModuleName -ModulePath $ModuleFolder

    Set-Location -Path $PreviousLocation
} else {
    Write-Warning "Build-HelpFiles script not found at $BuildHelpPath"
}

Write-Host ('[status] Autogenerating Pester Test Files...')
$BuildTestsPath = Join-Path -Path $PSScriptRoot -ChildPath "Build-PesterTestFiles.ps1"
if (Test-Path $BuildTestsPath) {
    # Called without any parameters, as it discovers the paths on its own.
    & $BuildTestsPath
}
 else {
    Write-Warning "Build-PesterTestFiles script not found at $BuildTestsPath"
}

