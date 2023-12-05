[CmdletBinding()]
param (
    [String]
    $ReleaseType,
    [Parameter()]
    [Boolean]
    $ManualModuleVersion
)
. "$PSScriptRoot/Get-Config.ps1"
# Region Checking PowerShell Gallery module version
Write-Host ('[status]Check PowerShell Gallery for module version info')
$PSGalleryInfo = Get-PSGalleryModuleVersion -Name:("JumpCloud") -ReleaseType:($RELEASETYPE) #('Major', 'Minor', 'Patch')
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

## Get the module version from the psd1 file and changelog
$VersionPsd1Regex = [regex]"(?<=ModuleVersion\s*=\s*')(([0-9]+)\.([0-9]+)\.([0-9]+))"
$VersionMatchPsd1 = Select-String -Path:($FilePath_psd1) -Pattern:($VersionPsd1Regex)
$PSD1Version = $VersionMatchPsd1.Matches.Value


$FilePath_ModuleChangelog = Join-Path -Path $PSScriptRoot -ChildPath '..\ModuleChangelog.md'
$ModuleChangelog = Get-Content -Path:($FilePath_ModuleChangelog)
$ModuleChangelogVersionRegex = "([0-9]+)\.([0-9]+)\.([0-9]+)"
$ModuleChangelogVersionMatch = ($ModuleChangelog | Select-Object -First 1) | Select-String -Pattern:($ModuleChangelogVersionRegex)
$ModuleChangelogVersion = $ModuleChangelogVersionMatch.Matches.Value

# Update ModuleChangelog.md File:
If ($ModuleChangelogVersion -ne $PSD1Version) {
    # add a new version section to the module ModuleChangelog.md
    Write-Host "[Status]: Appending new changelog for version: $PSD1Version"
    $NewModuleChangelogRecord = New-ModuleChangelog -LatestVersion:($PSD1Version) -ReleaseNotes:('{{Fill in the Release Notes}}') -Features:('{{Fill in the Features}}') -Improvements:('{{Fill in the Improvements}}') -BugFixes('{{Fill in the Bug Fixes}}')

    ($NewModuleChangelogRecord + ($ModuleChangelog | Out-String)).Trim() | Set-Content -Path:($FilePath_ModuleChangelog) -Force
} else {
    # Get content between latest version and last
    $ModuleChangelogContent = Get-Content -Path:($FilePath_ModuleChangelog) | Select -First 3
    $ReleaseDateRegex = [regex]'(?<=Release Date:\s)(.*)'
    $ReleaseDateRegexMatch = $ModuleChangelogContent | Select-String -Pattern $ReleaseDateRegex
    $ReleaseDate = $ReleaseDateRegexMatch.Matches.Value
    $todaysDate = $(Get-Date -UFormat:('%B %d, %Y'))
    if (($ReleaseDate) -and ($ReleaseDate -ne $todaysDate)) {
        write-host "[Status] Updating Changelog date: $ReleaseDate to: $todaysDate)"
        $ModuleChangelog.Replace($ReleaseDate, $todaysDate) | Set-Content $FilePath_ModuleChangelog
    }
}
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
If (!(($ModuleChangelog | Select-Object -First 1) -match $ModuleVersion)) {
    ($NewModuleChangelogRecord + ($ModuleChangelog | Out-String)).Trim() | Set-Content -Path:($FilePath_ModuleChangelog) -Force
}
# EndRegion Updating module change log

Write-Host "Building help files" -ForegroundColor Green
."$PSScriptRoot/Build-HelpFiles.ps1" -ModuleName "JumpCloud" -ModulePath "./PowerShell/JumpCloud Module"

Write-Host "Building Pester test files" -ForegroundColor Green
."$PSScriptRoot/Build-PesterTestFiles.ps1"

Write-Host "Building module" -ForegroundColor Green
."$PSScriptRoot/SdkSync/jcapiToSupportSync.ps1"
