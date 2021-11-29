Describe -Tag:('JCBackup') "Restore-JCOrganization" {
    BeforeAll {
        Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null
        If (-not (Get-JCAssociation -Type:('user') -Name:($PesterParams_User1.username) -TargetType:('system') -IncludeNames | Where-Object { $_.TargetName -eq $PesterParams_SystemLinux.displayName })) {
            Add-JCAssociation -Type:('user') -Name:($PesterParams_User1.username) -TargetType:('system') -TargetName:($PesterParams_SystemLinux.displayName) -Force
        }
        Add-JCUserGroupMember -GroupName $PesterParams_UserGroup.Name -username $PesterParams_User1.Username
        Add-JCSystemGroupMember -GroupName $PesterParams_SystemGroup.Name -SystemID $PesterParams_SystemLinux._id
    }
    It "Backs up and restores to a JumpCloud Org with no changes" {
        # Gather Info About Current Org
        $userCount = (Get-JcSdkSystemUser).Count
        $systemGroupCount = (Get-JcSdkSystemGroup).Count
        $systemUserCount = (Get-JcSdkUserGroup).Count
        # Backup
        $backupLocation = Backup-JCOrganization -Path ./ -All
        $zipArchive = Get-Item "$($backupLocation.FullName).zip"
        # Restore
        Restore-JCsdkOrganization -Path $zipArchive -Type All
        # Test Data
        $userCountAfter = (Get-JcSdkSystemUser).Count
        $systemGroupCountAfter = (Get-JcSdkSystemGroup).Count
        $systemUserCountAfter = (Get-JcSdkUserGroup).Count
        # Test Changes (Should be none)
        $userCount | should -BeExactly $userCountAfter
        $systemGroupCount | should -BeExactly $systemGroupCountAfter
        $systemUserCount | should -BeExactly $systemUserCountAfter
        # Cleanup
        $zipArchive | Remove-Item -Force
        $backupLocation | Remove-Item -Recurse -Force
    }
    It "Backs up and restores to a JumpCloud Org with changes" {
        # # Backup
        # $backupLocation = Backup-JCOrganization -Path ./ -All
        # $zipArchive = Get-Item "$($backupLocation.FullName).zip"
        # # Changes made to the Org
        # Get-JcSdkUserGroup | Remove-JcSdkUserGroup
        # # Gather Info About Current Org
        # $userCount = (Get-JcSdkSystemUser).Count
        # $systemGroupCount = (Get-JcSdkSystemGroup).Count
        # $systemUserCount = (Get-JcSdkUserGroup).Count
        # # Restore
        # Restore-JCsdkOrganization -Path $zipArchive -Type All
        # # Test Data
        # $userCountAfter = (Get-JcSdkSystemUser).Count
        # $systemGroupCountAfter = (Get-JcSdkSystemGroup).Count
        # $systemUserCountAfter = (Get-JcSdkUserGroup).Count
        # # Test Changes (Should be none)
        # $userCount | should -BeExactly $userCountAfter
        # $systemGroupCount | should -BeExactly $systemGroupCountAfter
        # $systemUserCount | should -BeLessThan $systemUserCountAfter
        # # Cleanup
        # $zipArchive | Remove-Item -Force
        # $backupLocation | Remove-Item -Recurse -Force
    }

    Context "Tests attributes are restored / updated"{

        It "Tests Attributes in a nested level are restored"{
            # If not a user with nested attributes, Create
            # if not a user group with nested attributes, Create
            # Get a backup of the org

            # modify the nested attributes
            # restore from backup
            # user & user group should have had their nested attributes written back

            # delete those user and user group resources

            # Restore from backup
            # user & user group should be created and have restored their nested attributes
        }
    }

    Context "CSV Functionality" {
        It "CSV Restore can restore nested level objects" {}
    }

    Context "Test unique identifiers can be used for restore" {
        It "A restored user with different ID from backup file can still be restored" {
            # Create a user for the test
            # Backup users
            # Delete the user for the test
            # Restore-JCOrg to restore the user, it should have a different ID now
            # Change an attribute on the restored user
            # Restore-JCOrg to restore the user, it should be able to write the attribute back even though the user has a different ID
        }
        Id "An Application, SoftwareApp can be restored by it's identifier name"
    }

    Context "Common restore scenarios where we'd rather do nothing vs. overwrite data"{
        It "When a user is restored but another unique identifier exists, data should not be overwritten"{
            # Create a user for the test
            # Backup Users
            # Delete the user from earlier
            # Create a user with the same "email" as the first user in the org
            # Attempt to restore users
            # The second user with the email from the first user SHOULD NOT be overwritten with attributes from the first user.
        }
    }
}
