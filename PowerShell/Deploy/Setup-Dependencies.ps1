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
            Install-Module -Name $DependentModule -Repository:('PSGallery') -AllowPrerelease -RequiredVersion '3.0.0-beta10' -Force
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
    $authToken = Get-CAAuthorizationToken -Domain jumpcloud-artifacts -Region us-east-1
    # Get-Command -Module:('PowerShellGet', 'PackageManagement') -ParameterName 'Repository' | ForEach-Object {
    #    If ( -not $global:PSDefaultParameterValues.GetEnumerator() | Where-Object { $_.Key -eq "$($_.Name):Repository" -and $_.Value -eq $RequiredModulesRepo })
    #    {
    #        $global:PSDefaultParameterValues["$($_.Name):Repository"] = $RequiredModulesRepo
    #    }
    # }
    # Set default -AllowPrerelease parameter value to be $True
    # Get-Command -Module:('PowerShellGet', 'PackageManagement') -ParameterName 'AllowPrerelease' | ForEach-Object {
    #    If ( -not $global:PSDefaultParameterValues.GetEnumerator() | Where-Object { $_.Key -eq "$($_.Name):AllowPrerelease" -and $_.Value -eq $true })
    #    {
    #        $global:PSDefaultParameterValues["$($_.Name):AllowPrerelease"] = $true
    #    }
    # }
    If (-not [System.String]::IsNullOrEmpty($authToken))
    {
        $RepositoryCredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $authToken.AuthorizationToken , ($authToken.AuthorizationToken | ConvertTo-SecureString -AsPlainText -Force)
        # Set default -Credential parameter value to be $RepositoryCredentials
        # Get-Command -Module:('PowerShellGet', 'PackageManagement') -ParameterName 'Credential' | ForEach-Object {
        #     If ( -not $global:PSDefaultParameterValues.GetEnumerator() | Where-Object { $_.Key -eq "$($_.Name):Credential" -and $_.Value -eq $RepositoryCredentials })
        #     {
        #         $global:PSDefaultParameterValues["$($_.Name):Credential"] = $RepositoryCredentials
        #     }
        # }
    }
    Else
    {
        Write-Warning ('No authToken has been provided')
    }
    # Register PSRepository
    try {
        $resourceRepos = Get-PSResourceRepository -Name:($RequiredModulesRepo)
        if ([String]::IsNullOrEmpty($resourceRepos)){
            Write-Host "Could not Find $RequiredModulesRepo"
        }
    }
    catch {
        Write-Host("[status]Register-PackageSource Setup '$RequiredModulesRepo'")
        $AWSRepo = 'jumpcloud-nuget-modules'
        $AWSDomain = 'jumpcloud-artifacts'
        $AWSRegion = 'us-east-1'
        $AWSCARepoEndpoint = Get-CARepositoryEndpoint -Domain:($AWSDomain) -Repository:($AWSRepo) -Region:($AWSRegion) -Format:('nuget')
        Register-PSResourceRepository -Name:($RequiredModulesRepo) -URL:("$($AWSCARepoEndpoint)v3/index.json") -Trusted
    }
}
If (-not [System.String]::IsNullOrEmpty($Psd1))
{
    # Install required modules
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    ForEach ($RequiredModule In $Psd1.RequiredModules)
    {
        # Check to see if the module is installed
        If ([System.String]::IsNullOrEmpty((Get-InstalledModule | Where-Object { $_.Name -eq $RequiredModule })))
        {
            Write-Host("[status]Installing module: '$RequiredModule' from '$RequiredModulesRepo'")
            If ($RequiredModulesRepo -ne 'PSGallery'){
                # install-PSResource -Name:($RequiredModule) -Repository:($RequiredModulesRepo) -Credential $RepositoryCredentials -Prerelease -Scope:('CurrentUser')
                # $modulePath = "C:\Users\circleci\Documents\PowerShell\Modules"
                # $installedModule = Get-PSResource -name:($RequiredModule) -path $modulePath
                # Write-Host("[status]Importing module: '$RequiredModule'")
                # import-module -Name C:\Users\circleci\Documents\PowerShell\Modules\$($installedModule.Name)\$($installedModule.Version)\$($installedModule.Name).psd1 -Force -Global
                # $module = Get-PSResource -name jumpcloud.sdk.directoryinsgiths -path C:\Users\circleci\Documents\PowerShell\Modules
                # if ([string]::isnullorempty($module)) {


                # Install Module Command
                $LocalPSModulePath = $env:PSModulePath.split(';') | Where-Object { $_ -like '*documents*' }
                $ModulePath = "$($LocalPSModulePath)/$($RequiredModule)"
                # Remove existing module
                If (Get-PSResource -Name:($_) -Path:($LocalPSModulePath)) { Remove-Item -Path:($ModulePath) -Recurse -Force; }
                # Install new module
                Install-PSResource -Name:($RequiredModule) -Repository:($RequiredModulesRepo) -Credential:($RepositoryCredentials) -Prerelease -Reinstall;
                # Rename version folder and import module
                Get-ChildItem -Path:($ModulePath) | ForEach-Object {
                    If ($_.Name -match '-') { Rename-Item -Path:($_.FullName) -NewName:(($_.Name.split('-'))[0]) -Force; };
                    Import-Module -Name:($_.Parent.Name) -Force;
                };
                # }
            }
            else{
                Install-Module -Force -Name:($RequiredModule) -Scope:('CurrentUser') -Repository:($RequiredModulesRepo) -Credential:($RepositoryCredentials) -AllowPrerelease
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