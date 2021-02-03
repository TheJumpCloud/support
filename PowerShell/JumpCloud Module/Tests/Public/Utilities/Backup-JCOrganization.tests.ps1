Describe -Tag:('JCBackup') "Backup-JCOrganization" {
    BeforeAll {
        Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null
    }
    It "Backs up JumpCloud Org" {
        # Create a backup
        $backupLocation = Backup-JCOrganization -Path ./ -All
        # From the output of the command, set the expected .zip output
        $zipArchive = Get-Item "$($backupLocation.FullName).zip"
        # Expand the Archive
        Expand-Archive -Path "$zipArchive" -DestinationPath ./
        # Get child items from the backup directory
        $backupChildItem = Get-ChildItem $backupLocation.FullName | Where-Object { $_ -notmatch 'Manifest' }
        # Get valid target types for the backup
        $ValidTargetTypes = (Get-Command Backup-JCOrganization -ArgumentList:($Type.value)).Parameters.Type.Attributes.ValidValues
        # verify that the object backup files exist
        foreach ($file in $backupChildItem | Where-Object { $_ -notmatch 'Association' })
        {
            # Only valid target types should exist in the backup directory
            $file.BaseName -in $ValidTargetTypes | Should -BeTrue
        }
        # verify that the association files have matching ids and target ids
        foreach ($file in $backupChildItem | Where-Object { $_ -match 'Association' })
        {
            # take a look at association files (if they exist)
            # Verify that each ID has a matching Target ID
            $fileContent = Get-Content $file | ConvertFrom-Json
            # test that the id and target id is not null or empty
            foreach ($item in $fileContent) {
                if (![System.String]::IsNullOrEmpty($item.Paths))
                {
                    # "Testing: $($item.Id)"
                    $item.Id | Should -Not -BeNullOrEmpty
                    # "Testing: $($item.Paths.ToId)"
                    $item.Paths.ToId | Should -Not -BeNullOrEmpty
                }
                else {
                    # "Testing: $($item.FromId)"
                    $item.FromId | Should -Not -BeNullOrEmpty
                    # "Testing: $($item.ToId)"
                    $item.ToId | Should -Not -BeNullOrEmpty
                }
            }
        }
        # verify that each file is not null or empty
        foreach ($item in $backupChildItem) {
            Get-Content $item -Raw | Should -Not -BeNullOrEmpty
        }
        # Check the Manifest file:
        $manifest = Get-ChildItem $backupLocation.FullName | Where-Object { $_ -match 'Manifest' } 
        $manifestContent = Get-Content $manifest | ConvertFrom-Json
        $manifestFiles = $manifestContent.result | Where-Object { $_ -notmatch 'Association' }
        # $manifestAssociationFiles = $manifestContent.result | Where-Object { $_ -match 'Association' }

        foreach ($file in $manifestFiles)
        {
            # Manifest Results should contain valid types
            $file.type -in $ValidTargetTypes | Should -BeTrue
            # Backup Files should contain file sin results manifest
            $backupChildItem.Name -match "$($file.type)" | Should -BeTrue
        }
        ($backupLocation.Parent.EnumerateFiles() | Where-Object { $_.Name -match "$($backupLocation.BaseName).zip" }) | Should -BeTrue
        $zipArchive | Remove-Item -Force
        $backupLocation | Remove-Item -Recurse -Force
    }
    It "Backs up JumpCloud Org with specific params" {
        # Create a backup
        $backupLocation = Backup-JCOrganization -Path ./ -Type:('User', 'UserGroup') -PassThru -Format:('csv') -Association
        # From the output of the command, set the expected .zip output
        $zipArchive = Get-Item "$($backupLocation.BackupLocation.FullName).zip"
        # Expand the Archive
        Expand-Archive -Path "$zipArchive" -DestinationPath ./
        # Get child items from the backup directory
        $backupChildItem = Get-ChildItem $backupLocation.BackupLocation.FullName | Where-Object { $_ -notmatch 'Manifest' }
        # Get valid target types for the backup
        $ValidTargetTypes = @('User', 'UserGroup')
        # verify that the object backup files exist
        foreach ($file in $backupChildItem | Where-Object { $_ -notmatch 'Association' })
        {
            # Only valid target types should exist in the backup directory
            $file.BaseName -in $ValidTargetTypes | Should -BeTrue
        }
        # verify that the association files have matching ids and target ids
        foreach ($file in $backupChildItem | Where-Object { $_ -match 'Association' })
        {
            # take a look at association files (if they exist)
            # Verify that each ID has a matching Target ID
            $fileContent = Get-Content $file | ConvertFrom-CSV
            # test that the id and target id is not null or empty
            foreach ($item in $fileContent)
            {
                if (![System.String]::IsNullOrEmpty($item.Paths))
                {
                    # "Testing: $($item.Id)"
                    $item.Id | Should -Not -BeNullOrEmpty
                    # "Testing: $($item.Paths.ToId)"
                    ($fileContent[0].paths | ConvertFrom-Json).toId | Should -Not -BeNullOrEmpty
                }
                else
                {
                    # "Testing: $($item.FromId)"
                    $item.FromId | Should -Not -BeNullOrEmpty
                    # "Testing: $($item.ToId)"
                    $item.ToId | Should -Not -BeNullOrEmpty
                }
            }
        }
        # verify that each file is not null or empty
        foreach ($item in $backupChildItem)
        {
            # Files should be of type csv
            $item.extension | Should -Be ".csv"
            Get-Content $item -Raw | Should -Not -BeNullOrEmpty
        }
        # Check the Manifest file:
        $manifest = Get-ChildItem $backupLocation.BackupLocation.FullName | Where-Object { $_ -match 'Manifest' } 
        $manifestContent = Get-Content $manifest | ConvertFrom-Json
        $manifestFiles = $manifestContent.result | Where-Object { $_ -notmatch 'Association' }
        # $manifestAssociationFiles = $manifestContent.result | Where-Object { $_ -match 'Association' }

        foreach ($file in $manifestFiles)
        {
            # Manifest Results should contain valid types
            $file.type -in $ValidTargetTypes | Should -BeTrue
            # Backup Files should contain file sin results manifest
            $backupChildItem.Name -match "$($file.type)" | Should -BeTrue
        }
        ($backupLocation.BackupLocation.Parent.EnumerateFiles() | Where-Object { $_.Name -match "$($backupLocation.BackupLocation.BaseName).zip" }) | Should -BeTrue
        $zipArchive | Remove-Item -Force
        $backupLocation.BackupLocation | Remove-Item -Recurse -Force
    }
}
