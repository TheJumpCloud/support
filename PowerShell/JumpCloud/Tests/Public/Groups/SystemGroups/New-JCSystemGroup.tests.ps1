Describe -Tag:('JCSystemGroup') 'New-JCSystemGroup 1.0' {
    BeforeAll {
        Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null
        If (Get-JCGroup -Type:('System') | Where-Object { $_.name -eq $PesterParams_SystemGroup.Name })
        {
            Remove-JCSystemGroup -GroupName:($PesterParams_SystemGroup.Name) -force
        }
    }
    It "Creates a new system group" {
        $NewG = New-JCSystemGroup -GroupName $PesterParams_SystemGroup.Name
        $NewG.Result | Should -Be 'Created'
        $DeletedG = Remove-JCSystemGroup -GroupName $NewG.name  -force
    }

}
