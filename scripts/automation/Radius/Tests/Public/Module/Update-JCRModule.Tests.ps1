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
        # get the local module path:
        $localModulePath = $env:PSModulePath.split(':')[0]
        # set the dev module path relative to this test:
        $devModulePath = "$PSScriptRoot/../../../"
        # module name
        $moduleName = "JumpCloud.Radius"
        # uninstall the module if it exists
        $installedModule = Get-InstalledModule -Name $moduleName -AllVersions -ErrorAction SilentlyContinue
        foreach ($module in $installedModule) {
            Uninstall-Module -Name $module.Name -Force -RequiredVersion $module.version
        }
        # remove the modules from the local module path
        $localNugetPkgs = Get-ChildItem -Path $localRepoPath -filter "$moduleName*.nupkg"
        foreach ($pkg in $localNugetPkgs) {
            Remove-Item -Path $pkg.FullName -Force
        }

        # module directory
        $moduleDirectory = Join-Path $localModulePath $moduleName
        # get the module version from the psd1 file
        $psd1Path = Join-Path $devModulePath "JumpCloud.Radius.psd1"
        $Psd1 = Import-PowerShellDataFile -Path:("$psd1Path")
        $moduleVersion = $Psd1.ModuleVersion

        # create the module directory within the local module path if it does not exist
        if (-NOT (Test-Path -Path $moduleDirectory)) {
            New-Item -Path $moduleDirectory -ItemType Directory
        }
        # create the version directory within the module directory if it does not exist
        $versionDirectory = Join-Path $moduleDirectory $moduleVersion
        # create the version directory within the module directory
        if (-NOT (Test-Path -Path $versionDirectory)) {
            New-Item -Path $versionDirectory -ItemType Directory
            # Copy all the contents from the parent folder to the destination folder
            Copy-Item -Path $devModulePath/* -Destination $versionDirectory -Recurse -Force -Exclude "Cert", "UserCerts", "images", "data", "users.json", "reports", "Tests", "deploy", "key.encrypted", "keyCert.encrypted", "log.txt", "changelog.md"
            # Publish the module to the local Repo
            Publish-Module -Name $moduleName -Repository $localRepoName -Force -RequiredVersion $moduleVersion
        } else {
            write-host "JumpCloud.Radius module v$ModuleVersion already exists"
        }

        # lastly populate the local module path with the JumpCloud Module from PS Gallery
        $latestJumpCloudModule = Find-Module -Name "JumpCloud" -Repository 'PSGallery' -ErrorAction Stop

        $content = Invoke-WebRequest -UseBasicParsing -Uri "https://www.powershellgallery.com/api/v2/package/JumpCloud/$($latestJumpCloudModule.version)" `
            -Headers @{
            "authority"       = "www.powershellgallery.com"
            "method"          = "GET"
            "path"            = "/api/v2/package/JumpCloud/$($latestJumpCloudModule.version)"
            "scheme"          = "https"
            "accept"          = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7"
            "accept-encoding" = "gzip, deflate, br, zstd"
            "accept-language" = "en-US,en;q=0.9,es;q=0.8"
            "referer"         = "https://www.powershellgallery.com/packages/JumpCloud/$($latestJumpCloudModule.version)"
        }
        $binaryData = $content.Content
        $filePath = Resolve-Path -Path $localRepoPath
        # Save the binary data to a file
        [System.IO.File]::WriteAllBytes("$($filePath.path)/JumpCloud.$($latestJumpCloudModule.version).nupkg", $binaryData)
    }
    Context 'Module can be installed from the local repo' {
        It 'Install Module' {
            # Install the module from the local repo
            $installModuleSplat = @{
                Name            = $moduleName
                Repository      = $localRepoName
                RequiredVersion = $moduleVersion
                Force           = $true
            }
            Install-Module @installModuleSplat
            # check that the module is installed:
            $installedModule = Get-InstalledModule -Name $moduleName
            $installedModule | Should -Not -BeNullOrEmpty
            $installedModule.version | Should -Be $moduleVersion
        }
    }
    Context 'When a new version of the module is available' {
        BeforeAll {
            # remove the module from the module directory
            Remove-Item -Path $moduleDirectory -Recurse -Force
            Install-Module -Name $moduleName -Repository $localRepoName -RequiredVersion $moduleVersion -Force

            # update the module manifest version to simulate a new version
            $newVersion = "$(([version]$moduleVersion).major).$(([version]$moduleVersion).minor).$(([version]$moduleVersion).build + 1)"
            Update-ModuleManifest -Path $psd1Path -ModuleVersion $newVersion

            # move the module to the local module path and publish it to the local repo
            # create the module directory within the local module path if it does not exist
            if (-NOT (Test-Path -Path $moduleDirectory)) {
                New-Item -Path $moduleDirectory -ItemType Directory
            }
            # create the version directory within the module directory if it does not exist
            $versionDirectory = Join-Path $moduleDirectory $newVersion
            # create the version directory within the module directory
            if (-NOT (Test-Path -Path $versionDirectory)) {
                New-Item -Path $versionDirectory -ItemType Directory
                # Copy all the contents from the parent folder to the destination folder
                Copy-Item -Path $devModulePath/* -Destination $versionDirectory -Recurse -Force -Exclude "Cert", "UserCerts", "images", "data", "users.json", "reports", "Tests", "deploy", "key.encrypted", "keyCert.encrypted", "log.txt", "changelog.md"
                # Publish the module to the local Repo
                Publish-Module -Name $moduleName -Repository $localRepoName -Force -RequiredVersion $newVersion
            } else {
                write-host "JumpCloud.Radius module v$newVersion already exists"
            }
            # import the local module
            Import-Module $psd1Path -Force
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