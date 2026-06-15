function Get-JCPolicyTargetSystem {
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    param (
        [Parameter(ParameterSetName = 'ByName', HelpMessage = 'Use the -ByName parameter when you want to query a specific policy. The -ByName SwitchParameter will set the ParameterSet to ''ByName'' which queries one JumpCloud policy at a time.')][Switch]$ByName,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True, Position = 0, ParameterSetName = 'ById', HelpMessage = 'The PolicyID of the JumpCloud policy you wish to query.')][ValidateNotNullOrEmpty()][Alias('_id', 'id')][String]$PolicyID,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True, Position = 0, ParameterSetName = 'ByName', HelpMessage = 'The Name of the JumpCloud policy you wish to query.')][ValidateNotNullOrEmpty()][Alias('Name')][String]$PolicyName
    )
    begin {

        Write-Verbose 'Verifying Connection to JumpCloud...'
        if (Test-JCConnection) {
            Connect-JCOnline
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

        Write-Verbose 'Initializing RawResults and resultsArrayList'
        $RawResults = @()
        $resultsArrayList = New-Object System.Collections.ArrayList
        $URL_Template = "{0}/api/v2/policies/{1}/systems"

        Write-Verbose 'Populating SystemHash'
        $SystemHash = Get-DynamicHash -Object System -returnProperties hostname, displayName
    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'ByName' {
                $Policy = Get-JCPolicy -Name:($PolicyName)
            }
            'ById' {
                $Policy = Get-JCPolicy -PolicyID:($PolicyID)
            }
        }
        if ($Policy) {
            $PolicyId = $Policy.id
            $PolicyName = $Policy.Name
            $URL = $URL_Template -f $JCUrlBasePath, $PolicyID
            $Results = Invoke-JCApi -Method:('GET') -Paginate:($true) -Url:($URL)
            foreach ($Result in $Results) {
                $SystemID = $Result.id
                $Hostname = $SystemHash[$SystemID].hostname
                $DisplayName = $SystemHash[$SystemID].displayName
                $OutputObject = [PSCustomObject]@{
                    'PolicyID'    = $PolicyID
                    'PolicyName'  = $PolicyName
                    'SystemID'    = $SystemID
                    'DisplayName' = $DisplayName
                    'HostName'    = $Hostname
                }
                $resultsArrayList.Add($OutputObject) | Out-Null
            } # end foreach
        } else {
            throw ('Policy provided does not exist. Run "Get-JCPolicy" to see a list of all your JumpCloud policies.')
        }
    } # end process
    end {
        return $resultsArrayList
    }
}
