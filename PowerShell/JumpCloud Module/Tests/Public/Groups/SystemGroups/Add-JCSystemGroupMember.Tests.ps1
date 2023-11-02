Describe -Tag:('JCSystemGroupMember') 'Add-JCSystemGroupMember 1.0' {
    BeforeAll {
        # System Group Definition:
        $SystemMemberGroup = @{
            'GroupName' = "PesterTest_SysMember_$(New-RandomString -NumberOfChars 5)"
        };
        $SystemMemberGroupForMemberTests = Get-JCGroup -Type:('System') | Where-Object { $_.name -match "PesterTest_SysMember_" }
        If (-not $SystemMemberGroupForMemberTests) {
            $SystemMemberGroupForMemberTests = New-JCSystemGroup @SystemMemberGroup
        }
    }
    AfterAll {
        Remove-JCSystemGroup -GroupName $SystemMemberGroupForMemberTests.Name -force
    }
    It "Adds a JumpCloud system to a JumpCloud system group by System Groupname and SystemID" {

        $SingleSystemGroupRemove = Remove-JCSystemGroupMember -SystemID $PesterParams_SystemLinux._id -GroupName $SystemMemberGroupForMemberTests.Name

        $SingleSystemGroupAdd = Add-JCSystemGroupMember -SystemID $PesterParams_SystemLinux._id -GroupName $SystemMemberGroupForMemberTests.Name
        $SingleSystemGroupAdd.Status | Should -Be 'Added'

    }

    It "Adds a JumpCloud system to a JumpCloud system group by System GroupID and SystemID" {

        $SingleSystemGroupRemove = Remove-JCSystemGroupMember -SystemID $PesterParams_SystemLinux._id -GroupID $SystemMemberGroupForMemberTests.Id

        $SingleSystemGroupAdd = Add-JCSystemGroupMember -SystemID $PesterParams_SystemLinux._id -GroupID $SystemMemberGroupForMemberTests.Id
        $SingleSystemGroupAdd.Status | Should -Be 'Added'
    }


    It "Adds two JumpCloud systems to a JumpCloud system group using the pipeline" {

        $MultiSystemGroupRemove = Get-JCSystem | Select-Object -Last 2 | Remove-JCSystemGroupMember -GroupName $SystemMemberGroupForMemberTests.Name

        $MultiSystemGroupAdd = Get-JCSystem | Select-Object -Last 2 | Add-JCSystemGroupMember -GroupName $SystemMemberGroupForMemberTests.Name
        $MultiSystemGroupAdd.Status | Select-Object -Unique | Should -Be 'Added'
    }

    It "Adds two JumpCloud systems to a JumpCloud system group using the pipeline using -ByID" {

        $MultiSystemGroupRemove = Get-JCSystem | Select-Object -Last 2 | Remove-JCSystemGroupMember -GroupName $SystemMemberGroupForMemberTests.Name -ByID

        $MultiSystemGroupAdd = Get-JCSystem | Select-Object -Last 2 | Add-JCSystemGroupMember -GroupName $SystemMemberGroupForMemberTests.Name -ByID
        $MultiSystemGroupAdd.Status | Select-Object -Unique | Should -Be 'Added'
    }

}
