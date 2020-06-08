Describe -Tag:('JCSystemGroupMember') 'Remove-JCSystemGroupMember 1.0' {
    Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force | Out-Null
    It "Removes a JumpCloud system from a JumpCloud system group by System Groupname and SystemID" {

        $SingleSystemGroupAdd = Add-JCSystemGroupMember -SystemID $PesterParams_SystemID -GroupName $PesterParams_SystemGroupName

        $SingleSystemGroupRemove = Remove-JCSystemGroupMember -SystemID $PesterParams_SystemID -GroupName $PesterParams_SystemGroupName
        $SingleSystemGroupRemove.Status | Should Be 'Removed'

    }


    It "Removes a JumpCloud system from a JumpCloud system group by System GroupID and SystemID" {

        $SingleSystemGroupAdd = Add-JCSystemGroupMember -SystemID $PesterParams_SystemID -GroupID $PesterParams_SystemGroupID

        $SingleSystemGroupRemove = Remove-JCSystemGroupMember -SystemID $PesterParams_SystemID -GroupID $PesterParams_SystemGroupID
        $SingleSystemGroupRemove.Status | Should Be 'Removed'

    }


    It "Removes two JumpCloud systems from a JumpCloud system group using the pipeline" {

        $MultiSystemGroupAdd = Get-JCSystem | Select-Object -Last 2 | Add-JCSystemGroupMember -GroupName $PesterParams_SystemGroupName

        $MultiSystemGroupRemove = Get-JCSystem | Select-Object -Last 2 | Remove-JCSystemGroupMember -GroupName $PesterParams_SystemGroupName
        $MultiSystemGroupRemove.Status | Select-Object -Unique | Should Be 'Removed'

    }



    It "Removes two JumpCloud systems from a JumpCloud system group using the pipeline using -ByID" {

        $MultiSystemGroupAdd = Get-JCSystem | Select-Object -Last 2 | Add-JCSystemGroupMember -GroupName $PesterParams_SystemGroupName -ByID

        $MultiSystemGroupRemove = Get-JCSystem | Select-Object -Last 2 | Remove-JCSystemGroupMember -GroupName $PesterParams_SystemGroupName -ByID
        $MultiSystemGroupRemove.Status | Select-Object -Unique | Should Be 'Removed'

    }


}
