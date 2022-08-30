Function Connect-JCOnline () {
    [CmdletBinding()]
    Param
    (
        [Parameter(ParameterSetName = 'force', HelpMessage = 'Using the "-Force" parameter the module update check is skipped. The ''-Force'' parameter should be used when using the JumpCloud module in scripts or other automation environments.')][Switch]$force
    )
    DynamicParam {
        $Param_JumpCloudApiKey = @{
            'Name'                            = 'JumpCloudApiKey';
            'Type'                            = [System.String];
            'Position'                        = 1;
            'ValueFromPipelineByPropertyName' = $true;
            'ValidateNotNullOrEmpty'          = $true;
            'ValidateLength'                  = (40, 40);
            'HelpMessage'                     = 'Please enter your JumpCloud API key. This can be found in the JumpCloud admin console within "API Settings" accessible from the drop down icon next to the admin email address in the top right corner of the JumpCloud admin console.';
        }
        $Param_JumpCloudOrgId = @{
            'Name'                            = 'JumpCloudOrgId';
            'Type'                            = [System.String];
            'Position'                        = 2;
            'ValueFromPipelineByPropertyName' = $true;
            'ValidateNotNullOrEmpty'          = $true;
            'HelpMessage'                     = 'Organization Id can be found in the Settings page within the admin console. Only needed for multi tenant admins.';
        }
        $Param_JCEnvironment = @{
            'Name'                            = 'JCEnvironment';
            'Type'                            = [System.String];
            'Position'                        = 3;
            'ValueFromPipelineByPropertyName' = $true;
            'ValidateNotNullOrEmpty'          = $true;
            'HelpMessage'                     = 'Specific to JumpCloud development team to connect to staging dev environment.';
            'ValidateSet'                     = ('production', 'staging');
        }
        # If the $env:JCApiKey is not set then make the JumpCloudApiKey mandatory else set the default value to be the env variable
        If ([System.String]::IsNullOrEmpty($env:JCApiKey)) {
            $Param_JumpCloudApiKey.Add('Mandatory', $true);
        } Else {
            $Param_JumpCloudApiKey.Add('Default', $env:JCApiKey);
        }
        # If the $env:JCOrgId is set then set the default value to be the env variable
        If (-not [System.String]::IsNullOrEmpty($env:JCOrgId)) {
            $Param_JumpCloudOrgId.Add('Default', $env:JCOrgId);
        }
        # If the $env:JCEnvironment is set then set the default value to be the env variable
        If (-not [System.String]::IsNullOrEmpty($env:JCEnvironment)) {
            $Param_JCEnvironment.Add('Default', $env:JCEnvironment);
        } Else {
            $Param_JCEnvironment.Add('Default', 'production');
        }
        # Build output
        # Build parameter array
        $RuntimeParameterDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
        $ParamVarPrefix = 'Param_'
        Get-Variable -Scope:('Local') | Where-Object { $_.Name -like '*' + $ParamVarPrefix + '*' } | Sort-Object { [int]$_.Value.Position } | ForEach-Object {
            # Add RuntimeDictionary to each parameter
            $_.Value.Add('RuntimeParameterDictionary', $RuntimeParameterDictionary)
            # Creating each parameter
            $VarName = $_.Name
            $VarValue = $_.Value
            Try {
                New-DynamicParameter @VarValue | Out-Null
            } Catch {
                Write-Error -Message:('Unable to create dynamic parameter:"' + $VarName.Replace($ParamVarPrefix, '') + '"; Error:' + $Error)
            }
        }
        $IndShowMessages = If ([System.String]::IsNullOrEmpty($JumpCloudApiKey) -and [System.String]::IsNullOrEmpty($JumpCloudOrgId) -and -not [System.String]::IsNullOrEmpty($env:JCApiKey) -and -not [System.String]::IsNullOrEmpty($env:JCOrgId)) {
            $false
        } Else {
            $true
        }
        Return $RuntimeParameterDictionary
    }
    Begin {
        # Debug message for parameter call
        $PSBoundParameters | Out-DebugParameter | Write-Debug
    }
    Process {
        # Load color scheme
        $JCColorConfig = Get-JCColorConfig
        # For DynamicParam with a default value set that value and then convert the DynamicParam inputs into new variables for the script to use
        Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDynamicParamProcess) -ArgumentList:($PsBoundParameters, $PSCmdlet, $RuntimeParameterDictionary) -NoNewScope
        Try {
            #Region Set environment variables that can be used by other scripts
            # If "$JCEnvironment" is populated or if "$env:JCEnvironment" is not set
            If (-not [System.String]::IsNullOrEmpty($JCEnvironment)) {
                # Set $env:JCEnvironment
                $env:JCEnvironment = $JCEnvironment
                $global:JCEnvironment = $env:JCEnvironment
            }
            $global:JCUrlBasePath = Switch ($JCEnvironment) {
                'production' {
                    "https://console.jumpcloud.com"
                }
                'staging' {
                    "https://console.awsstg.jumpcloud.com"
                }
                Default {
                    Write-Error ('Unknown value for $JCEnvironment.')
                }
            }
            # If "$JumpCloudApiKey" is populated set $env:JCApiKey
            If (-not [System.String]::IsNullOrEmpty($JumpCloudApiKey)) {
                $env:JCApiKey = $JumpCloudApiKey
                $global:JCAPIKEY = $env:JCApiKey
            }
            # Set $env:JCOrgId in Set-JCOrganization
            $Auth = If ([System.String]::IsNullOrEmpty($JumpCloudOrgId) -and [System.String]::IsNullOrEmpty($env:JCOrgId)) {
                Set-JCOrganization -JumpCloudApiKey:($env:JCApiKey)
            } ElseIf (-not [System.String]::IsNullOrEmpty($JumpCloudOrgId) -and [System.String]::IsNullOrEmpty($env:JCOrgId)) {
                Set-JCOrganization -JumpCloudApiKey:($env:JCApiKey) -JumpCloudOrgId:($JumpCloudOrgId)
            } ElseIf ([System.String]::IsNullOrEmpty($JumpCloudOrgId) -and -not [System.String]::IsNullOrEmpty($env:JCOrgId)) {
                Set-JCOrganization -JumpCloudApiKey:($env:JCApiKey) -JumpCloudOrgId:($env:JCOrgId)
            } ElseIf (-not [System.String]::IsNullOrEmpty($JumpCloudOrgId) -and -not [System.String]::IsNullOrEmpty($env:JCOrgId) -and $JumpCloudOrgId -ne $env:JCOrgId) {
                Set-JCOrganization -JumpCloudApiKey:($env:JCApiKey) -JumpCloudOrgId:($JumpCloudOrgId)
            } Else {
                Write-Debug ('The $JumpCloudOrgId supplied matches existing $env:JCOrgId.')
                Set-JCOrganization -JumpCloudApiKey:($env:JCApiKey) -JumpCloudOrgId:($env:JCOrgId)
            }
            If (-not [System.String]::IsNullOrEmpty($Auth)) {
                # Each time a new org is selected get settings info
                $global:JCSettingsUrl = $JCUrlBasePath + '/api/settings'
                $global:JCSettings = Invoke-JCApi -Method:('GET') -Url:($JCSettingsUrl)
                $global:JCOrgSettings = (Get-JcSdkOrganization -Id $env:JCOrgId).Settings
                #EndRegion Set environment variables that can be used by other scripts
                If (([System.String]::IsNullOrEmpty($JCOrgId)) -or ([System.String]::IsNullOrEmpty($env:JCOrgId))) {
                    Write-Error ('Incorrect JumpCloudOrgID OR no network connectivity. You can obtain your Organization Id below your Organization''s Contact Information on the Settings page.')
                    Break
                }
                If (([System.String]::IsNullOrEmpty($JCAPIKEY)) -or ([System.String]::IsNullOrEmpty($env:JCApiKey))) {
                    Write-Error ('Incorrect API key OR no network connectivity. To locate your JumpCloud API key log into the JumpCloud admin portal. The API key is located with "API Settings" accessible from the drop down in the top right hand corner of the screen')
                    Break
                }
                # Check for updates to the module and only prompt if user has not been prompted during the session already
                If (!($force)) {
                    If ([System.String]::IsNullOrEmpty($env:JcUpdateModule) -or $env:JcUpdateModule -eq 'True') {
                        # Update-JCModule depends on these resources being available, check if available then continue
                        $moduleSites = @(
                            'https://github.com/TheJumpCloud/support/blob/master/PowerShell/ModuleChangelog.md',
                            'https://github.com/TheJumpCloud/support/blob/master/PowerShell/ModuleBanner.md',
                            'https://www.powershellgallery.com/packages/JumpCloud/'
                        )
                        $downRepo = @()
                        foreach ($site in $moduleSites) {
                            $HTTP_Request = [System.Net.WebRequest]::Create($site)
                            try {
                                $HTTP_Response = $HTTP_Request.GetResponse()
                            } catch [System.Net.WebException] {
                                $HTTP_Response = $_.Exception.Response
                            }
                            $HTTP_Status = [int]$HTTP_Response.StatusCode
                            If ($HTTP_Status -eq 200) {
                            } #Site is working properly
                            Else {
                                $downRepo += $site
                            }
                            # Clean up the http request by closing it.
                            If ($HTTP_Response -eq $null) {
                            } Else {
                                $HTTP_Response.Close()
                            }
                        }
                        # If one of the 3 sites are inaccessible, skip running Update-JCModule
                        if ($downRepo.Count -ge 1) {
                            Write-Verbose ("One or more of the required resources to update the JumpCloud Module are inaccessible at the moment" )
                        } else {
                            $env:JcUpdateModule = $false
                            ($updateStatus = Update-JCModule) | Out-Null
                        }
                    }
                    If ($IndShowMessages) {
                        Write-Host ('Connection Status:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
                        Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
                        Write-Host ('Successfully connected to JumpCloud!') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                        Write-Host ('JumpCloudOrgID:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
                        Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
                        Write-Host ($Auth.JCOrgId) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                        Write-Host ('JumpCloudOrgName:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
                        Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
                        Write-Host ($Auth.JCOrgName) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                        # Process Module Notifications:
                        if (($JCConfig.moduleBanner.MessageCount -le 5)) {
                            Write-Host ('Notice:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
                            Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
                            Write-Host $JCConfig.moduleBanner.Message -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                            If (-Not $updateStatus) {
                                # If we recently updated the module, do not update messageCount
                                Set-JCSettingsFile -moduleBannerMessageCount ($JCConfig.moduleBanner.messagecount + 1)
                            }
                        }
                    }
                }
                # Return [PSCustomObject]@{
                # 'JCApiKey'  = $env:JCApiKey;
                # 'JCOrgId'   = $Auth.JCOrgId;
                # 'JCOrgName' = $Auth.JCOrgName;
                # }
            } Else {
                Write-Error ('Unable to set module authentication')
            }
        } Catch {
            Write-Error $_
        }
    }
    End {
    }
}