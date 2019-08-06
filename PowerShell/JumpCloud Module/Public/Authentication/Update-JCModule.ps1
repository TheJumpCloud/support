Function Update-JCModule
{
    Param(
        [Parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'Url to the release notes. Leave default value unless testing.')]$ReleaseNotesURL = 'https://git.io/jc-pwsh-releasenotes'
    )
    # Load color scheme
    $JCColorConfig = Get-JCColorConfig
    # Get local module
    $InstalledModuleVersion = Get-Module -All -Name:('JumpCloud') | Select-Object -ExpandProperty Version
    $GitHubModuleInfo = Get-GitHubModuleInfo
    $CurrentBanner = $GitHubModuleInfo.CurrentBanner
    $OldBanner = $GitHubModuleInfo.OldBanner
    $LatestVersion = $GitHubModuleInfo.LatestVersion
    If ($InstalledModuleVersion -ne $LatestVersion)
    {
        Write-Host ('Message:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
        Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
        Write-Host ($OldBanner) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
        Write-Host ('Installed Version:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
        Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
        Write-Host ($InstalledModuleVersion) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
        Write-Host ('Latest Version:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
        Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
        Write-Host ($LatestVersion) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
        Do
        {
            Write-Host ('Enter ''Y'' to update the JumpCloud module to the latest version or ''N'' to cancel:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_UserPrompt) -NoNewline
            Write-Host (' ') -NoNewLine
            $UserInput = Read-Host
        }
        Until ($UserInput.ToUpper() -in ('Y', 'N'))
        If ($UserInput.ToUpper() -eq 'N')
        {
            Write-Host ('Exiting the JumpCloud module update process.') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Action)
            Return [PSCustomObject]@{
                'InstalledVersion' = $InstalledModuleVersion;
                'LatestVersion'    = $LatestVersion;
                'Message'          = $OldBanner;
            }
        }
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
        # Remove InstalledModule
        $InstalledModule = Get-InstalledModule -Name:('JumpCloud') -ErrorAction:('SilentlyContinue')
        If ($InstalledModule)
        {
            Write-Host ('Uninstalling ' + $InstalledModule.Name + ' module version: ') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Action) -NoNewline
            Write-Host ($InstalledModule.Version) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
            $InstalledModule | Uninstall-Module -Force
        }
        # Remove Module
        $Module = Get-Module -Name:('JumpCloud') -All -ErrorAction:('SilentlyContinue')
        If ($Module)
        {
            Write-Host ('Removing ' + $Module.Name + ' module version: ') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Action) -NoNewline
            Write-Host ($Module.Version) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
            $Module | Remove-Module -Force
        }
        # Remove module specific functions from the current session
        $ModuleFunctions = Get-ChildItem -Path:('function:') | Where-Object {$_.Source -eq 'JumpCloud'}
        If ($ModuleFunctions)
        {
            $ModuleFunctions | ForEach-Object {
                Remove-Item -Path:('function:\' + $_.Name)
            }
        }
        # Install module
        Write-Host ('Installing JumpCloud module version: ') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Action) -NoNewline
        Write-Host ($LatestVersion) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
        Install-Module -Name:('JumpCloud') -Scope:('CurrentUser')
        $UpdatedModuleVersion = Get-InstalledModule -Name:('JumpCloud') | Where-Object {$_.Version -eq $LatestVersion} | Select-Object -ExpandProperty Version
        If ($UpdatedModuleVersion -eq $LatestVersion)
        {
            # Import latest version of module
            Import-Module -Name:('JumpCloud') -Force
            # If (!(Get-PSCallStack | Where-Object {$_.Command -match 'Pester'})) {Clear-Host}
            $ReleaseNotesRaw = Invoke-WebRequest -Uri:($ReleaseNotesURL) -UseBasicParsing
            $ReleaseNotes = ((((($ReleaseNotesRaw.RawContent -split "</a>$LatestVersion</h2>")[1]) -split "<pre><code>")[1]) -split "</code>")[0]
            Write-Host ('JumpCloud module has been updated to version:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
            Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
            Write-Host ($LatestVersion) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
            Write-Host ('Release Notes:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
            $ReleaseNotes.Trim().Split("`n") | ForEach-Object {
                Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
                Write-Host ($_.Trim())-BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
            }
            Write-Host ('Full release notes available at:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
            Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
            Write-Host ($ReleaseNotesURL.Trim()) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Url)
            Return [PSCustomObject]@{
                'InstalledVersion' = $UpdatedModuleVersion;
                'LatestVersion'    = $LatestVersion;
                'Message'          = $CurrentBanner;
            }
            Pause
        }
        Else
        {
            Write-Error ("Failed to update the JumpCloud module to latest version $($LatestVersion).")
        }
    }
    Else
    {
        Return [PSCustomObject]@{
            'InstalledVersion' = $InstalledModuleVersion;
            'LatestVersion'    = $LatestVersion;
            'Message'          = $OldBanner;
        }
    }
}