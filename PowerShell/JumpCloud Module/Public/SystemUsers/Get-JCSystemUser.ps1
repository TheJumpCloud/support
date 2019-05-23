function Get-JCSystemUser ()
{
    [CmdletBinding()]

    param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            Position = 0)]
        [Alias('_id', 'id')]
        [String]$SystemID
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

        [int]$limit = '100'
        Write-Verbose "Setting limit to $limit"

        Write-Verbose 'Initilizing resultsArrayList and resultsArray'
        $resultsArrayList = New-Object System.Collections.ArrayList
        $resultsArray = @()

        Write-Verbose 'Populating UserIDHash'
        $UserIDHash = Get-Hash_ID_Username

        Write-Verbose 'Populating SystemIDHash'
        $SystemIDHash = Get-Hash_SystemID_HostName

        Write-Verbose 'Populating DisplayNameHash'
        $DisplayNameHash = Get-Hash_SystemID_DisplayName

        Write-Verbose 'Populating SudoHash'
        $SudoHash = Get-Hash_ID_Sudo

    }

    process
    {
        Write-Verbose 'Setting skip to zero'
        [int]$skip = 0 #Do not change!

        while (($resultsArray.results).Count -ge $skip)
        {
            $URI = "$JCUrlBasePath/api/v2/systems/$SystemID/users?sort=type,_id&limit=$limit&skip=$skip"

            Write-Verbose $URI

            $APIresults = Invoke-RestMethod -Method GET -Uri $URI -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent)

            $skip += $limit
            Write-Verbose "Setting skip to $skip"

            $resultsArray += $APIresults

            $count = ($resultsArray).Count
            Write-Verbose "Results count equals $count"
        }


        $Hostname = $SystemIDHash.Get_Item($SystemID)
        $DisplayName = $DisplayNameHash.Get_Item($SystemID)

        foreach ($result in $resultsArray)
        {
            $UserID = $result.id
            $Username = $UserIDHash.Get_Item($UserID)
            $Groups = $result.compiledAttributes.ldapGroups.name

            if (($result.paths.to).Count -eq $null)
            {
                $DirectBind = $true
            }
            elseif ((($result.paths.to).Count % 3 -eq 0))
            {
                $DirectBind = $false
            }
            else
            {
                $DirectBind = $true
            }

            if ($result.compiledAttributes.sudo.enabled -eq $true)
            {

                $Admin = $true
            }
            else
            {

                $Sudo = $SudoHash.Get_Item($UserID)

                if ($Sudo -eq $true)
                {

                    $Admin = $true

                }

                else
                {
                    $Admin = $false
                }

            }

            $SystemUser = [pscustomobject]@{
                'DisplayName'   = $DisplayName
                'HostName'      = $Hostname
                'SystemID'      = $SystemID
                'Username'      = $Username
                'Administrator' = $Admin
                'DirectBind'    = $DirectBind
                'BindGroups'    = @($Groups)
            }

            $resultsArrayList.Add($SystemUser) | Out-Null

        }

        $resultsArray = $null

    }

    end
    {
        return $resultsArrayList
    }
}