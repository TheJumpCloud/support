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


        [string]$JumpCloudAPIKey,


        [Parameter(
            ParameterSetName = 'force',
            ValueFromPipelineByPropertyName,
            Position = 1)]

        [Parameter(
            ParameterSetName = 'Interactive',
            Position = 1,
            HelpMessage = "Using the JumpCloud multi tenant? Please enter your OrgID") ]

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

        [string]$UserAgent = "Pwsh_1.11.0"
    )



    DynamicParam
    {

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

        return $dict 
        
    }

    begin
    {
        $global:JCUserAgent = $UserAgent

        if ($JCEnvironment -eq 'local')
        {

            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls
        }

        else
        {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        }

        switch ($JCEnvironment)
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
                if ($PSBoundParameters['ip'])
                {
                    $global:JCUrlBasePath = $PSBoundParameters['ip']
                }
                else
                {
                    $global:JCUrlBasePath = "http://localhost"
                }
            }
        }

        $GitHubModuleInfoURL = 'https://github.com/TheJumpCloud/support/blob/master/PowerShell/ModuleBanner.md'

        $ReleaseNotesURL = 'https://git.io/jc-pwsh-releasenotes'

        $hdrs = @{
            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JumpCloudAPIKey
        }

        $global:JCOrgID = $null
    }

    process
    {

        try
        {
            $ConnectionTestURL = "$JCUrlBasePath/api/v2/ldapservers"
            Invoke-RestMethod -Method GET -Uri $ConnectionTestURL -Headers $hdrs -UserAgent $JCUserAgent | Out-Null
        }
        catch
        {

            if (Test-MultiTenant -JumpCloudAPIKey $JumpCloudAPIKey)
            {

                if (-not $JumpCloudOrgID)
                {

                    Invoke-SetJCOrganization -JumpCloudAPIKey $JumpCloudAPIKey                    
                
                }

                else
                {
                    $global:JCOrgID = $JumpCloudOrgID

                    try
                    {
                        $hdrs.Add('x-org-id', "$($JCOrgID)")
                        $ConnectionTestURL = "$JCUrlBasePath/api/v2/ldapservers"
                        Invoke-RestMethod -Method GET -Uri $ConnectionTestURL -Headers $hdrs -UserAgent $JCUserAgent | Out-Null

                        if (-not $force)
                        {
                            Write-Host -BackgroundColor Green -ForegroundColor Black "Connected to JumpCloud Tenant OrgID: $JCOrgID"
                        }
                    }
                    catch
                    {
    
                        Write-Error "Incorrect OrgID OR no network connectivity. You can obtain your Organization ID below your Organization's Contact Information on the Settings page."
                        $global:JCOrgID = $null
                        break
                        
                    }
                }

        

            }
            
            else
            {
                
                Write-Error "Incorrect API key OR no network connectivity. To locate your JumpCloud API key log into the JumpCloud admin portal. The API key is located with 'API Settings' accessible from the drop down in the top right hand corner of the screen"
                $global:JCAPIKEY = $null
                break
            }
            
        }
    }

    end
    {
        $global:JCAPIKEY = $JumpCloudAPIKey

        if ($JCEnvironment -ne "local")
        {
            if ($PSCmdlet.ParameterSetName -eq 'Interactive')
            {

                Write-Host -BackgroundColor Green -ForegroundColor Black "Successfully connected to JumpCloud"

                $GitHubModuleInfo = Invoke-WebRequest -uri  $GitHubModuleInfoURL -UseBasicParsing | Select-Object RawContent

                $CurrentBanner = ((((($GitHubModuleInfo -split "</a>Banner Current</h4>")[1]) -split "<pre><code>")[1]) -split "`n")[0]

                $OldBanner = ((((($GitHubModuleInfo -split "</a>Banner Old</h4>")[1]) -split "<pre><code>")[1]) -split "`n")[0]

                $LatestVersion = ((((($GitHubModuleInfo -split "</a>Latest Version</h4>")[1]) -split "<pre><code>")[1]) -split "`n")[0]

                $InstalledModuleVersion = Get-InstalledModule -Name JumpCloud | Select-Object -ExpandProperty Version

                if ($InstalledModuleVersion -eq $LatestVersion)
                {

                    Write-Host -BackgroundColor Green -ForegroundColor Black "$CurrentBanner Module version: $InstalledModuleVersion" 

                }

                elseif ($InstalledModuleVersion -ne $LatestVersion)
                {
    
                    Write-Host "$OldBanner" 
                    Write-Host -BackgroundColor Yellow -ForegroundColor Black  "Installed Version: $InstalledModuleVersion " -NoNewline
                    Write-Host -BackgroundColor Green -ForegroundColor Black  " Latest Version: $LatestVersion "

                    Write-Host  "`nWould you like to upgrade to version: $LatestVersion ?"
                
                    $Accept = Read-Host  "`nEnter 'Y' if you wish to update to version $LatestVersion or 'N' to continue using version: $InstalledModuleVersion"


                    if ($Accept -eq 'N')
                    {

                        return #Exit the function
                    }

                    While ($Accept -notcontains 'Y')
                    {

                        Write-Warning " Typo? $Accept != 'Y'"

                        $Accept = Read-Host "`nEnter 'Y' if you wish to update to the latest version or 'N' to continue using version: $InstalledModuleVersion `n"

                        if ($Accept -eq 'N')
                        {

                            return # Exist the function
                        }

                    }


                    if ($PSVersionTable.PSVersion.Major -eq '5')
                    {

                        If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
                        {

                            Write-Warning "You must have Administrative rights to update the module! To retry close this PowerShell session and open a new PowerShell session with Administrator permissions (Right click the PowerShell application and select 'Run as Administrator') and run the Connect-JCOnline command."
            
                            Return
            
                        }

                        Uninstall-Module -Name JumpCloud -RequiredVersion $InstalledModuleVersion

                        Install-Module -Name JumpCloud -Scope CurrentUser
                    }

                    elseif ($PSVersionTable.PSVersion.Major -ge 6)
                    {

                        if ($PSVersionTable.Platform -eq 'Unix')
                        {

                            Uninstall-Module -Name JumpCloud -RequiredVersion $InstalledModuleVersion

                            Install-Module -Name JumpCloud -Scope CurrentUser
                                
                        }

                        elseif ($PSVersionTable.Platform -like "*Win*")
                        {

                            If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
                            {

                                Write-Warning "You must have Administrative rights to update the module! To retry close this PowerShell session and open a new PowerShell session with Administrator permissions (Right click the PowerShell application and select 'Run as Administrator') and run the Connect-JCOnline command."
                
                                Return
                
                            }

                            Uninstall-Module -Name JumpCloud -RequiredVersion $InstalledModuleVersion

                            Install-Module -Name JumpCloud -Scope CurrentUser
                                
                        }

                    }

                    
                    $UpdatedModuleVersion = Get-InstalledModule -Name JumpCloud | Select-Object -ExpandProperty Version

                    if ($UpdatedModuleVersion -eq $LatestVersion)
                    {

                        If ($($PSVersionTable.Platform) -eq "Unix")
                        {
                            [System.Console]::Clear();
                        }
                        else
                        {
                            Clear-Host
                        }
                
                        $ReleaseNotesRaw = Invoke-WebRequest -uri $ReleaseNotesURL -UseBasicParsing #for backwards compatibility

                        $ReleaseNotes = ((((($ReleaseNotesRaw.RawContent -split "</a>$LatestVersion</h2>")[1]) -split "<pre><code>")[1]) -split "</code>")[0]

                        Write-Host "Module updated to version: $LatestVersion`n"

                        Write-Host "Release Notes: `n"

                        Write-Host $ReleaseNotes

                        Write-Host "`nTo see the full release notes navigate to: `n" 
                        Write-Host "$ReleaseNotesURL`n"

                        Pause
    
                    }
                
                }



            } #End if

        }

        
    }#End endblock

}