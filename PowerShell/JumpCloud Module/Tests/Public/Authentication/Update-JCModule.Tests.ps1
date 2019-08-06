## ToDo: Figure out how to run this check without removing the version of the module that we are currently testing and without overwriting it with an older version of the module.
# Describe -Tag:('JCModule') 'Test for Update-JCModule' {
#     It ('Installs old version of module and then updates it.') {
#         Install-Module -Name:('JumpCloud') -RequiredVersion:('1.0.0') -Scope:('CurrentUser') -Force
#         $OldVersion = (Get-InstalledModule -Name:('JumpCloud')).Version
#         Update-Module -Force
#         $NewVersion = (Get-InstalledModule -Name:('JumpCloud')).Version
#         $OldVersion | Should -Not -Be $NewVersion
#     }
# }