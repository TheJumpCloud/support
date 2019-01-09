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
    
        [Parameter(Mandatory,
        ValueFromPipelineByPropertyName,
        ParameterSetName = 'ByPolicyName',
        Position = 0)]
        [Alias('name')]
        [String]$PolicyName,

        [Parameter(
        ParameterSetName = 'BySystemID')]
        [String]
        $SystemID,

        [Parameter(
        ParameterSetName = 'ByPolicyResultID')]
        [String]
        $PolicyResultID,
    
        [int]$Skip = 0
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
        $resultsArray = @()
        $Url_Template1 = '{0}/api/v2/policies/{1}{2}'
        $Url_Template2 = '{0}/api/v2/policyresults{1}{2}'
        $Url_Template3 = '{0}/api/v2/systems{1}{2}'


        if ($PSCmdlet.ParameterSetName -eq 'ByPolicyName')
        {
            Write-Debug 'Populating PolicyNameHash'
            $PolicyNameHash = Get-Hash_PolicyName_ID
        }
    }

    process

    {

        switch ($PSCmdlet.ParameterSetName)
        {
            ByPolicyName
            {
                if ($PolicyNameHash.containsKey($PolicyName))
                {
                    $PolicyID = $PolicyNameHash.Get_Item($PolicyName)
                }
                else { Throw "Policy does not exist. Run 'Get-JCPolicy' to see a list of all your JumpCloud policies."}
                $URL = "$JCUrlBasePath/api/v2/policies/$PolicyID/policystatuses"
            }

            BySystemID {$URL = "$JCUrlBasePath/api/v2/systems/$SystemID/policystatuses"}
            ByPolicyResultID {$URL = "$JCUrlBasePath/api/v2/policyresults/$PolicyResultID/"}
            ByPolicyID {$URL = "$JCUrlBasePath/api/v2/policies/$PolicyID/policystatuses"}
        }
    }

    end

    {
            Invoke-JCApiGet -URL $URL
    }
}
