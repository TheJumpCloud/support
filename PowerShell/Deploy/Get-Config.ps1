# Log statuses
Write-Host ('[status]Platform: ' + [environment]::OSVersion.Platform)
Write-Host ('[status]PowerShell Version: ' + ($PSVersionTable.PSVersion -join '.'))
Write-Host ('[status]Host: ' + (Get-Host).Name)
Write-Host ('[status]Loaded config: ' + $MyInvocation.MyCommand.Path)
# Set variables from Azure Pipelines
$ModuleName = $env:MODULENAME
$ModuleFolderName = $env:MODULEFOLDERNAME
$GitSourceBranch = $env:BUILD_SOURCEBRANCHNAME
$GitSourceRepo = $env:BUILD_REPOSITORY_URI
$StagingDirectory = $env:BUILD_ARTIFACTSTAGINGDIRECTORY
$GitSourceRepoWiki = $GitSourceRepo + '.wiki'
$ScriptRoot = Switch ($env:DEPLOYFOLDER) { $true { $env:DEPLOYFOLDER } Default { $PSScriptRoot } }
$FolderPath_ModuleRootPath = (Get-Item -Path:($ScriptRoot)).Parent.FullName
$RELEASETYPE = $env:RELEASETYPE
$XAPIKEY_PESTER = $env:XAPIKEY_PESTER
$XAPIKEY_MTP = $env:XAPIKEY_MTP
$NUGETAPIKEY = $env:NUGETAPIKEY
$EnvironmentConfig = 'TestEnvironmentVariables.ps1'
$GitHubWikiUrl = 'https://github.com/TheJumpCloud/support/wiki/'
$FilePath_ModuleBanner = $FolderPath_ModuleRootPath + '/ModuleBanner.md'
$FilePath_ModuleChangelog = $FolderPath_ModuleRootPath + '/ModuleChangelog.md'
# Define required files and folders variables
$RequiredFiles = ('LICENSE', 'psm1', 'psd1', 'PesterConfig')
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
    $FileName = If ($_ -in ('psm1', 'psd1')) { $ModuleName + '.' + $_ } ElseIf ($_ -eq 'PesterConfig') { $EnvironmentConfig } Else { $_ }
    $FilePath = If ($_ -eq 'PesterConfig') { $FolderPath_Module + '/' + $FolderName_Tests + '/' + $FileName } Else { $FolderPath_Module + '/' + $FileName }
    New-Variable -Name:('FileName_' + $_) -Value:($FileName) -Force;
    New-Variable -Name:('FilePath_' + $_) -Value:($FilePath) -Force;
}
# Get module function names
$Functions_Public = If (Test-Path -Path:($FolderPath_Public)) { Get-ChildItem -Path:($FolderPath_Public + '/' + '*.ps1') -Recurse }
$Functions_Private = If (Test-Path -Path:($FolderPath_Private)) { Get-ChildItem -Path:($FolderPath_Private + '/' + '*.ps1') -Recurse }
# Get psd1 contents
$Psd1 = Import-PowerShellDataFile -Path:($FilePath_psd1)
$RequiredModules = $Psd1.RequiredModules
# Load deploy functions
$DeployFunctions = @(Get-ChildItem -Path:($PSScriptRoot + '/Functions/*.ps1') -Recurse)
Foreach ($DeployFunction In $DeployFunctions)
{
    Try
    {
        . $DeployFunction.FullName
    }
    Catch
    {
        Write-Error -Message:('Failed to import function: ' + $DeployFunction.FullName)
    }
}
# Install NuGet
If (!(Get-PackageProvider -Name:('NuGet') -ListAvailable -ErrorAction:('SilentlyContinue')))
{
    Write-Host ('[status]Installing package provider NuGet'); Install-PackageProvider -Name:('NuGet') -Scope:('CurrentUser') -Force
}
