Describe -Tag:('JCSystemGroupMember') 'Add-JCSystemGroupMember 1.0' {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force | Out-Null }
    It "Adds a JumpCloud system to a JumpCloud system group by System Groupname and SystemID" {

        $SingleSystemGroupRemove = Remove-JCSystemGroupMember -SystemID $PesterParams_SystemID -GroupName $PesterParams_SystemGroupName

        $SingleSystemGroupAdd = Add-JCSystemGroupMember -SystemID $PesterParams_SystemID -GroupName $PesterParams_SystemGroupName
        $SingleSystemGroupAdd.Status | Should Be 'Added'

    }

    It "Adds a JumpCloud system to a JumpCloud system group by System GroupID and SystemID" {

        $SingleSystemGroupRemove = Remove-JCSystemGroupMember -SystemID $PesterParams_SystemID -GroupID $PesterParams_SystemGroupID

        $SingleSystemGroupAdd = Add-JCSystemGroupMember -SystemID $PesterParams_SystemID -GroupID $PesterParams_SystemGroupID
        $SingleSystemGroupAdd.Status | Should Be 'Added'
    }


    It "Adds two JumpCloud systems to a JumpCloud system group using the pipeline" {

        $MultiSystemGroupRemove = Get-JCSystem | Select-Object -Last 2 | Remove-JCSystemGroupMember -GroupName $PesterParams_SystemGroupName

        $MultiSystemGroupAdd = Get-JCSystem | Select-Object -Last 2 | Add-JCSystemGroupMember -GroupName $PesterParams_SystemGroupName
        $MultiSystemGroupAdd.Status | Select-Object -Unique | Should Be 'Added'
    }

    It "Adds two JumpCloud systems to a JumpCloud system group using the pipeline using -ByID" {

        $MultiSystemGroupRemove = Get-JCSystem | Select-Object -Last 2 | Remove-JCSystemGroupMember -GroupName $PesterParams_SystemGroupName -ByID

        $MultiSystemGroupAdd = Get-JCSystem | Select-Object -Last 2 | Add-JCSystemGroupMember -GroupName $PesterParams_SystemGroupName -ByID
        $MultiSystemGroupAdd.Status | Select-Object -Unique | Should Be 'Added'
    }

}
