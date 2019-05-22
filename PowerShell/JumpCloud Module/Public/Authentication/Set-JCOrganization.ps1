function Set-JCOrganization
{
    [CmdletBinding(DefaultParameterSetName = 'Choice')]
    param (

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Entry',
            Position = 0)]

        [String]$OrgID

    )
    
    begin
    {
        Write-Verbose "Paramter Set: $($PSCmdlet.ParameterSetName)"
       
        #if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Verbose 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = "$JCAPIKEY"

        }

        $MultiTenant = Test-MultiTenant -JumpCloudAPIKey $JCAPIKEY

        if ($MultiTenant -eq $false)
        {
            Write-Error "Your admin account is not configured for multi tenat. The Set-JCOrganization command can only be used by admins configured for multi tenant"
            break
        }


        if ($PSCmdlet.ParameterSetName -ne 'Entry')
        {
            Write-Verbose 'Populating JCOrganizations'

            $Organizations = Invoke-GetJCOrganization -JumpCloudAPIKey $JCAPIKEY
        }       
        
    }
    
    process
    {

        switch ($PSCmdlet.ParameterSetName)
        {

            Entry
            { 

                try
                {
                    $hdrs.Add('x-org-id', "$($OrgID)")
                    $ConnectionTestURL = "$JCUrlBasePath/api/v2/ldapservers"
                    Invoke-RestMethod -Method GET -Uri $ConnectionTestURL -Headers $hdrs -UserAgent $JCUserAgent | Out-Null
                    $global:JCOrgID = $OrgID
                    Write-Host -BackgroundColor Green -ForegroundColor Black "Connected to JumpCloud Tenant OrgID: $JCOrgID"


                }
                catch
                {

                    Write-Error "Incorrect OrgID OR no network connectivity. You can obtain your Organization ID below your Organization's Contact Information on the Settings page."
                    $global:JCOrgID = $null
                    break
                    
                }

            }
            Choice
            {

                if ($Organizations.count -eq 1)
                {
                
                    try
                    {
                        $hdrs.Add('x-org-id', "$($Organizations.OrgID)")
                        $ConnectionTestURL = "$JCUrlBasePath/api/v2/ldapservers"
                        Invoke-RestMethod -Method GET -Uri $ConnectionTestURL -Headers $hdrs -UserAgent $JCUserAgent | Out-Null
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
                                $ConnectionTestURL = "$JCUrlBasePath/api/v2/ldapservers"
                                Invoke-RestMethod -Method GET -Uri $ConnectionTestURL -Headers $hdrs -UserAgent $JCUserAgent | Out-Null
        
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

        }


    }

        

    
    end
    {
    }
}