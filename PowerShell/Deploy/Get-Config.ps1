# Define variables that come from Azure DevOps Pipeline
param (
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Name of module')][ValidateNotNullOrEmpty()][System.String]$ModuleName = 'JumpCloud',
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Module Folder Name')][ValidateNotNullOrEmpty()][System.String]$ModuleFolderName = './PowerShell',
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Deploy Folder Name')][ValidateNotNullOrEmpty()][System.String]$DeployFolder = "$(ModuleFolderName)/Deploy",
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Git Source Branch')][ValidateNotNullOrEmpty()][System.String]$GitSourceBranch,
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Git Source Repository')][ValidateNotNullOrEmpty()][System.String]$GitSourceRepo,
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Git Source Repository')][ValidateNotNullOrEmpty()][System.String]$GitSourceRepoWiki = "$($GitSourceRepo).wiki",
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Name of module')][ValidateNotNullOrEmpty()][System.String]$StagingDirectory = $env:BUILD_ARTIFACTSTAGINGDIRECTORY
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Release Type')][ValidateNotNullOrEmpty()][System.String]$ReleaseType,
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Windows Pester JumpCloud API Key')][ValidateNotNullOrEmpty()][System.String]$XAPIKEY_PESTER = $env:XAPIKEY_PESTER,
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'MTP Pester JumpCloud API Key')][ValidateNotNullOrEmpty()][System.String]$XAPIKEY_MTP = $env:XAPIKEY_PESTER_MTP
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Nuget API Key')][ValidateNotNullOrEmpty()][System.String]$NUGETAPIKEY = $env:NUGETAPIKEY,
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'System Access Token')][ValidateNotNullOrEmpty()][System.String]$SYSTEM_ACCESSTOKEN = $env:SYSTEM_ACCESSTOKEN,
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Required Modules Repository')][ValidateNotNullOrEmpty()][System.String]$RequiredModulesRepo = "JumpCloudPowerShell-Dev"
)
#$ModuleName = "JumpCloud"
#$ModuleFolderName = "./PowerShell"
#$DeployFolder = "$(ModuleFolderName)/Deploy"
#$GitSourceBranch = << pipeline.git.branch >>
#$GitSourceRepo = << pipeline.project.git_url >>
#$StagingDirectory = $env:BUILD_ARTIFACTSTAGINGDIRECTORY
#$GitSourceRepoWiki = "$($GitSourceRepo).wiki"
#$RELEASETYPE = "patch"
#$XAPIKEY_PESTER = $env:XAPIKEY_PESTER
#$XAPIKEY_MTP = $env:XAPIKEY_MTP
#$NUGETAPIKEY = $env:NUGETAPIKEY
#$SYSTEM_ACCESSTOKEN = $env:SYSTEM_ACCESSTOKEN
#$RequiredModulesRepo = $env:REQUIREDMODULESREPO

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
    New-Variable -Name:('FolderName_' + $_.Replace('-', '')) -Value:($FolderName) -Force;
    New-Variable -Name:('FolderPath_' + $_.Replace('-', '')) -Value:($FolderPath) -Force
}
$RequiredFiles | ForEach-Object {
    $FileName = If ($_ -in ('psm1', 'psd1')) { $ModuleName + '.' + $_ } Else { $_ }
    $FilePath = $FolderPath_Module + '/' + $FileName
    New-Variable -Name:('FileName_' + $_) -Value:($FileName) -Force;
    New-Variable -Name:('FilePath_' + $_) -Value:($FilePath) -Force;
}
# Get .psd1 contents
$Psd1 = Import-PowerShellDataFile -Path:($FilePath_psd1)
# Get module function names
$Functions_Public = If (Test-Path -Path:($FolderPath_Public))
{
    Get-ChildItem -Path:($FolderPath_Public + '/' + '*.ps1') -Recurse
}
$Functions_Private = If (Test-Path -Path:($FolderPath_Private))
{
    Get-ChildItem -Path:($FolderPath_Private + '/' + '*.ps1') -Recurse
}
# Setup-Dependencies.ps1
.("$ScriptRoot/Setup-Dependencies.ps1") -RequiredModulesRepo:($env:REQUIREDMODULESREPO)