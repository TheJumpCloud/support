Param(
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 0)][System.String[]]$DependentModules = ('PowerShellGet', 'PackageManagement', 'PSScriptAnalyzer', 'PlatyPS', 'Pester')
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
    Write-Host("[status]Setting up dependency '$DependentModule'")
    # Check to see if the module is installed
    If ([System.String]::IsNullOrEmpty((Get-InstalledModule).Where( { $_.Name -eq $DependentModule })))
    {
        Write-Host("[status]Installing '$DependentModule' from 'PSGallery'")
        Install-Module -Repository:('PSGallery') -Force -Name:($DependentModule) -Scope:('CurrentUser')
    }
    # Get-Module -Refresh -ListAvailable
    If ([System.String]::IsNullOrEmpty((Get-Module).Where( { $_.Name -eq $DependentModule })))
    {
        Write-Host("[status]Importing '$DependentModule'")
        Import-Module -Name:($DependentModule) -Force -Global
    }
}
If ($RequiredModulesRepo -ne 'PSGallery')
{
    # Set default -Repository parameter value to be $RequiredModulesRepo
    Get-Command -Module:('PowerShellGet', 'PackageManagement') -ParameterName 'Repository' | ForEach-Object {
        If ( -not $global:PSDefaultParameterValues.GetEnumerator() | Where-Object { $_.Key -eq "$($_.Name):Repository" -and $_.Value -eq $RequiredModulesRepo })
        {
            $global:PSDefaultParameterValues["$($_.Name):Repository"] = $RequiredModulesRepo
        }
    }
    # Set default -AllowPrerelease parameter value to be $True
    Get-Command -Module:('PowerShellGet', 'PackageManagement') -ParameterName 'AllowPrerelease' | ForEach-Object {
        If ( -not $global:PSDefaultParameterValues.GetEnumerator() | Where-Object { $_.Key -eq "$($_.Name):AllowPrerelease" -and $_.Value -eq $true })
        {
            $global:PSDefaultParameterValues["$($_.Name):AllowPrerelease"] = $true
        }
    }
    If (-not [System.String]::IsNullOrEmpty($env:SYSTEM_ACCESSTOKEN))
    {
        $Password = $env:SYSTEM_ACCESSTOKEN | ConvertTo-SecureString -AsPlainText -Force
        $RepositoryCredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $env:SYSTEM_ACCESSTOKEN, $Password
        # Set default -Credential parameter value to be $RepositoryCredentials
        Get-Command -Module:('PowerShellGet', 'PackageManagement') -ParameterName 'Credential' | ForEach-Object {
            If ( -not $global:PSDefaultParameterValues.GetEnumerator() | Where-Object { $_.Key -eq "$($_.Name):Credential" -and $_.Value -eq $RepositoryCredentials })
            {
                $global:PSDefaultParameterValues["$($_.Name):Credential"] = $RepositoryCredentials
            }
        }
    }
    Else
    {
        Write-Warning ('No SYSTEM_ACCESSTOKEN has been provided')
        Write-Host ('No SYSTEM_ACCESSTOKEN has been provided')
    }
    # Register PSRepository
    If (-not (Get-PackageSource -Name:($RequiredModulesRepo) -ErrorAction SilentlyContinue))
    {
        Write-Host("[status]Register-PackageSource Setup '$RequiredModulesRepo'")
        Register-PackageSource -Trusted -ProviderName:("PowerShellGet") -Name:($RequiredModulesRepo) -Credential:($RepositoryCredentials) -Location:("https://pkgs.dev.azure.com/$(($RequiredModulesRepo.Split('-'))[0])/_packaging/$($(($RequiredModulesRepo.Split('-'))[1]))/nuget/v2/")
    }
}
If (-not [System.String]::IsNullOrEmpty($Psd1))
{
    # Install required modules
    ForEach ($RequiredModule In $Psd1.RequiredModules)
    {
        Write-Host("[status]Setting up dependency '$RequiredModule'")
        # Check to see if the module is installed
        If ([System.String]::IsNullOrEmpty((Get-InstalledModule).Where( { $_.Name -eq $RequiredModule })))
        {
            Write-Host("[status]Installing '$RequiredModule' from '$RequiredModulesRepo'")
            Install-Module -Force -Name:($RequiredModule) -Scope:('CurrentUser') -Repository:($RequiredModulesRepo) -Credential:($RepositoryCredentials) -AllowPrerelease
        }
        # Get-Module -Refresh -ListAvailable
        If ([System.String]::IsNullOrEmpty((Get-Module).Where( { $_.Name -eq $RequiredModule })))
        {
            Write-Host("[status]Importing '$RequiredModule'")
            Import-Module -Name:($RequiredModule) -Force -Global
        }
    }
    # Load current module
    If ([System.String]::IsNullOrEmpty((Get-Module).Where( { $_.Name -eq $ModuleName })))
    {
        Write-Host("[status]Importing '$ModuleName'")
        Import-Module ($FilePath_psd1) -Force -Global
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
}