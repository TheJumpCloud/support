Describe -Tag:('JCCommandTarget') 'Add-JCCommandTarget 1.3' {
    BeforeAll {
        $PesterParams_Command1 = Get-JCCommand -CommandID:($PesterParams_Command1.Id)
        If (-not $PesterParams_Command1) {
            $PesterParams_Command1 = New-JCCommand @PesterParams_NewCommand1
        }
        # System Group Definition:
        $CmdTargetSystemGroup = @{
            'GroupName' = "PesterTest_CmdTargetGroup_$(New-RandomString -NumberOfChars 5)"
        };
        $SystemGroupForCmdTarget = Get-JCGroup -Type:('System') | Where-Object { $_.name -match "PesterTest_CmdTargetGroup" }
        If (-not $SystemGroupForCmdTarget) {
            $SystemGroupForCmdTarget = New-JCSystemGroup @CmdTargetSystemGroup
        }
    }
    AfterAll {
        Remove-JCSystemGroup -GroupName $SystemGroupForCmdTarget.Name -force
    }
    It "Adds a single system to a JumpCloud command" {

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_Command1.id -SystemID $PesterParams_SystemLinux._id

        $TargetAdd = Add-JCCommandTarget -CommandID $PesterParams_Command1.id -SystemID $PesterParams_SystemLinux._id

        $TargetAdd.Status | Should -Be 'Added'

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_Command1.id -SystemID $PesterParams_SystemLinux._id


    }

    It "Adds a single system group to a JumpCloud command by GroupName" {

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_Command1.id -GroupName $SystemGroupForCmdTarget.Name

        $TargetAdd = Add-JCCommandTarget -CommandID $PesterParams_Command1.id -GroupName $SystemGroupForCmdTarget.Name

        $TargetAdd.Status | Should -Be 'Added'

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_Command1.id -GroupName $SystemGroupForCmdTarget.Name


    }

    It "Adds a single system group to a JumpCloud command by GroupID" {

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_Command1.id -GroupName $SystemGroupForCmdTarget.Name

        $TargetAdd = Add-JCCommandTarget -CommandID $PesterParams_Command1.id -GroupID $SystemGroupForCmdTarget.Id

        $TargetAdd.Status | Should -Be 'Added'

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_Command1.id -GroupName $SystemGroupForCmdTarget.Name


    }




}
