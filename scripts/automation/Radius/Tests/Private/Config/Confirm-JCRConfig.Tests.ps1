Describe 'Confirm-JCRConfig Tests' -Tag "Acceptance" {
    BeforeAll {
        # Load all functions from private folders
        if (-not (test-path -path $JCRScriptRoot -errorAction silentlyContinue)) {
            write-host "JCRScriptRoot not set, setting it to the parent directory of the script root"

            # until we've found the correct parent path traversing up the directory tree
            do {
                $JCRScriptRoot = Split-Path -Path $PSScriptRoot -Parent
                # check if the JumpCloud.Radius.psd1 file exists in the parent directory
                if (Test-Path -Path "$JCRScriptRoot/JumpCloud.Radius.psd1") {
                    break
                }
                # if not, traverse up one more level
                $PSScriptRoot = $JCRScriptRoot
            } while (-not (Test-Path -Path "$JCRScriptRoot/JumpCloud.Radius.psd1"))

        }
        $Private = @( Get-ChildItem -Path "$JCRScriptRoot/Functions/Private/*.ps1" -Recurse)
        Foreach ($Import in $Private) {
            Try {
                . $Import.FullName
            } Catch {
                Write-Error -Message "Failed to import function $($Import.FullName): $_"
            }
        }
        # Import the module to set the global variable
        Import-Module -Name "$JCRScriptRoot/JumpCloud.Radius.psd1" -Force

        # get the current config.json contents
        $configFilePath = Join-Path -Path $JCRScriptRoot -ChildPath 'Config.json'
        $configBefore = Get-Content -Path $configFilePath
    }

    It "should confirm the config file exists" {
        # Check if the config file exists
        $configFilePath = Join-Path -Path $JCRScriptRoot -ChildPath 'Config.json'
        Test-Path -Path $configFilePath | Should -Be $true
    }
    It "should confirm the config file is valid JSON" {
        # Check if the config file is valid JSON
        $configFilePath = Join-Path -Path $JCRScriptRoot -ChildPath 'Config.json'
        $configContent = Get-Content -Path $configFilePath -Raw
        { ConvertFrom-Json -InputObject $configContent } | Should -Not -Throw
    }
    Context "When there is no config file" {
        BeforeEach {
            # Remove the config file if it exists
            $configFilePath = Join-Path -Path $JCRScriptRoot -ChildPath 'Config.json'
            if (Test-Path -Path $configFilePath) {
                Remove-Item -Path $configFilePath -Force
            }
        }

        It "should create a new config file" {
            # Call the function to create a new config file
            New-JCRConfig
            # Check if the config file exists
            Test-Path -Path $configFilePath | Should -Be $true
            # the config file should be valid JSON
            $configContent = Get-Content -Path $configFilePath -Raw
            { ConvertFrom-Json -InputObject $configContent } | Should -Not -Throw
            # Check if the config file contains the expected keys
        }
        Context "Individually Set all of the required settings but one, Confirm-JCRConfig should still throw" {
            BeforeEach {
                # Create a new config file
                New-JCRConfig -force
                # Get all the required settings
                $requiredSettings = $Global:JCRConfigTemplate.GetEnumerator() | Where-Object { $_.Value.required -eq $true }
                foreach ($setting in $requiredSettings) {
                    # Set each required setting
                    if ($setting.Value.type -eq 'hashtable') {
                        $stringData = $setting.Value.placeholder

                        # Remove the leading and trailing '@{' and '}'
                        $cleanStringData = $stringData -replace '^@{|}$', ''

                        # Convert the string data to a hashtable
                        $hashTable = ConvertFrom-StringData $cleanStringData

                        $param = @{ $setting.Key = $hashTable }
                    } else {
                        switch ($setting.Key) {
                            'radiusDirectory' {
                                $param = @{ $setting.Key = "$HOME" }
                            }
                            Default {
                                $param = @{ $setting.Key = $setting.Value.placeholder.replace('<', '').replace('>', '') }
                            }
                        }
                    }
                    Set-JCRConfig @param

                    # set one of the required settings to null
                    if ($setting.Key -eq 'openSSLBinary') {
                        $param = @{ $setting.Key = $null }
                        Set-JCRConfig @param
                    }
                }
            }
        }
    }
    Context "Validation for individual setting" {
        It "Should throw when a subject header contains a space" {
            # Set the certSubjectHeader with a space in the CommonName
            $param = @{
                certSubjectHeader = @{
                    CountryCode      = 'US'
                    StateCode        = 'CA'
                    Locality         = 'San Francisco'
                    Organization     = 'JumpCloud'
                    OrganizationUnit = 'Engineering'
                    CommonName       = 'Test User'  # Contains a space
                }
            }
            { Set-JCRConfig @param } | Should -Throw
        }
        It "Should throw when a string value is set for an 'int' type setting" {
            # Set a string value for an int type setting
            $param = @{ caCertValidityDays = 'NotAnInt' }
            { Set-JCRConfig @param } | Should -Throw
        }
    }
    AfterAll {
        # Restore the original config file contents
        $configFilePath = Join-Path -Path $JCRScriptRoot -ChildPath 'Config.json'
        if (Test-Path -Path $configFilePath) {
            Set-Content -Path $configFilePath -Value $configBefore
            $Global:JCRConfig = Get-JCRConfig -asObject
        }

        Write-Host "-----------------------"
        Write-Host "[Status] JCRConfig Settings:"
        foreach ($setting in $global:JCRConfig.PSObject.Properties) {
            Write-Host ("$($setting.Name): $($setting.Value.value)")
        }
        Write-Host "-----------------------"
    }
}