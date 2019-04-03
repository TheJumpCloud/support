Describe 'Remove-JCSystemGroup' {

    It "Removes a system group" {
        $NewG = New-JCSystemGroup -GroupName $(New-RandomString 8)
        $DeletedG = Remove-JCSystemGroup -GroupName $NewG.name  -force
        $DeletedG.Result | Should -Be 'Deleted'

    }

}