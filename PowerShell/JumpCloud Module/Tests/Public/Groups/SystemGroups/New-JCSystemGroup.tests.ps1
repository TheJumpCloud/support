Describe -Tag:('JCSystemGroup') 'New-JCSystemGroup 1.0' {
    BeforeAll {
        Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null
        If (Get-JCGroup -Type:('System') | Where-Object { $_.name -eq $PesterParams_SystemGroupName })
        {
            Remove-JCSystemGroup -GroupName:($PesterParams_SystemGroupName) -force
        }
    }
    It "Creates a new system group" {
        $NewG = New-JCSystemGroup -GroupName $PesterParams_SystemGroupName
        $NewG.Result | Should -Be 'Created'
        $DeletedG = Remove-JCSystemGroup -GroupName $NewG.name  -force
    }

}
