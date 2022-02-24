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
        $SDKs = @('JumpCloud.SDK.DirectoryInsights'
            'JumpCloud.SDK.V2'
            'JumpCloud.SDK.V1')
        If (-not [System.String]::IsNullOrEmpty($RepositoryCredentials))
        {
            $FoundModule = Find-Module -Name:($ModuleName) -Repository:($Repository) -Credential:($RepositoryCredentials) -AllowPrerelease
            $FoundSDKs = foreach ($SDK in $SDKs)
            {
                Find-Module -Name:($SDK) -Repository:($Repository) -Credential:($RepositoryCredentials) -AllowPrerelease
            }
        }
        Else
        {
            $FoundModule = Find-Module -Name:($ModuleName) -Repository:($Repository)
            $FoundSDKs = foreach ($SDK in $SDKs)
            {
                Find-Module -Name:($SDK) -Repository:($Repository)
            }
        }
        # Get the version of the module installed locally
        $InstalledModulePreUpdate = Get-InstalledModule -Name:($ModuleName) -AllVersions -ErrorAction:('Ignore')
        $InstalledSDKsPreUpdate = foreach ($SDK in $SDKs)
        {
            Get-InstalledModule -Name:($SDK) -AllVersions -ErrorAction:('Ignore')
        }
        # Get module info from GitHub - This should not impact the auto update ability, only the banner message
        $ModuleBanner = Get-ModuleBanner
        $ModuleChangeLog = Get-ModuleChangeLog
        ###### $UpdateTrigger = $ModuleBanner.'Latest Version'
        $UpdateTrigger = $FoundModule.Version

        # SDK Lists
        $SDKsToUninstall = @()
        $SDKsToUpdate = @()
        $SDKsUpToDate = @()
        $SDKsInstalledSummary = @{}
        $SDKUpdateTable = @()
        $SDKResultsSummary = @()
        $SDKUninstallSummary = @()
        # Get the release notes for a specific version
        $ModuleChangeLogLatestVersion = $ModuleChangeLog | Where-Object { $_.Version -eq $UpdateTrigger }
        # To change update dependency from PowerShell Gallery to Github flip the commented code below
        ###### $LatestVersionReleaseDate = $ModuleChangeLogLatestVersion.'RELEASE DATE'
        $LatestVersionReleaseDate = ($FoundModule | ForEach-Object { ($_.Version).ToString() + ' (' + (Get-Date $_.PublishedDate).ToString('MMMM dd, yyyy') + ')' })
        # Build welcome page
        $WelcomePage = New-Object -TypeName:('PSCustomObject') | Select-Object `
        @{Name = 'MESSAGE'; Expression = { $ModuleBanner.'Banner Current' } } `
            , @{Name = 'INSTALLED VERSION(S)'; Expression = { $InstalledModulePreUpdate | ForEach-Object { ($_.Version).ToString() + ' (' + (Get-Date $_.PublishedDate).ToString('MMMM dd, yyyy') + ')' } } } `
            , @{Name = 'LATEST VERSION'; Expression = { $UpdateTrigger + ' (' + (Get-Date $LatestVersionReleaseDate).ToString('MMMM dd, yyyy') + ')' } } `
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
        # Update SDKs
        # Gather info about the installed SDKs/ What needs to be updated/ removed
        # For each installed SDK, check if it's out of date
        foreach ($installedSDK in $InstalledSDKsPreUpdate)
        {
            $latest = $FoundSDKs | Where-Object { $_.Name -eq $($installedSDK.Name) }
            If ($installedSDK.Version -notin $latest.Version)
            {
                $SDKUpdateTable += [PSCustomObject]@{
                    'SDK Name'          = $($installedSDK.Name)
                    'Installed Version' = $($installedSDK.Version)
                    'Latest Version'    = $($latest.Version)
                    'Update Action'     = 'Update'
                }
                $SDKsToUpdate += $installedSDK
            }
            else
            {
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
        foreach ($item in $groupCompare)
        {
            # Latest Installed, Older Installed as well
            if ('==' -in $item.group.sideIndicator)
            {
                $SDKsToUninstall += $item.Group | Where-Object { $_.SideIndicator -ne '==' }
            }
            elseif ($item.Count -gt 1 -and '==' -notin $item.group.sideIndicator)
            {
                $SDKsToUninstall += $item.Group | Sort-Object -Property Version -Descending | Select-Object -Skip 1
            }
        }
        # Compare InstalledSDKs to the Up To Date List, what remains should be our update list
        $ComparedSDKsToUpdate = Compare-Object -ReferenceObject $SDKsToUninstall -DifferenceObject $SDKsToUpdate -Property Version, Name
        # Update our update table to show the user:
        foreach ($updateItem in $SDKUpdateTable)
        {
            foreach ($uninstallItem in $SDKsToUninstall)
            {
                if (($updateItem.'SDK Name' -eq $uninstallItem.Name) -And ($($updateItem.'Installed Version')) -eq $uninstallItem.Version)
                {
                    If (!($SkipUninstallOld))
                    {
                        $updateItem.'Update Action' = 'Uninstall'
                    }
                    else
                    {
                        $updateItem.'Update Action' = 'No Action'
                    }
                }
            }
        }
        # If there are changes to the SDKs which should be made, prompt
        if (("Update" -in $SDKUpdateTable.'Update Action'))
        {
            Write-Host "An update is avaiable for the installed JumpCloud SDK module(s)"
            if ($PSBoundParameters.Debug -eq $true) {
                $SDKUpdateTable | Format-Table | Out-Host
            }
            else{
                # Print streamlined version
                $SDKUpdateTable | Where-Object { ($_.'Update Action' -ne 'uninstall') -And ($_.'Update Action' -ne 'No Action') } | Select-Object 'SDK Name', 'Installed Version', 'Latest Version' | Format-Table | Out-Host
            }
            # Ask user if they want to update the module
            If (!($Force))
            {
                Do
                {
                    Write-Host ('Enter ''Y'' to update the SDK modules or enter ''N'' to cancel:')
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
                Write-Host ('Skipping the ' + $ModuleName + ' SDK module update process.')
            }
            Else
            {
                # For each SDK in update list
                foreach ($SDK in $ComparedSDKsToUpdate)
                {
                    try
                    {
                        Update-Module -Name $SDK.Name -Force
                        $SDKsInstalledSummary.Add($SDK.Name, 'Success')
                    }
                    catch
                    {
                        $SDKsInstalledSummary.Add($SDK.Name, 'Failure')
                        Write-Warning -Message "$($SDK.Name) Could not be updated automatically; run the following command to install manually:"
                        Write-Warning -Message "Install-Module -Name $($SDK.Name)"
                    }
                    # Get and remove the current module
                    Get-Module -Name:($SDK.Name) -ListAvailable -All | Remove-Module -Force
                    try
                    {
                        Import-Module $SDK.Name -Scope:('Global') -Force
                        $SDKResultsSummary += [PSCustomObject]@{
                            'SDK Name' = $($SDK.Name)
                            'Imported' = $true
                        }
                    }
                    catch
                    {
                        $SDKResultsSummary += [PSCustomObject]@{
                            'SDK Name' = $($SDK.Name)
                            'Imported' = $false
                        }
                    }
                    If (Get-InstalledModule -Name $($SDK.Name) -RequiredVersion $($SDK.Version)){
                        Try {
                            Uninstall-Module -Name $($SDK.Name) -RequiredVersion $($SDK.Version)
                            $SDKUninstallSummary += [PSCustomObject]@{
                                'SDK Name'            = $($SDK.Name)
                                'Uninstalled Version' = $($SDK.Version)
                                'Uninstalled'         = $true
                            }
                        }
                        Catch{
                                Write-Warning -Message "Could not uninstall $($SDK.Name) $($SDK.Version)"
                                $SDKUninstallSummary += [PSCustomObject]@{
                                    'SDK Name'            = $($SDK.Name)
                                    'Uninstalled Version' = $($SDK.Version)
                                    'Uninstalled'         = $false
                                }
                        }
                    }
                }
            }
        }
        # For each SDK in uninstall list
        If (!($SkipUninstallOld))
        {
            if ($PSBoundParameters.Debug -eq $true -And $SDKsToUninstall.Count -ge 1) {
                Write-Debug "The following out-of-date SDK Module(s) will be uninstalled"
                $SDKUpdateTable | Where-Object { $_.'Update Action' -eq 'uninstall' } | Format-Table | Out-Host
            }
            foreach ($SDK in $SDKsToUninstall)
            {
                # Write-Host ('Uninstalling ' + $SDK.Name + ' module version: ' + $SDK.Version)
                try
                {
                    Uninstall-Module -Name $SDK.Name -RequiredVersion $SDK.Version -Force
                    $SDKUninstallSummary += [PSCustomObject]@{
                        'SDK Name'            = $($SDK.Name)
                        'Uninstalled Version' = $($SDK.Version)
                        'Uninstalled'         = $true
                    }
                }
                catch
                {
                    Write-Warning -Message "Could not uninstall $($SDK.Name) $($SDK.Version)"
                    $SDKUninstallSummary += [PSCustomObject]@{
                        'SDK Name'            = $($SDK.Name)
                        'Uninstalled Version' = $($SDK.Version)
                        'Uninstalled'         = $false
                    }
                }
            }
        }
        # Check to see if module is already installed
        If ([System.String]::IsNullOrEmpty($InstalledModulePreUpdate))
        {
            Write-Error ('The ' + $ModuleName + ' PowerShell module is not currently installed. To install the module please run the following command: Install-Module -Name ' + $ModuleName + ' -force;' )
        }
        Else
        {
            # Populate status message
            $Status = If ($UpdateTrigger -notin $InstalledModulePreUpdate.Version)
            {
                'An update is available for the ' + $ModuleName + ' PowerShell module.'
            }
            ElseIf ($UpdateTrigger -in $InstalledModulePreUpdate.Version)
            {
                'The ' + $ModuleName + ' PowerShell module is up to date.'
            }
            Else
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
                    # Update the module to the latest version
                    Write-Host ('Updating ' + $ModuleName + ' module to version: ') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Action) -NoNewline
                    Write-Host ($UpdateTrigger) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                    If (-not [System.String]::IsNullOrEmpty($RepositoryCredentials))
                    {
                        $InstalledModulePreUpdate | Update-Module -Force -Credential:($RepositoryCredentials) -AllowPrerelease
                    }
                    Else
                    {
                        $InstalledModulePreUpdate | Update-Module -Force
                    }
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
                    $InstalledModulePostUpdate = Get-InstalledModule -Name:($ModuleName) -AllVersions
                    # Check to see if the module version on the PowerShell gallery does not match the local module version
                    If ($UpdateTrigger -in $InstalledModulePostUpdate.Version)
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
    End
    {
        if ($SDKUninstallSummary)
        {
            if ($PSBoundParameters.Debug -eq $true) {
                Write-Debug "The following modules were sucessfully uninstalled:"
                $SDKUninstallSummary | Format-Table | Out-Host
            }
        }
        if ($SDKResultsSummary)
        {
            If ($false -in $SDKResultsSummary.Imported)
            {
                Write-Warning "One or more of the SDK modules could not be imported to this session"
                Write-Warning "Please restart this powershell session to use the new SDK module "
                if ($PSBoundParameters.Debug -eq $true) {
                $SDKResultsSummary | Format-Table | Out-Host
                }
            }
            else {
                if ($PSBoundParameters.Debug -eq $true) {
                    Write-Debug "The following modules were sucessfully updated:"
                $SDKResultsSummary | Format-Table | Out-Host
                }
            }
        }
    }
}