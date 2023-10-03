Describe -Tag:('JCSystemGroupMember') 'Remove-JCSystemGroupMember 1.0' {
    BeforeAll {
        Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null
        $System = Get-JCSystem -SystemID:($PesterParams_SystemLinux._id)
        $SystemGroup = If (-not (Get-JCGroup -Type:('System') | Where-Object { $_.name -eq $PesterParams_SystemGroup.Name })) {
            New-JCSystemGroup -GroupName:($PesterParams_SystemGroup.Name)
        } Else {
            $null = Remove-JCSystemGroup -GroupName:($PesterParams_SystemGroup.Name) -force
            New-JCSystemGroup -GroupName:($PesterParams_SystemGroup.Name)
        }
        If (Get-JCSystemGroupMember -GroupName:($SystemGroup.Name) | Where-Object { $_.SystemID -eq $System.id }) {
            Remove-JCSystemGroupMember -SystemID:($System.id) -GroupName:($SystemGroup.Name) -fo
        }
    }
    It "Removes a JumpCloud system from a JumpCloud system group by System Groupname and SystemID" {
        $SingleSystemGroupAdd = Add-JCSystemGroupMember -SystemID $System.id -GroupName $SystemGroup.Name
        $SingleSystemGroupRemove = Remove-JCSystemGroupMember -SystemID $System.id -GroupName $SystemGroup.Name
        $SingleSystemGroupRemove.Status | Should -Be 'Removed'
    }
    It "Removes a JumpCloud system from a JumpCloud system group by System GroupID and SystemID" {
        $SingleSystemGroupAdd = Add-JCSystemGroupMember -SystemID $System.id -GroupID $SystemGroup.Id
        $SingleSystemGroupRemove = Remove-JCSystemGroupMember -SystemID $System.id -GroupID $SystemGroup.Id
        $SingleSystemGroupRemove.Status | Should -Be 'Removed'
    }
    It "Removes two JumpCloud systems from a JumpCloud system group using the pipeline" {
        $MultiSystemGroupAdd = Get-JCSystem | Select-Object -Last 2 | Add-JCSystemGroupMember -GroupName $SystemGroup.Name
        $MultiSystemGroupRemove = Get-JCSystem | Select-Object -Last 2 | Remove-JCSystemGroupMember -GroupName $SystemGroup.Name
        $MultiSystemGroupRemove.Status | Select-Object -Unique | Should -Be 'Removed'
    }
    It "Removes two JumpCloud systems from a JumpCloud system group using the pipeline using -ByID" {
        $MultiSystemGroupAdd = Get-JCSystem | Select-Object -Last 2 | Add-JCSystemGroupMember -GroupName $SystemGroup.Name -ByID
        $MultiSystemGroupRemove = Get-JCSystem | Select-Object -Last 2 | Remove-JCSystemGroupMember -GroupName $SystemGroup.Name -ByID
        $MultiSystemGroupRemove.Status | Select-Object -Unique | Should -Be 'Removed'
    }
}
