Describe -Tag:('JCCommandTarget') 'Add-JCCommandTarget 1.3' {
    BeforeAll {
        Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null
        If (-not (Get-JCCommand -CommandID:($PesterParams_Command1.Id)))
        {
            $PesterParams_Command1 = New-JCCommand @PesterParams_NewCommand1
        }
        If (-not (Get-JCGroup -Type:('System') | Where-Object { $_.name -eq $PesterParams_SystemGroup.Name }))
        {
            $PesterParams_SystemGroup = New-JCSystemGroup @PesterParams_NewSystemGroup
        }
    }
    It "Adds a single system to a JumpCloud command" {

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_Command1.id -SystemID $PesterParams_SystemLinux._id

        $TargetAdd = Add-JCCommandTarget -CommandID $PesterParams_Command1.id -SystemID $PesterParams_SystemLinux._id

        $TargetAdd.Status | Should -Be 'Added'

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_Command1.id -SystemID $PesterParams_SystemLinux._id


    }

    It "Adds a single system group to a JumpCloud command by GroupName" {

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_Command1.id -GroupName $PesterParams_SystemGroup.Name

        $TargetAdd = Add-JCCommandTarget -CommandID $PesterParams_Command1.id -GroupName $PesterParams_SystemGroup.Name

        $TargetAdd.Status | Should -Be 'Added'

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_Command1.id -GroupName $PesterParams_SystemGroup.Name


    }

    It "Adds a single system group to a JumpCloud command by GroupID" {

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_Command1.id -GroupName $PesterParams_SystemGroup.Name

        $TargetAdd = Add-JCCommandTarget -CommandID $PesterParams_Command1.id -GroupID $PesterParams_SystemGroup.Id

        $TargetAdd.Status | Should -Be 'Added'

        $TargetRemove = Remove-JCCommandTarget -CommandID $PesterParams_Command1.id -GroupName $PesterParams_SystemGroup.Name


    }




}
