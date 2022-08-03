function Get-JCSystemUser () {
    [CmdletBinding()]

    param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            Position = 0,
            HelpMessage = 'The _id of the System which you want to query.
To find a JumpCloud SystemID run the command:
PS C:\> Get-JCSystem | Select hostname, _id
The SystemID will be the 24 character string populated for the _id field.
SystemID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically using the Get-JCSystem function before calling Get-JCSystemUser. This is shown in EXAMPLES 2 and 3.')]
        [Alias('_id', 'id')]
        [String]$SystemID
    )

    begin {
        Write-Verbose 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {
            Connect-JConline
        }

        Write-Verbose 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        if ($JCOrgID) {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }

        [int]$limit = '100'
        Write-Verbose "Setting limit to $limit"

        $Parallel = $JCConfig.parallel.Calculated

        if ($Parallel) {
            $resultsArray = [System.Collections.Concurrent.ConcurrentBag[object]]::new()
            $resultsArrayList = [System.Collections.Concurrent.ConcurrentBag[object]]::new()
        } else {
            Write-Verbose 'Initilizing resultsArrayList and resultsArray'
            $resultsArrayList = New-Object System.Collections.ArrayList
            $resultsArray = @()
        }

        $UserHash = Get-DynamicHash -Object User -returnProperties username, sudo
        $SystemHash = Get-DynamicHash -Object System -returnProperties hostname, displayName
    }

    process {
        $limitURL = "{0}/api/v2/systems/{1}/users" -f $JCUrlBasePath, $SystemID

        Write-Verbose $limitURL

        if ($Parallel) {
            $resultsArray = Get-JCResults -Url $limitURL -method "GET" -limit $limit -parallel $true
        } else {
            $resultsArray = Get-JCResults -Url $limitURL -method "GET" -limit $limit
        }

        $count = ($resultsArray).Count
        Write-Verbose "Results count equals $count"


        $Hostname = $SystemHash.Get_Item($SystemID).hostname
        $DisplayName = $SystemHash.Get_Item($SystemID).displayName

        if ($Parallel) {
            $resultsArray | ForEach-Object -Parallel {
                $UserHash = $using:UserHash
                $resultsArrayList = $using:resultsArrayList

                $UserID = $_.id
                $Username = $UserHash.Get_Item($UserID).username
                $Groups = $_.compiledAttributes.ldapGroups.name

                if ($null -eq ($_.paths.to).Count) {
                    $DirectBind = $true
                } elseif ((($_.paths.to).Count % 3 -eq 0)) {
                    $DirectBind = $false
                } else {
                    $DirectBind = $true
                }

                if ($_.compiledAttributes.sudo.enabled -eq $true) {

                    $Admin = $true
                } else {

                    $Sudo = $UserHash.Get_Item($UserID).sudo

                    if ($Sudo -eq $true) {

                        $Admin = $true

                    }

                    else {
                        $Admin = $false
                    }

                }

                $SystemUser = [pscustomobject]@{
                    'DisplayName'   = $using:DisplayName
                    'HostName'      = $using:Hostname
                    'SystemID'      = $using:SystemID
                    'Username'      = $Username
                    'Administrator' = $Admin
                    'DirectBind'    = $DirectBind
                    'BindGroups'    = @($Groups)
                }

                $resultsArrayList.Add($SystemUser) | Out-Null
            }
        } else {
            foreach ($result in $resultsArray) {
                $UserID = $result.id
                $Username = $UserHash.Get_Item($UserID).username
                $Groups = $result.compiledAttributes.ldapGroups.name

                if ($null -eq ($result.paths.to).Count) {
                    $DirectBind = $true
                } elseif ((($result.paths.to).Count % 3 -eq 0)) {
                    $DirectBind = $false
                } else {
                    $DirectBind = $true
                }

                if ($result.compiledAttributes.sudo.enabled -eq $true) {

                    $Admin = $true
                } else {

                    $Sudo = $UserHash.Get_Item($UserID).sudo

                    if ($Sudo -eq $true) {

                        $Admin = $true

                    }

                    else {
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
        }
        $resultsArray = $null
    }

    end {
        return $resultsArrayList
    }
}