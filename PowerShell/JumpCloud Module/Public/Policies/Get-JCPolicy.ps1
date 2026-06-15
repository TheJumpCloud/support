function Get-JCPolicy () {
    [CmdletBinding(DefaultParameterSetName = 'ReturnAll')]

    param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID',
            Position = 0,
            HelpMessage = 'The PolicyID of the JumpCloud policy you wish to query.')]
        [Alias('_id', 'id')]
        [String[]]$PolicyID,

        [Parameter(
            ParameterSetName = 'Name',
            HelpMessage = 'The Name of the JumpCloud policy you wish to query.')]
        [String[]]$Name,

        [Parameter(
            ParameterSetName = 'ByID',
            HelpMessage = 'Use the -ByID parameter when you want to query a specific policy. The -ByID SwitchParameter will set the ParameterSet to ''ByID'' which queries one JumpCloud policy at a time.')]
        [Switch]
        $ByID

    )

    begin {
        Write-Debug 'Verifying Connection to JumpCloud...'
        if (Test-JCConnection) {
            Connect-JCOnline
        }

        Write-Debug 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        if ($JCOrgID) {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }
        $Results = @()
    }

    process {
        $URLs = switch ($PSCmdlet.ParameterSetName) {
            "ReturnAll" {
                "$JCUrlBasePath/api/v2/policies"
            }
            "ByID" {
                foreach ($Item in $PolicyID) {
                    "$JCUrlBasePath/api/v2/policies/$Item"
                }
            }
            "Name" {
                foreach ($Item in $Name) {
                    "$JCUrlBasePath/api/v2/policies?sort=name&filter=name%3Aeq%3A$Item"
                }
            }
        }
        foreach ($URL in $URLs) {
            if ($URL -match "name&filter") {
                $Result = Invoke-JCApi -Method:('GET') -Paginate:($true) -Url:($URL)
                # search does not return values now need to return the policy by ID after matching name
                $Result = Invoke-JCApi -Method:('GET') -Paginate:($true) -Url:("$JCUrlBasePath/api/v2/policies/$($Result.id)")
            } else {
                $Result = Invoke-JCApi -Method:('GET') -Paginate:($true) -Url:($URL)
            }

            $Result | ForEach-Object {
                $_ | Add-Member -MemberType NoteProperty -Name "templateID" -Value $_.template.id
            }
            if ($result.id) {
                $Results += $Result
            }
        }
    }
    end {
        if ($Results) {
            return $Results | Select-Object -Property "name", "id", "templateID", "values", "template", "notes"
        }
    }
}