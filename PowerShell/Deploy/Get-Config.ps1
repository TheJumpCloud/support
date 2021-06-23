# Define variables that come from Azure DevOps Pipeline
param (
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Name of module')][ValidateNotNullOrEmpty()][System.String]$ModuleName = 'JumpCloud',
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Module Folder Name')][ValidateNotNullOrEmpty()][System.String]$ModuleFolderName = 'JumpCloud Module',
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Deploy Folder Name')][ValidateNotNullOrEmpty()][System.String]$DeployFolder = "/Powershell/Deploy",
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Git Source Branch')][ValidateNotNullOrEmpty()][System.String]$GitSourceBranch,
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Git Source Repository')][ValidateNotNullOrEmpty()][System.String]$GitSourceRepo,
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Git Source Repository')][ValidateNotNullOrEmpty()][System.String]$GitSourceRepoWiki = "$($GitSourceRepo).wiki",
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Name of module')][System.String]$StagingDirectory = $env:BUILD_ARTIFACTSTAGINGDIRECTORY,
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Release Type')][ValidateNotNullOrEmpty()][System.String]$ReleaseType,
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Windows Pester JumpCloud API Key')][ValidateNotNullOrEmpty()][System.String]$XAPIKEY_PESTER = $env:XAPIKEY_PESTER,
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'MTP Pester JumpCloud API Key')][ValidateNotNullOrEmpty()][System.String]$XAPIKEY_MTP = $env:XAPIKEY_PESTER_MTP,
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Nuget API Key')][System.String]$NUGETAPIKEY = $env:NUGETAPIKEY,
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'System Access Token')][System.String]$SYSTEM_ACCESSTOKEN = $env:SYSTEM_ACCESSTOKEN,
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Required Modules Repository')][ValidateNotNullOrEmpty()][System.String]$RequiredModulesRepo = "PSGallery"
)
# Log Parameters
#Write-Host "ModuleName: $ModuleName"
#Write-Host "ModuleFolderName: $ModuleFolderName"
#Write-Host "DeployFolder: $DeployFolder"
#Write-Host "GitSourceBranch: $GitSourceBranch"
#Write-Host "GitSourceRepo : $GitSourceRepo "
#Write-Host "StagingDirectory: $StagingDirectory"
#Write-Host "GitSourceRepoWiki: $GitSourceRepoWiki"
#Write-Host "ReleaseType: $ReleaseType"
#Write-Host "XAPIKEY_PESTER: $XAPIKEY_PESTER"
#Write-Host "XAPIKEY_MTP: $XAPIKEY_MTP"
#Write-Host "NUGETAPIKEY: $NUGETAPIKEY"
#Write-Host "SYSTEM_ACCESSTOKEN : $SYSTEM_ACCESSTOKEN "
#Write-Host "RequiredModulesRepo: $RequiredModulesRepo"

# Log statuses
Write-Host ('[status]Platform: ' + [environment]::OSVersion.Platform)
Write-Host ('[status]PowerShell Version: ' + ($PSVersionTable.PSVersion -join '.'))
Write-Host ('[status]Host: ' + (Get-Host).Name)
Write-Host ('[status]Loaded config: ' + $MyInvocation.MyCommand.Path)
# Set variables from Azure Pipelines
$ScriptRoot = Switch ($DeployFolder) { $true { $DeployFolder } Default { $PSScriptRoot } }
$FolderPath_ModuleRootPath = (Get-Item -Path:($ScriptRoot)).Parent.FullName
$GitHubWikiUrl = 'https://github.com/TheJumpCloud/support/wiki/'
$FilePath_ModuleBanner = $FolderPath_ModuleRootPath + '/ModuleBanner.md'
$FilePath_ModuleChangelog = $FolderPath_ModuleRootPath + '/ModuleChangelog.md'
# Define required files and folders variables
$RequiredFiles = ('LICENSE', 'psm1', 'psd1')
$RequiredFolders = ('Docs', 'Private', 'Public', 'Tests', 'en-US')
# Define folder path variables
$FolderPath_Module = $FolderPath_ModuleRootPath + '/' + $ModuleFolderName
$RequiredFolders | ForEach-Object {
    $FolderName = $_
    $FolderPath = $FolderPath_Module + '/' + $FolderName
    New-Variable -Name:('FolderName_' + $_.Replace('-', '')) -Value:($FolderName) -Force -Scope Global;
    New-Variable -Name:('FolderPath_' + $_.Replace('-', '')) -Value:($FolderPath) -Force -Scope Global
}
$RequiredFiles | ForEach-Object {
    $FileName = If ($_ -in ('psm1', 'psd1')) { $ModuleName + '.' + $_ } Else { $_ }
    $FilePath = $FolderPath_Module + '/' + $FileName
    New-Variable -Name:('FileName_' + $_) -Value:($FileName) -Force -Scope Global;
    New-Variable -Name:('FilePath_' + $_) -Value:($FilePath) -Force -Scope Global;
}
# Get .psd1 contents
$Psd1 = Import-PowerShellDataFile -Path:($FilePath_psd1)
Set-Variable $Psd1 -Scope Global
# Get module function names
$Functions_Public = If (Test-Path -Path:($FolderPath_Public))
{
    Get-ChildItem -Path:($FolderPath_Public + '/' + '*.ps1') -Recurse
}
Set-Variable $Functions_Public -Scope Global
$Functions_Private = If (Test-Path -Path:($FolderPath_Private))
{
    Get-ChildItem -Path:($FolderPath_Private + '/' + '*.ps1') -Recurse
}
# Setup-Dependencies.ps1
.("$ScriptRoot/Setup-Dependencies.ps1") -RequiredModulesRepo:($RequiredModulesRepo)
