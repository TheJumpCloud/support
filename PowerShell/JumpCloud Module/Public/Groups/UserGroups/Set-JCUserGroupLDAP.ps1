Function Set-JCUserGroupLDAP
{
    [CmdletBinding(DefaultParameterSetName = 'GroupName')]

    param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'GroupName',
            Position = 0)]
        [Alias('name')]
        [String]$GroupName,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'GroupID',
            Position = 0)]
        [Alias('id', '_id')]
        [String]$GroupID,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'GroupName')]

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'GroupID')]

        [Boolean]$LDAPEnabled
    )

    begin

    {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Debug 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        if ($JCOrgID)
        {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }

        Write-Debug 'Initilizing rawResults and results resultsArray'
        $resultsArray = @()




        if ($PSCmdlet.ParameterSetName -eq 'GroupName')
        {

            Write-Debug 'Populating GroupNameHash'
            $GroupNameHash = Get-Hash_UserGroupName_ID

        }


        $LDAPURL = "https://console.jumpcloud.com/api/v2/ldapservers"

        $LDAPServer = Invoke-RestMethod -Method GET -Uri $LDAPURL  -Header $hdrs -UserAgent 'Pwsh_1.7.0'
        
        if ($LDAPServer.Count -gt 1)
        {
            Write-Error "More than 1 LDAP Server. Action aborted"
            Return        
        }

        $LDAPServerID = $LDAPServer.id
    }
    
    process
    {


        if ($PSCmdlet.ParameterSetName -eq 'GroupName')
        {

            $GroupID = $GroupNameHash.Get_Item($GroupName)
            
            $POSTUrl = "https://console.jumpcloud.com/api/v2/usergroups/$GroupID/associations"

            switch ($LDAPEnabled)
            {
                $true
                {

                    $PostBody = @{
                        op         = 'add'
                        id         = "$LDAPServerID" 
                        type       = 'ldap_server'
                        attributes = $null
                    }

                }
                $false
                {

                    $PostBody = @{
                        op         = 'remove'
                        id         = "$LDAPServerID" 
                        type       = 'ldap_server'
                        attributes = $null
                    }
                }
            }

            $JsonPostBody = $PostBody | ConvertTo-Json

            try
            {
            
                $LDAPUpdate = Invoke-RestMethod -Method Post -Uri $POSTUrl -Body $JsonPostBody -Headers $hdrs -UserAgent 'Pwsh_1.7.0'

                $Results = [PSCustomObject]@{

                    GroupName   = $GroupName
                    LDAPEnabled = $LDAPEnabled

                }
                
            }
            catch
            {

                $Results = [PSCustomObject]@{

                    GroupName   = $GroupName
                    LDAPEnabled = $_.ErrorDetails

                }
                
            }

            $resultsArray += $Results

            
        } #End if

        elseif ($PSCmdlet.ParameterSetName -eq 'GroupID')
        {
            
            $POSTUrl = "https://console.jumpcloud.com/api/v2/usergroups/$GroupID/associations"

            switch ($LDAPEnabled)
            {
                $true
                {

                    $PostBody = @{
                        op         = 'add'
                        id         = "$LDAPServerID" 
                        type       = 'ldap_server'
                        attributes = $null
                    }

                }
                $false
                {

                    $PostBody = @{
                        op         = 'remove'
                        id         = "$LDAPServerID" 
                        type       = 'ldap_server'
                        attributes = $null
                    }
                }
            }

            $JsonPostBody = $PostBody | ConvertTo-Json

            try
            {
            
                $LDAPUpdate = Invoke-RestMethod -Method Post -Uri $POSTUrl -Body $JsonPostBody -Headers $hdrs -UserAgent 'Pwsh_1.7.0'

                $Results = [PSCustomObject]@{

                    GroupID     = $GroupID
                    LDAPEnabled = $LDAPEnabled

                }
                
            }
            catch
            {

                $Results = [PSCustomObject]@{

                    GroupID     = $GroupID
                    LDAPEnabled = $_.ErrorDetails

                }
                
            }

            $resultsArray += $Results
                
        }#End elseif 
            
    } #Ened process 
    
    end
    {

        Return $resultsArray

    }
}