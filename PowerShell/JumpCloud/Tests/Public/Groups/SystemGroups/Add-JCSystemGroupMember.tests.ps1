Describe -Tag:('JCSystemGroupMember') 'Add-JCSystemGroupMember 1.0' {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null }
    It "Adds a JumpCloud system to a JumpCloud system group by System Groupname and SystemID" {

        $SingleSystemGroupRemove = Remove-JCSystemGroupMember -SystemID $PesterParams_SystemLinux._id -GroupName $PesterParams_SystemGroup.Name

        $SingleSystemGroupAdd = Add-JCSystemGroupMember -SystemID $PesterParams_SystemLinux._id -GroupName $PesterParams_SystemGroup.Name
        $SingleSystemGroupAdd.Status | Should -Be 'Added'

    }

    It "Adds a JumpCloud system to a JumpCloud system group by System GroupID and SystemID" {

        $SingleSystemGroupRemove = Remove-JCSystemGroupMember -SystemID $PesterParams_SystemLinux._id -GroupID $PesterParams_SystemGroup.Id

        $SingleSystemGroupAdd = Add-JCSystemGroupMember -SystemID $PesterParams_SystemLinux._id -GroupID $PesterParams_SystemGroup.Id
        $SingleSystemGroupAdd.Status | Should -Be 'Added'
    }


    It "Adds two JumpCloud systems to a JumpCloud system group using the pipeline" {

        $MultiSystemGroupRemove = Get-JCSystem | Select-Object -Last 2 | Remove-JCSystemGroupMember -GroupName $PesterParams_SystemGroup.Name

        $MultiSystemGroupAdd = Get-JCSystem | Select-Object -Last 2 | Add-JCSystemGroupMember -GroupName $PesterParams_SystemGroup.Name
        $MultiSystemGroupAdd.Status | Select-Object -Unique | Should -Be 'Added'
    }

    It "Adds two JumpCloud systems to a JumpCloud system group using the pipeline using -ByID" {

        $MultiSystemGroupRemove = Get-JCSystem | Select-Object -Last 2 | Remove-JCSystemGroupMember -GroupName $PesterParams_SystemGroup.Name -ByID

        $MultiSystemGroupAdd = Get-JCSystem | Select-Object -Last 2 | Add-JCSystemGroupMember -GroupName $PesterParams_SystemGroup.Name -ByID
        $MultiSystemGroupAdd.Status | Select-Object -Unique | Should -Be 'Added'
    }

}
