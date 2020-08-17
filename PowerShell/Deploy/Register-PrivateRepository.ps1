# Configure Azure DevOps Artifacts
$patToken = $env:SYSTEM_ACCESSTOKEN | ConvertTo-SecureString -AsPlainText -Force
$AzureDevOpsAuthenicationCreds = New-Object System.Management.Automation.PSCredential($env:SYSTEM_ACCESSTOKEN, $patToken)
$PSDefaultParameterValues = @{
    # Set default value for PowerShellGet Credential
    "*-Module:Credential"         = $AzureDevOpsAuthenicationCreds;
    "*-PSRepository:Credential"   = $AzureDevOpsAuthenicationCreds;
    "*-Script:Credential"         = $AzureDevOpsAuthenicationCreds;
    # Set default value for PowerShellGet Repository
    "*-Command:Repository"        = 'PSGallery';
    "*-DscResource:Repository"    = 'PSGallery';
    "*-Module:Repository"         = 'PSGallery';
    "*-RoleCapability:Repository" = 'PSGallery';
    "*-Script:Repository"         = 'PSGallery';
}
# Register PSRepository
Register-PackageSource -ProviderName 'PowerShellGet' -Name:('JumpCloudPowershell-Dev') -Location:('https://pkgs.dev.azure.com/JumpCloudPowershell/_packaging/Dev/nuget/v2') -Credential:($AzureDevOpsAuthenicationCreds)