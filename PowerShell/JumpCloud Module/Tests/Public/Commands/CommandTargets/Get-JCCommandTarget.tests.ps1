Describe -Tag:('JCCommandTarget') 'Get-JCCommandTarget 1.3' {
    Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force | Out-Null
    It "Returns a JumpCloud commands system targets" {
        $TargetAdd = Add-JCCommandTarget -CommandID $PesterParams.CommandID -SystemID $PesterParams.SystemID

        $SystemTarget = Get-JCCommandTarget -CommandID $PesterParams.CommandID

        $SystemTarget.SystemID.count | Should -BeGreaterThan 0

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams.CommandID -SystemID $PesterParams.SystemID
    }

    It "Returns a JumpCloud commands group targets by groupname" {
        $TargetAdd = Add-JCCommandTarget -CommandID $PesterParams.CommandID -GroupName $PesterParams.SystemGroupName

        $SystemGroupTarget = Get-JCCommandTarget -CommandID $PesterParams.CommandID -Groups

        $SystemGroupTarget.GroupID.count | Should -BeGreaterThan 0

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams.CommandID -GroupName $PesterParams.SystemGroupName
    }

}
