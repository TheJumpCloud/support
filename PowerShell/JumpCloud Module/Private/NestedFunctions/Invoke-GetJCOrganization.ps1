function Invoke-GetJCOrganization
{
    [CmdletBinding()]
    Param (
        [String]$JumpCloudAPIKey
    )
    Begin
    {
        Write-Verbose ('Populating API headers')
        $hdrs = @{
            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = "$JumpCloudAPIKey"
        }
        $resultsArrayList = New-Object System.Collections.ArrayList
    }
    Process
    {
        $MultiTenantURL = "$JCUrlBasePath/api/organizations/?limit=100"
        $RawResults = Invoke-RestMethod -Method GET -Uri $MultiTenantURL -Headers $hdrs -UserAgent:(Get-JCUserAgent)
        ForEach ($org In $RawResults.results)
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