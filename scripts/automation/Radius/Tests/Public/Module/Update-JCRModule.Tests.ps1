Describe 'Module Update' -Tag "Module" {
    BeforeAll {
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
            Find-Module -Name "$module" -Repository $localRepoName -ErrorAction SilentlyContinue | Out-Null
            if ($?) {
                Write-Host "Module $module already exists in the local repo"
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
        }

        # # get the local module path:
        # $localModulePath = $env:PSModulePath.split(':')[0]
        # # set the dev module path relative to this test:
        # $devModulePath = "$PSScriptRoot/../../../"
        # # module name
        # $moduleName = "JumpCloud.Radius"
        # # uninstall the module if it exists
        # $installedModule = Get-InstalledModule -Name $moduleName -AllVersions -ErrorAction SilentlyContinue
        # foreach ($module in $installedModule) {
        #     Uninstall-Module -Name $module.Name -Force -RequiredVersion $module.version
        # }
        # # remove the modules from the local module path
        # $localNugetPkgs = Get-ChildItem -Path $localRepoPath -filter "$moduleName*.nupkg"
        # foreach ($pkg in $localNugetPkgs) {
        #     Remove-Item -Path $pkg.FullName -Force
        # }
        $devModulePath = "$PSScriptRoot/../../../"
        $psd1Path = Join-Path $devModulePath "JumpCloud.Radius.psd1"
        $Psd1 = Import-PowerShellDataFile -Path:("$psd1Path")
        $moduleVersion = $Psd1.ModuleVersion
        $radiusModule = "JumpCloud.Radius"
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
        Copy-Item -Path $devModulePath/* -Destination "$radiusModuleDirectory/$moduleVersion" -Recurse -Force -Exclude "Cert", "UserCerts", "images", "data", "users.json", "reports", "Tests", "deploy", "key.encrypted", "keyCert.encrypted", "log.txt", "changelog.md"
        Publish-Module -Name "$radiusModuleDirectory/$moduleVersion" -Repository $localRepoName -Force -RequiredVersion $moduleVersion
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
    }

    Context 'When a new version of the module is available' {
        BeforeAll {
            # remove the module from the module directory
            Remove-Item -Path $radiusModuleDirectory -Recurse -Force
            Install-Module -Name $radiusModule -Repository $localRepoName -RequiredVersion $moduleVersion -Force

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
                Copy-Item -Path $devModulePath/* -Destination "$radiusModuleDirectory/$newVersion" -Recurse -Force -Exclude "Cert", "UserCerts", "images", "data", "users.json", "reports", "Tests", "deploy", "key.encrypted", "keyCert.encrypted", "log.txt", "changelog.md"
                Publish-Module -Name "$radiusModuleDirectory/$newVersion" -Repository $localRepoName -Force -RequiredVersion $newVersion
            }

        }
        It 'Module can be updated from the local repo' {
            # update the module from the local repo
            Update-JCRModule -Force -Repository $localRepoName
            # $updateModuleSplat = @{
            #     Name            = $moduleName
            #     RequiredVersion = $newVersion
            #     Force           = $true
            # }
            # Update-Module @updateModuleSplat -ErrorAction Stop | Out-Null
            # check that the module is updated:
            $updatedModule = Get-InstalledModule -Name $moduleName
            $updatedModule | Should -Not -BeNullOrEmpty
            $updatedModule.version | Should -Be $newVersion
        }
    }
    AfterAll {
        # reset the module version
        update-modulemanifest -Path $psd1Path -ModuleVersion $moduleVersion
    }
}