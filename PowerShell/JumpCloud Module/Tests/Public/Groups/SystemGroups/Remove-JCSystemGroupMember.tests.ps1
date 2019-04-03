Describe 'Add-JCSystemGroupMember and Remove-JCSystemGroupmember' {


    It "Removes a JumpCloud system from a JumpCloud system group by System Groupname and SystemID" {

        $SingleSystemGroupAdd = Add-JCSystemGroupMember -SystemID $PesterParams.SystemID -GroupName $PesterParams.SystemGroupName

        $SingleSystemGroupRemove = Remove-JCSystemGroupMember -SystemID $PesterParams.SystemID -GroupName $PesterParams.SystemGroupName
        $SingleSystemGroupRemove.Status | Should Be 'Removed'

    }


    It "Removes a JumpCloud system from a JumpCloud system group by System GroupID and SystemID" {

        $SingleSystemGroupAdd = Add-JCSystemGroupMember -SystemID $PesterParams.SystemID -GroupID $PesterParams.SystemGroupID

        $SingleSystemGroupRemove = Remove-JCSystemGroupMember -SystemID $PesterParams.SystemID -GroupID $PesterParams.SystemGroupID
        $SingleSystemGroupRemove.Status | Should Be 'Removed'

    }


    It "Removes two JumpCloud systems from a JumpCloud system group using the pipeline" {

        $MultiSystemGroupAdd = Get-JCSystem | Select-Object -Last 2 | Add-JCSystemGroupMember -GroupName $PesterParams.SystemGroupName

        $MultiSystemGroupRemove = Get-JCSystem | Select-Object -Last 2 | Remove-JCSystemGroupMember -GroupName $PesterParams.SystemGroupName
        $MultiSystemGroupRemove.Status | Select-Object -Unique | Should Be 'Removed'

    }



    It "Removes two JumpCloud systems from a JumpCloud system group using the pipeline using -ByID" {

        $MultiSystemGroupAdd = Get-JCSystem | Select-Object -Last 2 | Add-JCSystemGroupMember -GroupName $PesterParams.SystemGroupName -ByID

        $MultiSystemGroupRemove = Get-JCSystem | Select-Object -Last 2 | Remove-JCSystemGroupMember -GroupName $PesterParams.SystemGroupName -ByID
        $MultiSystemGroupRemove.Status | Select-Object -Unique | Should Be 'Removed'

    }


}