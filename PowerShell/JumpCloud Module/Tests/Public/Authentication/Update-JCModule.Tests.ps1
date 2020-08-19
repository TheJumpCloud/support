Describe -Tag:('JCModule') 'Test for Update-JCModule' {
    It ("Where the local version number has been updated to match the $RequiredModulesRepo version number") {
        Install-Module -Repository:('PSGallery') -Name:('JumpCloud') -RequiredVersion:('1.0.0') -Scope:('CurrentUser') -Force
        $InitialModule = Get-Module -Name:('JumpCloud') -All | Where-Object { $_.Version -eq '1.0.0' }
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
        }
        $InitialModule | Remove-Module
        $LocalModulePost = Get-Module -Name:('JumpCloud') -All | Where-Object { $_.Version -eq $PowerShellGalleryModule.Version } | Get-Unique
        If ($LocalModulePost)
        {
            Write-Host ('Local Version After: ' + $LocalModulePost.Version)
            $LocalModulePost | Remove-Module
        }
        Else
        {
            Write-Error ('Unable to find latest version of the JumpCloud PowerShell module installed on local machine.')
        }
        $LocalModulePost.Version | Should -Be $PowerShellGalleryModule.Version
        $LocalModulePost | Should -Not -BeNullOrEmpty
    }
    AfterAll {
        Import-Module -Name:("$PesterParams_ModuleManifestPath/$PesterParams_ModuleManifestName") -Force
    }
}
