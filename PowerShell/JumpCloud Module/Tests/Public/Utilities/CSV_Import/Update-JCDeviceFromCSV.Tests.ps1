Describe -Tag:('JCDeviceFromCSV') 'Update-JCDeviceFromCSV' {
    BeforeAll {  }
    It 'Updates users from a CSV populated with all information' {
        $system = Get-JCDevice | Select-Object -First 1
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

        $DeviceCSVUpdate.displayName | Should -Be $CSVData.displayName
        $DeviceCSVUpdate.description | Should -Be $CSVData.description
        $DeviceCSVUpdate.allowSshPasswordAuthentication | Should -Be $CSVData.allowSshPasswordAuthentication
        $DeviceCSVUpdate.allowSshRootLogin | Should -Be $CSVData.allowSshRootLogin
        $DeviceCSVUpdate.allowMultiFactorAuthentication | Should -Be $CSVData.allowMultiFactorAuthentication
        $DeviceCSVUpdate.allowPublicKeyAuthentication | Should -Be $CSVData.allowPublicKeyAuthentication
        $DeviceCSVUpdate.systemInsights | Should -Be @{state = 'enabled'}
    }
}
