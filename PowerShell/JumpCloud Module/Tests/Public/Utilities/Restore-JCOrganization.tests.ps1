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
        # Backup
        $backupLocation = Backup-JCOrganization -Path ./ -All
        $zipArchive = Get-Item "$($backupLocation.FullName).zip"
        # Changes made to the Org
        Get-JcSdkUserGroup | Remove-JcSdkUserGroup
        # Gather Info About Current Org
        $userCount = (Get-JcSdkSystemUser).Count
        $systemGroupCount = (Get-JcSdkSystemGroup).Count
        $systemUserCount = (Get-JcSdkUserGroup).Count
        # Restore
        Restore-JCsdkOrganization -Path $zipArchive -Type All
        # Test Data
        $userCountAfter = (Get-JcSdkSystemUser).Count
        $systemGroupCountAfter = (Get-JcSdkSystemGroup).Count
        $systemUserCountAfter = (Get-JcSdkUserGroup).Count
        # Test Changes (Should be none)
        $userCount | should -BeExactly $userCountAfter
        $systemGroupCount | should -BeExactly $systemGroupCountAfter
        $systemUserCount | should -BeLessThan $systemUserCountAfter
        # Cleanup
        $zipArchive | Remove-Item -Force
        $backupLocation | Remove-Item -Recurse -Force
    }
}
