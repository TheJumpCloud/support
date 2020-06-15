BeforeAll {
}
Describe -Tag:('JCAssociation') "Copy-JCAssociation Tests" {
    Context ('some cool tests Im thinking about writing') {
        It '<testDescription>' -TestCases @(
            @{  testDescription = 'user case'
                Users           = Get-JCObject -Type:('user') -Fields:('_id', 'username') -limit:(2)
                QType            = "username"
                SourceTarget    = "Name"
                DestTarget      = "TargetName"
            }
            @{  testDescription = 'id case'
                Users           = Get-JCObject -Type:('user') -Fields:('_id', 'username') -limit:(2)
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

            # query for username TODO: combine with iex?
            if ($QType -eq "username") {
                Copy-JCAssociation -Type:('user') -Name:($SourceUser.$QType) -TargetName:($TargetUser.$QType) -Force
            }
            # query by id
            if ($QType -eq "_id") {
                Copy-JCAssociation -Type:('user') -Id:($SourceUser.$QType) -TargetId:($TargetUser.$QType) -Force
            }
            # compare results
            ($SourceUser | Get-JCAssociation | Select-Object -Property:('associationType', 'type', 'targetId', 'targetType', 'compiledAttributes') | ConvertTo-Json ) | Should -Be ($TargetUser | Get-JCAssociation | Select-Object -Property:('associationType', 'type', 'targetId', 'targetType', 'compiledAttributes') | ConvertTo-Json )
            $TargetUser | Get-JCAssociation | Remove-JCAssociation -force
        }
    }
}
