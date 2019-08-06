Describe -Tag:('JCModule') 'Test for Update-JCModule' {
    It ('Installs old version of module and then updates it.') {
        Install-Module -Name:('JumpCloud') -RequiredVersion:('1.0.0') -Scope:('CurrentUser') -Force
        $OldVersion = (Get-InstalledModule -Name:('JumpCloud')).Version
        Update-Module -Force
        $NewVersion = (Get-InstalledModule -Name:('JumpCloud')).Version
        $OldVersion | Should -Not -Be $NewVersion
    }
}