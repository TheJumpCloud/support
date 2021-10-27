Function Update-JCModule
{
    Param(
        [Parameter(HelpMessage = 'Skips the "Uninstall-Module" step that will uninstall old version of the module.')][Switch]$SkipUninstallOld
        , [Parameter(HelpMessage = 'ByPasses user prompts.')][Switch]$Force
        , [Parameter(DontShow, HelpMessage = 'Specify which repository to pull from.')][System.String]$Repository = 'PSGallery'
        , [Parameter(DontShow, HelpMessage = 'Specify the credentials for repository to pull from.')][System.Management.Automation.PSCredential]$RepositoryCredentials
    )
    Begin
    {
        $ModuleName = 'JumpCloud'
        # Find the module on the specified repository
        # Until PowerShellGet is updated to query nuget v3 modules, we need to determine PSGet versions ahead of function process block
        $PSGetModuleName = 'PowerShellGet'
        $PSGetLatestVersion = (Find-Module PowerShellGet -AllowPrerelease).Version
        $PSGet = Get-InstalledModule PowerShellGet
        $PSGetVersion = (Get-InstalledModule PowerShellGet).Version
        $PSGetSemanticRegex = [Regex]"[0-9]+.[0-9]+.[0-9]+"
        $PSGetSemeanticVersion = Select-String -InputObject $PSGet.Version -pattern ($PSGetSemanticRegex)
        $PSGetVersionMatch = $PSGetSemeanticVersion.Matches[0].Value.ToString()
        # $PSGetSemeanticVersion.Matches[0].Value # This should be the semantic version installed
        # Prelease regex
        # $PSGetPrereleaseRegex = [regex]"[0-9]+.[0-9]+.[0-9]+-(.*)"
        # $PSGetPrereleaseVersion = Select-String -InputObject $PSGet.Version -pattern ($PSGetPrereleaseRegex)
        # Convert base versions to semantic versioning so we can compare if the beta version of 3.0.11 is installed.
        # As of October 2021, powershell get 3.0.11 beta is required
        if ([System.Version]$PSGetVersionMatch -lt [System.Version]"3.0.11") {
            $PSGetBetaInstalled = $false
        }else {
            $PSGetBetaInstalled = $true
        }
        # If Repository Credneials are passed in, follow the flow to check for pre-release versions of the Module & SDKs
        If (-not [System.String]::IsNullOrEmpty($RepositoryCredentials))
        {
            if (-not $PSGetBetaInstalled) {
                If (!($Force))
                {
                    Do
                    {
                        Write-Host "$PSGetModuleName ($PSGetVersion) is installed but a newer version is required to interact with V3 nuget feeds. Enter ''Y'' to update the ' + $PSGetModuleName + ' PowerShell module to the latest version or enter ''N'' to cancel:"
                        Write-Host ('Enter ''Y'' to update the ' + $PSGetModuleName + ' module to the latest version ' + "($PSGetLatestVersion)" + ' or enter ''N'' to cancel:') #-BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_UserPrompt) -NoNewline
                        Write-Host (' ') -NoNewline
                        $UserInputPSGet = Read-Host
                    }
                    Until ($UserInputPSGet.ToUpper() -in ('Y', 'N'))
                }
                Else
                {
                    $UserInputPSGet = 'Y'
                }
                If ($UserInputPSGet.ToUpper() -eq 'N')
                {
                    Write-Host ('Exiting the ' + $ModuleName + ' PowerShell module update process.') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Action)
                }
                Else
                {
                    Install-Module -Name $PSGetModuleName -AllowPrerelease -Force
                    Import-Module $PSGetModuleName -Force
                }
            }
            else {
                Import-Module $PSGetModuleName
            }
            $FoundModule = Find-PSResource -Name:($ModuleName) -Repository:($Repository) -Credential:($RepositoryCredentials) -Prerelease
        }Else
        {
            $FoundModule = Find-Module -Name:($ModuleName) #-Repository:($Repository) -Credential:($RepositoryCredentials) -Prerelease
        }
        # Get the version of the module installed locally
        $InstalledModulePreUpdate = Get-InstalledModule -Name:($ModuleName) -AllVersions -ErrorAction:('Ignore')
        # if null and beta version of PSGet installed:
        if (($PSGetBetaInstalled) -And [System.String]::IsNullOrEmpty($InstalledModulePreUpdate)) {
            If (!($Force)){
                Do{
                    Write-Host "The $Module PowerShell module was not installed from any PSGallery repositories"
                    Write-Host "$PSGetModuleName ($PSGetVersion) is installed. Enter ''Y'' to search for $ModuleName PowerShell modules in a NugetV3 feed ''N'' to cancel:"
                    $UserInputSearch = Read-Host
                }
                Until ($UserInputSearch.ToUpper() -in ('Y', 'N'))
            }
            else{
                $UserInputSearch = 'Y'
            }
            If ($UserInputSearch.ToUpper() -eq 'N')
            {
                Write-Host ('Exiting the ' + $ModuleName + ' PowerShell module update process.') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Action)
            }
            Else
            {
                $InstalledModulePreUpdate = Get-InstalledPSResource -Name:($ModuleName) #-AllVersions -ErrorAction:('Ignore')
            }
        }
        If ([System.String]::IsNullOrEmpty($InstalledModulePreUpdate)){
        }
        # Get module info from GitHub - This should not impact the auto update ability, only the banner message
        $ModuleBanner = Get-ModuleBanner
        $ModuleChangeLog = Get-ModuleChangeLog
        # To change update dependency from PowerShell Gallery to Github flip the commented code below
        ###### $UpdateTrigger = $ModuleBanner.'Latest Version'
        if ($FoundModule.PrereleaseLabel){
            $UpdateTrigger = "$($FoundModule.Version)"
            $UpdateTriggerWithoutRevision = "$(($($FoundModule.Version)).Major).$(($($FoundModule.Version)).Minor).$(($($FoundModule.Version)).Build)"
            $UpdateTriggerFull = "$($FoundModule.Version)-$($FoundModule.PrereleaseLabel)"
            $UpdateTriggerFullRegex = [regex]"^[0-9]+.[0-9]+.[0-9]+.[0-9]+-(.*)"
            $UpdateTriggerFullDatetime = (Select-String -InputObject $UpdateTriggerFull -pattern ($UpdateTriggerFullRegex)).Matches.Groups[1].value
        }else{
            $UpdateTrigger = $FoundModule.Version
        }
        # Get the release notes for a specific version
        $ModuleChangeLogLatestVersion = $ModuleChangeLog | Where-Object { $_.Version -eq $UpdateTrigger }
        # To change update dependency from PowerShell Gallery to Github flip the commented code below
        ###### $LatestVersionReleaseDate = $ModuleChangeLogLatestVersion.'RELEASE DATE'
        If (-not [System.String]::IsNullOrEmpty($RepositoryCredentials)) {
            $LatestVersionReleaseDate = ($FoundModule | ForEach-Object { $_.Version.ToString() + ' (' + $foundModule.PrereleaseLabel + ')' })
        }Else{
            $LatestVersionReleaseDate = ($FoundModule | ForEach-Object { ($_.Version).ToString() + ' (' + (Get-Date $_.PublishedDate).ToString('yyyy-MM-dd') + ')' })
        }
        # $LatestVersionReleaseDate = ($FoundModule | ForEach-Object { ($_.Version).ToString() + ' (' + [datetime]::parseexact($foundModule.PrereleaseLabel, 'yyyyMMddHHmm', $null) + ')' })
        # $LatestVersionReleaseDate = [datetime]::parseexact($foundModule.PrereleaseLabel, 'yyyyMMddHHmm', $null)
        # $LatestVersionReleaseDate = ($FoundModule | ForEach-Object { ($_.Version).ToString() + ' (' + (Get-Date $_.foundModule.PrereleaseLabel).ToString('yyyyMMddHHmm') + ')' })
        # Build welcome page
        $WelcomePage = New-Object -TypeName:('PSCustomObject') | Select-Object `
        @{Name = 'MESSAGE'; Expression = { $ModuleBanner.'Banner Current' } } `
            , @{Name = 'INSTALLED VERSION(S)'; Expression = { $InstalledModulePreUpdate | ForEach-Object {
                    if ($InstalledModulePreUpdate.Repository -eq $Repository)
                    {
                        ($_.Version).ToString() + ' (' + [datetime]::parseexact($_.PrereleaseLabel, 'yyyyMMddHHmm', $null) + ')'
                    }
                    else
                    {
                        ($_.Version).ToString() + ' (' + (Get-Date $_.PublishedDate).ToString('yyyy-MM-dd HH:mm') + ')'
                    }
                } }
        } `
            , @{Name = 'LATEST VERSION'; Expression = { $UpdateTrigger + ' (' + (Get-Date $LatestVersionReleaseDate).ToString('yyyy-MM-dd HH:mm') + ')' } } `
            , @{Name = 'RELEASE NOTES'; Expression = { $ModuleChangeLogLatestVersion.'RELEASE NOTES' } } `
            , @{Name = 'FEATURES'; Expression = { $ModuleChangeLogLatestVersion.'FEATURES' } } `
            , @{Name = 'IMPROVEMENTS'; Expression = { $ModuleChangeLogLatestVersion.'IMPROVEMENTS' } } `
            , @{Name = 'BUG FIXES'; Expression = { $ModuleChangeLogLatestVersion.'BUG FIXES' } } `
            , @{Name = 'Learn more about the ' + $ModuleName + ' PowerShell module here'; Expression = { 'https://github.com/TheJumpCloud/support/wiki' } }
    }
    Process
    {
        # Load color scheme
        $JCColorConfig = Get-JCColorConfig
        Try
        {
            # Check to see if module is already installed
            If ([System.String]::IsNullOrEmpty($InstalledModulePreUpdate))
            {
                Write-Error ('The ' + $ModuleName + ' PowerShell module is not currently installed. To install the module please run the following command: Install-Module -Name ' + $ModuleName + ' -force;' )
            }
            Else
            {
                # Populate status message
                # [System.Version]($UpdateTrigger.ToString())
                # ($InstalledModulePreUpdate.Version | Select-Object -First 1)
                $latestVersionInstalled = ($InstalledModulePreUpdate.Version | Measure-Object -Maximum ).Maximum

                # [System.Version]($InstalledModulePreUpdate.Version.ToString())
                $Status = If ([System.Version]($UpdateTrigger.ToString()) -gt [System.Version]($latestVersionInstalled))
                {
                    'An update is available for the ' + $ModuleName + ' PowerShell module.'
                }ElseIf ($UpdateTrigger -in $InstalledModulePreUpdate.Version)
                {
                    'The ' + $ModuleName + ' PowerShell module is up to date.'
                }Else
                {
                    Write-Error ('Unable to determine ' + $ModuleName + ' PowerShell module install status.')
                }
                $WelcomePage = $WelcomePage | Select-Object @{Name = 'STATUS'; Expression = { $Status } }, *
                # Display message
                $WelcomePage.PSObject.Properties.Name | ForEach-Object {
                    If (-not [System.String]::IsNullOrEmpty($WelcomePage.($_)))
                    {
                        Write-Host (($_) + ': ') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
                        $WelcomePage.($_).Trim() -split ("`n") | ForEach-Object {
                            If (-not [System.String]::IsNullOrEmpty(($_)))
                            {
                                Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
                                If (($_) -like '*http*' -or ($_) -like '*www.*' -or ($_) -like '*.com*')
                                {
                                    Write-Host (($_).Trim())-BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Url)
                                }
                                ElseIf (($_) -like '*!!!*')
                                {
                                    Write-Host (($_).Replace('!!!', '').Trim())-BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Important)
                                }
                                Else
                                {
                                    Write-Host (($_).Trim())-BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                                }
                            }
                        }
                    }
                }
                # Check to see if the module version on the PowerShell Gallery does not match the local module version begin the update process (update existing module)
                If ($UpdateTrigger -notin $InstalledModulePreUpdate.Version)
                {
                    # Ask user if they want to update the module
                    If (!($Force))
                    {
                        Do
                        {
                            Write-Host ('Enter ''Y'' to update the ' + $ModuleName + ' PowerShell module to the latest version or enter ''N'' to cancel:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_UserPrompt) -NoNewline
                            Write-Host (' ') -NoNewline
                            $UserInput = Read-Host
                        }
                        Until ($UserInput.ToUpper() -in ('Y', 'N'))
                    }
                    Else
                    {
                        $UserInput = 'Y'
                    }
                    If ($UserInput.ToUpper() -eq 'N')
                    {
                        Write-Host ('Exiting the ' + $ModuleName + ' PowerShell module update process.') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Action)
                    }
                    Else
                    {
                        if (($InstalledModulePreUpdate.Repository -eq 'PSGallery') -And ($Repository -eq 'CodeArtifact')){
                            # PSGallery orig, updating to CodeArtifact Source
                            Write-Host ('Updating ' + $ModuleName + ' module to version: ') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Action) -NoNewline
                            Write-Host ($UpdateTrigger) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                            # install from CodeArtifact
                            Install-PSResource -Name:($ModuleName) -Repository:('CodeArtifact') -Credential:($RepositoryCredentials) -Prerelease -Reinstall;
                            # Remove existing module from the session
                            Get-Module -Name:($ModuleName) -ListAvailable -All | Remove-Module -Force
                            # Uninstall previous versions
                            If (!($SkipUninstallOld))
                            {
                                $InstalledModulePreUpdate | ForEach-Object {
                                    Write-Host ('Uninstalling ' + $_.Name + ' module version: ') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Action) -NoNewline
                                    Write-Host (($_.Version).ToString()) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                                    $_ | Uninstall-Module -Force
                                }
                            }
                            # Validate install
                            $InstalledModulePostUpdate = Get-InstalledPSResource -Name:($ModuleName)
                            # Check to see if the module version on the PowerShell gallery does not match the local module version
                            If (([System.Version]$UpdateTriggerWithoutRevision -eq [System.Version]($InstalledModulePostUpdate.Version | Measure-Object -Maximum ).Maximum) -And ([System.String]$UpdateTriggerFullDatetime -eq [System.String]($InstalledModulePostUpdate.PrereleaseLabel | Measure-Object -Maximum ).Maximum))
                            {
                                # Load new module
                                Import-Module -Name:($ModuleName) -Scope:('Global') -Force
                                # Confirm to user module update has been successful
                                Write-Host ('STATUS:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
                                Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
                                Write-Host ('The ' + $ModuleName + ' PowerShell module has successfully been updated!') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                            }
                            Else
                            {
                                Write-Error ("Failed to update the $($ModuleName) PowerShell module to the latest version. $($UpdateTrigger) is not in $($InstalledModulePostUpdate.Version -join ', ')")
                            }
                        }
                        elseif (($InstalledModulePreUpdate.Repository -eq 'CodeArtifact') -And ($Repository -eq 'CodeArtifact')) {
                            Write-Host ('Updating ' + $ModuleName + ' module to version: ') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Action) -NoNewline
                            Write-Host ($UpdateTrigger) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                            Install-PSResource -Name $ModuleName -Repository 'CodeArtifact' -Prerelease -Credential $RepositoryCredentials -Reinstall
                            # Remove existing module from the session
                            Get-Module -Name:($ModuleName) -ListAvailable -All | Remove-Module -Force
                            # Uninstall previous versions
                            If (!($SkipUninstallOld))
                            {
                                $InstalledModulePreUpdate | Where-Object { $_.PrereleaseLabel -ne $InstalledModulePreUpdate.PrereleaseLabel } | ForEach-Object {
                                    Write-Host ('Uninstalling ' + $_.Name + ' module version: ') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Action) -NoNewline
                                    Write-Host (($_.Version).ToString()) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                                    $_ | Uninstall-PSResource -Force
                                }
                            }
                            # Validate install
                            $InstalledModulePostUpdate = Get-InstalledPSResource -Name:($ModuleName)
                            # Check to see if the module version on the CA match the local module version
                            If (([System.Version]$UpdateTriggerWithoutRevision -eq [System.Version]($InstalledModulePostUpdate.Version | Measure-Object -Maximum ).Maximum) -And ([System.String]$UpdateTriggerFullDatetime -eq [System.String]($InstalledModulePostUpdate.PrereleaseLabel | Measure-Object -Maximum ).Maximum))
                            {
                                # Load new module
                                Import-Module -Name:($ModuleName) -Scope:('Global') -Force
                                # Confirm to user module update has been successful
                                Write-Host ('STATUS:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
                                Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
                                Write-Host ('The ' + $ModuleName + ' PowerShell module has successfully been updated!') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                            }
                            Else
                            {
                                Write-Error ("Failed to update the $($ModuleName) PowerShell module to the latest version. $($UpdateTrigger) is not in $($InstalledModulePostUpdate.Version -join ', ')")
                            }
                        }
                        else{
                            # TODO: Cover the case where Insatlled JC PS Module is lt, Found JC PS Module in PSGallery
                            # To test, Download, Install older version of the PS Module from CA, try and update using update-jcmodule.
                            # Update the module to the latest version
                            Write-Host ('Updating ' + $ModuleName + ' module to version: ') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Action) -NoNewline
                            Write-Host ($UpdateTrigger) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                            $InstalledModulePreUpdate | Update-Module -Force
                            # Remove existing module from the session
                            Get-Module -Name:($ModuleName) -ListAvailable -All | Remove-Module -Force
                            # Uninstall previous versions
                            If (!($SkipUninstallOld))
                            {
                                $InstalledModulePreUpdate | ForEach-Object {
                                    Write-Host ('Uninstalling ' + $_.Name + ' module version: ') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Action) -NoNewline
                                    Write-Host (($_.Version).ToString()) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                                    $_ | Uninstall-Module -Force
                                    #TODO: if insatlled version is from CA, Uninstall-PSResource
                                }
                            }
                            # Validate install
                            $InstalledModulePostUpdate = Get-InstalledModule -Name:($ModuleName) -AllVersions
                            # Check to see if the module version on the PowerShell gallery does not match the local module version
                            # TODO: These version casting statement don't work if multiple versions are installed, see prior elseif statement for reference
                            If ([System.Version]$UpdateTrigger -eq [System.Version]$InstalledModulePostUpdate.Version)
                            {
                                # Load new module
                                Import-Module -Name:($ModuleName) -Scope:('Global') -Force
                                # Confirm to user module update has been successful
                                Write-Host ('STATUS:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
                                Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
                                Write-Host ('The ' + $ModuleName + ' PowerShell module has successfully been updated!') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                            }
                            Else
                            {
                                Write-Error ("Failed to update the $($ModuleName) PowerShell module to the latest version. $($UpdateTrigger) is not in $($InstalledModulePostUpdate.Version -join ', ')")
                            }
                        }
                    }
                }
            }
        }
        Catch
        {
            Write-Error ($_)
        }
    }
    End
    {
    }
}