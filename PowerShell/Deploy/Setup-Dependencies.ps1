Param(
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 0)][System.String[]]$DependentModules = ('PowerShellGet', 'PackageManagement', 'PSScriptAnalyzer', 'PlatyPS', 'Pester', 'AWS.Tools.Common', 'AWS.Tools.CodeArtifact')
    , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 1)][System.String]$RequiredModulesRepo = 'PSGallery'
)
# Install NuGet
If (!(Get-PackageProvider -Name:('NuGet') -ListAvailable -ErrorAction:('SilentlyContinue')))
{
    Write-Host ('[status]Installing package provider NuGet');
    Install-PackageProvider -Name:('NuGet') -Scope:('CurrentUser') -Force
}
# Install dependent modules
ForEach ($DependentModule In $DependentModules)
{
    # Check to see if the module is installed
    If ([System.String]::IsNullOrEmpty((Get-InstalledModule | Where-Object { $_.Name -eq $DependentModule })))
    {
        Write-Host("[status]Installing module: '$DependentModule' from 'PSGallery'")
        if ($DependentModule -eq 'PowerShellGet'){
            Install-Module -Name $DependentModule -Repository:('PSGallery') -AllowPrerelease -Force
        }
        elseif ($DependentModule -eq 'PSScriptAnalyzer') {
            Install-Module -Name $DependentModule -Repository:('PSGallery') -RequiredVersion '1.19.1' -Force
        }
        else{
            Install-Module -Repository:('PSGallery') -Force -Name:($DependentModule) -Scope:('CurrentUser') -AllowClobber
        }
    }
    # Get-Module -Refresh -ListAvailable
    If ([System.String]::IsNullOrEmpty((Get-Module | Where-Object { $_.Name -eq $DependentModule })))
    {
        Write-Host("[status]Importing module: '$DependentModule'")
        Import-Module -Name:($DependentModule) -Force -Global
    }
}
### TODO: Switch to CodeArtifact
If ($RequiredModulesRepo -ne 'PSGallery')
{
    $AWSRepo = 'jumpcloud-nuget-modules'
    $AWSDomain = 'jumpcloud-artifacts'
    $AWSRegion = 'us-east-1'
    # Set AWS authToken using context from CI Pipeline (context: aws-credentials)
    $authToken = Get-CAAuthorizationToken -Domain $AWSDomain -Region $AWSRegion
    If (-not [System.String]::IsNullOrEmpty($authToken))
    {
        # Create Credential Object
        $RepositoryCredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $authToken.AuthorizationToken , ($authToken.AuthorizationToken | ConvertTo-SecureString -AsPlainText -Force)
    }
    Else
    {
        Write-Warning ('No authToken has been provided')
    }
    # Register PSRepository
    try {
        # Search for Repo Object, moved to try/ catch loop to avoid issue w/ PowerShell Get Beta10
        $resourceRepos = Get-PSResourceRepository -Name:($RequiredModulesRepo)
        if ([String]::IsNullOrEmpty($resourceRepos)){
            Write-Host "Could not Find $RequiredModulesRepo"
        }
    }
    catch {
        Write-Host("[status]Register-PackageSource Setup '$RequiredModulesRepo'")
        # Set Endpoint URL
        $AWSCARepoEndpoint = Get-CARepositoryEndpoint -Domain:($AWSDomain) -Repository:($AWSRepo) -Region:($AWSRegion) -Format:('nuget')
        # Set Resource Repository
        Register-PSResourceRepository -Name:($RequiredModulesRepo) -URL:("$($AWSCARepoEndpoint)v3/index.json") -Trusted
    }
}
If (-not [System.String]::IsNullOrEmpty($Psd1))
{
    # Install required modules
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    ForEach ($RequiredModule In $Psd1.RequiredModules.ModuleName)
    {
        # Check to see if the module is installed
        If ([System.String]::IsNullOrEmpty((Get-InstalledModule | Where-Object { $_.Name -eq $RequiredModule })))
        {
            Write-Host("[status]Installing module: '$RequiredModule' from '$RequiredModulesRepo'")
            If ($RequiredModulesRepo -ne 'PSGallery'){
                # Depending on OS (Unix or Windows) select the default Module Path
                $PowerShellModulesPaths = $env:PSModulePath
                if ($PowerShellModulesPaths -match '.local/share')
                {
                    # Unix Systems: Mac/ Linux
                    $LocalPSModulePath = $env:PSModulePath.split(':') | Where-Object { $_ -like '*.local/share*' }
                    Write-Host "Module Installation Path: $LocalPSModulePath"
                }
                elseif ($PowerShellModulesPaths -match 'documents')
                {
                    # Windows Ststems
                    $LocalPSModulePath = $env:PSModulePath.split(';') | Where-Object { $_ -like '*documents*' }
                    Write-Host "Module Installation Path: $LocalPSModulePath"
                }
                # Set Module Path from required Module
                $ModulePath = "$($LocalPSModulePath)/$($RequiredModule)"
                # Search for module in localPSModulePath
                $moduleFound = Get-InstalledPSResource -name $RequiredModule -path $LocalPSModulePath
                if ([string]::isnullorempty($moduleFound)) {
                    # Install module if it does not exist
                    Install-PSResource -Name:($RequiredModule) -Repository:($RequiredModulesRepo) -Credential:($RepositoryCredentials) -Prerelease -Scope 'CurrentUser';
                }
                # Rename version folder and import module
                # Satisfy the version requirements & naming convertion for SDKS
                # x.x.x-someversion is not supported, split to just semantic version
                #TODO: remove w/ powershell get 3.0.11 this is no longer an issue
                # Get-ChildItem -Path:($ModulePath) | ForEach-Object {
                #     If ($_.Name -match '-') { Rename-Item -Path:($_.FullName) -NewName:(($_.Name.split('-'))[0]) -Force; };
                #     Write-Host("[status]Importing module: '$RequiredModule'")
                #     Import-Module -Name:($_.Parent.Name) -Force;
                # };
            }
            else{
                # If not CodeArtifact, just install the module from the default repository (PSGallery)
                Install-Module -Force -Name:($RequiredModule) -Scope:('CurrentUser') # -Repository:($RequiredModulesRepo) -Credential:($RepositoryCredentials) -AllowPrerelease
                # Get-Module -Refresh -ListAvailable
                If ([System.String]::IsNullOrEmpty((Get-Module | Where-Object { $_.Name -eq $RequiredModule })))
                {
                    Write-Host("[status]Importing module: '$RequiredModule'")
                    Import-Module -Name:($RequiredModule) -Force -Global
                }
            }
        }
    }
    # Load current module
    If ([System.String]::IsNullOrEmpty((Get-Module | Where-Object { $_.Name -eq $ModuleName })))
    {
        Write-Host("[status]Importing module: '$FilePath_psd1'")
        Import-Module ($FilePath_psd1) -Force -Global
    }
    # Load "Deploy" functions
    Write-Host("[status]Importing deploy functions: '$PSScriptRoot/Functions/*.ps1'")
    $DeployFunctions = @(Get-ChildItem -Path:($PSScriptRoot + '/Functions/*.ps1') -Recurse)
    $DeployFunctions
    Foreach ($DeployFunction In $DeployFunctions)
    {
        Try
        {
            Write-Host "Importing $($DeployFunction.FullName)"
            . $DeployFunction.FullName
            # Get-Command $DeployFunction
        }
        Catch
        {
            Write-Error -Message:('Failed to import function: ' + $DeployFunction.FullName)
        }
    }
}