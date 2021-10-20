Describe -Tag:('JCModule') 'Test for Update-JCModule' {
    It ("Where the local version number has been updated to match the $env:RequiredModulesRepo version number") {
        $EarliestVersion = Find-Module -Name:('JumpCloud') -AllVersions | Sort-Object PublishedDate | Select-Object -First 1
        Install-Module -Name:('JumpCloud') -RequiredVersion:($EarliestVersion.Version) -Scope:('CurrentUser') -Force
        $InitialModule = Get-Module -Name:('JumpCloud') -All | Where-Object { $_.Version -eq $EarliestVersion.Version }
        $LocalModulePre = Get-Module -Name:('JumpCloud')
        Write-Host ("Local Version Before: $($LocalModulePre.Version)")
        If ($env:RequiredModulesRepo -eq 'PSGallery')
        {
            $PowerShellGalleryModule = Find-Module -Name:('JumpCloud')

            Write-Host ("$env:RequiredModulesRepo Version: $($PowerShellGalleryModule.Version)")

            Update-JCModule -SkipUninstallOld -Force -Repository:('PSGallery')
        }Else
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
            }Else
            {
                Write-Warning ('No authToken has been provided')
            }
            $PowerShellGalleryModule = Find-PSResource -Name:('JumpCloud') -Repository:($env:RequiredModulesRepo) -Credential:($RepositoryCredentials) -Prerelease
            Write-Host ("$env:RequiredModulesRepo Version: $($PowerShellGalleryModule.Version)")

            Update-JCModule -SkipUninstallOld -Force -Repository:($PesterParams_RequiredModulesRepo) -RepositoryCredentials:($RepositoryCredentials)
        }
        $InitialModule | Remove-Module
        # Remove prerelease tag from build number
        $PowerShellGalleryModuleVersion = If ($PowerShellGalleryModule.AdditionalMetadata.IsPrerelease)
        {
            $PowerShellGalleryModule.Version.Split('-')[0]
        }Else
        {
            $PowerShellGalleryModule.Version
        }
        $LocalModulePost = Get-Module -Name:('JumpCloud') -All | Where-Object { $_.Version -eq $PowerShellGalleryModuleVersion } | Get-Unique
        If ($LocalModulePost)
        {
            Write-Host ('Local Version After: ' + $LocalModulePost.Version)
            $LocalModulePost | Remove-Module
        }
        Else
        {
            Write-Error ('Unable to find latest version of the JumpCloud PowerShell module installed on local machine.')
        }
        $LocalModulePost.Version | Should -Be $PowerShellGalleryModuleVersion
        $LocalModulePost | Should -Not -BeNullOrEmpty
    }
    AfterAll {
        Import-Module -Name:("$PesterParams_ModuleManifestPath/$PesterParams_ModuleManifestName") -Force -Global
    }
}
