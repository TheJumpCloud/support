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

                Else {$true}
            })]


        [string]$JumpCloudAPIKey,

        [Parameter(
            ParameterSetName = 'force')]
        [Switch]
        $force
    )

    begin
    {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        $GitHubModuleInfoURL = 'https://github.com/TheJumpCloud/support/blob/master/PowerShell/ModuleBanner.md'

        $ReleaseNotesURL = 'https://git.io/jc-pwsh-releasenotes'

        $hdrs = @{
            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JumpCloudAPIKey
        }

        $ConnectionTestURL = "https://console.jumpcloud.com/api"

    }

    process
    {

        try
        {
            Invoke-RestMethod -Method GET -Uri $ConnectionTestURL -Headers $hdrs -UserAgent 'Pwsh_1.5.0'  | Out-Null
        }
        catch
        {
            Write-Error "Incorrect API key OR no network connectivity. To locate your JumpCloud API key log into the JumpCloud admin portal. The API key is located with 'API Settings' accessible from the drop down in the top right hand corner of the screen"
            $global:JCAPIKEY = $null
            break
        }
    }

    end
    {
        $global:JCAPIKEY = $JumpCloudAPIKey

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

                    write-warning " Typo? $Accept != 'Y'"

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

                    Clear-Host
                
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

        
    }#End endblock

}