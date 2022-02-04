BeforeAll {
    Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null
    # If (-not (Get-JCAssociation -Type:('user') -Id:($PesterParams_User1._id) -TargetType:('user_group') | Where-Object { $_.TargetId -eq $PesterParams_UserGroup.id }))
    # {
    #     Add-JCAssociation -Type:('user') -Id:($PesterParams_User1._id) -TargetType:('user_group') -TargetId:($PesterParams_UserGroup.id) -Force
    # }
    $associationSystem = Get-JCSystem | Select-Object -First 1
}
Describe -Tag:('JCAssociation') "Copy-JCAssociation Tests" {
    Context ('Tests Copy-JCAssociation function with attributes') {
        It ('Tests attributes from users to systems are copied') {
            # Generate new users
            $user1 = "association_" + -join ((65..90) + (97..122) | Get-Random -Count 5 | ForEach-Object { [char]$_ })
            $user2 = "association_" + -join ((65..90) + (97..122) | Get-Random -Count 5 | ForEach-Object { [char]$_ })
            $tempUser = New-JCUser -username:($user1) -firstname:($user1) -lastname:($user1) -email:("$user1@pesterlinux.org")
            $tempUser2 = New-JCUser -username:($user2) -firstname:($user2) -lastname:($user2) -email:("$user2@pesterlinux.org")
            # Set associations and copy
            Add-JCAssociation -Type:('user') -Id:($tempUser._id) -TargetType:('system') -TargetId:($associationSystem._id) -Force
            Copy-JCAssociation -Id:($tempUser._id) -TargetId:($tempUser2.id) -Type:("user") -Force
            # Test that the association was copied: Should Not Be Null or Empty
            # Get User Association to Systems. The copied association should be the same as the original association
            $theCopiedAssociation = Get-JcSdkUserAssociation -UserId:($($tempUser2.id)) -Targets:("system") | Where-Object { $_.ToId -eq $associationSystem._id }
            $FromAssociation = Get-JcSdkUserAssociation -UserId:($($tempUser._id)) -Targets:("system") | Where-Object { $_.ToId -eq $associationSystem._id }
            # Compare the attributes, these should be the same, including sudo attributes
            $theCopiedAssociation.Attributes.AdditionalProperties.sudo.enabled | Should -Be $FromAssociation.Attributes.AdditionalProperties.sudo.enabled
            $theCopiedAssociation.Attributes.AdditionalProperties.sudo.withoutPassword | Should -Be $FromAssociation.Attributes.AdditionalProperties.sudo.withoutPassword
            # ($theCopiedAssociation.Attributes | ConvertTo-Json -Depth:(99) -Compress) | Should -Be ($FromAssociation.attributes | ConvertTo-Json -Depth:(99) -Compress)
        }
        It ('Tests attributes (sudoEnabled) from users to systems are copied') {
            # Generate new users
            $user1 = "association_" + -join ((65..90) + (97..122) | Get-Random -Count 5 | ForEach-Object { [char]$_ })
            $user2 = "association_" + -join ((65..90) + (97..122) | Get-Random -Count 5 | ForEach-Object { [char]$_ })
            $tempUser = New-JCUser -username:($user1) -firstname:($user1) -lastname:($user1) -email:("$user1@pesterlinux.org")
            $tempUser2 = New-JCUser -username:($user2) -firstname:($user2) -lastname:($user2) -email:("$user2@pesterlinux.org")
            # Set SudoEnable attribute on tempUser system association
            # TODO: SA-2378 Attribute Object needs custom type
            $attributes = [JumpCloud.SDK.V2.Models.IGraphOperationSystemAttributes]@{ 'sudo' = @{'enabled' = $true; 'withoutPassword' = $false } }
            Set-JcSdkUserAssociation -UserId:($tempUser.id) -Id:($associationSystem._id) -Op:("add") -Type:("system") -Attributes $attributes
            # Copy association from tempUser to tempUser2
            Copy-JCAssociation -Id:($tempUser.id) -TargetId:($tempUser2.id) -Type:("user") -Force

            $theCopiedAssociation = Get-JcSdkUserAssociation -UserId:($($tempUser2.id)) -Targets:("system") | Where-Object { $_.ToId -eq $associationSystem._id }
            $FromAssociation = Get-JcSdkUserAssociation -UserId:($($tempUser.id)) -Targets:("system") | Where-Object { $_.ToId -eq $associationSystem._id }
            # Compare the attributes, these should be the same, including sudo attributes
            $theCopiedAssociation.Attributes.AdditionalProperties.sudo.enabled | Should -Be $FromAssociation.Attributes.AdditionalProperties.sudo.enabled
            $theCopiedAssociation.Attributes.AdditionalProperties.sudo.withoutPassword | Should -Be $FromAssociation.Attributes.AdditionalProperties.sudo.withoutPassword
            # ($theCopiedAssociation2.Attributes | ConvertTo-Json -Depth:(99) -Compress) | Should -Be ($FromAssociation2.attributes | ConvertTo-Json -Depth:(99) -Compress)
        }
    }
    # Context ('User and Id Association Tests') {
    #     It '<testDescription>' -TestCases @(
    #         @{  testDescription = 'Copy Associtations by username'
    #             QType           = "username"
    #             SourceTarget    = "Name"
    #             DestTarget      = "TargetName"
    #         }
    #         @{  testDescription = 'Copy Associtations by UserID'
    #             QType           = "_id"
    #             SourceTarget    = "Id"
    #             DestTarget      = "TargetId"
    #         }
    #     ) {
    #         param (
    #             [string] $SourceTarget,
    #             [string] $DestTarget,
    #             [string] $QType
    #         )
    #         # build query
    #         Invoke-Expression -Command:("Copy-JCAssociation -Type:('user') -$($SourceTarget):('$($PesterParams_User1.$QType)') -$($DestTarget):('$($PesterParams_User2.$QType)') -Force")
    #         # compare results
    #         $User1Associations = $PesterParams_User1 | Get-JCAssociation -Type:('user')
    #         $User2Associations = $PesterParams_User2 | Get-JCAssociation -Type:('user')
    #         $User1Associations.associationType | Should -Be $User2Associations.associationType
    #         $User1Associations.type | Should -Be $User2Associations.type
    #         $User1Associations.targetId | Should -Be $User2Associations.targetId
    #         $User1Associations.targetType | Should -Be $User2Associations.targetType
    #         # $User1Associations.compiledAttributes | Should -Be $User2Associations.compiledAttributes
    #     }
    # }
}
AfterAll {
    Get-JCUser | where-object { $_.username -match "association_" } | Remove-JCUser -force
}