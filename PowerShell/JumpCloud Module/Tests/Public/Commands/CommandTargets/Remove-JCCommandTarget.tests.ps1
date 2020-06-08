Describe -Tag:('JCCommandTarget') 'Add-JCCommandTarget 1.3' {
    Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force | Out-Null
    It "Removes a single system to a JumpCloud command" {


        $TargetAdd = Add-JCCommandTarget -CommandID $PesterParams_CommandID -SystemID $PesterParams_SystemID


        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_CommandID -SystemID $PesterParams_SystemID

        $TargetRemove.Status | Should -Be 'Removed'



    }

    It "Removes a single system group to a JumpCloud command by GroupName" {

        $TargetAdd = Add-JCCommandTarget -CommandID $PesterParams_CommandID -GroupName $PesterParams_SystemGroupName

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_CommandID -GroupName $PesterParams_SystemGroupName

        $TargetRemove.Status | Should -Be 'Removed'

    }

    It "Removes a single system group to a JumpCloud command by GroupID" {

        $TargetAdd = Add-JCCommandTarget -CommandID $PesterParams_CommandID -GroupID $PesterParams_SystemGroupID

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_CommandID -GroupName $PesterParams_SystemGroupName

        $TargetRemove.Status | Should -Be 'Removed'

    }


}
