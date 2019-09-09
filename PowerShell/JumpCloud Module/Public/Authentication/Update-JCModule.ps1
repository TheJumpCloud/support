Function Update-JCModule
{
    Param(
        [Parameter(HelpMessage = 'Skips the "Uninstall-Module" step that will uninstall old version of the module.')][Switch]$SkipUninstallOld
        , [Parameter(HelpMessage = 'ByPasses user prompts.')][Switch]$Force
    )
    Begin
    {
        # Get the version of the module on the PowerShell Gallery
        $PowerShellGalleryModule = Find-Module -Name:('JumpCloud')
        # Get the version of the module installed locally
        $InstalledModulePreUpdate = Get-InstalledModule -Name:($PowerShellGalleryModule.Name) -AllVersions -ErrorAction:('Ignore')
        # Get module info from GitHub
        $ModuleBanner = Get-ModuleBanner
        $ModuleChangeLog = Get-ModuleChangeLog
        $ModuleChangeLogLatestVersion = $ModuleChangeLog | Where-Object { $_.Version -eq $PowerShellGalleryModule.Version }
        $WelcomePage = New-Object -TypeName:('PSCustomObject') | Select-Object `
        @{Name = 'Message'; Expression = { $ModuleBanner.'Banner Old' } } `
            , @{Name = 'Installed Version(s)'; Expression = { $InstalledModulePreUpdate | ForEach-Object { $_.Version + ' (' + (Get-Date $_.PublishedDate).ToString('MMMM dd, yyyy') + ')' } } } `
            , @{Name = 'Latest Version'; Expression = { $PowerShellGalleryModule | ForEach-Object { $_.Version + ' (' + (Get-Date $_.PublishedDate).ToString('MMMM dd, yyyy') + ')' } } } `
            , @{Name = 'Update Summary'; Expression = { $ModuleBanner.'Banner Current' } } `
            , @{Name = 'RELEASE NOTES'; Expression = { $ModuleChangeLogLatestVersion.'RELEASE NOTES' } } `
            , @{Name = 'FEATURES'; Expression = { $ModuleChangeLogLatestVersion.'FEATURES' } } `
            , @{Name = 'IMPROVEMENTS'; Expression = { $ModuleChangeLogLatestVersion.'IMPROVEMENTS' } } `
            , @{Name = 'BUG FIXES'; Expression = { $ModuleChangeLogLatestVersion.'BUG FIXES' } } `
            , @{Name = 'More info can be found at'; Expression = { 'https://github.com/TheJumpCloud/support/wiki' } }
        # , @{Name = 'Latest Version'; Expression = { $ModuleBanner.'Latest Version' + ' (' + $ModuleChangeLogLatestVersion.'RELEASE DATE' + ')' } }`
        # , @{Name = 'VERSION'; Expression = { $ModuleChangeLogLatestVersion.'VERSION' } }
        # , @{Name = 'RELEASE DATE'; Expression = { $ModuleChangeLogLatestVersion.'RELEASE DATE' } } `
        # , @{Name = 'ModuleBannerUrl'; Expression = { $ModuleBanner.'ModuleBannerUrl' } }
        # , @{Name = 'Full release notes available at'; Expression = { $ModuleChangeLogLatestVersion.'ModuleChangeLogUrl' } }
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
                Write-Error ('The ' + $PowerShellGalleryModule.Name + ' PowerShell module is not currently installed. To install the module please run the following command: Install-Module -Name ' + $PowerShellGalleryModule.Name + ' -force;' )
            }
            Else
            {
                # Populate status message
                $Status = If ($ModuleBanner.'Latest Version' -notin $InstalledModulePreUpdate.Version)
                {
                    'An update is available for the ' + $PowerShellGalleryModule.Name + ' PowerShell module.'
                }
                ElseIf ($ModuleBanner.'Latest Version' -in $InstalledModulePreUpdate.Version)
                {
                    'The ' + $PowerShellGalleryModule.Name + ' PowerShell module is up to date.'
                }
                Else
                {
                    Write-Error ('Unable to determine ' + $PowerShellGalleryModule.Name + ' PowerShell module install status.')
                }
                $WelcomePage = $WelcomePage | Select-Object @{Name = 'Status'; Expression = { $Status } }, *
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
                # Check to see if the module version on the GitHub page does not match the local module version begin the update process (update existing module)
                If ($ModuleBanner.'Latest Version' -notin $InstalledModulePreUpdate.Version)
                {
                    # Ask user if they want to update the module
                    If (!($Force))
                    {
                        Do
                        {
                            Write-Host ('Enter ''Y'' to update the ' + $PowerShellGalleryModule.Name + ' PowerShell module to the latest version or enter ''N'' to cancel:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_UserPrompt) -NoNewline
                            Write-Host (' ') -NoNewLine
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
                        Write-Host ('Exiting the ' + $PowerShellGalleryModule.Name + ' PowerShell module update process.') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Action)
                    }
                    Else
                    {
                        # Update the module to the latest version
                        Write-Host ('Updating ' + $PowerShellGalleryModule.Name + ' module to version: ') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Action) -NoNewline
                        Write-Host ($PowerShellGalleryModule.Version) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                        $InstalledModulePreUpdate | Update-Module -Force
                        # Remove existing module from the session
                        Get-Module -Name:($PowerShellGalleryModule.Name) -ListAvailable -All | Remove-Module -Force
                        # Uninstall previous versions
                        If (!($SkipUninstallOld))
                        {
                            $InstalledModulePreUpdate | ForEach-Object {
                                Write-Host ('Uninstalling ' + $_.Name + ' module version: ') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Action) -NoNewline
                                Write-Host ($_.Version) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                                $_ | Uninstall-Module -Force
                            }
                        }
                        # Validate install
                        $InstalledModulePostUpdate = Get-InstalledModule -Name:($PowerShellGalleryModule.Name) -AllVersions
                        # Check to see if the module version on the PowerShell gallery does not match the local module version
                        If ($PowerShellGalleryModule.Version -in $InstalledModulePostUpdate.Version)
                        {
                            # Load new module
                            Import-Module -Name:($PowerShellGalleryModule.Name) -Scope:('Global') -Force
                            # Confirm to user module update has been successful
                            Write-Host ('Status:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
                            Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
                            Write-Host ('The ' + $PowerShellGalleryModule.Name + ' PowerShell module has successfully been updated!') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                        }
                        Else
                        {
                            Write-Error ('Failed to update the ' + $PowerShellGalleryModule.Name + ' PowerShell module to the latest version.')
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