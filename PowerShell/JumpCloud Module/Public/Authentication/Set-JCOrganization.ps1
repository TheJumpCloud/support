Function Set-JCOrganization
{
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage = "Please enter your JumpCloud API key. This can be found in the JumpCloud admin console within 'API Settings' accessible from the drop down icon next to the admin email address in the top right corner of the JumpCloud admin console.")][ValidateNotNullOrEmpty()][System.String]$JumpCloudAPIKey = $env:JcApiKey
        , [Parameter(HelpMessage = 'Organization ID can be found in the Settings page within the admin console. Only needed for multi tenant admins.')][ValidateNotNullOrEmpty()][System.String]$JumpCloudOrgID
    )
    Begin
    {
        # Debug message for parameter call
        Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDebugMessageBegin) -ArgumentList:($MyInvocation, $PsBoundParameters, $PSCmdlet) -NoNewScope
    }
    Process
    {
        # If parameter $JumpCloudAPIKey is populated but $env:JcApiKey has not yet been set
        If (-not [System.String]::IsNullOrEmpty($JumpCloudAPIKey) -and [System.String]::IsNullOrEmpty($env:JcApiKey))
        {
            Return Connect-JCOnline -JumpCloudAPIKey:($JumpCloudAPIKey)
        }
        # If $env:JcApiKey has not yet been set or parameter $JumpCloudAPIKey does not equal $env:JcApiKey
        ElseIf ([System.String]::IsNullOrEmpty($env:JcApiKey) -or $JumpCloudAPIKey -ne $env:JcApiKey)
        {
            Return Connect-JCOnline
        }
        Else
        {
            Write-Verbose ("Parameter Set: $($PSCmdlet.ParameterSetName)")
            Write-Verbose ('Populating JCOrganizations')
            $Organizations = Get-JCObject -Type:('organization') -Fields:('_id', 'displayName')
            If ([System.String]::IsNullOrEmpty($JumpCloudOrgID))
            {
                If ($Organizations.Count -gt 1)
                {
                    $OrgIDHash = [ordered]@{}
                    $OrgNameHash = [ordered]@{}
                    # Build user menu
                    [Int32]$menuNumber = 1
                    Write-Host ("`n======== JumpCloud Multi Tenant Selector ======= `n")
                    ForEach ($Org In $Organizations)
                    {
                        Write-Host ("$menuNumber. Tenant: $($Org.displayName) | OrgID:  $($Org._id)   ")
                        $OrgIDHash.add($menuNumber, "$($Org._id)")
                        $OrgNameHash.add($menuNumber, "$($Org.displayName)")
                        $menuNumber++
                    }
                    # Prompt user for org selection
                    Write-Host ("`nSelect the number of the JumpCloud tenant you wish to connect to`n") -ForegroundColor Yellow
                    Do
                    {
                        [Int32]$selection = Read-Host ("Enter a value between 1 and $($OrgIDHash.Count)")
                        If (!($selection -le $OrgIDHash.Count))
                        {
                            Write-Warning ("$selection is not a valid choice")
                            $selection = $null
                        }
                    }
                    Until ($selection -le $OrgIDHash.Count)
                    # Validate user input
                    If ($selection -le $OrgIDHash.Count)
                    {
                        If ($Organizations.Count -gt 1)
                        {
                            $OrgId = $($OrgIDHash.$selection)
                            $OrgName = $($OrgNameHash.$selection)
                        }
                        Else
                        {
                            $OrgId = $null
                            $OrgName = $null
                            Write-Error ('Org count is less than 1')
                        }
                    }
                    Else
                    {
                        Write-Error ('Unable to validate user input.')
                    }
                }
                Else
                {
                    $OrgId = $($Organizations._id)
                    $OrgName = $($Organizations.displayName)
                }
            }
            Else
            {
                $OrgId = ($Organizations | Where-Object {$_._id -eq $JumpCloudOrgID})._id
                $OrgName = ($Organizations | Where-Object {$_._id -eq $JumpCloudOrgID}).displayName
            }
            If (-not ([System.String]::IsNullOrEmpty($OrgName)) -and -not ([System.String]::IsNullOrEmpty($OrgId)))
            {
                $env:JcOrgId = $OrgId
                $global:JCOrgID = $env:JcOrgId
                $env:JcOrgName = $OrgName
                Write-Host ("Connected to JumpCloud Tenant: $($OrgName) | OrgId: $($OrgId)") -BackgroundColor:('Green') -ForegroundColor:('Black')
                Return [PSCustomObject]@{
                    'JcApiKey'  = $env:JcApiKey;
                    'JcOrgId'   = $env:JcOrgId;
                    'JcOrgName' = $env:JcOrgName;
                }
            }
            Else
            {
                Write-Error ('OrgId and OrgName have not been set.')
            }
        }
    }
    End
    {
    }
}