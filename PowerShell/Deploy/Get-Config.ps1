# Define baseline path variables for scripts to reference common files by variables:
# FolderPath_Docs: /src/support/PowerShell/JumpCloud Module/Docs
# FolderPath_Private: /src/support/PowerShell/JumpCloud Module/Private
# FolderPath_Public: /src/support/PowerShell/JumpCloud Module/Public
# FolderPath_Tests: /src/support/PowerShell/JumpCloud Module/Tests
# FolderPath_en-US: /src/support/PowerShell/JumpCloud Module/en-US
# FilePath_LICENSE: /src/support/PowerShell/JumpCloud Module/LICENSE
# FilePath_psm1: /src/support/PowerShell/JumpCloud Module/JumpCloud.psm1
# FilePath_psd1: /src/support/PowerShell/JumpCloud Module/JumpCloud.psd1
param (
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Name of module')][ValidateNotNullOrEmpty()][System.String]$ModuleName = 'JumpCloud',
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Module Folder Name')][ValidateNotNullOrEmpty()][System.String]$ModuleFolderName = 'JumpCloud Module',
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Deploy Folder Name')][ValidateNotNullOrEmpty()][System.String]$DeployFolder = "/Powershell/Deploy"
)
# Set variables:
$ScriptRoot = $PSScriptRoot
$FolderPath_ModuleRootPath = (Get-Item -Path:($ScriptRoot)).Parent.FullName
$GitHubWikiUrl = 'https://github.com/TheJumpCloud/support/wiki/'
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
    # write-host "New Variable: $('FolderPath_' + $_) with value: $($FolderPath)"
}
$RequiredFiles | ForEach-Object {
    $FileName = If ($_ -in ('psm1', 'psd1')) {
        $ModuleName + '.' + $_
    } Else {
        $_
    }
    $FilePath = $FolderPath_Module + '/' + $FileName
    New-Variable -Name:('FileName_' + $_) -Value:($FileName) -Force -Scope Global;
    New-Variable -Name:('FilePath_' + $_) -Value:($FilePath) -Force -Scope Global;
    # write-host "New Variable: $('FilePath_' + $_) with value: $($FilePath)"
}
# Get .psd1 contents
$Psd1 = Import-PowerShellDataFile -Path:($FilePath_psd1)
Set-Variable $Psd1 -Scope Global
# Get module function names
$Functions_Public = If (Test-Path -Path:($FolderPath_Public)) {
    Get-ChildItem -Path:($FolderPath_Public + '/' + '*.ps1') -Recurse
}
Set-Variable $Functions_Public -Scope Global
$Functions_Private = If (Test-Path -Path:($FolderPath_Private)) {
    Get-ChildItem -Path:($FolderPath_Private + '/' + '*.ps1') -Recurse
}
