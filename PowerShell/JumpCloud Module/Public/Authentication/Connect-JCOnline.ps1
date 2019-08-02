Function Connect-JCOnline ()
{
    [CmdletBinding(DefaultParameterSetName = 'Interactive')]
    Param
    (
        [Parameter(ParameterSetName = 'force', ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName = 'Interactive', ValueFromPipelineByPropertyName)]
        [ValidateSet('production', 'staging', 'local')]
        [System.String]$JCEnvironment = 'production',
        [Parameter(ParameterSetName = 'force')][Switch]$force,
        [System.String]$UserAgent
    )
    DynamicParam
    {
        $Param_JumpCloudAPIKey = @{
            'Name'                            = 'JumpCloudAPIKey';
            'Type'                            = [System.String];
            'Position'                        = 0;
            'ValueFromPipelineByPropertyName' = $true;
            'ValidateNotNullOrEmpty'          = $true;
            'ValidateLength'                  = (40, 40);
            'ParameterSets'                   = ('force', 'Interactive');
            'HelpMessage'                     = "Please enter your JumpCloud API key. This can be found in the JumpCloud admin console within 'API Settings' accessible from the drop down icon next to the admin email address in the top right corner of the JumpCloud admin console.";
        }
        $Param_JumpCloudOrgID = @{
            'Name'                            = 'JumpCloudOrgID';
            'Type'                            = [System.String];
            'Position'                        = 1;
            'ValueFromPipelineByPropertyName' = $true;
            'ValidateNotNullOrEmpty'          = $true;
            'ParameterSets'                   = ('force', 'Interactive');
            'HelpMessage'                     = 'Organization ID can be found in the Settings page within the admin console. Only needed for multi tenant admins.';
        }
        # If the $env:JcApiKey is not set then make the JumpCloudAPIKey mandatory else set the default value to be the env variable
        If ([System.String]::IsNullOrEmpty($env:JcApiKey))
        {
            $Param_JumpCloudAPIKey.Add('Mandatory', $true);
        }
        Else
        {
            $Param_JumpCloudAPIKey.Add('Default', $env:JcApiKey);
        }
        # If the $env:JcOrgId is set then set the default value to be the env variable
        If (-not [System.String]::IsNullOrEmpty($env:JcOrgId))
        {
            $Param_JumpCloudOrgID.Add('Default', $env:JcOrgId);
        }
        If ((Get-PSCallStack).Command -like '*MarkdownHelp')
        {
            $JCEnvironment = 'local'
        }
        If ($JCEnvironment -eq "local")
        {
            $Param_ip = @{
                'Name'                            = 'ip';
                'Type'                            = [System.String];
                'ValueFromPipelineByPropertyName' = $true;
                'HelpMessage'                     = 'Enter an IP address';
            }
        }
        # Build output
        # Build parameter array
        $RuntimeParameterDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
        $ParamVarPrefix = 'Param_'
        Get-Variable -Scope:('Local') | Where-Object {$_.Name -like '*' + $ParamVarPrefix + '*'} | ForEach-Object {
            # Add RuntimeDictionary to each parameter
            $_.Value.Add('RuntimeParameterDictionary', $RuntimeParameterDictionary)
            # Creating each parameter
            $VarName = $_.Name
            $VarValue = $_.Value
            Try
            {
                New-DynamicParameter @VarValue | Out-Null
            }
            Catch
            {
                Write-Error -Message:('Unable to create dynamic parameter:"' + $VarName.Replace($ParamVarPrefix, '') + '"; Error:' + $Error)
            }
        }
        Return $RuntimeParameterDictionary
    }
    Begin
    {
        # Debug message for parameter call
        Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDebugMessageBegin) -ArgumentList:($MyInvocation, $PsBoundParameters, $PSCmdlet) -NoNewScope
        If ($JCEnvironment -eq 'local')
        {
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls
        }
        Else
        {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        }
        Switch ($JCEnvironment)
        {
            'production'
            {
                $global:JCUrlBasePath = "https://console.jumpcloud.com"
            }
            'staging'
            {
                $global:JCUrlBasePath = "https://console.awsstg.jumpcloud.com"
            }
            'local'
            {
                If ($PSBoundParameters['ip'])
                {
                    $global:JCUrlBasePath = $PSBoundParameters['ip']
                }
                Else
                {
                    $global:JCUrlBasePath = "http://localhost"
                }
            }
        }
        $GitHubModuleInfoURL = 'https://github.com/TheJumpCloud/support/blob/master/PowerShell/ModuleBanner.md'
        $ReleaseNotesURL = 'https://git.io/jc-pwsh-releasenotes'
    }
    Process
    {
        # For DynamicParam with a default value set that value and then convert the DynamicParam inputs into new variables for the script to use
        Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDynamicParamProcess) -ArgumentList:($PsBoundParameters, $PSCmdlet, $RuntimeParameterDictionary) -NoNewScope
        #Region Set environment variables that can be used by other scripts
        # If "$JumpCloudAPIKey" is populated or if "$env:JcApiKey" is not set
        If (-not ([System.String]::IsNullOrEmpty($JumpCloudAPIKey)))
        {
            # Set JcApiKey
            $env:JcApiKey = $JumpCloudAPIKey
            $global:JCAPIKEY = $env:JcApiKey
        }
        # If "$JumpCloudOrgID" is populated or if "$env:JcOrgId" is not set
        If ($JumpCloudOrgID -ne $env:JcOrgId)
        {
            #  JcOrgId set in Set-JCOrganization
            $Auth = If ([System.String]::IsNullOrEmpty($JumpCloudOrgID))
            {
                Set-JCOrganization -JumpCloudAPIKey:($JumpCloudAPIKey)
            }
            Else
            {
                Set-JCOrganization -JumpCloudAPIKey:($JumpCloudAPIKey) -JumpCloudOrgID:($JumpCloudOrgID)
            }
            # Each time a new org is selected get settings info
            $global:JCSettingsUrl = $JCUrlBasePath + '/api/settings'
            $global:JCSettings = Invoke-JCApi -Method:('GET') -Url:($JCSettingsUrl)
        }
        # Set JCUserAgent to global to be used in other scripts
        If ($UserAgent)
        {
            $global:JCUserAgent = $UserAgent
        }
        Else
        {
            $global:JCUserAgent = $null
        }
        #EndRegion Set environment variables that can be used by other scripts
        If (([System.String]::IsNullOrEmpty($JCOrgID)) -or ([System.String]::IsNullOrEmpty($env:JcOrgId)))
        {
            Write-Error "Incorrect OrgID OR no network connectivity. You can obtain your Organization ID below your Organization's Contact Information on the Settings page."
            Break
        }
        If (([System.String]::IsNullOrEmpty($JCAPIKEY)) -or ([System.String]::IsNullOrEmpty($env:JcApiKey)))
        {
            Write-Error "Incorrect API key OR no network connectivity. To locate your JumpCloud API key log into the JumpCloud admin portal. The API key is located with 'API Settings' accessible from the drop down in the top right hand corner of the screen"
            Break
        }
    }
    End
    {
        Return $Auth
        If ([System.String]::IsNullOrEmpty($env:JcUpdateModule) -or $env:JcUpdateModule -ne 'False')
        {
            If ($JCEnvironment -ne 'local')
            {
                If ($PSCmdlet.ParameterSetName -eq 'Interactive')
                {
                    Write-Host ('Successfully connected to JumpCloud') -BackgroundColor:('Green') -ForegroundColor:('Black')
                    $GitHubModuleInfo = Invoke-WebRequest -Uri $GitHubModuleInfoURL -UseBasicParsing -UserAgent:(Get-JCUserAgent) | Select-Object RawContent
                    $CurrentBanner = ((((($GitHubModuleInfo -split "</a>Banner Current</h4>")[1]) -split "<pre><code>")[1]) -split "`n")[0]
                    $OldBanner = ((((($GitHubModuleInfo -split "</a>Banner Old</h4>")[1]) -split "<pre><code>")[1]) -split "`n")[0]
                    $LatestVersion = ((((($GitHubModuleInfo -split "</a>Latest Version</h4>")[1]) -split "<pre><code>")[1]) -split "`n")[0]
                    $InstalledModuleVersion = Get-Module -All -Name:('JumpCloud') | Select-Object -ExpandProperty Version
                    If ($InstalledModuleVersion -eq $LatestVersion)
                    {
                        Write-Host ("$CurrentBanner Module version: $InstalledModuleVersion") -BackgroundColor:('Green') -ForegroundColor:('Black')
                    }
                    ElseIf ($InstalledModuleVersion -ne $LatestVersion)
                    {
                        Write-Host "$OldBanner"
                        Write-Host -BackgroundColor Yellow -ForegroundColor Black  "Installed Version: $InstalledModuleVersion " -NoNewline
                        Write-Host -BackgroundColor Green -ForegroundColor Black  " Latest Version: $LatestVersion "
                        Write-Host  "`nWould you like to upgrade to version: $($LatestVersion)?"
                        $env:JcUpdateModule = $true
                        Do
                        {
                            $Accept = Read-Host -Prompt:("`nEnter 'Y' If you wish to update to the latest version $($LatestVersion) or 'N' to continue using version: $($InstalledModuleVersion)")
                        }
                        Until ($Accept.ToUpper() -in ('Y', 'N'))
                        If ($Accept.ToUpper() -eq 'N')
                        {
                            $env:JcUpdateModule = $false
                            Return # Exit the function
                        }
                        If ($PSVersionTable.PSVersion.Major -eq '5')
                        {
                            If (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
                            {
                                Write-Warning "You must have Administrative rights to update the module! To retry close this PowerShell session and open a new PowerShell session with Administrator permissions (Right click the PowerShell application and select 'Run as Administrator') and run the Connect-JCOnline command."
                                Return
                            }
                        }
                        ElseIf ($PSVersionTable.PSVersion.Major -ge 6 -and $PSVersionTable.Platform -like "*Win*")
                        {
                            If (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
                            {
                                Write-Warning "You must have Administrative rights to update the module! To retry close this PowerShell session and open a new PowerShell session with Administrator permissions (Right click the PowerShell application and select 'Run as Administrator') and run the Connect-JCOnline command."
                                Return
                            }
                        }
                        # Remove InstalledModule
                        $InstalledModule = Get-InstalledModule -Name:('JumpCloud') -ErrorAction:('SilentlyContinue')
                        If ($InstalledModule)
                        {
                            Write-Host ('Uninstall-Module: ' + $InstalledModule.Name + ' ' + $InstalledModule.Version ) -BackgroundColor:('Yellow') -ForegroundColor:('Black')
                            $InstalledModule | Uninstall-Module
                        }
                        # Remove Module
                        $Module = Get-Module -Name:('JumpCloud') -All -ErrorAction:('SilentlyContinue')
                        If ($Module)
                        {
                            Write-Host ('Remove-Module: ' + $Module.Name + ' ' + $Module.Version) -BackgroundColor:('Yellow') -ForegroundColor:('Black')
                            $Module | Remove-Module
                        }
                        # Install module
                        Install-Module -Name:('JumpCloud') -Scope:('CurrentUser')
                        $UpdatedModuleVersion = Get-InstalledModule -Name:('JumpCloud') | Where-Object {$_.Version -eq $LatestVersion} | Select-Object -ExpandProperty Version
                        If ($UpdatedModuleVersion -eq $LatestVersion)
                        {
                            # Import latest version of module
                            Import-Module -Name:('JumpCloud') -Force
                            If (!(Get-PSCallStack | Where-Object {$_.Command -match 'Pester'})) {Clear-Host}
                            $ReleaseNotesRaw = Invoke-WebRequest -uri $ReleaseNotesURL -UseBasicParsing -UserAgent:(Get-JCUserAgent) #for backwards compatibility
                            $ReleaseNotes = ((((($ReleaseNotesRaw.RawContent -split "</a>$LatestVersion</h2>")[1]) -split "<pre><code>")[1]) -split "</code>")[0]
                            Write-Host "Module updated to version: $LatestVersion`n"
                            Write-Host "Release Notes: `n"
                            Write-Host $ReleaseNotes
                            Write-Host "`nTo see the full release notes navigate to: `n"
                            Write-Host "$ReleaseNotesURL`n"
                            $env:JcUpdateModule = $false
                            Pause
                        }
                        Else
                        {
                            Write-Error ("Failed to update the JumpCloud module to latest version $($LatestVersion).")
                        }
                    }
                } #End If
            }
        }
    }#End endblock
}