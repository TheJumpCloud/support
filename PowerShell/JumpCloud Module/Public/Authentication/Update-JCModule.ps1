Function Update-JCModule
{
    Param(
        [Parameter(HelpMessage = 'Skips the "Uninstall-Module" step that will uninstall old version of the module.')][Switch]$SkipUninstallOld
        , [Parameter(HelpMessage = 'ByPasses user prompts.')][Switch]$Force
    )
    Begin
    {
        # Validate that the user is admin or that the PowerShell window has been started with admin privileges
        If ($PSVersionTable.PSVersion.Major -eq '5')
        {
            If (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
            {
                Write-Warning ('You must have Administrative rights to update the module! To retry close this PowerShell session and open a new PowerShell session with Administrator permissions (Right click the PowerShell application and select "Run as Administrator") and run the Connect-JCOnline command.')
                Return
            }
        }
        ElseIf ($PSVersionTable.PSVersion.Major -ge 6 -and $PSVersionTable.Platform -like "*Win*")
        {
            If (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
            {
                Write-Warning ('You must have Administrative rights to update the module! To retry close this PowerShell session and open a new PowerShell session with Administrator permissions (Right click the PowerShell application and select "Run as Administrator") and run the Connect-JCOnline command.')
                Return
            }
        }
        # Load color scheme
        $JCColorConfig = Get-JCColorConfig
        # Get the version of the module on the PowerShell Gallery
        $PowerShellGalleryModule = Find-Module -Name:('JumpCloud')
        # Get the version of the module installed locally
        $InstalledModulePreUpdate = Get-InstalledModule -Name:($PowerShellGalleryModule.Name) -ErrorAction:('Ignore')
        # Get module info from GitHub page
        $GitHubModuleInfo = Get-GitHubModuleInfo
        # Set release notes url
        $ReleaseNotesURL = 'https://git.io/jc-pwsh-releasenotes'
        # Get release notes from GitHub page
        $ReleaseNotesRaw = Invoke-WebRequest -Uri:($ReleaseNotesURL) -UseBasicParsing
        $ReleaseNotes = ((((($ReleaseNotesRaw.RawContent -split "</a>$($GitHubModuleInfo.LatestVersion)</h2>")[1]) -split "<pre><code>")[1]) -split "</code>")[0]
    }
    Process
    {
        Try
        {
            # Check to see if module is already installed
            If ([System.String]::IsNullOrEmpty($InstalledModulePreUpdate))
            {
                Write-Host ('Status:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
                Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
                Write-Host ('Fresh install of ' + $PowerShellGalleryModule.Name + ' PowerShell module.') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                Write-Host ('Message:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
                Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
                Write-Host ($GitHubModuleInfo.CurrentBanner) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                Write-Host ('Release Notes:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
                $ReleaseNotes.Trim().Split("`n") | ForEach-Object {
                    Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
                    Write-Host ($_.Trim())-BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                }
                Write-Host ('Full release notes available at:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
                Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
                Write-Host ($ReleaseNotesURL.Trim()) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Url)
                # Ask user if they want to install the module
                If (!($Force))
                {
                    Do
                    {
                        Write-Host ('Enter ''Y'' to install the ' + $PowerShellGalleryModule.Name + ' PowerShell module or enter ''N'' to cancel:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_UserPrompt) -NoNewline
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
                    Write-Host ('Exiting the ' + $PowerShellGalleryModule.Name + ' PowerShell module install process.') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Action)
                }
                Else
                {
                    # Install the latest version of the module (fresh install)
                    Write-Host ('Installing the ' + $PowerShellGalleryModule.Name + ' PowerShell module version:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Action) -NoNewline
                    Write-Host ($PowerShellGalleryModule.Version) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                    Install-Module -Name:($PowerShellGalleryModule.Name) -RequiredVersion:($PowerShellGalleryModule.Version) -Scope:('CurrentUser') -Force
                    # Validate install
                    $InstalledModulePostUpdate = Get-InstalledModule -Name:($PowerShellGalleryModule.Name)
                    # Check to see if the module version on the PowerShell gallery does not match the local module version
                    If ($PowerShellGalleryModule.Version -eq $InstalledModulePostUpdate.Version)
                    {
                        # Load new module
                        Import-Module -Name:($PowerShellGalleryModule.Name) -Scope:('Global') -Force
                        # Confirm to user module update has been successful
                        Write-Host ('Status:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
                        Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
                        Write-Host ('The ' + $PowerShellGalleryModule.Name + ' PowerShell module has successfully been installed!') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                    }
                    Else
                    {
                        Write-Error ('Failed to install the ' + $PowerShellGalleryModule.Name + ' PowerShell module.')
                    }
                }
            }
            Else
            {
                # Check to see if the module version on the GitHub page does not match the local module version begin the update process (update existing module)
                If ($GitHubModuleInfo.LatestVersion -ne $InstalledModulePreUpdate.Version)
                {
                    Write-Host ('Status:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
                    Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
                    Write-Host ('An update is available for the ' + $PowerShellGalleryModule.Name + ' PowerShell module.') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                    Write-Host ('Update Notification:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
                    Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
                    Write-Host ($GitHubModuleInfo.OldBanner) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                    Write-Host ('Installed Version:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
                    Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
                    Write-Host ($InstalledModulePreUpdate.Version) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                    Write-Host ('Latest Version:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
                    Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
                    Write-Host ($GitHubModuleInfo.LatestVersion) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)

                    Write-Host ('Message:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
                    Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
                    Write-Host ($GitHubModuleInfo.CurrentBanner) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                    Write-Host ('Release Notes:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
                    $ReleaseNotes.Trim().Split("`n") | ForEach-Object {
                        Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
                        Write-Host ($_.Trim())-BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                    }
                    Write-Host ('Full release notes available at:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
                    Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
                    Write-Host ($ReleaseNotesURL.Trim()) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Url)
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
                        Exit;
                    }
                    Else
                    {
                        # Update the module to the latest version
                        Write-Host ('Updating ' + $PowerShellGalleryModule.Name + ' module to version:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Action) -NoNewline
                        Write-Host ($PowerShellGalleryModule.Version) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                        $InstalledModulePreUpdate | Update-Module -Force
                        # Remove existing module from the session
                        Get-Module -Name:($PowerShellGalleryModule.Name) -All | Remove-Module -Force
                        Write-Host ('Removing from session old ' + $PowerShellGalleryModule.Name + ' module version:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Action) -NoNewline
                        Write-Host ($PowerShellGalleryModule.Version) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                        # Uninstall previous versions
                        If (!($SkipUninstallOld))
                        {
                            $InstalledModulePreUpdate | ForEach-Object {
                                Write-Host ('Uninstalling from system old ' + $_.Name + ' module version:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Action) -NoNewline
                                Write-Host ($_.Version) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                            } | Uninstall-Module -Force
                        }
                    }
                    # Validate install
                    $InstalledModulePostUpdate = Get-InstalledModule -Name:($PowerShellGalleryModule.Name)
                    # Check to see if the module version on the PowerShell gallery does not match the local module version
                    If ($PowerShellGalleryModule.Version -eq $InstalledModulePostUpdate.Version)
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
                Else
                {
                    Write-Host ('Status:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
                    Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
                    Write-Host ('The ' + $PowerShellGalleryModule.Name + ' PowerShell module is up to date.') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                    Write-Host ('Message:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
                    Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
                    Write-Host ($GitHubModuleInfo.CurrentBanner) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                    Write-Host ('Installed Version:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
                    Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
                    Write-Host ($InstalledModulePreUpdate.Version) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                    Write-Host ('Release Notes:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
                    $ReleaseNotes.Trim().Split("`n") | ForEach-Object {
                        Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
                        Write-Host ($_.Trim())-BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                    }
                    Write-Host ('Full release notes available at:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
                    Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
                    Write-Host ($ReleaseNotesURL.Trim()) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Url)
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