function Get-JCPolicyResult () {
    [CmdletBinding(DefaultParameterSetName = 'ByPolicyName')]

    param
    (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ByPolicyID', Position = 0, HelpMessage = 'The PolicyID of the JumpCloud policy you wish to query.')]
        [Alias('_id', 'id')]
        [String]$PolicyID,

        [Parameter(, ValueFromPipelineByPropertyName, ParameterSetName = 'ByPolicyID', HelpMessage = 'The -ByPolicyID switch parameter will enforce the ByPolicyID parameter set and improve performance of gathering multiple policy results via the pipeline when the input object contains a property with PolicyID.')]
        [Switch]$ByPolicyID,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ByPolicyName', Position = 0, HelpMessage = 'The PolicyName of the JumpCloud policy you wish to query.')]
        [Alias('name')]
        [String]$PolicyName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'BySystemID', HelpMessage = 'The SystemID of the JumpCloud system you wish to query the latest policy result of.')]
        [string]$SystemID,

        [Parameter(, ValueFromPipelineByPropertyName, ParameterSetName = 'BySystemID', HelpMessage = 'The -BySystemID switch parameter will enforce the BySystemID parameter set and search for results by SystemID.')]
        [Switch]$BySystemID,

        [Parameter(ParameterSetName = 'ByPolicyResultID', HelpMessage = 'The PolicyResultID of the JumpCloud policy result you wish to query.')]
        [String]$PolicyResultID

    )


    begin {
        Write-Verbose 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) { Connect-JCOnline }

        Write-Verbose 'Populating API headers'
        $hdrs = @{
            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY
        }

        if ($JCOrgID) {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }

        Write-Verbose 'Initilizing resultsArraylist'

    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            ByPolicyName {
                $Policy = Get-JCPolicy | Where-Object { $_.name -eq $PolicyName }

                if ($Policy) {
                    $PolicyID = $Policy.id
                } Else {
                    Throw "Policy does not exist. Run 'Get-JCPolicy' to see a list of all your JumpCloud policies."
                }

                $URL = "$JCUrlBasePath/api/v2/policies/$PolicyID/policystatuses"
            }
            BySystemID { $URL = "$JCUrlBasePath/api/v2/systems/$SystemID/policystatuses" }
            ByPolicyResultID { $URL = "$JCUrlBasePath/api/v2/policyresults/$PolicyResultID/" }
            ByPolicyID { $URL = "$JCUrlBasePath/api/v2/policies/$PolicyID/policystatuses" }
        }
        Invoke-JCApi -Method:('GET') -Paginate:($true) -Url:($URL)
    }
}
