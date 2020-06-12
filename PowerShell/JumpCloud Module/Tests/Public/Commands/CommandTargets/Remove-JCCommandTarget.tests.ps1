Describe -Tag:('JCCommandTarget') 'Add-JCCommandTarget 1.3' {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null }
    It "Removes a single system to a JumpCloud command" {


        $TargetAdd = Add-JCCommandTarget -CommandID $PesterParams_Command.id -SystemID $PesterParams_SystemLinux._id


        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_Command.id -SystemID $PesterParams_SystemLinux._id

        $TargetRemove.Status | Should -Be 'Removed'



    }

    It "Removes a single system group to a JumpCloud command by GroupName" {

        $TargetAdd = Add-JCCommandTarget -CommandID $PesterParams_Command.id -GroupName $PesterParams_SystemGroup.Name

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_Command.id -GroupName $PesterParams_SystemGroup.Name

        $TargetRemove.Status | Should -Be 'Removed'

    }

    It "Removes a single system group to a JumpCloud command by GroupID" {

        $TargetAdd = Add-JCCommandTarget -CommandID $PesterParams_Command.id -GroupID $PesterParams_SystemGroup.Id

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_Command.id -GroupName $PesterParams_SystemGroup.Name

        $TargetRemove.Status | Should -Be 'Removed'

    }


}
