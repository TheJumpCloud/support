Function Get-JCOrganization
{
    [CmdletBinding()]
    param ()
    Begin
    {
        Connect-JCOnline -force | Out-Null
        $resultsArrayList = New-Object System.Collections.ArrayList
    }
    Process
    {
        $RawResults = Get-JCObject -Type:('organization') -Fields:('_id', 'displayName')
        ForEach ($org In $RawResults)
        {
            $MSPOrg = [PSCustomObject]@{
                'OrgID'       = $org._id
                'displayName' = $org.displayName
            }
            $resultsArrayList.add($MSPOrg) | Out-Null
        }
    }
    End
    {
        Return $resultsArrayList
    }
}