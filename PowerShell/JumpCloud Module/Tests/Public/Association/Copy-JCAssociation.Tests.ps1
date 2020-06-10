BeforeAll {
    $Users = Get-JCObject -Type:('user') -Fields:('_id', 'username') -limit:(2)
    $SourceUser = $Users[0]
    $TargetUser = $Users[1]
    # Remove all associations from target user
    $TargetUser | Get-JCAssociation | Remove-JCAssociation -force
}
Describe -Tag:('JCAssociation') "Copy-JCAssociation Tests" {
    Context ('Copy the associations of a user to another user ById.') {
        It("Associations should be the same.") {
            # Copy-JCAssociation -Type:('user') -Id:($SourceUser._id) -TargetId:($TargetUser._id) -Force
            # ($SourceUser | Get-JCAssociation | Select-Object -Property:('associationType', 'type', 'targetId', 'targetType', 'compiledAttributes') | ConvertTo-Json ) | Should -Be ($TargetUser | Get-JCAssociation | Select-Object -Property:('associationType', 'type', 'targetId', 'targetType', 'compiledAttributes') | ConvertTo-Json )
        }
    }
    # Remove all associations from target user
    # $TargetUser | Get-JCAssociation | Remove-JCAssociation -force
    Context ('Copy the associations of a user to another user ByName.') {
        It("Associations should be the same.") {
            # Copy-JCAssociation -Type:('user') -Name:($SourceUser.username) -TargetName:($TargetUser.username) -Force
            # ($SourceUser | Get-JCAssociation | Select-Object -Property:('associationType', 'type', 'targetId', 'targetType', 'compiledAttributes') | ConvertTo-Json ) | Should -Be ($TargetUser | Get-JCAssociation | Select-Object -Property:('associationType', 'type', 'targetId', 'targetType', 'compiledAttributes') | ConvertTo-Json )
        }
    }
}
