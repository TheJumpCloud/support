function Connect-JCOnline () {
    [CmdletBinding()]
    param
    (
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Using the "-Force" parameter the module update check is skipped.'
        )]
        [Switch]$force,
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use the -select to select from stored API keys. Or informe an value with the same param'
        )]
        [Switch]$Select,
        # Its the key name, not the key value
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Vault Key Name.'
        )]
        [string]$Credential
    )
    dynamicparam {
        $BoundParams = $PSCmdlet.MyInvocation.BoundParameters
        $RuntimeParameterDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
        $RawCommandLine = [string]$MyInvocation.Line
        
        $Param_JumpCloudApiKey = @{
            'Name'                            = 'JumpCloudApiKey';
            'Type'                            = [System.String];
            'Position'                        = 1;
            'ValueFromPipelineByPropertyName' = $true;
            'ValidateNotNullOrEmpty'          = $false;
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
            'HelpMessage'                     = 'Enter the region for your JumpCloud organization; "EU" or "STANDARD".';
            'ValidateSet'                     = ('STANDARD', 'STAGING', 'EU');
        }
        # If the $env:JCApiKey is not set then make the JumpCloudApiKey mandatory else set the default value to be the env variable
        # Priority for selecting key is: 1)  -JumpCloudApiKey parameter, 2) -Select parameter, 3) $env:JCApiKey
        # Reformulated to get less confusing
        $containsApiKey = $false
        if($RawCommandLine -match 'JumpCloudApiKey') {$containsApiKey = $true}
        $emp1 = $BoundParams.ContainsKey('Select') -and (-not $BoundParams.ContainsKey('Credential')) -and (-not $containsApiKey)
        $emp2 = [System.String]::IsNullOrEmpty($env:JCApiKey) -and (-not $containsApiKey) -and (-not $BoundParams.ContainsKey('Credential'))
        if($emp1 -or $emp2) {
            $newKey = KeySelector
        }
        if($BoundParams.ContainsKey('Credential')) {
            $newKey = KeySelector -keyName $BoundParams['Credential']
        }

        if(-not [System.String]::IsNullOrEmpty($newKey)) { $env:JCApiKey = $newKey }
        if([System.String]::IsNullOrEmpty($env:JCApiKey)) {
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
        # Debug message for parameter call]
        Write-Debug -Message:('Parameter values:')
        $PSBoundParameters | Out-DebugParameter | Write-Debug
    }
    process {
        # Load color scheme
        $JCColorConfig = Get-JCColorConfig
        # For DynamicParam with a default value set that value and then convert the DynamicParam inputs into new variables for the script to use
        Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDynamicParamProcess) -ArgumentList:($PsBoundParameters, $PSCmdlet, $RuntimeParameterDictionary) -NoNewScope
        try {
            #Region Set environment variables that can be used by other scripts
            if ([System.String]::IsNullOrEmpty($JCEnvironment)) {
                $env:JCEnvironment = $JCConfig.JCEnvironment.location
                $global:JCEnvironment = $env:JCEnvironment
            } else {
                # Set $env:JCEnvironment
                $env:JCEnvironment = $JCEnvironment
                $global:JCEnvironment = $env:JCEnvironment
                Set-JCSettingsFile -JCEnvironmentLocation $JCEnvironment
            }

            switch ($env:JCEnvironment) {
                'STANDARD' {
                    $global:JCUrlBasePath = "https://console.jumpcloud.com"
                    $Global:PSDefaultParameterValues['*-JcSdk*:ApiHost'] = "api"
                    $PSDefaultParameterValues['*-JcSdk*:ApiHost'] = "api"
                    $Global:PSDefaultParameterValues['*-JcSdk*:ConsoleHost'] = "console"
                    $PSDefaultParameterValues['*-JcSdk*:ConsoleHost'] = "console"
                    $env:JCEnvironment = 'STANDARD'
                }
                'STAGING' {
                    $global:JCUrlBasePath = "https://console.stg01.jumpcloud.com"
                    $Global:PSDefaultParameterValues['*-JcSdk*:ApiHost'] = "api.stg01"
                    $PSDefaultParameterValues['*-JcSdk*:ApiHost'] = "api.stg01"
                    $Global:PSDefaultParameterValues['*-JcSdk*:ConsoleHost'] = "console.stg01"
                    $PSDefaultParameterValues['*-JcSdk*:ConsoleHost'] = "console.stg01"
                    $env:JCEnvironment = 'STAGING'

                }
                'EU' {
                    $global:JCUrlBasePath = "https://console.eu.jumpcloud.com"
                    $Global:PSDefaultParameterValues['*-JcSdk*:ApiHost'] = "api.eu"
                    $PSDefaultParameterValues['*-JcSdk*:ApiHost'] = "api.eu"
                    $Global:PSDefaultParameterValues['*-JcSdk*:ConsoleHost'] = "console.eu"
                    $PSDefaultParameterValues['*-JcSdk*:ConsoleHost'] = "console.eu"
                    $env:JCEnvironment = 'EU'
                }
                default {
                    $global:JCUrlBasePath = "https://console.jumpcloud.com"
                    $Global:PSDefaultParameterValues['*-JcSdk*:ApiHost'] = "api"
                    $PSDefaultParameterValues['*-JcSdk*:ApiHost'] = "api"
                    $Global:PSDefaultParameterValues['*-JcSdk*:ConsoleHost'] = "console"
                    $PSDefaultParameterValues['*-JcSdk*:ConsoleHost'] = "console"
                    $env:JCEnvironment = 'STANDARD'
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
                            if ($null -eq $HTTP_Response) {
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

function KeySelector {
    param(
        [Parameter(Mandatory=$false)]
        [string]$keyName
    ) 
    Unlock-Platform
    if(-not [System.String]::IsNullOrEmpty($keyName)) {
        return Request-Key -vaultKey $keyName
    }

    $sufix_ = ".api.jc"
    $keys = Get-VaultKeys -sufix $sufix_
    if(($null -eq $keys) -or ($keys.Count -eq 0)) {
        Write-Host "No keys found in vault. Please add a new key." -ForegroundColor Yellow
        Request-NewKey -sufix $sufix_
        $keys = Get-VaultKeys -sufix $sufix_
    }

    Write-Host "Select the JumpCloud Api Key. Press [Escape] to type a new key. Press [Backspace] to remove the selected key" -ForegroundColor Green
    # Stays in selection loop until user selects a key or abort.
    while (@($false, $null) -contains ($vaultKey = Find-Interactive -choices $keys -Callback {
        param($param)
        return Confirm-Console -Message "Selected key: $param. Are you sure want to remove this key from vault?" -YesAction { Remove-FromVault -Key $param }
    })) {
        $keys = Get-VaultKeys -sufix $sufix_
        if (($null -eq $vaultKey) -or ($null -eq $keys) -or ($keys.Count -eq 0)) {
            if($keys.Count -eq 0) {
                Write-Host "No keys found in vault. Please add a new key." -ForegroundColor Yellow
            }
            Request-NewKey -sufix $sufix_
        }
        $keys = Get-VaultKeys -sufix $sufix_
    }

    # $vaultKey is being declared above as the output of Find-Interactive, so it will be available here for
    $foundKey = Request-Key -vaultKey $vaultKey

    Clear-Console -LinesToClear 2
    return $foundKey
}

function Request-Key {
    param (
        [Parameter(Mandatory=$false)]
        [string]$vaultKey
    )
    $foundKey = Get-KeyFromVault -Key $vaultKey

    if("" -eq $foundKey -or $null -eq $foundKey) {
        Write-Host "Aborted. Exiting." -ForegroundColor Yellow
        throw "No key selected"
    } else {
        return $foundKey
    }
}