Describe "Get Global Variable Data Tests" -Tag "Cache" {
    BeforeAll {
        $dataPath = "$JCScriptRoot/data/"
        $requiredFiles = @(
            'associationHash.json',
            'radiusMembers.json',
            'systemHash.json',
            'userHash.json'
        )
        # explicitly import the settings file functions for these tests:
        $Private = @( Get-ChildItem -Path "$JCScriptRoot/Functions/Private/Settings/*.ps1" -Recurse)
        Foreach ($Import in $Private) {
            Try {
                . $Import.FullName
            } Catch {
                Write-Error -Message "Failed to import function $($Import.FullName): $_"
            }
        }
    }
    Context "When no 'data' directory exists" {
        BeforeAll {
            if (Test-Path -Path ($dataPath)) {
                Remove-Item -Path $dataPath -Recurse
            }
        }
        It "The tool is able to generate a 'data' directory and populate the global variables" {
            # Get the latest data for the org:
            Get-JCRGlobalVars
            foreach ($file in $requiredFiles) {
                # each json hash should have been generated and exist
                "$dataPath/$file" | Should -Exist
                # each file should be non-null
                $fileContent = Get-Content -Path "$dataPath/$file"
                $fileContent | Should -Not -BeNullOrEmpty
            }
        }
    }
    Context "When the 'data' directory already exists" {
        BeforeAll {
            # if the data directory does not exist, generate the global vars + directory
            if (-not (Test-Path -Path ($dataPath))) {
                Write-Host "Generating data:"
                Get-JCRGlobalVars
            }

        }
        It "Data should not be refreshed when running Get-JCRGlobalVars if it's been less than 24 hours since last update" {
            # Get the settings data
            $settingsData = Get-JCRSettingsFile
            $timespan = New-TimeSpan -Start (Get-Date).AddHours(-24) -End $settingsData.globalVars.lastupdate
            # Write-Host "Time between 24 hrs and settings file: $($timespan.TotalHours)"
            # get files before
            $filesBefore = Get-ChildItem -Path $dataPath
            # check the settings time the files were last written
            if ($timespan.TotalHours -lt 24) {
                # continue with test
            } else {
                # set the settings file to a mocked value of now
                Set-JCRSettingsFile -globalVarslastUpdate (Get-Date)

            }
            # run Get-JCRGlobalVars
            Get-JCRGlobalVars

            # check the files:
            $filesAfter = Get-ChildItem -Path $dataPath

            # test each file write date
            foreach ($file in $requiredFiles) {
                # write-host "validating write times for $file"
                $beforeWriteTime = (($filesBefore | Where-Object { $_.Name -eq $file })).LastWriteTime
                $afterWriteTime = (($filesAfter | Where-Object { $_.Name -eq $file })).LastWriteTime
                # Write-Host "before: $beforeWriteTime should be after: $afterWriteTime"
                # The file write time before running Get-JCRGlobalVars should be the same after running the function
                $beforeWriteTime | should -be $afterWriteTime
            }
        }
        It "Data should refresh when running Get-JCRGlobalVars if it's been more than 24 hours since last update" {
            # Get the settings data
            $settingsData = Get-JCRSettingsFile
            $timespan = New-TimeSpan -Start (Get-Date).AddHours(-24) -End $settingsData.globalVars.lastupdate
            # Write-Host "Time between 24 hrs and settings file: $($timespan.TotalHours)"
            # get files before
            $filesBefore = Get-ChildItem -Path $dataPath
            # check the settings time the files were last written
            if ($timespan.TotalHours -gt 24) {
                # continue with test
            } else {
                # set the settings file to a mocked value of now
                Set-JCRSettingsFile -globalVarslastUpdate (Get-Date).AddHours(-25)
                Start-Sleep 2
                $settingsData = Get-JCRSettingsFile
                $timespan = New-TimeSpan -Start  $settingsData.globalVars.lastupdate -End (Get-Date).AddHours(-24)
                Write-Host "Time between 24 hrs and settings file: $($timespan.TotalHours)"
            }
            # run Get-JCRGlobalVars
            Get-JCRGlobalVars

            # check the files:
            $filesAfter = Get-ChildItem -Path $dataPath
            # test each file write date
            foreach ($file in $requiredFiles) {
                write-host "validating write times for $file"
                $beforeWriteTime = (($filesBefore | Where-Object { $_.Name -eq $file })).LastWriteTime.Ticks
                $afterWriteTime = (($filesAfter | Where-Object { $_.Name -eq $file })).LastWriteTime.Ticks
                Write-Host "before: $beforeWriteTime should not be after: $afterWriteTime"
                # The file write time before running Get-JCRGlobalVars should not be the same after running the function
                $beforeWriteTime | should -Not -Be $afterWriteTime
            }
        }
        It "Data should be re-written when the -Force parameter is used; regardless of setings write date" {
            # check the files before
            $filesBefore = Get-ChildItem -Path $dataPath
            # run Get-JCRGlobalVars with force param
            Get-JCRGlobalVars -Force

            # check the files after:
            $filesAfter = Get-ChildItem -Path $dataPath
            # test each file write date
            foreach ($file in $requiredFiles) {
                # write-host "validating write times for $file"
                $beforeWriteTime = (($filesBefore | Where-Object { $_.Name -eq $file })).LastWriteTime.Ticks
                $afterWriteTime = (($filesAfter | Where-Object { $_.Name -eq $file })).LastWriteTime.Ticks
                # Write-Host "before: $beforeWriteTime should not be after: $afterWriteTime"
                # The file write time before running Get-JCRGlobalVars should not be the same after running the function
                $beforeWriteTime | should -Not -Be $afterWriteTime
            }
        }
        It "Data should be re-written when the -Force parameter is used and Association data should be skipped with -SkipAssociation; regardless of setings write date" {
            # check the files before
            $filesBefore = Get-ChildItem -Path $dataPath
            # run Get-JCRGlobalVars with force param
            Get-JCRGlobalVars -Force -SkipAssociation

            # check the files after:
            $filesAfter = Get-ChildItem -Path $dataPath
            # test each file write date
            foreach ($file in $requiredFiles) {
                # write-host "validating write times for $file"
                if ($file -ne "associationHash.json") {
                    $beforeWriteTime = (($filesBefore | Where-Object { $_.Name -eq $file })).LastWriteTime.Ticks
                    $afterWriteTime = (($filesAfter | Where-Object { $_.Name -eq $file })).LastWriteTime.Ticks
                    # Write-Host "before: $beforeWriteTime should not be after: $afterWriteTime"
                    # The file write time before running Get-JCRGlobalVars should not be the same after running the function
                    $beforeWriteTime | should -Not -Be $afterWriteTime

                } else {
                    $beforeWriteTime = (($filesBefore | Where-Object { $_.Name -eq $file })).LastWriteTime.Ticks
                    $afterWriteTime = (($filesAfter | Where-Object { $_.Name -eq $file })).LastWriteTime.Ticks
                    # Write-Host "before: $beforeWriteTime should not be after: $afterWriteTime"
                    # The file write time before running Get-JCRGlobalVars should not be the same after running the function
                    $beforeWriteTime | should -Be $afterWriteTime

                }
            }
        }
    }
}
