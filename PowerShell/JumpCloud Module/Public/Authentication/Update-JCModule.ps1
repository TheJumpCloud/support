Function Update-JCModule
{
    Param()
    $ReleaseNotesURL = 'https://git.io/jc-pwsh-releasenotes'
    $InstalledModuleVersion = Get-Module -All -Name:('JumpCloud') | Select-Object -ExpandProperty Version
    $GitHubModuleInfo = Get-GitHubModuleInfo
    $CurrentBanner = $GitHubModuleInfo.CurrentBanner
    $OldBanner = $GitHubModuleInfo.OldBanner
    $LatestVersion = $GitHubModuleInfo.LatestVersion
    If ($InstalledModuleVersion -ne $LatestVersion)
    {
        Write-Host ("$OldBanner")
        Write-Host ("Installed Version: $InstalledModuleVersion ") -BackgroundColor:('Yellow') -ForegroundColor:('Black') -NoNewline
        Write-Host (" Latest Version: $LatestVersion ") -BackgroundColor:('Green') -ForegroundColor:('Black')
        Write-Host ("`nWould you like to upgrade to version: $($LatestVersion)?")
        Do
        {
            $UserInput = (Read-Host -Prompt:("`nEnter 'Y' If you wish to update to the latest version $($LatestVersion) or 'N' to continue using version: $($InstalledModuleVersion)")).ToUpper()
        }
        Until ($UserInput.ToUpper() -in ('Y', 'N'))
        If ($UserInput.ToUpper() -eq 'N')
        {
            Return [PSCustomObject]@{
                'InstalledVersion' = $InstalledModuleVersion;
                'LatestVersion'    = $LatestVersion;
                'Message'          = $OldBanner;
            }# Exit the function
        }
        If ($PSVersionTable.PSVersion.Major -eq '5')
        {
            If (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
            {
                Write-Warning ("You must have Administrative rights to update the module! To retry close this PowerShell session and open a new PowerShell session with Administrator permissions (Right click the PowerShell application and select 'Run as Administrator') and run the Connect-JCOnline command.")
                Return
            }
        }
        ElseIf ($PSVersionTable.PSVersion.Major -ge 6 -and $PSVersionTable.Platform -like "*Win*")
        {
            If (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
            {
                Write-Warning ("You must have Administrative rights to update the module! To retry close this PowerShell session and open a new PowerShell session with Administrator permissions (Right click the PowerShell application and select 'Run as Administrator') and run the Connect-JCOnline command.")
                Return
            }
        }
        # Remove InstalledModule
        $InstalledModule = Get-InstalledModule -Name:('JumpCloud') -ErrorAction:('SilentlyContinue')
        If ($InstalledModule)
        {
            Write-Host ('Uninstall-Module: ' + $InstalledModule.Name + ' ' + $InstalledModule.Version ) -BackgroundColor:('Yellow') -ForegroundColor:('Black')
            $InstalledModule | Uninstall-Module -Force
        }
        # Remove Module
        $Module = Get-Module -Name:('JumpCloud') -All -ErrorAction:('SilentlyContinue')
        If ($Module)
        {
            Write-Host ('Remove-Module: ' + $Module.Name + ' ' + $Module.Version) -BackgroundColor:('Yellow') -ForegroundColor:('Black')
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
        Install-Module -Name:('JumpCloud') -Scope:('CurrentUser')
        $UpdatedModuleVersion = Get-InstalledModule -Name:('JumpCloud') | Where-Object {$_.Version -eq $LatestVersion} | Select-Object -ExpandProperty Version
        If ($UpdatedModuleVersion -eq $LatestVersion)
        {
            # Import latest version of module
            Import-Module -Name:('JumpCloud') -Force
            If (!(Get-PSCallStack | Where-Object {$_.Command -match 'Pester'})) {Clear-Host}
            $ReleaseNotesRaw = Invoke-WebRequest -Uri:($ReleaseNotesURL) -UseBasicParsing
            $ReleaseNotes = ((((($ReleaseNotesRaw.RawContent -split "</a>$LatestVersion</h2>")[1]) -split "<pre><code>")[1]) -split "</code>")[0]
            Write-Host ("Module updated to version: $LatestVersion`n")
            Write-Host ("Release Notes: `n")
            Write-Host ($ReleaseNotes)
            Write-Host ("`nTo see the full release notes navigate to: `n")
            Write-Host ("$ReleaseNotesURL`n")
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