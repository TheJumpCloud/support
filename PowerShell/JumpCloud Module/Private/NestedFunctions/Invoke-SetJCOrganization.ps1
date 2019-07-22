Function Invoke-SetJCOrganization
{
    [CmdletBinding()]
    Param (
        [String]$JumpCloudAPIKey
    )
    Begin
    {
        Write-Verbose ("Parameter Set: $($PSCmdlet.ParameterSetName)")
        Write-Verbose ('Populating API headers')
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = "$JumpCloudAPIKey"

        }
        $MultiTenant = Test-MultiTenant -JumpCloudAPIKey $JumpCloudAPIKey
        If ($MultiTenant -eq $false)
        {
            Write-Error ("Your admin account is not configured for multi tenant. The Set-JCOrganization command can only be used by admins configured for multi tenant")
            Break
        }
        Write-Verbose ('Populating JCOrganizations')
        $Organizations = Invoke-GetJCOrganization -JumpCloudAPIKey $JumpCloudAPIKey
    }
    Process
    {
        $OrgIDHash = [ordered]@{}
        $OrgNameHash = [ordered]@{}
        # Build user menu
        [Int32]$menuNumber = 1
        Write-Host ("`n======== JumpCloud Multi Tenant Selector ======= `n")
        ForEach ($Org In $Organizations)
        {

            Write-Host ("$menuNumber. displayName: $($Org.displayName) | OrgID:  $($Org.OrgID)   ")
            $OrgIDHash.add($menuNumber, "$($Org.OrgID)")
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
        # Run connection test
        If ($selection -le $OrgIDHash.Count)
        {
            Try
            {
                If ($Organizations.Count -eq 1)
                {
                    $hdrs.Add('x-org-id', "$($Organizations.OrgID)")
                    $global:JCOrgID = $($Organizations.OrgID)
                    Write-Host ("Connected to JumpCloud Tenant: $($Organizations.displayName) | OrgID: $JCOrgID") -BackgroundColor:('Green') -ForegroundColor:('Black')
                }
                ElseIf ($Organizations.Count -gt 1)
                {
                    $hdrs.Add('x-org-id', "$($OrgIDHash.$selection)")
                    $global:JCOrgID = $($OrgIDHash.$selection)
                    Write-Host ("Connected to JumpCloud Tenant: $($OrgNameHash.$selection) | OrgID: $JCOrgID") -BackgroundColor:('Green') -ForegroundColor:('Black')
                }
                Else
                {
                    Write-Error ('Org count is less than 1')
                }
                $ConnectionTestURL = "$JCUrlBasePath/api/v2/ldapservers"
                Invoke-RestMethod -Method GET -Uri $ConnectionTestURL -Headers $hdrs -UserAgent:(Get-JCUserAgent) | Out-Null
            }
            Catch
            {
                Write-Error ("Incorrect OrgID OR no network connectivity. You can obtain your Organization ID below your Organization's Contact Information on the Settings page.")
                $global:JCOrgID = $null
                Break
            }
        }
        Else
        {
            Write-Error ('Unable to validate user input.')
        }
    }
    End
    {
    }

}