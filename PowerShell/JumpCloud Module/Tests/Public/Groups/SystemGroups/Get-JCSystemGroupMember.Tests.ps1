Describe -Tag:('JCSystemGroupMember') 'Get-JCSystemGroupMember 1.0' {
    BeforeEach {
        $string = "sysGroup_" + $(New-RandomString -NumberOfChars 5)
        $pesterTest_NewSysGroup = @{
            GroupName = $string
        }
        $pesterTest_NewSysGroup = New-JCSystemGroup @pesterTest_NewSysGroup
    }
    AfterEach {
        Remove-JCSystemGroup -GroupName $pesterTest_NewSysGroup.Name -force
    }
    It 'Gets a System Groups membership by Groupname' {
        Write-Host "Adding members to $($PesterTest_NewSysGroup.Name)"
        $MultiSystemGroupAdd = Get-JCSystem | Select-Object -Last 2 | Add-JCSystemGroupMember -GroupName $pesterTest_NewSysGroup.Name
        $SystemGroupMembers = Get-JCSystemGroupMember -GroupName $pesterTest_NewSysGroup.Name
        $SystemGroupMembers.SystemID.Count | Should -BeGreaterThan 0
    }

    It 'Gets a System Groups membership -ByID' {
        Write-Host "Adding members to $($PesterTest_NewSysGroup.Name)"
        $MultiSystemGroupAdd = Get-JCSystem | Select-Object -Last 2 | Add-JCSystemGroupMember -GroupID $pesterTest_NewSysGroup.Id
        $SystemGroupMembers = Get-JCSystemGroupMember -ByID $pesterTest_NewSysGroup.Id
        $SystemGroupMembers.SystemID.Count | Should -BeGreaterThan 0
    }

    It 'Gets all System Group members using Get-JCGroup -type system and the pipeline' {
        Write-Host "Adding members to $($PesterTest_NewSysGroup.Name)"
        $MultiSystemGroupAdd = Get-JCSystem | Select-Object -Last 2 | Add-JCSystemGroupMember -GroupID $pesterTest_NewSysGroup.Id
        $AllSystemGroupmembers = Get-JCGroup -Type System -Name $pesterTest_NewSysGroup.Name | Get-JCSystemGroupMember
        $AllSystemGroupmembers.GroupName.Count | Should -BeGreaterThan 1
    }

}
