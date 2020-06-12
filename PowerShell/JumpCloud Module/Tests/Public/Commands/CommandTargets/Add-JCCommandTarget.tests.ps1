Describe -Tag:('JCCommandTarget') 'Add-JCCommandTarget 1.3' {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null }
    It "Adds a single system to a JumpCloud command" {

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_Command.id -SystemID $PesterParams_SystemLinux._id

        $TargetAdd = Add-JCCommandTarget -CommandID $PesterParams_Command.id -SystemID $PesterParams_SystemLinux._id

        $TargetAdd.Status | Should -Be 'Added'

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_Command.id -SystemID $PesterParams_SystemLinux._id


    }

    It "Adds a single system group to a JumpCloud command by GroupName" {

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_Command.id -GroupName $PesterParams_SystemGroup.Name

        $TargetAdd = Add-JCCommandTarget -CommandID $PesterParams_Command.id -GroupName $PesterParams_SystemGroup.Name

        $TargetAdd.Status | Should -Be 'Added'

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_Command.id -GroupName $PesterParams_SystemGroup.Name


    }

    It "Adds a single system group to a JumpCloud command by GroupID" {

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_Command.id -GroupName $PesterParams_SystemGroup.Name

        $TargetAdd = Add-JCCommandTarget -CommandID $PesterParams_Command.id -GroupID $PesterParams_SystemGroup.Id

        $TargetAdd.Status | Should -Be 'Added'

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_Command.id -GroupName $PesterParams_SystemGroup.Name


    }




}
