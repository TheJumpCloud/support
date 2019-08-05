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
        $Param_JumpCloudApiKey = @{
            'Name'                            = 'JumpCloudApiKey';
            'Type'                            = [System.String];
            'Position'                        = 0;
            'ValueFromPipelineByPropertyName' = $true;
            'ValidateNotNullOrEmpty'          = $true;
            'ValidateLength'                  = (40, 40);
            'ParameterSets'                   = ('force', 'Interactive');
            'HelpMessage'                     = "Please enter your JumpCloud API key. This can be found in the JumpCloud admin console within 'API Settings' accessible from the drop down icon next to the admin email address in the top right corner of the JumpCloud admin console.";
        }
        $Param_JumpCloudOrgId = @{
            'Name'                            = 'JumpCloudOrgId';
            'Type'                            = [System.String];
            'Position'                        = 1;
            'ValueFromPipelineByPropertyName' = $true;
            'ValidateNotNullOrEmpty'          = $true;
            'ParameterSets'                   = ('force', 'Interactive');
            'HelpMessage'                     = 'Organization Id can be found in the Settings page within the admin console. Only needed for multi tenant admins.';
        }
        # If the $env:JcApiKey is not set then make the JumpCloudApiKey mandatory else set the default value to be the env variable
        If ([System.String]::IsNullOrEmpty($env:JcApiKey))
        {
            $Param_JumpCloudApiKey.Add('Mandatory', $true);
        }
        Else
        {
            $Param_JumpCloudApiKey.Add('Default', $env:JcApiKey);
        }
        # If the $env:JcOrgId is set then set the default value to be the env variable
        If (-not [System.String]::IsNullOrEmpty($env:JcOrgId))
        {
            $Param_JumpCloudOrgId.Add('Default', $env:JcOrgId);
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
    }
    Process
    {

        # For DynamicParam with a default value set that value and then convert the DynamicParam inputs into new variables for the script to use
        Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDynamicParamProcess) -ArgumentList:($PsBoundParameters, $PSCmdlet, $RuntimeParameterDictionary) -NoNewScope
        Try
        {
            # Update security protocol
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls, [System.Net.SecurityProtocolType]::Tls12
            #Region Set environment variables that can be used by other scripts
            # Check for updates to the module and only prompt if user has not been prompted during the session already
            If ($JCEnvironment -ne 'local')
            {
                If (!($force))
                {
                    If ([System.String]::IsNullOrEmpty($env:JcUpdateModule) -or $env:JcUpdateModule -eq 'True')
                    {
                        $env:JcUpdateModule = $false
                        $ModuleUpdate = Update-JCModule
                        $InstalledVersion = $ModuleUpdate.InstalledVersion
                        $LatestVersion = $ModuleUpdate.LatestVersion
                        If ($InstalledVersion -eq $LatestVersion)
                        {
                            Break
                        }
                    }
                }
            }
            # If "$JumpCloudApiKey" is populated or if "$env:JcApiKey" is not set
            If (-not ([System.String]::IsNullOrEmpty($JumpCloudApiKey)))
            {
                # Set $env:JcApiKey
                $env:JcApiKey = $JumpCloudApiKey
                $global:JCAPIKEY = $env:JcApiKey
            }
            # Set $env:JcOrgId in Set-JCOrganization
            $Auth = If ([System.String]::IsNullOrEmpty($JumpCloudOrgId) -and [System.String]::IsNullOrEmpty($env:JcOrgId))
            {
                Set-JCOrganization -JumpCloudApiKey:($env:JcApiKey)
            }
            ElseIf (-not [System.String]::IsNullOrEmpty($JumpCloudOrgId) -and [System.String]::IsNullOrEmpty($env:JcOrgId))
            {
                Set-JCOrganization -JumpCloudApiKey:($env:JcApiKey) -JumpCloudOrgId:($JumpCloudOrgId)
            }
            ElseIf ([System.String]::IsNullOrEmpty($JumpCloudOrgId) -and -not [System.String]::IsNullOrEmpty($env:JcOrgId))
            {
                Set-JCOrganization -JumpCloudApiKey:($env:JcApiKey) -JumpCloudOrgId:($env:JcOrgId)
            }
            ElseIf (-not [System.String]::IsNullOrEmpty($JumpCloudOrgId) -and -not [System.String]::IsNullOrEmpty($env:JcOrgId) -and $JumpCloudOrgId -ne $env:JcOrgId)
            {
                Set-JCOrganization -JumpCloudApiKey:($env:JcApiKey) -JumpCloudOrgId:($JumpCloudOrgId)
            }
            Else
            {
                Write-Debug ('The $JumpCloudOrgId supplied matches existing $env:JcOrgId.')
                Set-JCOrganization -JumpCloudApiKey:($env:JcApiKey) -JumpCloudOrgId:($env:JcOrgId)
            }
            If (-not [System.String]::IsNullOrEmpty($Auth))
            {
                # Each time a new org is selected get settings info
                $global:JCSettingsUrl = $JCUrlBasePath + '/api/settings'
                $global:JCSettings = Invoke-JCApi -Method:('GET') -Url:($JCSettingsUrl)
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
                If (([System.String]::IsNullOrEmpty($JCOrgId)) -or ([System.String]::IsNullOrEmpty($env:JcOrgId)))
                {
                    Write-Error "Incorrect OrgId OR no network connectivity. You can obtain your Organization Id below your Organization's Contact Information on the Settings page."
                    Break
                }
                If (([System.String]::IsNullOrEmpty($JCAPIKEY)) -or ([System.String]::IsNullOrEmpty($env:JcApiKey)))
                {
                    Write-Error "Incorrect API key OR no network connectivity. To locate your JumpCloud API key log into the JumpCloud admin portal. The API key is located with 'API Settings' accessible from the drop down in the top right hand corner of the screen"
                    Break
                }
                Write-Host ('Successfully connected to JumpCloud!') -BackgroundColor:('Green') -ForegroundColor:('Black')
                Return [PSCustomObject]@{
                    'JcApiKey'  = $env:JcApiKey;
                    'JcOrgId'   = $Auth.JcOrgId;
                    'JcOrgName' = $Auth.JcOrgName;
                }
            }
            Else
            {
                Write-Error ('Unable to set module authentication')
            }
        }
        Catch
        {
            Write-Error $_
        }
    }
    End
    {
    }
}