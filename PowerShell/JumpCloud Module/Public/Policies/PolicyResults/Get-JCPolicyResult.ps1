function Get-JCPolicyResult () 
{
    [CmdletBinding(DefaultParameterSetName = 'ByPolicyName')]

    param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByPolicyID',
            Position = 0)]
        [Alias('_id', 'id')]
        [String]$PolicyID,

        [Parameter(,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByPolicyID')]
        [Switch]$ByPolicyID,
    
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByPolicyName',
            Position = 0)]
        [Alias('name')]
        [String]$PolicyName,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'BySystemID')]
        [string]$SystemID,

        [Parameter(,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'BySystemID')]
        [Switch]$BySystemID,

        [Parameter(
            ParameterSetName = 'ByPolicyResultID')]
        [String]$PolicyResultID
    
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

        Write-Verbose 'Initilizing resultsArraylist'

    }

    process

    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByPolicyName
            {
                $Policy = Get-JCPolicy | Where-Object {$_.name -eq $PolicyName}

                if ($Policy)
                {
                    $PolicyID = $Policy.id
                }              
                Else
                {
                    Throw "Policy does not exist. Run 'Get-JCPolicy' to see a list of all your JumpCloud policies."
                }
                
                $URL = "$JCUrlBasePath/api/v2/policies/$PolicyID/policystatuses"
            }
            BySystemID {$URL = "$JCUrlBasePath/api/v2/systems/$SystemID/policystatuses"}
            ByPolicyResultID {$URL = "$JCUrlBasePath/api/v2/policyresults/$PolicyResultID/"}
            ByPolicyID {$URL = "$JCUrlBasePath/api/v2/policies/$PolicyID/policystatuses"}
        }
        Invoke-JCApiGet -URL $URL
    }
}
