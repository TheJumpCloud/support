Function Set-JCSystemUser ()
{
    [CmdletBinding(DefaultParameterSetName = 'ByName')]

    param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByName',
            Position = 0)]
        [String]$Username,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'ByID')]
        [string]
        $UserID,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByName',
            Position = 1)]

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'ByID')]

        [string]
        [alias("_id")]
        $SystemID,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByName',
            Position = 2)]

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'ByID')]

        [bool]
        $Administrator

    )

    begin

    {
        Write-Verbose 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Verbose 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        if ($JCOrgID)
        {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }

        Write-Verbose 'Initilizing SystemUpdateArray'
        $SystemUpdateArray = @()

        if ($PSCmdlet.ParameterSetName -eq 'ByName')
        {
            Write-Verbose $PSCmdlet.ParameterSetName

            Write-Verbose 'Populating HostNameHash'
            $HostNameHash = Get-Hash_SystemID_HostName
            Write-Verbose 'Populating UserNameHash'
            $UserNameHash = Get-Hash_UserName_ID
        }

        Write-Verbose $PSCmdlet.ParameterSetName
    }

    process

    {
        if ($PSCmdlet.ParameterSetName -eq 'ByName')
        {
            if ($HostNameHash.containsKey($SystemID)) {}

            else { Throw "SystemID does not exist. Run 'Get-JCsystem | select Hostname, _id' to see a list of all your JumpCloud systems and the associated _id."}

            if ($UserNameHash.containsKey($Username)) {}

            else { Throw "Username does not exist. Run 'Get-JCUser | select username' to see a list of all your JumpCloud users."}

            $UserID = $UserNameHash.Get_Item($Username)
            $HostName = $HostNameHash.Get_Item($SystemID)

            if ($Administrator -eq $true)
            {

                $body = @{

                    op         = "update"
                    type       = "user"
                    id         = $UserID
                    attributes = @{
                        sudo = @{
                            enabled         = $true
                            withoutPassword = $false
                    
                        }
                    }
    
                }
                    
            }

            elseif ($Administrator -eq $false)
            {

                $body = @{

                    op         = "update"
                    type       = "user"
                    id         = $UserID
                    attributes = @{
                        sudo = @{
                            enabled         = $false
                            withoutPassword = $false
                    
                        }
                    }
    
                }
                    
                    
            }

            $jsonbody = $body | ConvertTo-Json
            Write-Verbose $jsonbody

            $URL = "https://console.jumpcloud.com/api/v2/systems/$SystemID/associations"

            Write-Verbose $URL


            try
            {
                $SystemUpdate = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent 'Pwsh_1.8.0'
                $Status = 'Updated'

            }
            catch
            {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{

                'System'        = $HostName
                'SystemID'      = $SystemID
                'Username'      = $Username
                'Status'        = $Status
                'Administrator' = $Administrator
            }


            $SystemUpdateArray += $FormattedResults

        }

        elseif ($PSCmdlet.ParameterSetName -eq 'ByID')
        {
            if ($Administrator -eq $true)
            {

                $body = @{

                    op         = "update"
                    type       = "user"
                    id         = $UserID
                    attributes = @{
                        sudo = @{
                            enabled         = $true
                            withoutPassword = $false
                    
                        }
                    }
    
                }
                    
            }

            elseif ($Administrator -eq $false)
            {

                $body = @{

                    op         = "update"
                    type       = "user"
                    id         = $UserID
                    attributes = @{
                        sudo = @{
                            enabled         = $false
                            withoutPassword = $false
                    
                        }
                    }
    
                }
                    
                    
            }

            $jsonbody = $body | ConvertTo-Json
            Write-Verbose $jsonbody

            $URL = "https://console.jumpcloud.com/api/v2/systems/$SystemID/associations"
            Write-Verbose $URL

            try
            {
                $SystemUpdate = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent 'Pwsh_1.8.0'
                $Status = 'Updated'

            }
            catch
            {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{

                'SystemID'      = $SystemID
                'UserID'        = $UserID
                'Status'        = $Status
                'Administrator' = $Administrator
            }   

            $SystemUpdateArray += $FormattedResults
        }
    }

    end

    {
        return $SystemUpdateArray
    }

}