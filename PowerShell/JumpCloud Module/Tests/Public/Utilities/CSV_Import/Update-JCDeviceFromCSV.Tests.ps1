Describe -Tag:('JCDeviceFromCSV') 'Update-JCDeviceFromCSV' {
    BeforeAll {  }
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
}
