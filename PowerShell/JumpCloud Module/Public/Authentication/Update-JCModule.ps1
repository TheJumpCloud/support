Function Update-JCModule {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    Param(
        [Parameter(HelpMessage = 'Skips the "Uninstall-Module" step that will uninstall old version of the module.')][Switch]$SkipUninstallOld
        , [Parameter(HelpMessage = 'ByPasses user prompts.')][Switch]$Force
        , [Parameter(DontShow, ParameterSetName = 'CodeArtifact', HelpMessage = 'Specify the credentials for repository to pull from.')][System.Management.Automation.PSCredential]$RepositoryCredentials
        , [Parameter(DontShow, ParameterSetName = 'CodeArtifact', HelpMessage = 'Switch to toggle CodeArtifact Updates')][Switch]$CodeArtifact
    )
    Begin {
        # Update Status
        $updateStatus = $false
        # JumpCloud Module Name
        $ModuleName = 'JumpCloud'
        # Module Names for the SDKs
        $SDKs = @('JumpCloud.SDK.DirectoryInsights'
            'JumpCloud.SDK.V2'
            'JumpCloud.SDK.V1')
        # Set Repository
        $Repository = if ($CodeArtifact) {
            'CodeArtifact'
        } else {
            'PSGallery'
        }
        # Module Root Path
        $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent.FullName

        # Get Modules & SDKs From Remote & Locally Installed
        if ($CodeArtifact) {
            $FoundModule = Get-JCLatestModule -ModuleName:($ModuleName) -Repository:($Repository) -RepositoryCredentials:($RepositoryCredentials) -CodeArtifact
            $FoundSDKs = foreach ($SDK in $SDKs) {
                Get-JCLatestModule -ModuleName:($SDK) -Repository:($Repository) -RepositoryCredentials:($RepositoryCredentials) -CodeArtifact
            }
            $InstalledModulePreUpdate = Get-JCInstalledModule -ModuleName:($ModuleName) -CodeArtifact
            $InstalledSDKsPreUpdate = foreach ($SDK in $SDKs) {
                Get-JCInstalledModule -ModuleName:($SDK) -CodeArtifact
            }
        } else {
            $FoundModule = Get-JCLatestModule -ModuleName:($ModuleName) -Repository:($Repository)
            $FoundSDKs = foreach ($SDK in $SDKs) {
                Get-JCLatestModule -ModuleName:($SDK) -Repository:($Repository)
            }
            $InstalledModulePreUpdate = Get-JCInstalledModule -ModuleName:($ModuleName)
            $InstalledSDKsPreUpdate = foreach ($SDK in $SDKs) {
                Get-JCInstalledModule -ModuleName:($SDK)
            }
        }

        # SDK Lists
        $SDKsToUninstall = @()
        $SDKsToUpdate = @()
        $SDKsUpToDate = @()
        $SDKsInstalledSummary = @()
        $SDKUpdateTable = @()
        $SDKResultsSummary = @()
        $SDKUninstallSummary = @()

        # Build welcome page
        $WelcomePage = New-Object -TypeName:('PSCustomObject')
    }
    Process {
        # Load color scheme
        $JCColorConfig = Get-JCColorConfig
        # Update SDKs
        # Gather info about the installed SDKs/ What needs to be updated/ removed
        # For each installed SDK, check if it's out of date
        foreach ($installedSDK in $InstalledSDKsPreUpdate) {
            $latest = $FoundSDKs | Where-Object { $_.Name -eq $($installedSDK.Name) }
            If ($installedSDK.Version -notin $latest.Version) {
                $SDKUpdateTable += [PSCustomObject]@{
                    'SDK Name'          = $($installedSDK.Name)
                    'Installed Version' = $($installedSDK.Version)
                    'Latest Version'    = $($latest.Version)
                    'Update Action'     = 'Update'
                }
                $SDKsToUpdate += $installedSDK
            } else {
                $SDKUpdateTable += [PSCustomObject]@{
                    'SDK Name'          = $($installedSDK.Name)
                    'Installed Version' = $($installedSDK.Version)
                    'Latest Version'    = $($latest.Version)
                    'Update Action'     = 'No Action'
                }
                $SDKsUpToDate += $installedSDK
            }
        }
        # Compare InstalledSDKs to the Up To Date List
        $ComparedSDKs = Compare-Object -ReferenceObject $InstalledSDKsPreUpdate -DifferenceObject $SDKsUpToDate -Property Version, Name -IncludeEqual
        # If multiple versions of an installed SDK exist, add to uninstall list - Here we deal with multiple versions
        $groupCompare = $ComparedSDKs | Group-Object Name
        foreach ($item in $groupCompare) {
            # Latest Installed, Older Installed as well
            if ('==' -in $item.group.sideIndicator) {
                $SDKsToUninstall += $item.Group | Where-Object { $_.SideIndicator -ne '==' }
            } elseif ($item.Count -gt 1 -and '==' -notin $item.group.sideIndicator) {
                $SDKsToUninstall += $item.Group | Sort-Object -Property Version -Descending | Select-Object -Skip 1
            }
        }
        # Compare InstalledSDKs to the Up To Date List, what remains should be our update list
        $ComparedSDKsToUpdate = Compare-Object -ReferenceObject $SDKsToUninstall -DifferenceObject $SDKsToUpdate -Property Version, Name
        # Update our update table to show the user:
        foreach ($updateItem in $SDKUpdateTable) {
            foreach ($uninstallItem in $SDKsToUninstall) {
                if (($updateItem.'SDK Name' -eq $uninstallItem.Name) -And ($($updateItem.'Installed Version')) -eq $uninstallItem.Version) {
                    If (!($SkipUninstallOld)) {
                        $updateItem.'Update Action' = 'Uninstall'
                    } else {
                        $updateItem.'Update Action' = 'No Action'
                    }
                }
            }
        }
        # If there are changes to the SDKs which should be made, prompt
        if (("Update" -in $SDKUpdateTable.'Update Action')) {
            # Populate status message
            $WelcomePage = $WelcomePage | Select-Object @{Name = 'STATUS'; Expression = { 'An update is available for the JumpCloud SDK module(s) PowerShell module.' } }, *
            $WelcomePage.PSObject.Properties.Name | ForEach-Object {
                If (-not [System.String]::IsNullOrEmpty($WelcomePage.($_))) {
                    Write-Host (($_) + ': ') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
                    $WelcomePage.($_).Trim() -split ("`n") | ForEach-Object {
                        If (-not [System.String]::IsNullOrEmpty(($_))) {
                            Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline

                            Write-Host (($_).Trim())-BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)

                        }
                    }
                }
            }
            # Write-Host "An update is avaiable for the installed JumpCloud SDK module(s)"
            if ($PSBoundParameters.Debug -eq $true) {
                $SDKUpdateTable | Format-Table | Out-Host
            } else {
                # Print streamlined version
                $SDKUpdateTable | Where-Object { ($_.'Update Action' -ne 'uninstall') -And ($_.'Update Action' -ne 'No Action') } | Select-Object 'SDK Name', 'Installed Version', 'Latest Version' | Format-Table | Out-Host
            }
            # Ask user if they want to update the module
            If (!($Force)) {
                Do {
                    Write-Host ('Enter ''Y'' to update the ' + $ModuleName + ' SDK modules to the latest version or enter ''N'' to cancel:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_UserPrompt) -NoNewline
                    Write-Host (' ') -NoNewline
                    $UserInput = Read-Host
                }
                Until ($UserInput.ToUpper() -in ('Y', 'N'))
            } Else {
                $UserInput = 'Y'
            }
            If ($UserInput.ToUpper() -eq 'N') {
                Write-Host ('Skipping the ' + $ModuleName + ' SDK module update process.')
            } Else {
                # For each SDK in update list where we need to update:
                foreach ($SDK in $SDKUpdateTable | Where-Object { $_."Update Action" -eq 'Update' }) {
                    try {
                        Write-Debug -Message "Running Command: Install-Module -Name $($SDK."SDK Name") -RequiredVersion $($SDK."Latest Version") -Force"
                        Install-Module -Name $($SDK."SDK Name") -RequiredVersion $($SDK."Latest Version") -Force
                        $SDKsInstalledSummary += [PSCustomObject]@{
                            'SDK Name'        = $($SDK."SDK Name")
                            'Target Version'  = $($SDK."Latest Version")
                            'Install Success' = $true
                        }
                    } catch {
                        $SDKsInstalledSummary += [PSCustomObject]@{
                            'SDK Name'        = $($SDK."SDK Name")
                            'Target Version'  = $($SDK."Latest Version")
                            'Install Success' = $false
                        }
                        Write-Warning -Message "$($SDK."SDK Name") Could not be updated automatically; run the following command to install manually:"
                        Write-Warning -Message "Install-Module -Name $($SDK."SDK Name") -RequiredVersion $($SDK."Latest Version") -Force"
                    }
                    # Get and remove the current module
                    Get-Module -Name:($SDK."SDK Name") -ListAvailable -All | Remove-Module -Force
                    try {
                        Write-Debug -Message "Running Command: Import-Module -Name $($SDK."SDK Name") -RequiredVersion $($SDK."Latest Version") -Force"
                        Import-Module $SDK."SDK Name" -RequiredVersion $($SDK."Latest Version") -Scope:('Global') -Force
                        $SDKResultsSummary += [PSCustomObject]@{
                            'SDK Name' = $($SDK."SDK Name")
                            'Imported' = $true
                        }
                    } catch {
                        Write-Debug -Message "Error: Import-Module -Name $($SDK."SDK Name") -RequiredVersion $($SDK."Latest Version") -Force"
                        $SDKResultsSummary += [PSCustomObject]@{
                            'SDK Name' = $($SDK."SDK Name")
                            'Imported' = $false
                        }
                    }
                    If (Get-InstalledModule -Name $($SDK."SDK Name") -RequiredVersion $($SDK."Installed Version")) {
                        Try {
                            Write-Debug -Message "Running Command: Uninstall-Module -Name $($SDK."SDK Name") -RequiredVersion $($SDK."Installed Version") -Force"
                            Uninstall-Module -Name $($SDK."SDK Name") -RequiredVersion $($SDK."Installed Version") -Force
                            $SDKUninstallSummary += [PSCustomObject]@{
                                'SDK Name'            = $($SDK."SDK Name")
                                'Uninstalled Version' = $($SDK."Installed Version")
                                'Uninstalled'         = $true
                            }
                        } Catch {
                            Write-Warning -Message "Could not uninstall $($SDK."SDK Name") $($SDK."Installed Version")"
                            $SDKUninstallSummary += [PSCustomObject]@{
                                'SDK Name'            = $($SDK."SDK Name")
                                'Uninstalled Version' = $($SDK."Installed Version")
                                'Uninstalled'         = $false
                            }
                        }
                    }
                }
                # For each SDK in uninstall list
                If (!($SkipUninstallOld)) {
                    if ($PSBoundParameters.Debug -eq $true -And $SDKsToUninstall.Count -ge 1) {
                        Write-Debug "The following out-of-date SDK Module(s) will be uninstalled"
                        $SDKUpdateTable | Where-Object { $_.'Update Action' -eq 'uninstall' } | Format-Table | Out-Host
                    }
                    foreach ($SDK in $SDKUpdateTable | Where-Object { $_."Update Action" -eq 'Uninstall' }) {
                        If (Get-InstalledModule -Name $($SDK."SDK Name") -RequiredVersion $($SDK."Installed Version")) {
                            Try {
                                Write-Debug -Message "Running Command: Uninstall-Module -Name $($SDK."SDK Name") -RequiredVersion $($SDK."Installed Version") -Force"
                                Uninstall-Module -Name $($SDK."SDK Name") -RequiredVersion $($SDK."Installed Version") -Force
                                $SDKUninstallSummary += [PSCustomObject]@{
                                    'SDK Name'            = $($SDK."SDK Name")
                                    'Uninstalled Version' = $($SDK."Installed Version")
                                    'Uninstalled'         = $true
                                }
                            } Catch {
                                Write-Warning -Message "Could not uninstall $($SDK."SDK Name") $($SDK."Installed Version")"
                                $SDKUninstallSummary += [PSCustomObject]@{
                                    'SDK Name'            = $($SDK."SDK Name")
                                    'Uninstalled Version' = $($SDK."Installed Version")
                                    'Uninstalled'         = $false
                                }
                            }
                        }
                    }
                }
            }
        }
        # Check to see if module is already installed
        If ([System.String]::IsNullOrEmpty($InstalledModulePreUpdate)) {
            Write-Error ('The ' + $ModuleName + ' PowerShell module is not currently installed. To install the module please run the following command: Install-Module -Name ' + $ModuleName + ' -force;' )
        } Else {
            # Populate status message
            $Status = If ($FoundModule.Version -notin $InstalledModulePreUpdate.Version) {
                'An update is available for the ' + $ModuleName + ' PowerShell module.'
            } ElseIf ($FoundModule.Version -in $InstalledModulePreUpdate.Version) {
                'The ' + $ModuleName + ' PowerShell module is up to date.'
            } Else {
                Write-Error ('Unable to determine ' + $ModuleName + ' PowerShell module install status.')
            }
            # Build the welcomePage Message
            $WelcomePage = New-Object -TypeName:('PSCustomObject') | Select-Object `
            @{Name = 'INSTALLED VERSION(S)'; Expression = { $InstalledModulePreUpdate | ForEach-Object { ($_.Version).ToString() + ' (' + (Get-Date $_.PublishedDate).ToString('MMMM dd, yyyy') + ')' } } }
            If ($FoundModule.Version -notin $InstalledModulePreUpdate.Version) {
                # If there is an update, display the latest version
                $versionString = $FoundModule.Version + ' (' + (Get-Date $FoundModule.PublishedDate).ToString('MMMM dd, yyyy') + ')'
                $WelcomePage | Add-Member -MemberType NoteProperty -Name "LATEST VERSION" -Value $versionString
            }
            $WelcomePage | Add-Member -MemberType NoteProperty -Name "Learn more about the $ModuleName PowerShell module here" -Value "https://github.com/TheJumpCloud/support/wiki"
            $WelcomePage = $WelcomePage | Select-Object @{Name = 'STATUS'; Expression = { $Status } }, *
            # Display message
            $WelcomePage.PSObject.Properties.Name | ForEach-Object {
                If (-not [System.String]::IsNullOrEmpty($WelcomePage.($_))) {
                    Write-Host (($_) + ': ') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
                    $WelcomePage.($_).Trim() -split ("`n") | ForEach-Object {
                        If (-not [System.String]::IsNullOrEmpty(($_))) {
                            Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
                            If (($_) -like '*http*' -or ($_) -like '*www.*' -or ($_) -like '*.com*') {
                                Write-Host (($_).Trim())-BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Url)
                            } ElseIf (($_) -like '*!!!*') {
                                Write-Host (($_).Replace('!!!', '').Trim())-BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Important)
                            } Else {
                                Write-Host (($_).Trim())-BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                            }
                        }
                    }
                }
            }
            # Check to see if the module version on the PowerShell Gallery does not match the local module version begin the update process (update existing module)
            If ($FoundModule.Version -notin $InstalledModulePreUpdate.Version) {
                # Ask user if they want to update the module
                If (!($Force)) {
                    Do {
                        Write-Host ('Enter ''Y'' to update the ' + $ModuleName + ' PowerShell module to the latest version or enter ''N'' to cancel:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_UserPrompt) -NoNewline
                        Write-Host (' ') -NoNewline
                        $UserInput = Read-Host
                    }
                    Until ($UserInput.ToUpper() -in ('Y', 'N'))
                } Else {
                    $UserInput = 'Y'
                }
                If ($UserInput.ToUpper() -eq 'N') {
                    Write-Host ('Exiting the ' + $ModuleName + ' PowerShell module update process.') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Action)
                } Else {
                    # Get the module config from the current module:
                    try {
                        $savedJCSettings = Get-JCSettingsFile -raw
                    } catch {
                        Write-Warning ('Could not copy JumpCloud Module Settings')
                    }
                    # Update the module to the latest version
                    Write-Host ('Updating ' + $ModuleName + ' module to version: ') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Action) -NoNewline
                    Write-Host ($FoundModule.Version) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                    If (-not [System.String]::IsNullOrEmpty($RepositoryCredentials)) {
                        # SkipDependancy, we manage SDKs seperatly
                        $InstalledModulePreUpdate | Update-PSResource -Credential $RepositoryCredentials -Repository CodeArtifact -Prerelease -Force -SkipDependencyCheck
                    } Else {
                        Install-Module -Repository:($Repository) -Name:($ModuleName) -RequiredVersion:($FoundModule.Version) -Force
                    }
                    # Remove existing module from the session
                    if (-Not $CodeArtifact) {
                        Get-Module -Name:($ModuleName) -ListAvailable -All | Remove-Module -Force
                        If (!($SkipUninstallOld)) {
                            $InstalledModulePreUpdate | ForEach-Object {
                                Write-Host ('Uninstalling ' + $_.Name + ' module version: ') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Action) -NoNewline
                                Write-Host (($_.Version).ToString()) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                                Uninstall-Module -Name:($_.Name) -RequiredVersion:($_.Version) -Force
                            }
                        } else {
                            Get-Module -Name:($ModuleName) -ListAvailable -All | Remove-Module -Force
                        }
                    }
                    # Uninstall previous versions
                    # Validate install
                    if ($CodeArtifact) {
                        $InstalledModulePostUpdate = Get-JCInstalledModule -ModuleName:($ModuleName) -CodeArtifact
                    } else {
                        $InstalledModulePostUpdate = Get-JCInstalledModule -ModuleName:($ModuleName)
                    }

                    # Check to see if the module version on the PowerShell gallery does not match the local module version
                    $updateCheck = If ($CodeArtifact) {
                        if ($FoundModule.Prerelease -eq $InstalledModulePostUpdate.Prerelease) {
                            $true
                        } else {
                            $false
                        }

                    } else {
                        if ($FoundModule.Version -in $InstalledModulePostUpdate.Version) {
                            $true
                        } else {
                            $false
                        }
                    }
                    # Just compare the Major.Minor.Build Versions
                    If ($updateCheck) {
                        # Load new module
                        Import-Module -Name:($ModuleName) -Scope:('Global') -Force -RequiredVersion $FoundModule.Version
                        # Copy saved settings to new config.json
                        if (-Not ($savedJCSettings)::IsNullOrEmpty) {
                            # Get private settings functions:
                            $SettingsFunctionsDir = join-path -path $ModuleRoot -childpath 'private/settings'
                            $regpattern = [regex]"(\/|\\)(\d+\.)?(\d+\.)?(\*|\d+)(\/|\\)"
                            $SettingsFunctionsDir = $SettingsFunctionsDir -replace $regpattern, "/$($FoundModule.Version)/"
                            $Private = @( Get-ChildItem -Path $SettingsFunctionsDir -Recurse)
                            Foreach ($Import in @($Private)) {
                                Try {
                                    # Import the functions into the session
                                    . $Import.FullName
                                } Catch {
                                    Write-Error -Message "Failed to import function $($Import.FullName): $_"
                                }
                            }
                            # update the settings file config.json
                            Update-JCSettingsFile -settings $savedJCSettings
                            # re-import the settings file variable
                            $global:JCConfig = Get-JCSettingsFile
                        }
                        # Confirm to user module update has been successful
                        Write-Host ('STATUS:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
                        Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
                        Write-Host ('The ' + $ModuleName + ' PowerShell module has successfully been updated!') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                        # function should return true if we update the module
                        $updateStatus = $true
                    } Else {
                        Write-Error ("Failed to update the $($ModuleName) PowerShell module to the latest version. $($FoundModule.Version) is not in $($InstalledModulePostUpdate.Version -join ', ')")
                    }
                }
            }
        }
    }
    End {
        if ($SDKUninstallSummary) {
            if ($false -in $SDKUninstallSummary.Uninstalled) {
                if ($PSBoundParameters.Debug -eq $true) {
                    Write-Warning "One or more of the previous SDK modules could not be uninstalled in this session"
                    Write-Warning "Please restart this powershell session"
                    Write-Debug "The following modules were unabled to be uninstalled:"
                    $SDKUninstallSummary | Format-Table | Out-Host
                }
            } else {
                Write-Debug "The following modules were uninstalled:"
                $SDKUninstallSummary | Format-Table | Out-Host
            }
        }
        if ($SDKResultsSummary) {
            If ($false -in $SDKResultsSummary.Imported) {
                Write-Warning "One or more of the updated SDK modules could not be imported to this session"
                Write-Warning "Please restart this powershell session to use the new SDK module(s)"
                if ($PSBoundParameters.Debug -eq $true) {
                    $SDKResultsSummary | Format-Table | Out-Host
                }
            } else {
                if ($PSBoundParameters.Debug -eq $true) {
                    Write-Debug "The following modules were sucessfully updated:"
                    $SDKResultsSummary | Format-Table | Out-Host
                }
            }
        }
        if ($updateStatus) {
            Return $true
        } else {
            Return $false
        }
    }
}
