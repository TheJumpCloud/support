Describe -Tag:('JCBackup') "Backup-JCOrganization" {
    BeforeAll {
        Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null
        If (-not (Get-JCAssociation -Type:('user') -Name:($PesterParams_User1.username) -TargetType:('system') -IncludeNames | Where-Object { $_.TargetName -eq $PesterParams_SystemLinux.displayName })) {
            Add-JCAssociation -Type:('user') -Name:($PesterParams_User1.username) -TargetType:('system') -TargetName:($PesterParams_SystemLinux.displayName) -Force
        }
        Add-JCUserGroupMember -GroupName $PesterParams_UserGroup.Name -username $PesterParams_User1.Username
        Add-JCSystemGroupMember -GroupName $PesterParams_SystemGroup.Name -SystemID $PesterParams_SystemLinux._id
    }
    It "Backs up JumpCloud Org" {
        $backupLocation = Backup-JCOrganization -Path ./ -All
        $zipArchive = Get-Item "$($backupLocation.FullName).zip"
        Expand-Archive -Path "$zipArchive" -DestinationPath ./
        $backupChildItem = Get-ChildItem $backupLocation.FullName
        $ValidTargetTypes = (Get-Command Backup-JCOrganization -ArgumentList:($Type.value)).Parameters.Type.Attributes.ValidValues
        # verify that the object backup files exist
        foreach ($item in $ValidTargetTypes) {
            $item -in $backupChildItem.BaseName | Should -BeTrue
        }
        # verify that the association files exist
        foreach ($item in $ValidTargetTypes | Where-Object { $_ -ne 'System' })
        {
            "$($item)-Association" -in ($backupChildItem.BaseName | Where-Object { $_ -match 'Association' }) | Should -BeTrue
        }
        # verify that each file is not null or empty
        foreach ($item in $backupChildItem) {
            Get-Content $item -Raw | Should -Not -BeNullOrEmpty
        }
        ($backupLocation.Parent.EnumerateFiles() | Where-Object { $_.Name -match "$($backupLocation.BaseName).zip" }) | Should -BeTrue
        $zipArchive | Remove-Item -Force
        $backupLocation | Remove-Item -Recurse -Force
    }
}
