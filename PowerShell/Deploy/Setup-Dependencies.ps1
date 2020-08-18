# Install NuGet
If (!(Get-PackageProvider -Name:('NuGet') -ListAvailable -ErrorAction:('SilentlyContinue')))
{
    Write-Host ('[status]Installing package provider NuGet');
    Install-PackageProvider -Name:('NuGet') -Scope:('CurrentUser') -Force
}
# Install dependent modules
$DependentModules = @('PSScriptAnalyzer', 'PlatyPS')
ForEach ($DependentModule In $DependentModules)
{
    Write-Host("[status]Setting up dependency '$DependentModule'")
    # Check to see if the module is installed
    If ([System.String]::IsNullOrEmpty((Get-InstalledModule).Where( { $_.Name -eq $DependentModule })))
    {
        Write-Host("[status]Installing '$DependentModule'")
        Install-Module -Repository:('PSGallery') -Force -Name:($DependentModule)
    }
    # Get-Module -Refresh -ListAvailable
    If ([System.String]::IsNullOrEmpty((Get-Module).Where( { $_.Name -eq $DependentModule })))
    {
        Write-Host("[status]Importing '$DependentModule'")
        Import-Module -Name:($DependentModule) -Force
    }
}
# Register PSRepository
If (-not (Get-PackageSource -Name:('JumpCloudPowershell-Dev') -ErrorAction SilentlyContinue))
{
    $Password = $SYSTEM_ACCESSTOKEN | ConvertTo-SecureString -AsPlainText -Force
    $Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $SYSTEM_ACCESSTOKEN, $Password
    Register-PackageSource -Trusted -ProviderName "PowerShellGet" -Name:('JumpCloudPowershell-Dev') -Location "https://pkgs.dev.azure.com/JumpCloudPowershell/_packaging/Dev/nuget/v2/" -Credential:($Credentials)
}
# Install required modules
ForEach ($RequiredModule In $Psd1.RequiredModules)
{
    Write-Host("[status]Setting up dependency '$RequiredModule'")
    # Check to see if the module is installed
    If ([System.String]::IsNullOrEmpty((Get-InstalledModule).Where( { $_.Name -eq $RequiredModule })))
    {
        Write-Host("[status]Installing '$RequiredModule'")
        Install-Module -Repository:('JumpCloudPowershell-Dev') -AllowPrerelease -Force -Name:($RequiredModule) -Credential:($Credentials)
    }
    # Get-Module -Refresh -ListAvailable
    If ([System.String]::IsNullOrEmpty((Get-Module).Where( { $_.Name -eq $RequiredModule })))
    {
        Write-Host("[status]Importing '$RequiredModule'")
        Import-Module -Name:($RequiredModule) -Force
    }
}
# Load current module
If ([System.String]::IsNullOrEmpty((Get-Module).Where( { $_.Name -eq $ModuleName })))
{
    Write-Host("[status]Importing '$ModuleName'")
    Import-Module ($FilePath_psd1) -Force
}
# Load "Deploy" functions
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