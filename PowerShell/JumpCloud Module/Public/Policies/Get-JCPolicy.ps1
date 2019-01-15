Function Get-JCPolicy ()
{
    [CmdletBinding(DefaultParameterSetName = 'ReturnAll')]

    param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID',
            Position = 0)]
        [Alias('_id', 'id')]
        [String]$PolicyID,

        [Parameter(
            ParameterSetName = 'Name')]
        [String]$Name,

        [Parameter(
            ParameterSetName = 'ByID')]
        [Switch]
        $ByID
    
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
    }

    process

    {

        switch ($PSCmdlet.ParameterSetName) 
        {
            "ReturnAll" {$URL = "$JCUrlBasePath/api/v2/policies"}
            "ByID" {$URL = "$JCUrlBasePath/api/v2/policies/$PolicyID"}
            "Name" {$URL = "$JCUrlBasePath/api/v2/policies?sort=name&filter=name%3Aeq%3A$Name"}
        }
        $Result = Invoke-JCApiGet -URL $URL 
        If ($Result)
        {
            Return $Result
        }
    }
}
