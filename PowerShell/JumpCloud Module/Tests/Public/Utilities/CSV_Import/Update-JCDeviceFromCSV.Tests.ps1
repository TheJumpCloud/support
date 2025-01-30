Describe -Tag:('JCDeviceFromCSV') 'Update-JCDeviceFromCSV' {
    BeforeEach {
        $NewUser = New-RandomUser -domain "delPrimarySystemUser.$(New-RandomString -NumberOfChars 5)" | New-JCUser
    }
    It 'Updates users from a CSV populated with all information' {
        $system = Get-JCSystem | Select-Object -First 1
        $CSVData = @{
            "DeviceID"                       = $system.id
            "displayName"                    = "PesterUpdateFromCSV"
            "description"                    = "PesterUpdateFromCSV"
            "allowSshPasswordAuthentication" = $true
            "allowSshRootLogin"              = $true
            "allowMultiFactorAuthentication" = $false
            "allowPublicKeyAuthentication"   = $true
            "systemInsights"                 = $true
            "primarySystemUser"              = $NewUser._id
        }
        $CSVDATA | Export-Csv "$PesterParams_ImportPath/UpdateDeviceFromCSV.csv" -Force
        $DeviceCSVUpdate = Update-JCDeviceFromCSV -CSVFilePath "$PesterParams_ImportPath/UpdateDeviceFromCSV.csv" -force

        $UpdatedDevice = Get-JCSystem -SystemID $system.id

        $UpdatedDevice.displayName | Should -Be $CSVData.displayName
        $UpdatedDevice.description | Should -Be $CSVData.description
        $UpdatedDevice.allowSshPasswordAuthentication | Should -Be $CSVData.allowSshPasswordAuthentication
        $UpdatedDevice.allowSshRootLogin | Should -Be $CSVData.allowSshRootLogin
        $UpdatedDevice.allowMultiFactorAuthentication | Should -Be $CSVData.allowMultiFactorAuthentication
        $UpdatedDevice.allowPublicKeyAuthentication | Should -Be $CSVData.allowPublicKeyAuthentication
        $UpdatedDevice.systemInsights | Should -Be '@{state=enabled}'
    }
    It 'Updates users from a CSV populated with a null value' {
        $system = Get-JCSystem | Select-Object -First 1
        $CSVData = @{
            "DeviceID"                       = $system.id
            "displayName"                    = ""
            "description"                    = ""
            "allowSshPasswordAuthentication" = $true
            "allowSshRootLogin"              = $true
            "allowMultiFactorAuthentication" = $false
            "allowPublicKeyAuthentication"   = $true
            "systemInsights"                 = $true
            "primarySystemUser"              = $NewUser._id
        }
        $CSVDATA | Export-Csv "$PesterParams_ImportPath/UpdateDeviceFromCSV.csv" -Force
        $DeviceCSVUpdate = Update-JCDeviceFromCSV -CSVFilePath "$PesterParams_ImportPath/UpdateDeviceFromCSV.csv" -force

        $UpdatedDevice = Get-JCSystem -SystemID $system.id

        $UpdatedDevice.displayName | Should -Be $system.displayName
        $UpdatedDevice.description | Should -Be $system.description
        $UpdatedDevice.allowSshPasswordAuthentication | Should -Be $CSVData.allowSshPasswordAuthentication
        $UpdatedDevice.allowSshRootLogin | Should -Be $CSVData.allowSshRootLogin
        $UpdatedDevice.allowMultiFactorAuthentication | Should -Be $CSVData.allowMultiFactorAuthentication
        $UpdatedDevice.allowPublicKeyAuthentication | Should -Be $CSVData.allowPublicKeyAuthentication
        $UpdatedDevice.systemInsights | Should -Be '@{state=enabled}'

        $DeviceCSVUpdate.primarySystemUser | Should -Be $NewUser._id
        $systemAssociations = Get-JcSdkSystemAssociation -SystemId $system.Id -Targets 'user'
        $CSVData.primarySystemUser | Should -BeIn $systemAssociations.ToId
    }
    It 'Updates users from a CSV populated with an invalid primarySystemUser' {
        $system = Get-JCSystem | Select-Object -First 1
        $CSVData = @{
            "DeviceID"                       = $system.id
            "displayName"                    = ""
            "description"                    = ""
            "allowSshPasswordAuthentication" = $true
            "allowSshRootLogin"              = $true
            "allowMultiFactorAuthentication" = $false
            "allowPublicKeyAuthentication"   = $true
            "systemInsights"                 = $true
            "primarySystemUser"              = "RandomUserThatDoesntExist"
        }
        $CSVDATA | Export-Csv "$PesterParams_ImportPath/UpdateDeviceFromCSV.csv" -Force
        $DeviceCSVUpdate = Update-JCDeviceFromCSV -CSVFilePath "$PesterParams_ImportPath/UpdateDeviceFromCSV.csv" -force

        $UpdatedDevice = Get-JCSystem -SystemID $system.id

        $UpdatedDevice.displayName | Should -Be $system.displayName
        $UpdatedDevice.description | Should -Be $system.description
        $UpdatedDevice.allowSshPasswordAuthentication | Should -Be $CSVData.allowSshPasswordAuthentication
        $UpdatedDevice.allowSshRootLogin | Should -Be $CSVData.allowSshRootLogin
        $UpdatedDevice.allowMultiFactorAuthentication | Should -Be $CSVData.allowMultiFactorAuthentication
        $UpdatedDevice.allowPublicKeyAuthentication | Should -Be $CSVData.allowPublicKeyAuthentication
        $UpdatedDevice.systemInsights | Should -Be '@{state=enabled}'

        $DeviceCSVUpdate.primarySystemUser | Should -Contain "Could not validate"
        $systemAssociations = Get-JcSdkSystemAssociation -SystemId $system.Id -Targets 'user'
        $CSVData.primarySystemUser | Should -Not -BeIn $systemAssociations.ToId
    }
}
