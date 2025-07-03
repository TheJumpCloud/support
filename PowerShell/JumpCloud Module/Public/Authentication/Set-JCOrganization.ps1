Function Set-JCOrganization {
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage = 'Please enter your JumpCloud API key. This can be found in the JumpCloud admin console within "API Settings" accessible from the drop down icon next to the admin email address in the top right corner of the JumpCloud admin console.')][ValidateNotNullOrEmpty()][System.String]$JumpCloudApiKey = $env:JCApiKey
        , [Parameter(HelpMessage = 'Organization Id can be found in the Settings page within the admin console. Only needed for multi tenant admins.')][ValidateNotNullOrEmpty()][System.String]$JumpCloudOrgId = $env:JCOrgId
    )
    Begin {
        # Debug message for parameter call
        $PSBoundParameters | Out-DebugParameter | Write-Debug
    }
    Process {
        # Load color scheme
        $JCColorConfig = Get-JCColorConfig
        # If "$JumpCloudOrgId" is populated set $env:JCOrgId
        If (-not [System.String]::IsNullOrEmpty($JumpCloudOrgId)) {
            $env:JCOrgId = $JumpCloudOrgId
            $global:JCOrgId = $env:JCOrgId
        }
        # Set $env:JCApiKey in Connect-JCOnline
        If ([System.String]::IsNullOrEmpty($JumpCloudApiKey) -and [System.String]::IsNullOrEmpty($env:JCApiKey)) {
            Connect-JCOnline
        } ElseIf ((-not [System.String]::IsNullOrEmpty($JumpCloudApiKey) -and [System.String]::IsNullOrEmpty($env:JCApiKey))) {
            Connect-JCOnline -JumpCloudApiKey:($JumpCloudApiKey)
        } ElseIf ([System.String]::IsNullOrEmpty($JumpCloudApiKey) -and -not [System.String]::IsNullOrEmpty($env:JCApiKey)) {
            Connect-JCOnline -JumpCloudApiKey:($env:JCApiKey)
        } ElseIf ((-not [System.String]::IsNullOrEmpty($JumpCloudApiKey) -and -not [System.String]::IsNullOrEmpty($env:JCApiKey)) -and $JumpCloudApiKey -ne $env:JCApiKey) {
            Connect-JCOnline -JumpCloudApiKey:($JumpCloudApiKey)
        } Else {
            # Auth has been verified
        }
        If ((-not [System.String]::IsNullOrEmpty($JumpCloudApiKey) -and -not [System.String]::IsNullOrEmpty($env:JCApiKey)) -and $JumpCloudApiKey -eq $env:JCApiKey) {
            Write-Verbose ("Parameter Set: $($PSCmdlet.ParameterSetName)")
            Write-Verbose ('Populating JCOrganizations')
            try {
                $Organizations = Get-JCObject -Type:('organization') -Fields:('_id', 'displayName') -ErrorVariable api_err
            } catch {
                Throw
            }
            If (-not [System.String]::IsNullOrEmpty($Organizations)) {
                If ($Organizations.Count -gt 1) {
                    # Set the JCProviderID
                    $JCProviderHeaders = @{
                        'x-api-key' = $env:JCApiKey
                    }
                    $ProviderResponse = Invoke-RestMethod -Uri 'https://console.jumpcloud.com/api/users/getSelf?fields=provider' -Method GET -Headers $JCProviderHeaders
                    If ($ProviderResponse) {
                        $env:JCProviderId = $ProviderResponse.provider
                    }

                    # If not JumpCloudOrgId was specified or if the specified JumpCloudOrgId does not exist within the list of available organizations prompt for selection
                    If ([System.String]::IsNullOrEmpty($JumpCloudOrgId) -or $JumpCloudOrgId -notin $Organizations._id) {
                        $OrgIdHash = [ordered]@{ }
                        $OrgNameHash = [ordered]@{ }
                        # Build user menu
                        $LengthDisplayName = ($Organizations.displayName | Measure-Object -Maximum -Property Length).Maximum
                        $LengthOrgId = ($Organizations._id | Measure-Object -Maximum -Property Length).Maximum
                        $MenuItemTemplate = "{0} {1,-$LengthDisplayName} | {2,-$LengthOrgId}"
                        [Int32]$menuNumber = 1
                        Write-Host ('======= JumpCloud Multi Tenant Selector =======') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
                        Write-Host ($MenuItemTemplate -f '   ', 'JCOrgName', 'JCOrgId') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Action)
                        ForEach ($Org In $Organizations) {
                            $FormattedMenuNumber = If (([System.String]$menuNumber).Length -eq 1) {
                                ' ' + [System.String]$menuNumber
                            } Else {
                                [System.String]$menuNumber
                            }
                            Write-Host ($MenuItemTemplate -f ($FormattedMenuNumber + '.' ), $Org.displayName, $Org._id) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
                            $OrgIdHash.add($menuNumber, $Org._id)
                            $OrgNameHash.add($menuNumber, $Org.displayName)
                            $menuNumber++
                        }
                        # Prompt user for org selection
                        Do {
                            Write-Host ('Select JumpCloud tenant you wish to connect to. Enter a value between 1 and ' + [System.String]$OrgIdHash.Count + ':') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_UserPrompt) -NoNewline
                            Write-Host (' ') -NoNewLine
                            [Int32]$UserSelection = Read-Host
                        }
                        Until ($UserSelection -le $OrgIdHash.Count)
                        $OrgId = $($OrgIdHash.$UserSelection)
                        $OrgName = $($OrgNameHash.$UserSelection)
                    } Else {
                        $OrgId = ($Organizations | Where-Object { $_._id -eq $JumpCloudOrgId })._id
                        $OrgName = ($Organizations | Where-Object { $_._id -eq $JumpCloudOrgId }).displayName
                    }
                } Else {
                    $OrgId = $($Organizations._id)
                    $OrgName = $($Organizations.displayName)
                }
                If (-not ([System.String]::IsNullOrEmpty($OrgId))) {
                    $env:JCOrgId = $OrgId
                    $global:JCOrgId = $env:JCOrgId
                    $env:JCOrgName = $OrgName
                    Return [PSCustomObject]@{
                        # 'JCApiKey'  = $env:JCApiKey;
                        'JCOrgId'   = $env:JCOrgId;
                        'JCOrgName' = $env:JCOrgName;
                    }
                } Else {
                    Write-Error ('OrgId has not been set.')
                }
            } Else {
                Write-Error ('Unable to get organization info.')
            }
        }
    }
    End {
    }
}
