# Configure Azure DevOps Artifacts
$UserName = $env:AzureDevOpsUserName # Azure DevOps email address
$AzureDevOpsPAT = $env:AzureDevOpsPAT # Create PAT and grant it "Packaging (Read & write)" https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page
$AzureDevOpsAuthenicationCreds = New-Object System.Management.Automation.PSCredential($UserName, ($AzureDevOpsPAT | ConvertTo-SecureString -AsPlainText -Force))
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
$OrgName = 'JumpCloudPowershell'
$FeedNames = @('Dev') # Dev, Prod
$LocalPSRepositories = Get-PSRepository
ForEach ($FeedName In $FeedNames)
{
    $PSRepositoryParams = @{
        Name               = "$OrgName-$FeedName";
        SourceLocation     = "https://pkgs.dev.azure.com/$OrgName/_packaging/$FeedName/nuget/v2";
        PublishLocation    = "https://pkgs.dev.azure.com/$OrgName/_packaging/$FeedName/nuget/v2";
        InstallationPolicy = 'Trusted';
    }
    If (-not [System.String]::IsNullOrEmpty($OldRepos)) { Unregister-PSRepository -Name:($OldRepos.Name) }
    # Register new feeds if they do not exist
    If (-not ($LocalPSRepositories | Where-Object { `
                    $_.Name -eq $PSRepositoryParams.Name `
                    -and $_.SourceLocation -eq $PSRepositoryParams.SourceLocation `
                    -and $_.PublishLocation -eq $PSRepositoryParams.PublishLocation `
                    -and $_.InstallationPolicy -eq $PSRepositoryParams.InstallationPolicy })
    )
    {
        Register-PSRepository @PSRepositoryParams
    }
}
