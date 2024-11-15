Describe -Tag:('ModuleValidation') 'SDK Generation' {

    it 'tests that the sdks have been generated before release' {
        # run the jcapi to support sync function:
        . "$PSScriptRoot/../../../Deploy/SdkSync/jcapiToSupportSync.ps1" -RequiredModulesRepo 'PSGallery'
        # validate that there's no changes to git diff

        # $ApprovedFunctions variable is imported when we run jcapiToSupportSync.ps1
        foreach ($item in $ApprovedFunctions.values) {
            # $Item is sdk level function
            foreach ($subitem in $item) {
                # $subItem is function level of SDK
                # Set the function File Path to test:
                $functionFilePath = "$FolderPath_Public" -replace "/Public", "$($subitem.Destination)/$($subitem.Name).ps1"
                $functionFilePath = "$functionFilePath" -replace "JcSdk", "JC"
                # Each function defined in the jcapiToSupportSync file should exist
                Test-Path -Path $functionFilePath | should -Be $true
                # Git Diff for the file should not exist
                $diff = git diff $functionFilePath
                if ($diff) {
                    write-warning "diff found in file: $functionFilePath when we expected none to exist; have you run jcapiToSupportSync.ps1 and committed the resulting changes?"
                }
                $diff | Should -BeNullOrEmpty
            }

        }
    }
}

