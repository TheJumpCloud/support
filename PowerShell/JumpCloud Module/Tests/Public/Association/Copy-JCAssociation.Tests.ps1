BeforeAll {
}
Describe -Tag:('JCAssociation') "Copy-JCAssociation Tests" {
    Context ('some cool tests Im thinking about writing') {
        It '<testDescription>' -TestCases @(
            @{  testDescription = 'user case'
                Users           = Get-JCObject -Type:('user') -Fields:('_id', 'username') -limit:(2)
                UserGroup       = (Get-JCObject -Type:('user_group') -limit:(1))[0]
                QType            = "username"
                SourceTarget    = "Name"
                DestTarget      = "TargetName"
            }
            @{  testDescription = 'id case'
                Users           = Get-JCObject -Type:('user') -Fields:('_id', 'username') -limit:(2)
                UserGroup       = (Get-JCObject -Type:('user_group') -limit:(1))[0]
                QType            = "_id"
                SourceTarget    = "Id"
                DestTarget      = "TargetId"

            }
        ) {
            param (
                [string] $SourceTarget,
                [string] $DestTarget,
                [string] $QType
            )
            # define first testing users
            $SourceUser = $Users[0]
            $TargetUser = $Users[1]
            
            # write-host($UserGroup.id)
            If (-not (Get-JCAssociation -Type:('user') -Id:($SourceUser._id) -TargetType:('user_group') | Where-Object { $_.TargetId -eq $UserGroup.id })){
                Add-JCAssociation -Type:('user') -Id:($SourceUser._id) -TargetType:('user_group') -TargetId:($UserGroup.id) -Force
            }
            # build query
            $Command = "Copy-JCAssociation -Type:('user') -$($SourceTarget):('$($SourceUser.$QType)') -$($DestTarget):('$($TargetUser.$QType)') -Force"
            invoke-expression -command $Command
            # compare results
            ($SourceUser | Get-JCAssociation | Select-Object -Property:('associationType', 'type', 'targetId', 'targetType', 'compiledAttributes') | ConvertTo-Json ) | Should -Be ($TargetUser | Get-JCAssociation | Select-Object -Property:('associationType', 'type', 'targetId', 'targetType', 'compiledAttributes') | ConvertTo-Json )
            $SourceUser | Get-JCAssociation | Remove-JCAssociation -force
            $TargetUser | Get-JCAssociation | Remove-JCAssociation -force
        }
    }
}
