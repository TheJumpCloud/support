Function Get-JCPolicyTargetGroup
{
    [CmdletBinding(DefaultParameterSetName = 'ID')]
    param (
        [Parameter(ParameterSetName = 'Name')][Switch]$ByName,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True, Position = 0, ParameterSetName = 'ID')][ValidateNotNullOrEmpty()][Alias('_id', 'id')][String]$PolicyID,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True, Position = 0, ParameterSetName = 'Name')][ValidateNotNullOrEmpty()][Alias('Name')][String]$PolicyName
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

        Write-Verbose 'Initializing RawResults and resultsArrayList'
        $RawResults = @()
        $resultsArrayList = New-Object System.Collections.ArrayList

        If ($PolicyName)
        {
            $PolicyId = Get-JCPolicy | Where-Object {$_.name -eq $PolicyName}
            If (!($PolicyId))
            {
                Throw ('Policy name "' + $PolicyName + '" does not exist. Run "Get-JCPolicy" to see a list of all your JumpCloud policies.')
            }
        }
    }
    process
    {
        $RawResults = @()
        $URL = "$JCUrlBasePath/api/v2/policies/$PolicyID/systemgroups"
        Write-Verbose 'Populating SystemGroupNameHash'
        $SystemGroupNameHash = Get-Hash_ID_SystemGroupName
        $RawResults = Invoke-JCApiGet -URL:($URL)
        foreach ($result in $RawResults)
        {
            $Policy = Get-JCPolicy | Where-Object {$_.id -eq $PolicyID}
            if ($Policy)
            {
                $PolicyName = $Policy.Name
                $GroupID = $result.id
                $GroupName = $SystemGroupNameHash.($GroupID)
                $OutputObject = [PSCustomObject]@{
                    'PolicyID'   = $PolicyID
                    'PolicyName' = $PolicyName
                    'GroupID'    = $GroupID
                    'GroupName'  = $GroupName
                }
                $resultsArrayList.Add($OutputObject) | Out-Null
            }
            Else
            {
                Throw "Policy does not exist. Run 'Get-JCPolicy' to see a list of all your JumpCloud policies."
            }
        } # end foreach
    } # end process
    end
    {
        If ($resultsArrayList)
        {
            Return $resultsArrayList
        }
    }
}
