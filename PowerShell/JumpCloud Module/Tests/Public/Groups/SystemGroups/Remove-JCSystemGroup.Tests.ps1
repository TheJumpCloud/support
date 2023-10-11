Describe -Tag:('JCSystemGroup') 'Remove-JCSystemGroup 1.0' {
    Context 'Using the default parameter set' {

        It "Removes a system group by Name" {
            $NewG = New-JCSystemGroup -GroupName $(New-RandomString 8)
            $DeletedG = Remove-JCSystemGroup -GroupName $NewG.name  -force
            $DeletedG.Result | Should -Be 'Deleted'
        }
        It "Removes a system group by ID" {
            $NewG = New-JCSystemGroup -GroupName $(New-RandomString 8)
            $DeletedG = Remove-JCSystemGroup -GroupId $NewG.id  -force
            $DeletedG.Result | Should -Be 'Deleted'
        }
    }
    Context 'Using pipeline input' {
        It "Removes a system group by Name" {
            $NewG = New-JCSystemGroup -GroupName $(New-RandomString 8)
            $DeletedG = $NewG | Remove-JCSystemGroup -force
            $DeletedG.Result | Should -Be 'Deleted'
        }
    }
}