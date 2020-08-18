. ($PSScriptRoot + '/' + 'Get-Config.ps1')
###########################################################################
# Register PSRepository
$Password = $env:SYSTEM_ACCESSTOKEN | ConvertTo-SecureString -AsPlainText -Force
$Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $env:SYSTEM_ACCESSTOKEN, $Password
if (-not (Get-PackageSource -Name:('JumpCloudPowershell-Dev') -ErrorAction SilentlyContinue))
{
    Register-PackageSource -Trusted -ProviderName "PowerShellGet" -Name:('JumpCloudPowershell-Dev') -Location "https://pkgs.dev.azure.com/JumpCloudPowershell/_packaging/Dev/nuget/v2/" -Credential:($Credentials)
}
# Install required modules
ForEach ($RequiredModule In $RequiredModules)
{
    Write-Host("Setting up dependency '$RequiredModule'")
    # Check to see if the module is installed
    If ([System.String]::IsNullOrEmpty((Get-InstalledModule).Where( { $_.Name -eq $RequiredModule })))
    {
        Write-Host("Installing '$RequiredModule'")
        Install-Module -Repository:('JumpCloudPowershell-Dev') -AllowPrerelease -Force -Name:($RequiredModule) -Credential:($Credentials)
    }
    # Get-Module -Refresh -ListAvailable
    If ([System.String]::IsNullOrEmpty((Get-Module).Where( { $_.Name -eq $RequiredModule })))
    {
        Write-Host("Importing '$RequiredModule'")
        Import-Module -Name:($RequiredModule) -Force
    }
}