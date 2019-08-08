Describe -Tag:('JCCommandTarget') 'Get-JCCommandTarget 1.3' {
    Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force | Out-Null
    It "Returns a JumpCloud commands system targets" {

        $SystemTarget = Get-JCCommandTarget -CommandID $PesterParams.CommandID

        $SystemTarget.SystemID.count | Should -BeGreaterThan 0
    }

    It "Returns a JumpCloud commands group targets by groupname" {

        $SystemGroupTarget = Get-JCCommandTarget -CommandID $PesterParams.CommandID -Groups

        $SystemGroupTarget.GroupID.count | Should -BeGreaterThan 0

    }

}
