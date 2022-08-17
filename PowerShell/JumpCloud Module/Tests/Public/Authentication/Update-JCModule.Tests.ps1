Describe -Tag:('JCModule') 'Test for Update-JCModule' {
    It ("Where the local version number has been updated to match the $PesterParams_RequiredModulesRepo version number") {
        $EarliestVersion = Find-Module -Name:('JumpCloud') -AllVersions | Sort-Object PublishedDate | Select-Object -First 1
        Install-Module -Name:('JumpCloud') -RequiredVersion:($EarliestVersion.Version) -Scope:('CurrentUser') -Force
        $InitialModule = Get-Module -Name:('JumpCloud') -ListAvailable | Where-Object { $_.Version -eq $EarliestVersion.Version }
        $LocalModulePre = Get-Module -Name:('JumpCloud')
        Write-Host ("Local Version Before: $($LocalModulePre.Version)")
        If ($PesterParams_RequiredModulesRepo -eq 'PSGallery') {
            $PowerShellGalleryModule = Find-Module -Name:('JumpCloud')

            Write-Host ("$PesterParams_RequiredModulesRepo Version: $($PowerShellGalleryModule.Version)")

            Update-JCModule -SkipUninstallOld -Force
        } Else {
            $AWSRepo = 'jumpcloud-nuget-modules'
            $AWSDomain = 'jumpcloud-artifacts'
            $AWSRegion = 'us-east-1'
            # Set AWS authToken using context from CI Pipeline (context: aws-credentials)
            $authToken = Get-CAAuthorizationToken -Domain $AWSDomain -Region $AWSRegion
            If (-not [System.String]::IsNullOrEmpty($authToken)) {
                # Create Credential Object
                $RepositoryCredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $authToken.AuthorizationToken , ($authToken.AuthorizationToken | ConvertTo-SecureString -AsPlainText -Force)
            } Else {
                Write-Warning ('No authToken has been provided')
            }
            $PowerShellGalleryModule = Find-PSResource -Name:('JumpCloud') -Repository:($PesterParams_RequiredModulesRepo) -Credential:($RepositoryCredentials) -Prerelease
            Write-Host ("$PesterParams_RequiredModulesRepo Version: $($PowerShellGalleryModule.Version)")

            Update-JCModule -SkipUninstallOld -Force -CodeArtifact -RepositoryCredentials:($RepositoryCredentials)
        }
        $InitialModule | Remove-Module
        # Remove prerelease tag from build number
        $PowerShellGalleryModuleVersion = If ($PowerShellGalleryModule.IsPrerelease) {
            "$(($($PowerShellGalleryModule.Version)).Major).$(($($PowerShellGalleryModule.Version)).Minor).$(($($PowerShellGalleryModule.Version)).Build)"
        } Else {
            $PowerShellGalleryModule.Version
        }
        $LocalModulePost = Get-Module -Name:('JumpCloud') -ListAvailable | Where-Object { $_.Version -eq $PowerShellGalleryModuleVersion } | Get-Unique
        If ($LocalModulePost) {
            Write-Host ('Local Version After: ' + $LocalModulePost.Version)
            $LocalModulePost | Remove-Module
        } Else {
            Write-Error ('Unable to find latest version of the JumpCloud PowerShell module installed on local machine.')
        }
        $LocalModulePost.Version | Should -Be $PowerShellGalleryModuleVersion
        $LocalModulePost | Should -Not -BeNullOrEmpty
    }
    AfterAll {
        Import-Module -Name:("$PesterParams_ModuleManifestPath/$PesterParams_ModuleManifestName") -Force -Global
    }
    It ("When a previous version of an SDK is installed, Update-JCModule prompts to update and the next version of that SDK is insatlled") {
        # Get Installed SDKs
        $SDKlist = ('JumpCloud.SDK.v2', 'JumpCloud.SDK.v1', 'JumpCloud.SDK.directoryinsights')

        $latestSDKs += foreach ($SDK in $SDKlist) {
            Find-Module -Name $SDK
        }
        # Get-InstalledModule | Where-Object { $_.Name -match "JumpCloud.SDK" }
        $installedSDKs = Get-InstalledModule | Where-Object { $_.Name -match "JumpCloud.SDK" }
        $previousSDKs = @()
        # Get previous version of the SDKs
        foreach ($SDK in $latestSDKs) {
            # Find Previous Version
            try {
                Clear-Variable foundPrevious -ErrorAction Ignore
            } catch {
                Write-Debug "No Variable named 'foundPrevious' existed"
            }
            write-host "$($SDK.Name)"
            while (-not $foundPrevious) {
                try {
                    # $PreviousBuildVersion = ([Version]$SDK.Version).Build - 1
                    $PreviousVersion = [Version]::new(([Version]$SDK.Version).Major, ([Version]$SDK.Version).Minor, (([Version]$SDK.Version).Build - 1))
                    $foundPrevious = Find-Module -Name $SDK.Name -RequiredVersion $PreviousVersion
                } catch {
                    Write-Debug "no previous version found"
                }
                try {
                    $PreviousVersion = [Version]::new(([Version]$SDK.Version).Major, (([Version]$SDK.Version).Minor - 1), ([Version]$SDK.Version).Build)
                    $foundPrevious = Find-Module -Name $SDK.Name -RequiredVersion $PreviousVersion
                } catch {
                    Write-Debug "no previous version found"
                }
                try {
                    $PreviousVersion = [Version]::new((([Version]$SDK.Version).Major - 1), ([Version]$SDK.Version).Minor, ([Version]$SDK.Version).Build)
                    $foundPrevious = Find-Module -Name $SDK.Name -RequiredVersion $PreviousVersion
                } catch {
                    Write-Debug "no previous version found"
                }
            }
            $foundPrevious
            $previousSDKs += $foundPrevious
        }
        # Uninstall current version of Module the SDKs
        # Get-Module Jumpcloud | Remove-Module
        # Uninstall-Module -Name "JumpCloud" -Force
        # foreach ($SDK in $installedSDKs) {
        #     Get-Module -Name $SDK.Name | Remove-Module -Force
        #     Uninstall-Module -Name $SDK.Name -RequiredVersion $SDK.version -Force
        # }
        # Install Previous version of the SDKs
        foreach ($SDK in $previousSDKs) {
            Install-Module -Name $SDK.Name -RequiredVersion $SDK.version -Force
            # Importing will throw the assembly error (since we already have it loaded) / Check w/o importing
            # Import-Module -Name $SDK.Name -Force
        }
        # Import-Module -Name:("$PesterParams_ModuleManifestPath/$PesterParams_ModuleManifestName") -Force -Global
        # Run Update-JCModule with -Force
        Update-JCModule -Force
        # Installed Module Should be equal to versions from $installedSDKs (updates should have occured)
        $TestSDKs = Get-InstalledModule | Where-Object { $_.Name -match "JumpCloud.SDK" }
        # Test that the version of the TestSDKs is indeed the version of the LatestSDKs
        foreach ($sdk in $TestSDKs) {
            ($TestSDKs | Where-Object { $_.Name -eq $sdk.Name }).Version | Should -Not -Be ($previousSDKs | Where-Object { $_.Name -eq $sdk.Name }).Version
        }
    }
}
