Function Get-JCPolicy ()
{
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

    begin

    {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) { Connect-JCOnline }

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
        $Results = @()
    }

    process

    {
        $URLs = switch ($PSCmdlet.ParameterSetName)
        {
            "ReturnAll" { "$JCUrlBasePath/api/v2/policies" }
            "ByID"
            {
                ForEach ($Item In $PolicyID)
                {
                    "$JCUrlBasePath/api/v2/policies/$Item"
                }
            }
            "Name"
            {
                ForEach ($Item In $Name)
                {
                    "$JCUrlBasePath/api/v2/policies?sort=name&filter=name%3Aeq%3A$Item"
                }
            }
        }
        ForEach ($URL In $URLs)
        {

            $Result = Invoke-JCApi -Method:('GET') -Paginate:($true) -Url:($URL)
            $Results += $Result
        }
    }
    End
    {
        If ($Results)
        {
            Return $Results
        }
    }
}
