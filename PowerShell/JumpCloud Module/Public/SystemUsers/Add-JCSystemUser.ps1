Function Add-JCSystemUser ()
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

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByName',
            Position = 2)]

        [Parameter(
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'ByID')]
        [bool]
        $Administrator = $false

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

        Write-Verbose 'Populating SudoHash'
        $SudoHash = Get-Hash_ID_Sudo

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

            $GlobalAdmin = $SudoHash.Get_Item($UserID)

            if ($GlobalAdmin -eq $true)
            {
                $Administrator = $true           
            }

            if ($Administrator -eq $true)
            {

                $body = @{

                    op         = "add"
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

            else
            {

                $body = @{

                    op         = "add"
                    type       = "user"
                    id         = $UserID
                    attributes = $null
    
                }

            }

            $jsonbody = $body | ConvertTo-Json
            Write-Verbose $jsonbody

            $URL = "https://console.jumpcloud.com/api/v2/systems/$SystemID/associations"
            Write-Verbose $URL


            try
            {
                $SystemUpdate = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent 'Pwsh_1.4.1'
                $Status = 'Added'

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

            $GlobalAdmin = $SudoHash.Get_Item($UserID)

            if ($GlobalAdmin -eq $true)
            {
                $Administrator = $true        
            }

            if ($Administrator -eq $true)
            {

                $body = @{

                    op         = "add"
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

            else
            {

                $body = @{

                    op         = "add"
                    type       = "user"
                    id         = $UserID
                    attributes = $null
    
                }

            }

            $jsonbody = $body | ConvertTo-Json
            Write-Verbose $jsonbody

            $URL = "https://console.jumpcloud.com/api/v2/systems/$SystemID/associations"
            Write-Verbose $URL

            try
            {
                $SystemUpdate = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent 'Pwsh_1.4.1'
                $Status = 'Added'

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