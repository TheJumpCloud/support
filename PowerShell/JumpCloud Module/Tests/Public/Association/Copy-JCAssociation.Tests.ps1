BeforeAll {
    Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null
    If (-not (Get-JCAssociation -Type:('user') -Id:($PesterParams_User1._id) -TargetType:('user_group') | Where-Object { $_.TargetId -eq $PesterParams_UserGroup.id }))
    {
        Add-JCAssociation -Type:('user') -Id:($PesterParams_User1._id) -TargetType:('user_group') -TargetId:($PesterParams_UserGroup.id) -Force
    }
}
Describe -Tag:('JCAssociation') "Copy-JCAssociation Tests" {
    Context ('User and Id Association Tests') {
        It '<testDescription>' -TestCases @(
            @{  testDescription = 'Copy Associtations by username'
                QType           = "username"
                SourceTarget    = "Name"
                DestTarget      = "TargetName"
            }
            @{  testDescription = 'Copy Associtations by UserID'
                QType           = "_id"
                SourceTarget    = "Id"
                DestTarget      = "TargetId"
            }
        ) {
            param (
                [string] $SourceTarget,
                [string] $DestTarget,
                [string] $QType
            )
            # build query
            Invoke-Expression -command:("Copy-JCAssociation -Type:('user') -$($SourceTarget):('$($PesterParams_User1.$QType)') -$($DestTarget):('$($PesterParams_User2.$QType)') -Force")
            # compare results
            ($PesterParams_User1 | Get-JCAssociation -Type:('user') | Select-Object -Property:('associationType', 'type', 'targetId', 'targetType', 'compiledAttributes') | ConvertTo-Json ) | Should -Be ($PesterParams_User2 | Get-JCAssociation -Type:('user') | Select-Object -Property:('associationType', 'type', 'targetId', 'targetType', 'compiledAttributes') | ConvertTo-Json )
        }
    }
}
