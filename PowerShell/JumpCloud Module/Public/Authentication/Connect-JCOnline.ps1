Function Connect-JCOnline ()
{
    [CmdletBinding(DefaultParameterSetName = 'Interactive')]
    param
    (
        [Parameter(
            ParameterSetName = 'force',
            Mandatory,
            ValueFromPipelineByPropertyName,
            Position = 0)]

        [Parameter(Mandatory = $True,
            ParameterSetName = 'Interactive',
            Position = 0,
            HelpMessage = "Please enter your JumpCloud API key. This can be found in the JumpCloud admin console within 'API Settings' accessible from the drop down icon next to the admin email address in the top right corner of the JumpCloud admin console.") ]
        [ValidateScript( {
                If (($_).Length -ne 40)
                {
                    Throw "Please enter your API key. This can be found in the JumpCloud admin console within 'API Settings' accessible from the drop down icon next to the admin email address in the top right corner of the JumpCloud admin console."
                }

                Else { $true }
            })]
        [Alias('JCAPIKEY')]
        [String]$JumpCloudAPIKey,

        [Parameter(
            ParameterSetName = 'force',
            ValueFromPipelineByPropertyName,
            Position = 1)]
        [Parameter(
            ParameterSetName = 'Interactive',
            Position = 1,
            HelpMessage = "Only needed for multi tenant admins. Organization ID can be found in the Settings page within the admin console.") ]
        [string]$JumpCloudOrgID,

        [Parameter(
            ParameterSetName = 'force',
            ValueFromPipelineByPropertyName
        )]
        [Parameter(
            ParameterSetName = 'Interactive',
            ValueFromPipelineByPropertyName
        )]
        [ValidateSet('production', 'staging', 'local')]
        $JCEnvironment = 'production',

        [Parameter(
            ParameterSetName = 'force')]
        [Switch]
        $force,

        [string]$UserAgent
    )
    DynamicParam
    {
        If ((Get-PSCallStack).Command -like '*MarkdownHelp')
        {
            $JCEnvironment = 'local'
        }
        $dict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        If ($JCEnvironment -eq "local")
        {
            $attr = New-Object System.Management.Automation.ParameterAttribute
            $attr.HelpMessage = "Enter an IP address"
            $attr.ValueFromPipelineByPropertyName = $true
            $attrColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attrColl.Add($attr)
            $param = New-Object System.Management.Automation.RuntimeDefinedParameter('ip', [string], $attrColl)
            $dict.Add('ip', $param)

        }
        Return $dict
    }
    Begin
    {
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
        # Set JCAPIKEY to global to be used in other scripts
        If (-not ([System.String]::IsNullOrEmpty($JumpCloudAPIKey)))
        {
            If ($JumpCloudAPIKey -ne $JCAPIKEY)
            {
                $global:JCOrgID = (Set-JCOrganization -JumpCloudAPIKey:($JumpCloudAPIKey) -JumpCloudOrgID:($JumpCloudOrgID)).xOrgId
            }
            Else
            {
                $global:JCAPIKEY = $JumpCloudAPIKey
            }
        }
        ElseIf (-not ([System.String]::IsNullOrEmpty($JCAPIKEY)))
        {
            $global:JCAPIKEY = $JCAPIKEY
        }
        Else
        {
            $global:JCAPIKEY = $null
        }
        # Set JCOrgID to global to be used in other scripts
        If (-not ([System.String]::IsNullOrEmpty($JumpCloudOrgID)))
        {
            $global:JCOrgID = $JumpCloudOrgID
        }
        ElseIf (-not ([System.String]::IsNullOrEmpty($JCOrgID)))
        {
            $global:JCOrgID = $JCOrgID
        }
        Else
        {
            $global:JCOrgID = (Set-JCOrganization -JumpCloudAPIKey:($JCAPIKEY) -JumpCloudOrgID:($JCOrgID)).xOrgId
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
    }
    Process
    {
        Try
        {
            If (([System.String]::IsNullOrEmpty($JCOrgID)))
            {
                Write-Error "Incorrect OrgID OR no network connectivity. You can obtain your Organization ID below your Organization's Contact Information on the Settings page."
                $global:JCOrgID = $null
                Break
            }
        }
        Catch
        {
            Write-Error "Incorrect API key OR no network connectivity. To locate your JumpCloud API key log into the JumpCloud admin portal. The API key is located with 'API Settings' accessible from the drop down in the top right hand corner of the screen"
            $global:JCAPIKEY = $null
            Break
        }
    }
    End
    {
        # Get settings info
        $global:JCSettingsUrl = $JCUrlBasePath + '/api/settings'
        $global:JCSettings = Invoke-JCApi -Method:('GET') -Url:($JCSettingsUrl)
        If ($JCEnvironment -ne "local")
        {
            If ($PSCmdlet.ParameterSetName -eq 'Interactive')
            {
                Write-Host -BackgroundColor Green -ForegroundColor Black "Successfully connected to JumpCloud"

                $GitHubModuleInfo = Invoke-WebRequest -uri  $GitHubModuleInfoURL -UseBasicParsing -UserAgent:(Get-JCUserAgent) | Select-Object RawContent

                $CurrentBanner = ((((($GitHubModuleInfo -split "</a>Banner Current</h4>")[1]) -split "<pre><code>")[1]) -split "`n")[0]

                $OldBanner = ((((($GitHubModuleInfo -split "</a>Banner Old</h4>")[1]) -split "<pre><code>")[1]) -split "`n")[0]

                $LatestVersion = ((((($GitHubModuleInfo -split "</a>Latest Version</h4>")[1]) -split "<pre><code>")[1]) -split "`n")[0]

                $InstalledModuleVersion = Get-Module -All -ListAvailable -Name:('JumpCloud') | Select-Object -ExpandProperty Version

                If ($InstalledModuleVersion -eq $LatestVersion)
                {

                    Write-Host -BackgroundColor Green -ForegroundColor Black "$CurrentBanner Module version: $InstalledModuleVersion"

                }
                ElseIf ($InstalledModuleVersion -ne $LatestVersion)
                {
                    Write-Host "$OldBanner"
                    Write-Host -BackgroundColor Yellow -ForegroundColor Black  "Installed Version: $InstalledModuleVersion " -NoNewline
                    Write-Host -BackgroundColor Green -ForegroundColor Black  " Latest Version: $LatestVersion "
                    Write-Host  "`nWould you like to upgrade to version: $LatestVersion ?"
                    $Accept = Read-Host  "`nEnter 'Y' If you wish to update to version $LatestVersion or 'N' to continue using version: $InstalledModuleVersion"
                    If ($Accept.ToUpper() -eq 'N')
                    {
                        Return #Exit the function
                    }
                    While ($Accept -notcontains 'Y')
                    {
                        Write-Warning " Typo? $Accept != 'Y'"
                        $Accept = Read-Host "`nEnter 'Y' If you wish to update to the latest version or 'N' to continue using version: $InstalledModuleVersion `n"
                        If ($Accept.ToUpper() -eq 'N')
                        {
                            Return # Exit the function
                        }
                    }
                    If ($PSVersionTable.PSVersion.Major -eq '5')
                    {
                        If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
                        {
                            Write-Warning "You must have Administrative rights to update the module! To retry close this PowerShell session and open a new PowerShell session with Administrator permissions (Right click the PowerShell application and select 'Run as Administrator') and run the Connect-JCOnline command."
                            Return
                        }
                    }
                    ElseIf ($PSVersionTable.PSVersion.Major -ge 6 -and $PSVersionTable.Platform -like "*Win*")
                    {
                        If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
                        {
                            Write-Warning "You must have Administrative rights to update the module! To retry close this PowerShell session and open a new PowerShell session with Administrator permissions (Right click the PowerShell application and select 'Run as Administrator') and run the Connect-JCOnline command."
                            Return
                        }
                    }
                    $InstalledModule = Get-InstalledModule | Where-Object {$_.Name -eq 'JumpCloud' -and $_.Version -eq $InstalledModuleVersion}
                    If ([System.String]::IsNullOrEmpty($InstalledModule))
                    {
                        $InstalledModule | Uninstall-Module
                    }
                    Install-Module -Name:('JumpCloud') -Scope:('CurrentUser')
                    $UpdatedModuleVersion = Get-Module -All -ListAvailable -Name:('JumpCloud') | Where-Object {$_.Version -eq $LatestVersion} | Select-Object -ExpandProperty Version
                    If ($UpdatedModuleVersion -eq $LatestVersion)
                    {
                        If (!(Get-PSCallStack | Where-Object {$_.Command -match 'Pester'})) {Clear-Host}
                        $ReleaseNotesRaw = Invoke-WebRequest -uri $ReleaseNotesURL -UseBasicParsing -UserAgent:(Get-JCUserAgent) #for backwards compatibility
                        $ReleaseNotes = ((((($ReleaseNotesRaw.RawContent -split "</a>$LatestVersion</h2>")[1]) -split "<pre><code>")[1]) -split "</code>")[0]
                        Write-Host "Module updated to version: $LatestVersion`n"
                        Write-Host "Release Notes: `n"
                        Write-Host $ReleaseNotes
                        Write-Host "`nTo see the full release notes navigate to: `n"
                        Write-Host "$ReleaseNotesURL`n"
                        Pause
                    }
                    Else
                    {
                        Write-Error ('Failed to update the JumpCloud module to latest version.')
                    }
                }
            } #End If
        }
    }#End endblock
}