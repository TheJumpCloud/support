Function Get-JCPolicyTargetGroup
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
        If ($JCAPIKEY.length -ne 40) {Connect-JConline}

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

        Write-Verbose 'Initializing RawResults and resultsArrayList'
        $Results = @()
        $resultsArrayList = New-Object System.Collections.ArrayList
        $URL_Template = "{0}/api/v2/policies/{1}/systemgroups"
        # Moved to begin block so this hash is only computed once if multiple objects passed via pipeline.
        Write-Verbose 'Populating SystemGroupNameHash'
        $SystemGroupNameHash = Get-Hash_ID_SystemGroupName 
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
                $GroupID = $Result.id
                $GroupName = $SystemGroupNameHash.($GroupID)
                $OutputObject = [PSCustomObject]@{
                    'PolicyID'   = $PolicyID
                    'PolicyName' = $PolicyName
                    'GroupID'    = $GroupID
                    'GroupName'  = $GroupName
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
