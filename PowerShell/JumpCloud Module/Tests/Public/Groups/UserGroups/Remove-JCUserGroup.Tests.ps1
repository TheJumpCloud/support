Describe -Tag:('JCUserGroup') 'New-JCUserGroup 1.0' {
    context 'Using the default parameter set' {
        It "Creates a new user group by Name" {
            $NewG = New-JCUserGroup -GroupName $(New-RandomString 8)
            $DeletedG = Remove-JCUserGroup -GroupName $NewG.name  -force
            $DeletedG.Result | Should -Be 'Deleted'
        }
        It "Creates a new user groupby ID" {
            $NewG = New-JCUserGroup -GroupName $(New-RandomString 8)
            $DeletedG = Remove-JCUserGroup -GroupId $NewG.id  -force
            $DeletedG.Result | Should -Be 'Deleted'
        }
    }
    Context 'Using pipeline input' {
        It "Removes a user group by Name" {
            $NewG = New-JCUserGroup -GroupName $(New-RandomString 8)
            $DeletedG = $NewG | Remove-JCUserGroup -force
            $DeletedG.Result | Should -Be 'Deleted'
        }
    }
}

