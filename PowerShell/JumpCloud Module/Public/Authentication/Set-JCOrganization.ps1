Function Set-JCOrganization
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)][System.String]$JumpCloudAPIKey
        , [Parameter(Mandatory = $false)][System.String]$JumpCloudOrgID
    )
    Begin
    {
        Write-Verbose ("Parameter Set: $($PSCmdlet.ParameterSetName)")
        Write-Verbose ('Populating JCOrganizations')
        $Organizations = Get-JCObject -Type:('organization') -Fields:('_id', 'displayName')
    }
    Process
    {
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
    }
    End
    {
        If (-not ([System.String]::IsNullOrEmpty($OrgName)) -and -not ([System.String]::IsNullOrEmpty($OrgId)))
        {
            Write-Host ("Connected to JumpCloud Tenant: $($OrgName) | OrgID: $OrgId") -BackgroundColor:('Green') -ForegroundColor:('Black')
            Return [PSCustomObject]@{
                'xOrgId'  = $OrgId;
                'OrgName' = $OrgName;
            }
        }
    }
}