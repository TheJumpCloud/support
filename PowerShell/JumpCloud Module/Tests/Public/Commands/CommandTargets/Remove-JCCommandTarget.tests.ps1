Describe -Tag:('JCCommandTarget') 'Add-JCCommandTarget 1.3' {
    BeforeAll {
        Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null
        $PesterParams_Command1 = Get-JCCommand -CommandID:($PesterParams_Command1.Id)
        If (-not $PesterParams_Command1)
        {
            $PesterParams_Command1 = New-JCCommand @PesterParams_NewCommand1
        }
        $PesterParams_SystemGroup = Get-JCGroup -Type:('System') | Where-Object { $_.name -eq $PesterParams_SystemGroup.Name }
        If (-not $PesterParams_SystemGroup)
        {
            $PesterParams_SystemGroup = New-JCSystemGroup @PesterParams_NewSystemGroup
        }
    }
    It "Removes a single system to a JumpCloud command" {
        $TargetAdd = Add-JCCommandTarget -CommandID $PesterParams_Command1.id -SystemID $PesterParams_SystemLinux._id
        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_Command1.id -SystemID $PesterParams_SystemLinux._id
        $TargetRemove.Status | Should -Be 'Removed'
    }
    It "Removes a single system group to a JumpCloud command by GroupName" {
        $TargetAdd = Add-JCCommandTarget -CommandID $PesterParams_Command1.id -GroupName $PesterParams_SystemGroup.Name
        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_Command1.id -GroupName $PesterParams_SystemGroup.Name
        $TargetRemove.Status | Should -Be 'Removed'
    }
    It "Removes a single system group to a JumpCloud command by GroupID" {
        $TargetAdd = Add-JCCommandTarget -CommandID $PesterParams_Command1.id -GroupID $PesterParams_SystemGroup.Id
        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_Command1.id -GroupName $PesterParams_SystemGroup.Name
        $TargetRemove.Status | Should -Be 'Removed'
    }
}
