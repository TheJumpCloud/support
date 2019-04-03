Describe 'Add-JCSystemGroupMember' {

    It "Adds a JumpCloud system to a JumpCloud system group by System Groupname and SystemID" {

        $SingleSystemGroupRemove = Remove-JCSystemGroupMember -SystemID $PesterParams.SystemID -GroupName $PesterParams.SystemGroupName

        $SingleSystemGroupAdd = Add-JCSystemGroupMember -SystemID $PesterParams.SystemID -GroupName $PesterParams.SystemGroupName
        $SingleSystemGroupAdd.Status | Should Be 'Added'

    }

    It "Adds a JumpCloud system to a JumpCloud system group by System GroupID and SystemID" {

        $SingleSystemGroupRemove = Remove-JCSystemGroupMember -SystemID $PesterParams.SystemID -GroupID $PesterParams.SystemGroupID

        $SingleSystemGroupAdd = Add-JCSystemGroupMember -SystemID $PesterParams.SystemID -GroupID $PesterParams.SystemGroupID
        $SingleSystemGroupAdd.Status | Should Be 'Added'
    }


    It "Adds two JumpCloud systems to a JumpCloud system group using the pipeline" {

        $MultiSystemGroupRemove = Get-JCSystem | Select-Object -Last 2 | Remove-JCSystemGroupMember -GroupName $PesterParams.SystemGroupName

        $MultiSystemGroupAdd = Get-JCSystem | Select-Object -Last 2 | Add-JCSystemGroupMember -GroupName $PesterParams.SystemGroupName
        $MultiSystemGroupAdd.Status | Select-Object -Unique | Should Be 'Added'
    }

    It "Adds two JumpCloud systems to a JumpCloud system group using the pipeline using -ByID" {

        $MultiSystemGroupRemove = Get-JCSystem | Select-Object -Last 2 | Remove-JCSystemGroupMember -GroupName $PesterParams.SystemGroupName -ByID

        $MultiSystemGroupAdd = Get-JCSystem | Select-Object -Last 2 | Add-JCSystemGroupMember -GroupName $PesterParams.SystemGroupName -ByID
        $MultiSystemGroupAdd.Status | Select-Object -Unique | Should Be 'Added'
    }

}
