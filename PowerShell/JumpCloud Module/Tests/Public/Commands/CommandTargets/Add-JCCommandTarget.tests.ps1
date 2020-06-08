Describe -Tag:('JCCommandTarget') 'Add-JCCommandTarget 1.3' {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force | Out-Null }
    It "Adds a single system to a JumpCloud command" {

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_CommandID -SystemID $PesterParams_SystemID

        $TargetAdd = Add-JCCommandTarget -CommandID $PesterParams_CommandID -SystemID $PesterParams_SystemID

        $TargetAdd.Status | Should -Be 'Added'

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_CommandID -SystemID $PesterParams_SystemID


    }

    It "Adds a single system group to a JumpCloud command by GroupName" {

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_CommandID -GroupName $PesterParams_SystemGroupName

        $TargetAdd = Add-JCCommandTarget -CommandID $PesterParams_CommandID -GroupName $PesterParams_SystemGroupName

        $TargetAdd.Status | Should -Be 'Added'

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_CommandID -GroupName $PesterParams_SystemGroupName


    }

    It "Adds a single system group to a JumpCloud command by GroupID" {

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_CommandID -GroupName $PesterParams_SystemGroupName

        $TargetAdd = Add-JCCommandTarget -CommandID $PesterParams_CommandID -GroupID $PesterParams_SystemGroupID

        $TargetAdd.Status | Should -Be 'Added'

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_CommandID -GroupName $PesterParams_SystemGroupName


    }




}
