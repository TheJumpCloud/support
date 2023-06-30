Describe -Tag:('JCPolicy') 'Registry File Tests' {
    Context 'Test Reg File Conversion' {
        $regFile = Convert-RegToPSObject -regFilePath $PesterParams_RegistryFilePath
        It 'Convert-RegToPSObject should return object with values' {
            foreach ($regKey in $regFile) {
                $regKey.customLocation | Should -Not -BeNullOrEmpty
                $regKey.customValueName | Should -Not -BeNullOrEmpty
                $regKey.customRegType | Should -Not -BeNullOrEmpty
                $regKey.customData | Should -Not -BeNullOrEmpty
            }
        }
        It 'Convert-RegToPSObject validate correct values' {
            foreach ($regKey in $regFile) {
                $regKey.customLocation | Should -Be "SOFTWARE\Policies\Microsoft\Power\PowerSettings"
                switch ($regKey.customRegType) {
                    DWORD {
                        $regKey.customValueName | Should -Be "DWORDValue"
                        $regKey.customData | Should -Be 0
                    }
                    QWORD {
                        $regKey.customValueName | Should -Be "QWORDValue"
                        $regKey.customData | Should -Be 16
                    }
                    multiString {
                        $regKey.customValueName | Should -Be "MULTISZValue"
                        $regKey.customData | Should -Be "Test1\0Test2\0\0"
                    }
                    expandString {
                        $regKey.customValueName | Should -Be "EXPANDSZValue"
                        $regKey.customData | Should -Be "Test1"
                    }
                    String {
                        $regKey.customValueName | Should -Be "ActivePowerScheme"
                        $regKey.customData | Should -Be "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
                    }
                }
            }
        }
    }
}