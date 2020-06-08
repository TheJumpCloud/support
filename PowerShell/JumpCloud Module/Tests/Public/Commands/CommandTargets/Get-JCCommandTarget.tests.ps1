Describe -Tag:('JCCommandTarget') 'Get-JCCommandTarget 1.3' {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force | Out-Null }
    It "Returns a JumpCloud commands system targets" {
        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_CommandID -SystemID $PesterParams_SystemID
        $TargetAdd = Add-JCCommandTarget -CommandID $PesterParams_CommandID -SystemID $PesterParams_SystemID

        $SystemTarget = Get-JCCommandTarget -CommandID $PesterParams_CommandID

        $SystemTarget.SystemID.count | Should -BeGreaterThan 0
    }

    It "Returns a JumpCloud commands group targets by groupname" {
        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_CommandID -GroupName $PesterParams_SystemGroupName
        $TargetAdd = Add-JCCommandTarget -CommandID $PesterParams_CommandID -GroupName $PesterParams_SystemGroupName

        $SystemGroupTarget = Get-JCCommandTarget -CommandID $PesterParams_CommandID -Groups

        $SystemGroupTarget.GroupID.count | Should -BeGreaterThan 0
    }

}
