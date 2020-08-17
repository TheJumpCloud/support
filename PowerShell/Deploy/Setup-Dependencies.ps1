. ($PSScriptRoot + '/' + 'Get-Config.ps1')
###########################################################################
ForEach ($RequiredModule In $RequiredModules)
{
    Write-Host("Setting up dependency '$RequiredModule'")
    # Check to see if the module is installed
    If ([System.String]::IsNullOrEmpty((Get-InstalledModule).Where( { $_.Name -eq $RequiredModule })))
    {
        Write-Host("Installing '$RequiredModule'")
        Install-Module -Repository:('JumpCloudPowershell-Dev') -AllowPrerelease -Force -Name:($RequiredModule) -Credential:(New-Object System.Management.Automation.PSCredential($env:SYSTEM_ACCESSTOKEN, ($env:SYSTEM_ACCESSTOKEN | ConvertTo-SecureString -AsPlainText -Force)))
    }
    # Get-Module -Refresh -ListAvailable
    If ([System.String]::IsNullOrEmpty((Get-Module).Where( { $_.Name -eq $RequiredModule })))
    {
        Write-Host("Importing '$RequiredModule'")
        Import-Module -Name:($RequiredModule) -Force
    }
}