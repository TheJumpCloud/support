function Connect-JCOnline () {
    [CmdletBinding()]
    param
    (
        [Parameter(
            ParameterSetName = 'force',
            HelpMessage = 'Using the "-Force" parameter the module update check is skipped. The ''-Force'' parameter should be used when using the JumpCloud module in scripts or other automation environments.'
        )]
        [Switch]$force
    )
    dynamicparam {
        $Param_JumpCloudApiKey = @{
            'Name'                            = 'JumpCloudApiKey';
            'Type'                            = [System.String];
            'Position'                        = 1;
            'ValueFromPipelineByPropertyName' = $true;
            'ValidateNotNullOrEmpty'          = $true;
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
            'ValidateNotNullOrEmpty'          = $false;
            'HelpMessage'                     = 'Enter the region for your JumpCloud organization; "EU" or "STANDARD".';
            'ValidateSet'                     = ('STANDARD', 'staging', 'EU');
        }
        # If the $env:JCApiKey is not set then make the JumpCloudApiKey mandatory else set the default value to be the env variable
        if ([System.String]::IsNullOrEmpty($env:JCApiKey)) {
            $Param_JumpCloudApiKey.Add('Mandatory', $true);
        } else {
            $Param_JumpCloudApiKey.Add('Default', $env:JCApiKey);
        }
        # If the $env:JCOrgId is set then set the default value to be the env variable
        if (-not [System.String]::IsNullOrEmpty($env:JCOrgId)) {
            $Param_JumpCloudOrgId.Add('Default', $env:JCOrgId);
        }
        # If the $env:JCEnvironment is set then set the default value to be the env variable
        if (-not [System.String]::IsNullOrEmpty($env:JCEnvironment)) {
            $Param_JCEnvironment.Add('Default', $env:JCEnvironment);
        } else {
            $Param_JCEnvironment.Add('Default', 'STANDARD');
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
            try {
                New-DynamicParameter @VarValue | Out-Null
            } catch {
                Write-Error -Message:('Unable to create dynamic parameter:"' + $VarName.Replace($ParamVarPrefix, '') + '"; Error:' + $Error)
            }
        }
        $IndShowMessages = if ([System.String]::IsNullOrEmpty($JumpCloudApiKey) -and [System.String]::IsNullOrEmpty($JumpCloudOrgId) -and -not [System.String]::IsNullOrEmpty($env:JCApiKey) -and -not [System.String]::IsNullOrEmpty($env:JCOrgId)) {
            $false
        } else {
            $true
        }
        return $RuntimeParameterDictionary
    }
    begin {
        # Debug message for parameter call
        $PSBoundParameters | Out-DebugParameter | Write-Debug
    }
    process {
        # Load color scheme
        $JCColorConfig = Get-JCColorConfig
        # For DynamicParam with a default value set that value and then convert the DynamicParam inputs into new variables for the script to use
        Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDynamicParamProcess) -ArgumentList:($PsBoundParameters, $PSCmdlet, $RuntimeParameterDictionary) -NoNewScope
        try {
            #Region Set environment variables that can be used by other scripts
            # If "$JCEnvironment" is populated or if "$env:JCEnvironment" is not set
            if ($JCConfig.JCEnvironment.Location -ne 'US') {
                $JCEnvironment = $JCConfig.JCEnvironment.Location
            }
            if (-not [System.String]::IsNullOrEmpty($JCEnvironment)) {
                # Set $env:JCEnvironment
                $env:JCEnvironment = $JCEnvironment
                $global:JCEnvironment = $env:JCEnvironment
                Set-JCSettingsFile -JCEnvironmentLocation $JCEnvironment
            }
            $global:JCUrlBasePath = switch ($JCEnvironment) {
                'STANDARD' {
                    "https://console.jumpcloud.com"
                }
                'staging' {
                    "https://console.awsstg.jumpcloud.com"
                }
                'EU' {
                    "https://console.eu.jumpcloud.com"
                }
                default {
                    "https://console.jumpcloud.com"
                }
            }
            # If "$JumpCloudApiKey" is populated set $env:JCApiKey
            if (-not [System.String]::IsNullOrEmpty($JumpCloudApiKey)) {
                $env:JCApiKey = $JumpCloudApiKey
                $global:JCAPIKEY = $env:JCApiKey
            }
            # Set $env:JCOrgId in Set-JCOrganization
            try {
                $Auth = if ([System.String]::IsNullOrEmpty($JumpCloudOrgId) -and [System.String]::IsNullOrEmpty($env:JCOrgId)) {
                    Set-JCOrganization -JumpCloudApiKey:($env:JCApiKey) -ErrorVariable api_err
                } elseif (-not [System.String]::IsNullOrEmpty($JumpCloudOrgId) -and [System.String]::IsNullOrEmpty($env:JCOrgId)) {
                    Set-JCOrganization -JumpCloudApiKey:($env:JCApiKey) -JumpCloudOrgId:($JumpCloudOrgId) -ErrorVariable api_err
                } elseif ([System.String]::IsNullOrEmpty($JumpCloudOrgId) -and -not [System.String]::IsNullOrEmpty($env:JCOrgId)) {
                    Set-JCOrganization -JumpCloudApiKey:($env:JCApiKey) -JumpCloudOrgId:($env:JCOrgId) -ErrorVariable api_err
                } elseif (-not [System.String]::IsNullOrEmpty($JumpCloudOrgId) -and -not [System.String]::IsNullOrEmpty($env:JCOrgId) -and $JumpCloudOrgId -ne $env:JCOrgId) {
                    Set-JCOrganization -JumpCloudApiKey:($env:JCApiKey) -JumpCloudOrgId:($JumpCloudOrgId) -ErrorVariable api_err
                } else {
                    Write-Debug ('The $JumpCloudOrgId supplied matches existing $env:JCOrgId.')
                    Set-JCOrganization -JumpCloudApiKey:($env:JCApiKey) -JumpCloudOrgId:($env:JCOrgId) -ErrorVariable api_err
                }
            } catch {
                Write-Verbose "Error: Unable to validate API Key"
            }
            if (-not [System.String]::IsNullOrEmpty($Auth)) {
                # Each time a new org is selected get settings info
                $global:JCSettingsUrl = $JCUrlBasePath + '/api/settings'
                $global:JCSettings = Invoke-JCApi -Method:('GET') -Url:($JCSettingsUrl)
                $global:JCOrgSettings = (Get-JcSdkOrganization -Id $env:JCOrgId).Settings
                #EndRegion Set environment variables that can be used by other scripts
                if (([System.String]::IsNullOrEmpty($JCOrgId)) -or ([System.String]::IsNullOrEmpty($env:JCOrgId))) {
                    Write-Error ('Incorrect JumpCloudOrgID OR no network connectivity. You can obtain your Organization Id below your Organization''s Contact Information on the Settings page.')
                    break
                }
                if (([System.String]::IsNullOrEmpty($JCAPIKEY)) -or ([System.String]::IsNullOrEmpty($env:JCApiKey))) {
                    Write-Error ('Incorrect API key OR no network connectivity. To locate your JumpCloud API key log into the JumpCloud admin portal. The API key is located with "API Settings" accessible from the drop down in the top right hand corner of the screen')
                    break
                }
                # Check for updates to the module and only prompt if user has not been prompted during the session already
                if (!($force)) {
                    if ([System.String]::IsNullOrEmpty($env:JcUpdateModule) -or $env:JcUpdateModule -eq 'True') {
                        # Update-JCModule depends on these resources being available, check if available then continue
                        $moduleSites = @(
                            'https://github.com/TheJumpCloud/support/blob/master/PowerShell/ModuleChangelog.md',
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
                            if ($HTTP_Status -eq 200) {
                            } #Site is working properly
                            else {
                                $downRepo += $site
                            }
                            # Clean up the http request by closing it.
                            if ($HTTP_Response -eq $null) {
                            } else {
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
                    if ($IndShowMessages) {
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
                            if (-not $updateStatus) {
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
            } else {
                Write-Verbose "Error: Unable to set module authentication"
            }
            # set Argument Completer(s) which require authentication
            $templates = Get-JcSdkPolicyTemplate
            $global:TemplateNameList = New-Object System.Collections.ArrayList
            foreach ($template in $templates) {
                $templateHashObject = [PSCustomObject]@{
                    Name = ("$($template.osmetafamily) $($template.displayname)").Replace(' ', '_')
                    Id   = $template.Id
                }
                $TemplateNameList.Add($templateHashObject) | Out-Null
            }

            Register-ArgumentCompleter -CommandName New-JCpolicy -ParameterName TemplateName -ScriptBlock {
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

                $TypeFilter = $fakeBoundParameter.Name;
                $TemplateNameList.Name | Where-Object { $_ -like "${TypeFilter}*" } | Where-Object { $_ -like "${wordToComplete}*" } | Sort-Object -Unique | ForEach-Object { $_ }
            }

        } catch {
            throw "Unable to authenticate: $_"
        }
    }
    end {
    }
}
