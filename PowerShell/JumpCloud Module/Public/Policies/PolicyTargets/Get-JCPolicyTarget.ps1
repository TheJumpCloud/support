Function Get-JCPolicyTarget
{
    [CmdletBinding(DefaultParameterSetName = 'Systems')]
    param (

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Systems',
            Position = 0)]

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Groups',
            Position = 0)]


        [Alias('_id', 'id')]
        [String]$PolicyID,

        [Parameter(ParameterSetName = 'Groups')]
        [switch]
        $Groups

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


        if ($PSCmdlet.ParameterSetName -eq 'Groups')
        {

            Write-Verbose 'Populating SystemGroupNameHash'
            $SystemGroupNameHash = Get-Hash_ID_SystemGroupName

        }

        if ($PSCmdlet.ParameterSetName -eq 'Systems')
        {

            Write-Verbose 'Populating SystemDisplayNameHash'
            $SystemDisplayNameHash = Get-Hash_SystemID_DisplayName

            Write-Verbose 'Populating SystemIDHash'
            $SystemHostNameHash = Get-Hash_SystemID_HostName

        }

        Write-Verbose 'Populating PolicyNameHash'
        $PolicyNameHash = Get-Hash_PolicyID_Name

        [int]$limit = '100'
        Write-Verbose "Setting limit to $limit"

        Write-Verbose 'Initilizing RawResults and resultsArrayList'
        $RawResults = @()
        $resultsArrayList = New-Object System.Collections.ArrayList

        Write-Verbose "Parameter set: $($PSCmdlet.ParameterSetName)"

    }

    process
    {

        [int]$skip = 0 #Do not change!
        [int]$count = 0 #Do not change
        Write-Verbose 'Setting skip and count to zero'
        $RawResults = $null

        switch ($PSCmdlet.ParameterSetName)
        {

            Systems
            {

                while ($count -ge $skip)
                {
                    $SystemURL = "$JCUrlBasePath/api/v2/policies/$PolicyID/systems?limit=$limit&skip=$skip"


                    Write-Verbose $SystemURL

                    $APIresults = Invoke-RestMethod -Method GET -Uri  $SystemURL  -Header $hdrs -UserAgent $JCUserAgent

                    $skip += $limit
                    Write-Verbose "Setting skip to  $skip"

                    $RawResults += $APIresults

                    $count = ($RawResults).Count
                    Write-Verbose "Results count equals $count"

                } #end while

                foreach ($result in $RawResults)
                {

                    $PolicyName = $PolicyNameHash.($PolicyID)
                    $SystemID = $result.id
                    $Hostname = $SystemHostNameHash.($SystemID )
                    $Displyname = $SystemDisplayNameHash.($SystemID)

                    $PolicyTargetSystem = [pscustomobject]@{

                        'PolicyID'   = $PolicyID
                        'PolicyName' = $PolicyName
                        'SystemID'    = $SystemID
                        'DisplayName' = $Displyname
                        'HostName'    = $Hostname

                    }

                    $resultsArrayList.Add($PolicyTargetSystem) | Out-Null

                } # end foreach

            } # end Systems switch

            Groups
            {

                while ($count -ge $skip)
                {
                    $SystemGroupsURL = "$JCUrlBasePath/api/v2/policies/$PolicyID/systemgroups?limit=$limit&skip=$skip"

                    Write-Verbose $SystemGroupsURL

                    $APIresults = Invoke-RestMethod -Method GET -Uri  $SystemGroupsURL  -Header $hdrs -UserAgent $JCUserAgent

                    $skip += $limit
                    Write-Verbose "Setting skip to  $skip"

                    $RawResults += $APIresults

                    $count = ($RawResults).Count
                    Write-Verbose "Results count equals $count"
                } # end while

                foreach ($result in $RawResults)
                {

                    $PolicyName = $PolicyNameHash.($PolicyID)
                    $GroupID = $result.id
                    $GroupName = $SystemGroupNameHash.($GroupID)

                    $Group = [pscustomobject]@{

                        'PolicyID'   = $PolicyID
                        'PolicyName' = $PolicyName
                        'GroupID'    = $GroupID
                        'GroupName'  = $GroupName

                    }

                    $resultsArrayList.Add($Group) | Out-Null

                } # end foreach
            } # end Groups switch
        } # end switch
    } # end process

    end
    {
        Return $resultsArrayList
    }
}
