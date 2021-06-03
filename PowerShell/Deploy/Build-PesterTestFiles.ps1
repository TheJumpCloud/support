. "$PSScriptRoot/Get-Config.ps1"
################################################################################
# This script creates a new test file for each function in the PowerShell Module
################################################################################
Write-Host ('[status]Creating files for Pester tests')
$Files = $Functions_Public + $Functions_Private
Foreach ($File in $Files)
{
    $NewDirectory = ([string]$File.Directory).Replace($ModuleFolderName, $ModuleFolderName + '/' + $FolderName_Tests)
    $NewName = $File.BaseName + '.Tests' + $File.Extension
    $NewFullName = $NewDirectory + '/' + $NewName
    If ( !( Test-Path -Path:($NewFullName) ))
    {
        New-FolderRecursive -Path:($NewFullName)
        Write-Host ('[status]Create test files for new function')
        New-Item -ItemType:('File') -Path:($NewFullName) -Force
    }
}
