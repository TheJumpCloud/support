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
        $DiSdkModuleName = 'JumpCloud.SDK.DirectoryInsights'
        $V2SdkModuleName = 'JumpCloud.SDK.V2'
        $V1SdkModuleName = 'JumpCloud.SDK.V1'
        # Find the module on the specified repository
        If (-not [System.String]::IsNullOrEmpty($RepositoryCredentials))
        {
            $FoundModule = Find-Module -Name:($ModuleName) -Repository:($Repository) -Credential:($RepositoryCredentials) -AllowPrerelease
        }
        Else
        {
            $FoundModule = Find-Module -Name:($ModuleName) -Repository:($Repository)
            $FoundDiSdkModule = Find-Module -Name:($DiSdkModuleName) -Repository:($Repository)
            $FoundV2SdkModule = Find-Module -Name:($V2SdkModuleName) -Repository:($Repository)
            $FoundV1SdkModule = Find-Module -Name:($V1SdkModuleName) -Repository:($Repository)
        }
        # Get the version of the module installed locally
        $InstalledModulePreUpdate = Get-InstalledModule -Name:($ModuleName) -AllVersions -ErrorAction:('Ignore')
        $InstalledDiSdkModulePreUpdate = Get-InstalledModule -Name:($DiSdkModuleName) -AllVersions -ErrorAction:('Ignore')
        $InstalledV2SdkModulePreUpdate = Get-InstalledModule -Name:($V2SdkModuleName) -AllVersions -ErrorAction:('Ignore')
        $InstalledV1SdkModulePreUpdate = Get-InstalledModule -Name:($V1SdkModuleName) -AllVersions -ErrorAction:('Ignore')
        # Get module info from GitHub - This should not impact the auto update ability, only the banner message
        $ModuleBanner = Get-ModuleBanner
        $ModuleChangeLog = Get-ModuleChangeLog
        # To change update dependency from PowerShell Gallery to Github flip the commented code below
        ###### $UpdateTrigger = $ModuleBanner.'Latest Version'
        $UpdateTrigger = $FoundModule.Version
        $UpdateTriggerDi = $FoundDiSdkModule.Version
        $UpdateTriggerV2 = $FoundV2SdkModule.Version
        $UpdateTriggerV1 = $FoundV1SdkModule.Version
        # Create hashtables for each SDK
        $DiSdkHash = @{Name = $DiSdkModuleName; CurrentVersion = $UpdateTriggerDi; InstalledModule = $InstalledDiSdkModulePreUpdate}
        $V2SdkHash = @{Name = $V2SdkModuleName; CurrentVersion = $UpdateTriggerV2; InstalledModule = $InstalledV2SdkModulePreUpdate}
        $V1SdkHash = @{Name = $V1SdkModuleName; CurrentVersion = $UpdateTriggerV1; InstalledModule = $InstalledV1SdkModulePreUpdate}
        
        
        # Create Array Holding SDK Hashes
        $sdkArray = @($DiSdkHash, $V2SdkHash, $V1SdkHash)
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
        #List for SDKS that needs restart to use the newest version
        $SdkRestartList = @()
        $uninstallSummary = @{}
        $installedSummary = @{}
        $currSdkVersions = @{}
        Try
        {
            foreach ($sdk in $sdkArray){
                if ($sdk.CurrentVersion -notin $sdk.InstalledModule.Version) {
                    $currSdkVersions.Add($sdk.Name, $sdk.CurrentVersion)
                }
            }
            if ($currSdkVersions) {
                Write-Host ("Here are the new sdk versions: " + $currSdkVersions.Keys.ForEach({"$_ $($currSdkVersions.$_)"}) -join ' | ' )
                Do
                        {
                            Write-Host ('Enter ''Y'' to update these modules ' + $currSdkVersions.Keys.ForEach({"$_ $($currSdkVersions.$_)"}) -join ' | ' + ' PowerShell module to the latest version or enter ''N'' to cancel:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_UserPrompt) -NoNewline
                            Write-Host (' ') -NoNewline
                            $UserInput = Read-Host
                        }
                        Until ($UserInput.ToUpper() -in ('Y', 'N'))
                If ($UserInput.ToUpper() -eq 'N')
                {
                    Write-Host ('Exiting the ' + $ModuleName + ' PowerShell module update process.') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Action)
                }
                Else{
                    foreach ($sdk in $sdkArray){
                        # If update is available for sdk, update and import new version into session
                        if ($sdk.CurrentVersion -notin $sdk.InstalledModule.Version) {
                            # TODO: Eventually replace the write-hosts with debug
                            Write-Host "An dependancy is available for the $($sdk.Name) PowerShell module." -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                            Write-Host 'attempting to update module'
                            $sdk.InstalledModule | Update-Module -Force
                            Write-Host 'attempting to remove loaded module from memory'
                            Get-Module -Name:($sdk.Name) -ListAvailable -All | Remove-Module -Force
                            $installedSummary.Add($sdk.Name, $sdk.CurrentVersion)
                            # Uninstall previous versions
                            If (!($SkipUninstallOld))
                            {
                                Write-Host ('Uninstalling ' + $sdk.Name + ' module version: ') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Action) -NoNewline
                                #$testSdkArray += $($sdk.Name, $sdk.InstalledModule.Version)
                                $uninstallSummary.Add($sdk.Name, $sdk.InstalledModule.Version)
                                Write-Host (($sdk.InstalledModule.Version).ToString()) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                                Uninstall-Module -Name $sdk.Name -RequiredVersion $sdk.InstalledModule.Version -Force
                            }
                            Write-Host 'attempting to import dependant module'
                            try{
                                Import-Module $sdk.Name -Scope:('Global') -Force
                            }
                            catch{
                                # TODO: don't prompt each time, just prompt once at the end if any of the modules failed to import.
                                # TODO: Summary of the SDK modules (and versions) we uninstalled, and the ones that we installed.
                                # Add SDK to the list
                                $SdkRestartList += $($sdk.Name) + ','
                                # Write-Warning "Hey we couldn't import the $($sdk.Name) test - restart your session to use the latest sdks"
                            }
                            
                        }
                        elseif ($sdk.CurrentVersion -in $sdk.InstalledModule.Version) {
                            Write-Host 'The ' $sdk.Name ' PowerShell module is up to date' -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                        }
                        else {
                            Write-Error ('Unable to determine ' + $sdk.Name + 'PowerShell module install status.')
                        }
                    }
                }
            }
            if ($installedSummary) {
                Write-Host ("Installed sdks: " + $installedSummary.Keys.ForEach({"$_ $($installedSummary.$_)"}) -join ' | ') 
            }
            if ($uninstallSummary) {
                Write-Warning ("Uninstalled sdks: " + $uninstallSummary.Keys.ForEach({"$_ $($uninstallSummary.$_)"}) -join ' | ')
            }
             #TODO: Create if statement to check list if there are modules not imported
            if($SdkRestartList)
            {
                Write-Warning "Hey we couldn't import these sdk's: $SdkRestartList - please restart your session to use the latest sdks"  
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
        Catch
        {
            Write-Host "Error"
            Write-Error ($_)
        }
    }
    End
    {
    }
}