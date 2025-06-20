[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = 'The type of build to create.')]
    [ValidateSet('Major', 'Minor', 'Patch')]
    [System.String]
    $buildType = 'Patch'
)

# Define the module path and output path
$modulePath = "$PSScriptRoot/../"
$outputPath = "$PSScriptRoot/output"
$rootPath = "$PSScriptRoot/../../../../"

# Ensure the output directory exists
if (-not (Test-Path -Path $outputPath)) {
    New-Item -ItemType Directory -Path $outputPath | Out-Null
}

# Get the public functions from the module
$publicFunctions = Get-ChildItem -Path "$modulePath/Functions/Public" -Recurse -Filter '*.ps1'

# Get the psd1 file for the module
$psd1Path = "$modulePath/JumpCloud.Radius.psd1"
$Psd1 = Import-PowerShellDataFile -Path:("$psd1Path")

$moduleManifest = @{
    ModuleVersion     = $Psd1.ModuleVersion
    RootModule        = 'JumpCloud.Radius.psm1'
    GUID              = $Psd1.GUID
    Author            = $Psd1.Author
    CompanyName       = $psd1.CompanyName
    Copyright         = $Psd1.Copyright
    Description       = $Psd1.Description
    PowerShellVersion = $Psd1.PowerShellVersion
    RequiredModules   = $Psd1.RequiredModules
    FunctionsToExport = $publicFunctions.basename
    Path              = $psd1Path

}

# update the module manifest with public functions and generation date
Update-ModuleManifest @moduleManifest

# Package the module into a .nupkg file
. $PSScriptRoot/BuildNuspecFromPsd1.ps1

# generate docs
$helpFileFunctionPath = Join-Path $rootPath "PowerShell/Deploy/Build-HelpFiles.ps1"

. $helpFileFunctionPath -ModuleName 'JumpCloud.Radius' -ModulePath $modulePath

Write-Host "Module packaged successfully to $outputPath"