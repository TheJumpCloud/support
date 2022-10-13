[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $GitSourceBranch,
    [Parameter()]
    [String]
    $GitSourceRepo,
    [Parameter()]
    [String]
    $ReleaseType,
    [Parameter()]
    [String]
    $ModuleName,
    [Parameter()]
    [string]
    $RequiredModulesRepo,
    [Parameter()]
    [Boolean]
    $ManualModuleVersion
)
. "$PSScriptRoot/Get-Config.ps1" -GitSourceBranch:($GitSourceBranch) -GitSourceRepo:($GitSourceRepo) -ReleaseType:($ReleaseType) -RequiredModulesRepo:($RequiredModulesRepo)
# Region Checking PowerShell Gallery module version
Write-Host ('[status]Check PowerShell Gallery for module version info')
$PSGalleryInfo = Get-PSGalleryModuleVersion -Name:($ModuleName) -ReleaseType:($RELEASETYPE) #('Major', 'Minor', 'Patch')
# Check to see if ManualModuleVersion parameter is set to true
if ($ManualModuleVersion) {
    $ManualModuleVersionRetrieval = Get-Content -Path:($FilePath_psd1) | Where-Object { $_ -like '*ModuleVersion*' }
    $SemanticRegex = [Regex]"[0-9]+.[0-9]+.[0-9]+"
    $SemeanticVersion = Select-String -InputObject $ManualModuleVersionRetrieval -pattern ($SemanticRegex)
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
# Region Updating module banner
Write-Host ('[status]Updating module banner: "' + $FilePath_ModuleBanner + '"')
$ModuleBanner = Get-Content -Path:($FilePath_ModuleBanner)
$NewModuleBannerRecord = New-ModuleBanner -LatestVersion:($ModuleVersion) -BannerCurrent:('{{Fill in the Banner Current}}') -BannerOld:('{{Fill in the Banner Old}}')
If (!(($ModuleBanner | Select-Object -Index 3) -match $ModuleVersion)) {
    $NewModuleBannerRecord.Trim() | Set-Content -Path:($FilePath_ModuleBanner) -Force
}
# EndRegion Updating module banner
# Region Updating module change log
Write-Host ('[status]Updating module change log: "' + $FilePath_ModuleChangelog + '"')
$ModuleChangelog = Get-Content -Path:($FilePath_ModuleChangelog)
$NewModuleChangelogRecord = New-ModuleChangelog -LatestVersion:($ModuleVersion) -ReleaseNotes:('{{Fill in the Release Notes}}') -Features:('{{Fill in the Features}}') -Improvements:('{{Fill in the Improvements}}') -BugFixes('{{Fill in the Bug Fixes}}')
If (!(($ModuleChangelog | Select-Object -First 1) -match $ModuleVersion)) {
    ($NewModuleChangelogRecord + ($ModuleChangelog | Out-String)).Trim() | Set-Content -Path:($FilePath_ModuleChangelog) -Force
}
# EndRegion Updating module change log