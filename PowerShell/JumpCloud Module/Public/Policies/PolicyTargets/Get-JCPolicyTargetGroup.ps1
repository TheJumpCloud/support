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
        $RawResults = @()
        $resultsArrayList = New-Object System.Collections.ArrayList
        $URL_Template = "{0}/api/v2/policies/{1}/systemgroups"
    }
    Process
    {
        If ($PSCmdlet.ParameterSetName -eq 'ByName')
        {
            $PolicyId = (Get-JCPolicy -Name:($PolicyName)).id
        }
        If ($PolicyId)
        {
            $URL = $URL_Template -f $JCUrlBasePath, $PolicyID
            Write-Verbose 'Populating SystemGroupNameHash'
            $SystemGroupNameHash = Get-Hash_ID_SystemGroupName
            $RawResults = Invoke-JCApiGet -URL:($URL)
            ForEach ($result In $RawResults)
            {
                $Policy = Get-JCPolicy | Where-Object {$_.id -eq $PolicyID}
                If ($Policy)
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
        }
        Else
        {
            Throw ('Policy name "' + $PolicyName + '" does not exist. Run "Get-JCPolicy" to see a list of all your JumpCloud policies.')
        }
    } # end process
    End
    {
        If ($resultsArrayList)
        {
            Return $resultsArrayList
        }
    }
}
