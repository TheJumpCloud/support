function Invoke-SetJCOrganization
{
    [CmdletBinding()]
    param (

        [String]$JumpCloudAPIKey
    )
    
    begin
    {
        Write-Verbose "Paramter Set: $($PSCmdlet.ParameterSetName)"
       
        Write-Verbose 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = "$JumpCloudAPIKey"

        }

        $MultiTenant = Test-MultiTenant -JumpCloudAPIKey $JumpCloudAPIKey

        if ($MultiTenant -eq $false)
        {
            Write-Error "Your admin account is not configured for multi tenat. The Set-JCOrganization command can only be used by admins configured for multi tenant"
            break
        }


     
        Write-Verbose 'Populating JCOrganizations'

        $Organizations = Invoke-GetJCOrganization -JumpCloudAPIKey $JumpCloudAPIKey
          
        
    }
    
    process
    {

    
        if ($Organizations.count -eq 1)
        {
        
            try
            {
                $hdrs.Add('x-org-id', "$($Organizations.OrgID)")
                $ConnectionTestURL = "https://console.jumpcloud.com/api"
                Invoke-RestMethod -Method GET -Uri $ConnectionTestURL -Headers $hdrs -UserAgent 'Pwsh_1.7.0'  | Out-Null
                $global:JCOrgID = $($Organizations.OrgID)
                Write-Host -BackgroundColor Green -ForegroundColor Black "Connected to JumpCloud Tenant: $($Organizations.displayName) | OrgID: $JCOrgID"
                
    
            }
            catch
            {
    
                Write-Error "Incorrect OrgID OR no network connectivity. You can obtain your Organization ID below your Organization's Contact Information on the Settings page."
                $global:JCOrgID = $null
                break
                        
            }
        
        }

        elseif ($Organizations.count -gt 1)
        {
          
            $OrgIDHash = [ordered]@{}
            $OrgNameHash = [ordered]@{}
            [int]$menuNumber = 1
            Write-Host "`n======== JumpCloud Multi Tenant Selector ======= `n"

            Foreach ($Org in $Organizations)
            {
        
                Write-Host "$menuNumber. displayName: $($Org.displayName) | OrgID:  $($Org.OrgID)   "
                $OrgIDHash.add($menuNumber, "$($Org.OrgID)")
                $OrgNameHash.add($menuNumber, "$($Org.displayName)")
                $menuNumber++
                
            } 

            Write-Host "`nSelect the number of the JumpCloud tenant you wish to connect to`n" -ForegroundColor Yellow

            $selection = Read-Host "Enter a value between 1 and $($OrgIDHash.count)"

            while ($(1..$OrgIDHash.count) -notcontains $selection)
            {
                write-warning "$selection is not a valid choice"
                $selection = $null
                $selection = Read-Host "Enter a value between 1 and $($OrgIDHash.count)"

            }

            switch ($selection)
            {
                {$_ -le $OrgIDHash.count }
                { 
                                
                    try
                    {
                        $selection = [int]$selection
                        $hdrs.Add('x-org-id', "$($OrgIDHash.$selection)")
                        $ConnectionTestURL = "https://console.jumpcloud.com/api"
                        Invoke-RestMethod -Method GET -Uri $ConnectionTestURL -Headers $hdrs -UserAgent 'Pwsh_1.7.0'  | Out-Null

                        $global:JCOrgID = $($OrgIDHash.$selection)
                        Write-Host -BackgroundColor Green -ForegroundColor Black "Connected to JumpCloud Tenant: $($OrgNameHash.$selection) | OrgID: $JCOrgID"
                
                    }
                    catch
                    {
                
                        Write-Error "Incorrect OrgID OR no network connectivity. You can obtain your Organization ID below your Organization's Contact Information on the Settings page."
                        $global:JCOrgID = $null
                        break
                                    
                    }
                                
                }
            
            }
                    
        }
        
    }

    end
    {
    }

}


#10a38a1b549502b97e02a39059d7c25c254468d5
    
    
