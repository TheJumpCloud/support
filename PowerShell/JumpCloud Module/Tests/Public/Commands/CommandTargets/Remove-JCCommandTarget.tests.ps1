Describe -Tag:('JCCommandTarget') 'Add-JCCommandTarget' {
    Context 'SystemGroup to Command tests' {

        BeforeEach {
            $RandomString1 = ( -join (( 0x41..0x5A) + ( 0x61..0x7A) | Get-Random -Count 8 | ForEach-Object { [char]$_ }))
            $commandDef = @{
                name        = "pester-JCCMDTarget_$RandomString1"
                trigger     = 'JCCMDTarget'
                commandType = 'linux'
                command     = 'test'
                launchType  = 'trigger'
                timeout     = 120
            }
            $systemGroupDef = @{
                GroupName = "PesterTest_SystemGroup_$RandomString1"
            }
            $cmd = New-JCCommand @commandDef
            Write-Host "commandName: $($cmd.name)"

            $systemGroup = New-JCSystemGroup @systemGroupDef
            Write-Host "systemGroupName: $($systemGroup.name)"

        }

        It "Removes a single system group to a JumpCloud command by GroupName" {
            $TargetAdd = Add-JCCommandTarget -CommandID $cmd.id -GroupName $systemGroup.Name
            $TargetRemove = Remove-JCCommandTarget -CommandID $cmd.id -GroupName $systemGroup.Name
            $TargetRemove.Status | Should -Be 'Removed'
        }
        It "Removes a single system group to a JumpCloud command by GroupID" {
            $TargetAdd = Add-JCCommandTarget -CommandID $cmd.id -GroupID $systemGroup.Id
            $TargetRemove = Remove-JCCommandTarget -CommandID $cmd.id -GroupID $systemGroup.id
            $TargetRemove.Status | Should -Be 'Removed'
        }
        AfterEach {
            Write-Host "removing commandName: $($cmd.name)"
            Remove-JCCommand -CommandID $cmd._id -force
            Write-Host "removing systemGroupName: $($systemGroup.name)"
            Remove-JcSdkSystemGroup -Id $systemGroup.id
        }
    }
    Context "System to Command tests" {
        BeforeEach {
            $RandomString1 = ( -join (( 0x41..0x5A) + ( 0x61..0x7A) | Get-Random -Count 8 | ForEach-Object { [char]$_ }))
            $commandDef = @{
                name        = "pester-JCCMDTarget_$RandomString1"
                trigger     = 'JCCMDTarget'
                commandType = 'linux'
                command     = 'test'
                launchType  = 'trigger'
                timeout     = 120
            }
            $systemGroupDef = @{
                GroupName = "PesterTest_SystemGroup_$RandomString1"
            }
            $cmd = New-JCCommand @commandDef
            Write-Host "commandName: $($cmd.name)"

        }
        It "Removes a single system to a JumpCloud command" {
            $TargetAdd = Add-JCCommandTarget -CommandID $cmd.id -SystemID $PesterParams_SystemLinux._id
            $TargetRemove = Remove-JCCommandTarget -CommandID $cmd.id -SystemID $PesterParams_SystemLinux._id
            $TargetRemove.Status | Should -Be 'Removed'
        }
        AfterEach {
            Write-Host "removing commandName: $($cmd.name)"
            Remove-JCCommand -CommandID $cmd._id -force
        }
    }
}