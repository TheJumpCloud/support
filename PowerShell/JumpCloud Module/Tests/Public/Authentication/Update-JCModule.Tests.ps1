Describe -Tag:('JCModule') 'Test for Update-JCModule' {
    $PowerShellGalleryModule = Find-Module -Name:('JumpCloud') -ErrorAction:('Ignore')
    $LocalModulePre = Get-Module -Name:('JumpCloud')
    Write-Host ('PowerShellGallery Version: ' + $PowerShellGalleryModule.Version)
    Write-Host ('Local Version Before: ' + $LocalModulePre.Version)
    Update-JCModule -SkipUninstallOld
    $LocalModulePost = Get-Module -Name:('JumpCloud') -All | Where-Object {$_.Version -eq $PowerShellGalleryModule.Version}
    If ($LocalModulePost)
    {
        Write-Host ('Local Version After: ' + $LocalModulePost.Version)
        $LocalModulePost | Remove-Module
        It ('Where the local version number has been updated to match the PowerShell gallery version number') {
            $LocalModulePost | Should -Be $PowerShellGalleryModule.Version
            $LocalModulePost | Should -Not -BeNullOrEmpty
        }
    }
    Else
    {
        Write-Error ('Unable to find latest version of the JumpCloud PowerShell module installed on local machine.')
    }
}