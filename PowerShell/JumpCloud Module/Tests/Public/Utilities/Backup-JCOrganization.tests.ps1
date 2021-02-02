Describe -Tag:('JCBackup') "Backup-JCOrganization" {
    BeforeAll {
        Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null
    }
    It "Backs up JumpCloud Org" {
        $backupLocation = Backup-JCOrganization -Path ./ -All
        $zipArchive = Get-Item "$($backupLocation.FullName).zip"
        Expand-Archive -Path "$zipArchive" -DestinationPath ./
        $backupChildItem = Get-ChildItem $backupLocation.FullName | Where-Object { $_ -notmatch 'BackupManifest' }
        $ValidTargetTypes = (Get-Command Backup-JCOrganization -ArgumentList:($Type.value)).Parameters.Type.Attributes.ValidValues
        # verify that the object backup files exist
        foreach ($file in $backupChildItem | Where-Object { $_ -notmatch 'Association' }) 
        {
            $file.BaseName -in $ValidTargetTypes | Should -BeTrue
        }
        # verify that the association files have matching ids and target ids
        foreach ($file in $backupChildItem | Where-Object { $_ -match 'Association' })
        {
            # "testing $file"
            # take a look at association files (if they exist)
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
        ($backupLocation.Parent.EnumerateFiles() | Where-Object { $_.Name -match "$($backupLocation.BaseName).zip" }) | Should -BeTrue
        $zipArchive | Remove-Item -Force
        $backupLocation | Remove-Item -Recurse -Force
    }
}
