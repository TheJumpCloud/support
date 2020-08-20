Describe -Tag:('JCModule') 'Test for Update-JCModule' {
    It ("Where the local version number has been updated to match the $RequiredModulesRepo version number") {
        $EarliestVersion = Find-Module -Name:('JumpCloud') -Repository:($RequiredModulesRepo) -Credential:($RepositoryCredentials) -AllVersions -AllowPrerelease | Sort-Object PublishedDate | Select-Object -First 1
        Install-Module -Name:('JumpCloud') -Repository:($RequiredModulesRepo) -Credential:($RepositoryCredentials) -RequiredVersion:($EarliestVersion.Version) -Scope:('CurrentUser') -Force -AllowPrerelease
        $InitialModule = Get-Module -Name:('JumpCloud') -All | Where-Object { $_.Version -eq $EarliestVersion.Version }
        $PowerShellGalleryModule = If (-not [System.String]::IsNullOrEmpty($RepositoryCredentials))
        {
            Find-Module -Name:('JumpCloud') -Repository:($RequiredModulesRepo) -Credential:($RepositoryCredentials) -AllowPrerelease
        }
        Else
        {
            Find-Module -Name:('JumpCloud') -Repository:($RequiredModulesRepo)
        }
        $LocalModulePre = Get-Module -Name:('JumpCloud')
        Write-Host ("$RequiredModulesRepo Version: $($PowerShellGalleryModule.Version)")
        Write-Host ("Local Version Before: $($LocalModulePre.Version)")
        If ($RequiredModulesRepo -eq 'PSGallery')
        {
            Update-JCModule -SkipUninstallOld -Force -Repository:($RequiredModulesRepo)
        }
        Else
        {
            Update-JCModule -SkipUninstallOld -Force -Repository:($RequiredModulesRepo) -RepositoryCredentials:($RepositoryCredentials)
        }
        $InitialModule | Remove-Module
        # Remove prerelease tag from build number
        $PowerShellGalleryModuleVersion = If ($PowerShellGalleryModule.AdditionalMetadata.IsPrerelease)
        {
            $PowerShellGalleryModule.Version.Split('-')[0]
        }
        Else
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
        Import-Module -Name:("$PesterParams_ModuleManifestPath/$PesterParams_ModuleManifestName") -Force
    }
}
