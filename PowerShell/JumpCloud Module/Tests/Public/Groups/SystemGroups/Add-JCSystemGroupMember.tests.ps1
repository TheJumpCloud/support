Describe -Tag:('JCSystemGroupMember') 'Add-JCSystemGroupMember 1.0' {
    BeforeAll {
        $testGroup = New-JCSystemGroup -GroupName "pt-$(New-RandomString 8)"
    }
    It "Adds a JumpCloud system to a JumpCloud system group by System Groupname and SystemID" {

        $SingleSystemGroupRemove = Remove-JCSystemGroupMember -SystemID $PesterParams_SystemLinux._id -GroupName $testGroup.Name

        $SingleSystemGroupAdd = Add-JCSystemGroupMember -SystemID $PesterParams_SystemLinux._id -GroupName $testGroup.Name
        $SingleSystemGroupAdd.Status | Should -Be 'Added'

    }

    It "Adds a JumpCloud system to a JumpCloud system group by System GroupID and SystemID" {

        $SingleSystemGroupRemove = Remove-JCSystemGroupMember -SystemID $PesterParams_SystemLinux._id -GroupID $testGroup.Id

        $SingleSystemGroupAdd = Add-JCSystemGroupMember -SystemID $PesterParams_SystemLinux._id -GroupID $testGroup.Id
        $SingleSystemGroupAdd.Status | Should -Be 'Added'
    }


    It "Adds two JumpCloud systems to a JumpCloud system group using the pipeline" {

        $MultiSystemGroupRemove = Get-JCSystem | Select-Object -Last 2 | Remove-JCSystemGroupMember -GroupName $testGroup.Name

        $MultiSystemGroupAdd = Get-JCSystem | Select-Object -Last 2 | Add-JCSystemGroupMember -GroupName $testGroup.Name
        $MultiSystemGroupAdd.Status | Select-Object -Unique | Should -Be 'Added'
    }

    It "Adds two JumpCloud systems to a JumpCloud system group using the pipeline using -ByID" {

        $MultiSystemGroupRemove = Get-JCSystem | Select-Object -Last 2 | Remove-JCSystemGroupMember -GroupName $testGroup.Name -ByID

        $MultiSystemGroupAdd = Get-JCSystem | Select-Object -Last 2 | Add-JCSystemGroupMember -GroupName $testGroup.Name -ByID
        $MultiSystemGroupAdd.Status | Select-Object -Unique | Should -Be 'Added'
    }
    AfterAll {
        $group = Get-JCGroup -Type System -name $testGroup.Name
        Remove-JCSDKSystemGroup -id $group.id
    }

}
