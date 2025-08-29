Describe 'Module Update' -Tag "Module" -skip {
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

        # local repo name:
        $localRepoName = 'LocalPSRepo'
        # get the registered repositories:
        $repositories = Get-PSRepository
        $localRepoPath = "~/$localRepoName"
        if ($localRepoName -notin $repositories.Name) {
            If (-not (Test-Path -Path $localRepoPath)) {
                # create the local file share
                New-Item -ItemType Directory -Path $localRepoPath -Force
            }
            $fullRepoPath = Resolve-Path $localRepoPath
            # Register a file share on the local machine
            $registerPSRepositorySplat = @{
                Name                 = $localRepoName
                SourceLocation       = $fullRepoPath.Path
                ScriptSourceLocation = $fullRepoPath.Path
                InstallationPolicy   = 'Trusted'
            }
            Register-PSRepository @registerPSRepositorySplat
        } else {
            Write-Host "LocalPSRepo already exists"
        }

        $requiredModules = @(
            'JumpCloud.SDK.V1',
            'JumpCloud.SDK.V2',
            'JumpCloud.SDK.DirectoryInsights',
            'JumpCloud'
        )
        foreach ($module in $requiredModules) {
            # Populate the local module path with the JumpCloud Module from PS Gallery
            $latestJumpCloudModule = Find-Module -Name "$module" -Repository 'PSGallery' -ErrorAction Stop

            # if the nuget package already exists in the local repo, skip downloading
            $foundModule = Find-Module -Name "$module" -Repository $localRepoName -ErrorAction SilentlyContinue #| Out-Null
            if ($foundModule.Name -eq $module) {
                Write-Host "Module $module already exists in the local repo: $localRepoPath"
                $filesFound = Get-ChildItem -Path $localRepoPath -Filter "$module*.nupkg"
                #print the file names:
                foreach ($file in $filesFound) {
                    Write-Host "Found file: $($file.FullName) in local repo: $localRepoPath"
                }
                continue
            }
            $content = Invoke-WebRequest -UseBasicParsing -Uri "https://www.powershellgallery.com/api/v2/package/$module/$($latestJumpCloudModule.version)" `
                -Headers @{
                "authority"       = "www.powershellgallery.com"
                "method"          = "GET"
                "path"            = "/api/v2/package/$module/$($latestJumpCloudModule.version)"
                "scheme"          = "https"
                "accept"          = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7"
                "accept-encoding" = "gzip, deflate, br, zstd"
                "accept-language" = "en-US,en;q=0.9,es;q=0.8"
                "referer"         = "https://www.powershellgallery.com/packages/$module/$($latestJumpCloudModule.version)"
            }
            $binaryData = $content.Content
            $filePath = Resolve-Path -Path $localRepoPath
            # Save the binary data to a file
            [System.IO.File]::WriteAllBytes("$($filePath.path)/$module.$($latestJumpCloudModule.version).zip", $binaryData)
            # create a local module path if it does not exist
            if (-not (Test-Path -Path "$($filePath.Path)/temp/$module")) {
                New-Item -Path "$($filePath.Path)/temp/$module" -ItemType Directory
                # create the version directory within the module path if it does not exist
                New-Item -Path "$($filePath.Path)/temp/$module/$($latestJumpCloudModule.version)" -ItemType Directory
                # Unzip the file to the local module path
                Expand-Archive -Path "$($filePath.path)/$module.$($latestJumpCloudModule.version).zip" -DestinationPath "$localRepoPath/temp/$module/$($latestJumpCloudModule.version)" -Force
            }
            publish-module -Path "$($filePath.Path)/temp/$module/$($latestJumpCloudModule.version)" -Repository $localRepoName
            # remove the zip file after publishing
            Remove-Item -Path "$($filePath.path)/$module.$($latestJumpCloudModule.version).zip" -Force
            # remove the module from the local module path if it exists
            Remove-Item -Path "$($filePath.path)/temp.$module" -Recurse -Force -ErrorAction SilentlyContinue
            # Print the LocalPSRepo File Contents:
            Write-Host "# LocalPSRepo File Contents after $module insert #"
            Get-ChildItem -Path $localRepoPath | ForEach-Object {
                # print the file type, name and size
                Write-Host "$($_.PSObject.TypeNames[0]) | $($_.Name) | $($_.Length) bytes"
            }
        }

        # Now publish the JumpCloud.Radius module to the local repo
        $devModulePath = "$JCRScriptRoot"
        $psd1Path = Join-Path $JCRScriptRoot "JumpCloud.Radius.psd1"
        $Psd1 = Import-PowerShellDataFile -Path:("$psd1Path")
        $moduleVersion = $Psd1.ModuleVersion
        $radiusModule = "JumpCloud.Radius"
        $filePath = Resolve-Path -Path $localRepoPath
        $radiusModuleDirectory = "$($filePath.Path)/temp/$radiusModule"

        # remove the module if it exists
        if (Test-Path -Path $radiusModuleDirectory) {
            # remove the module directory if it exists
            Remove-Item -Path $radiusModuleDirectory -Recurse -Force
        }
        # remove the .nupkg if it exists
        $localNugetPkgs = Get-ChildItem -Path $localRepoPath -Filter "$radiusModule*.nupkg"
        foreach ($pkg in $localNugetPkgs) {
            Remove-Item -Path $pkg.FullName -Force
        }
        New-Item -Path "$radiusModuleDirectory" -ItemType Directory
        # create the version directory within the module path if it does not exist
        New-Item -Path "$radiusModuleDirectory/$moduleVersion" -ItemType Directory
        # Copy all the contents from the parent folder to the destination folder
        Copy-Item -Path $devModulePath/* -Destination "$radiusModuleDirectory/$moduleVersion" -Recurse -Force -Exclude "Cert", "UserCerts", "images", "data", "users.json", "reports", "Tests", "deploy", "key.encrypted", "keyCert.encrypted", "log.txt", "changelog.md", "config.json"
        Publish-Module -Name "$radiusModuleDirectory/$moduleVersion" -Repository $localRepoName -Force -RequiredVersion $moduleVersion

        # Print the LocalPSRepo File Contents:
        Write-Host "# LocalPSRepo File Contents #"
        Get-ChildItem -Path $localRepoPath | ForEach-Object {
            # print the file type, name and size
            Write-Host "$($_.PSObject.TypeNames[0]) | $($_.Name) | $($_.Length) bytes"
        }
    }
    Context 'Module can be installed from the local repo' {
        BeforeAll {
            # Get installed Radius Modules:
            $installedModules = Get-InstalledModule -Name $radiusModule -AllVersions -ErrorAction SilentlyContinue
            # Uninstall the module if it exists
            foreach ($module in $installedModules) {
                Uninstall-Module -Name $module.Name -Force -RequiredVersion $module.version
            }
        }
        It 'Install Module' {
            # Install the module from the local repo
            write-host "Installing module $radiusModule from local repo $localRepoName with version $moduleVersion"

            install-Module -Name "JumpCloud.Radius" -Repository $localRepoName -RequiredVersion $moduleVersion
            # check that the module is installed:
            $installedModule = Get-InstalledModule -Name 'JumpCloud.Radius'
            $installedModule | Should -Not -BeNullOrEmpty
            $installedModule.version | Should -Be $moduleVersion
        }
        AfterAll {
            $moduleCheck = Get-Module -Name $radiusModule
            if ($moduleCheck) {
                Write-Host "Removing module $radiusModule from the session"
                Remove-Module -Name $radiusModule -Force
            } else {
                Write-Host "Module $radiusModule is not loaded in the session"
            }
        }
    }

    Context 'When a new version of the module is available' {
        BeforeAll {
            # remove the module from the module directory
            Remove-Item -Path $radiusModuleDirectory -Recurse -Force
            Install-Module -Name $radiusModule -Repository $localRepoName -RequiredVersion $moduleVersion

            # import the installed Module
            Write-Host "Importing module $radiusModule from local repo $localRepoName with version $moduleVersion"
            Import-Module -Name $radiusModule -force

            $moduleCheck = Get-Module -Name $radiusModule
            $moduleCheck | Should -Not -BeNullOrEmpty
            $moduleCheck.version | Should -Be $moduleVersion

            # populate the config:
            $settings = @{
                certType          = "UsernameCn"
                certSecretPass    = "secret1234!"
                radiusDirectory   = "$(Resolve-Path $HOME/RADIUS)"
                networkSSID       = "TP-Link_SSID"
                userGroup         = "111111111111111111111111"
                openSSLBinary     = 'openssl'
                certSubjectHeader = @{
                    CountryCode      = "US"
                    StateCode        = "CO"
                    Locality         = "Boulder"
                    Organization     = "JumpCloud"
                    OrganizationUnit = "Customer_Tools"
                    CommonName       = "JumpCloud.com"
                }
            }

            Set-JCRConfig @settings

            Write-Host "-----------------------"
            Write-Host "[status] Module Path : $($moduleCheck.Path)"
            Write-Host "[Status] JCRConfig Settings:"
            foreach ($setting in $global:JCRConfig.PSObject.Properties) {
                Write-Host ("$($setting.Name): $($setting.Value.value)")
            }
            Write-Host "-----------------------"

            # update the module manifest version to simulate a new version
            $newVersion = "$(([version]$moduleVersion).major).$(([version]$moduleVersion).minor).$(([version]$moduleVersion).build + 1)"
            Update-ModuleManifest -Path $psd1Path -ModuleVersion $newVersion

            # move the module to the local module path and publish it to the local repo
            # create the module directory within the local module path if it does not exist
            if (-NOT (Test-Path -Path $radiusModuleDirectory)) {
                New-Item -Path $radiusModuleDirectory -ItemType Directory
                # create the version directory within the module path if it does not exist
                New-Item -Path "$radiusModuleDirectory/$newVersion" -ItemType Directory
                # Copy all the contents from the parent folder to the destination folder
                Write-Warning "Copying module files from $devModulePath to the local repo for version $newVersion"
                Copy-Item -Path $devModulePath/* -Destination "$radiusModuleDirectory/$newVersion" -Recurse -Force -Exclude "Cert", "UserCerts", "images", "data", "users.json", "reports", "Tests", "deploy", "key.encrypted", "keyCert.encrypted", "log.txt", "changelog.md", "config.json"
                Publish-Module -Name "$radiusModuleDirectory/$newVersion" -Repository $localRepoName -Force -RequiredVersion $newVersion
            }

        }
        It 'Module can be updated from the local repo' {
            # update the module from the local repo
            $configFileBefore = Get-JCRConfig -asObject
            Update-JCRModule -Force -Repository $localRepoName
            # $updateModuleSplat = @{
            #     Name            = $moduleName
            #     RequiredVersion = $newVersion
            #     Force           = $true
            # }
            # Update-Module @updateModuleSplat -ErrorAction Stop | Out-Null
            # check that the module is updated:
            $updatedModule = Get-InstalledModule -Name $radiusModule
            $updatedModule | Should -Not -BeNullOrEmpty
            $updatedModule.version | Should -Be $newVersion

            # test that the config.json file contains the data from the previous module version
            $configFileAfter = Get-JCRConfig -asObject

            foreach ($property in $configFileBefore.PSObject.Properties) {
                # if the property is a hashtable, check each key-value pair
                if ($property.value.type -eq "hashtable") {
                    foreach ($key in $configFileAfter.$($property.Name).value.PSObject.Properties) {
                        $configFileAfter.$($property.Name).value.$($key.name) | Should -Be $key.Value
                        # Validate that the value is the same as before
                    }
                    continue
                } else {

                    $configFileAfter.$($property.Name).value | Should -Be $property.value.value
                }
            }

            # Validate that the extension files in /Extensions are updated from JCRConfig
            # print the $JCRScriptRoot
            Write-Host "JCRScriptRoot: $JCRScriptRoot"
            $extensionsDir = Join-Path $JCRScriptRoot "Extensions"
            Write-Host "Extensions Directory: $extensionsDir"
            # Validate the extension files exist:
            $extensionsFiles = Get-ChildItem -Path (Resolve-Path -Path $extensionsDir) -Filter "extensions-*.cnf"
            $extensionsFiles | Should -Not -BeNullOrEmpty
            foreach ($file in $extensionsFiles) {
                Write-Host "Found extension file: $($file.FullName)"
                $fileContent = Get-Content -Path $file.FullName -Raw
                # Validate that the file contains the expected headers
                $expectedHeaders = @(
                    "C = $($global:JCRConfig.certSubjectHeader.Value.CountryCode)",
                    "ST = $($global:JCRConfig.certSubjectHeader.Value.StateCode)",
                    "L = $($global:JCRConfig.certSubjectHeader.Value.Locality)",
                    "O = $($global:JCRConfig.certSubjectHeader.Value.Organization)",
                    "OU = $($global:JCRConfig.certSubjectHeader.Value.OrganizationUnit)",
                    "CN = $($global:JCRConfig.certSubjectHeader.Value.CommonName)"
                )
                foreach ($header in $expectedHeaders) {
                    $fileContent | Should -Match $header
                }
            }
            # Validate that the extensions files are valid with the function
            $extensionsValid = Test-JCRExtensionFile
            $extensionsValid | Should -BeTrue
        }
    }
    AfterAll {
        # reset the module version
        Update-ModuleManifest -Path $psd1Path -ModuleVersion $moduleVersion
    }
}