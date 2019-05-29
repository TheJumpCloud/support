Connect-JCOnlineTest

Describe -Tag:('JCCommandTarget') 'Add-JCCommandTarget 1.3' {

    It "Adds a single system to a JupmCloud command" {

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams.CommandID -SystemID $PesterParams.SystemID

        $TargetAdd = Add-JCCommandTarget -CommandID $PesterParams.CommandID -SystemID $PesterParams.SystemID

        $TargetAdd.Status | Should -Be 'Added'

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams.CommandID -SystemID $PesterParams.SystemID


    }

    It "Adds a single system group to a JupmCloud command by GroupName" {

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams.CommandID -GroupName $PesterParams.SystemGroupName

        $TargetAdd = Add-JCCommandTarget -CommandID $PesterParams.CommandID -GroupName $PesterParams.SystemGroupName

        $TargetAdd.Status | Should -Be 'Added'

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams.CommandID -GroupName $PesterParams.SystemGroupName


    }

    It "Adds a single system group to a JupmCloud command by GroupID" {

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams.CommandID -GroupName $PesterParams.SystemGroupName

        $TargetAdd = Add-JCCommandTarget -CommandID $PesterParams.CommandID -GroupID $PesterParams.SystemGroupID

        $TargetAdd.Status | Should -Be 'Added'

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams.CommandID -GroupName $PesterParams.SystemGroupName


    }




}
