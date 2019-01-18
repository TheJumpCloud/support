Function Get-JCPolicyTargetSystem
{
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    param (
        [Parameter(ParameterSetName = 'ByName')][Switch]$ByName,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True, Position = 0, ParameterSetName = 'ById')][ValidateNotNullOrEmpty()][Alias('_id', 'id')][String]$PolicyID,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True, Position = 0, ParameterSetName = 'ByName')][ValidateNotNullOrEmpty()][Alias('Name')][String]$PolicyName
    )
    Begin
    {

        Write-Verbose 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Verbose 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        If ($JCOrgID)
        {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }

        Write-Verbose 'Initializing RawResults and resultsArrayList'
        $RawResults = @()
        $resultsArrayList = New-Object System.Collections.ArrayList
        $URL_Template = "{0}/api/v2/policies/{1}/systems"

        # Moved to begin block so this hash is only computed once if multiple objects passed via pipeline.
        Write-Verbose 'Populating SystemDisplayNameHash'
        $SystemDisplayNameHash = Get-Hash_SystemID_DisplayName
        Write-Verbose 'Populating SystemIDHash'
        $SystemHostNameHash = Get-Hash_SystemID_HostName
    }
    Process
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            'ByName' {$Policy = Get-JCPolicy -Name:($PolicyName)}
            'ById' {$Policy = Get-JCPolicy -PolicyID:($PolicyID)}
        }
        If ($Policy)
        {
            $PolicyId = $Policy.id
            $PolicyName = $Policy.Name
            $URL = $URL_Template -f $JCUrlBasePath, $PolicyID

            $Results = Invoke-JCApiGet -URL:($URL)
            ForEach ($Result In $Results)
            {
                $SystemID = $Result.id
                $Hostname = $SystemHostNameHash.($SystemID)
                $DisplayName = $SystemDisplayNameHash.($SystemID)
                $OutputObject = [PSCustomObject]@{
                    'PolicyID'    = $PolicyID
                    'PolicyName'  = $PolicyName
                    'SystemID'    = $SystemID
                    'DisplayName' = $DisplayName
                    'HostName'    = $Hostname
                }
                $resultsArrayList.Add($OutputObject) | Out-Null
            } # end foreach
        }
        Else
        {
            Throw ('Policy provided does not exist. Run "Get-JCPolicy" to see a list of all your JumpCloud policies.')
        }
    } # end process
    End
    {
        # Removed unnecessary if statement. If this was necessary please explain.
        Return $resultsArrayList
    }
}
