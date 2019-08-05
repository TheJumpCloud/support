Function Set-JCOrganization
{
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage = "Please enter your JumpCloud API key. This can be found in the JumpCloud admin console within 'API Settings' accessible from the drop down icon next to the admin email address in the top right corner of the JumpCloud admin console.")][ValidateNotNullOrEmpty()][System.String]$JumpCloudApiKey = $env:JcApiKey
        , [Parameter(HelpMessage = 'Organization Id can be found in the Settings page within the admin console. Only needed for multi tenant admins.')][ValidateNotNullOrEmpty()][System.String]$JumpCloudOrgId
    )
    Begin
    {
        # Debug message for parameter call
        Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDebugMessageBegin) -ArgumentList:($MyInvocation, $PsBoundParameters, $PSCmdlet) -NoNewScope
    }
    Process
    {
        If ([System.String]::IsNullOrEmpty($JumpCloudApiKey) -and [System.String]::IsNullOrEmpty($env:JcApiKey))
        {
            Connect-JCOnline
        }
        ElseIf ((-not [System.String]::IsNullOrEmpty($JumpCloudApiKey) -and [System.String]::IsNullOrEmpty($env:JcApiKey)))
        {
            Connect-JCOnline -JumpCloudApiKey:($JumpCloudApiKey)
        }
        ElseIf ([System.String]::IsNullOrEmpty($JumpCloudApiKey) -and -not [System.String]::IsNullOrEmpty($env:JcApiKey))
        {
            Connect-JCOnline -JumpCloudApiKey:($env:JcApiKey)
        }
        ElseIf ((-not [System.String]::IsNullOrEmpty($JumpCloudApiKey) -and -not [System.String]::IsNullOrEmpty($env:JcApiKey)) -and $JumpCloudApiKey -ne $env:JcApiKey)
        {
            Connect-JCOnline -JumpCloudApiKey:($JumpCloudApiKey)
        }
        Else
        {
            Write-Verbose ("Parameter Set: $($PSCmdlet.ParameterSetName)")
            Write-Verbose ('Populating JCOrganizations')
            $Organizations = Get-JCObject -Type:('organization') -Fields:('_id', 'displayName')
            If ($Organizations.Count -gt 1)
            {
                # If not JumpCloudOrgId was specified or if the specified JumpCloudOrgId does not exist within the list of available organizations prompt for selection
                If ([System.String]::IsNullOrEmpty($JumpCloudOrgId) -or $JumpCloudOrgId -notin $Organizations._id)
                {

                    $OrgIdHash = [ordered]@{}
                    $OrgNameHash = [ordered]@{}
                    # Build user menu
                    [Int32]$menuNumber = 1
                    Write-Host ("`n======== JumpCloud Multi Tenant Selector ======= `n")
                    ForEach ($Org In $Organizations)
                    {
                        Write-Host ("$menuNumber. Tenant: $($Org.displayName) | OrgId:  $($Org._id)   ")
                        $OrgIdHash.add($menuNumber, "$($Org._id)")
                        $OrgNameHash.add($menuNumber, "$($Org.displayName)")
                        $menuNumber++
                    }
                    # Prompt user for org selection
                    Write-Host ("`nSelect the number of the JumpCloud tenant you wish to connect to`n") -ForegroundColor Yellow
                    Do
                    {
                        [Int32]$selection = Read-Host ("Enter a value between 1 and $($OrgIdHash.Count)")
                        If (!($selection -le $OrgIdHash.Count))
                        {
                            Write-Warning ("$selection is not a valid choice")
                            $selection = $null
                        }
                    }
                    Until ($selection -le $OrgIdHash.Count)
                    $OrgId = $($OrgIdHash.$selection)
                    $OrgName = $($OrgNameHash.$selection)
                }
                Else
                {
                    $OrgId = ($Organizations | Where-Object {$_._id -eq $JumpCloudOrgId})._id
                    $OrgName = ($Organizations | Where-Object {$_._id -eq $JumpCloudOrgId}).displayName
                }
            }
            Else
            {
                $OrgId = $($Organizations._id)
                $OrgName = $($Organizations.displayName)
            }
            If (-not ([System.String]::IsNullOrEmpty($OrgName)) -and -not ([System.String]::IsNullOrEmpty($OrgId)))
            {
                $env:JcOrgId = $OrgId
                $global:JCOrgId = $env:JcOrgId
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