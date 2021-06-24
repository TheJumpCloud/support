Describe -Tag:('JCCommandTarget') 'Get-JCCommandTarget 1.3' {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null }
    It "Returns a JumpCloud commands system targets" {
        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_Command1.id -SystemID $PesterParams_SystemLinux._id
        $TargetAdd = Add-JCCommandTarget -CommandID $PesterParams_Command1.id -SystemID $PesterParams_SystemLinux._id

        $SystemTarget = Get-JCCommandTarget -CommandID $PesterParams_Command1.id

        $SystemTarget.SystemID.count | Should -BeGreaterThan 0
    }

    It "Returns a JumpCloud commands group targets by groupname" {
        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_Command1.id -GroupName $PesterParams_SystemGroup.Name
        $TargetAdd = Add-JCCommandTarget -CommandID $PesterParams_Command1.id -GroupName $PesterParams_SystemGroup.Name

        $SystemGroupTarget = Get-JCCommandTarget -CommandID $PesterParams_Command1.id -Groups

        $SystemGroupTarget.GroupID.count | Should -BeGreaterThan 0
    }

}
