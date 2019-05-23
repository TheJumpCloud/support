function Invoke-GetJCOrganization
{
    [CmdletBinding()]
    param (
        [String]$JumpCloudAPIKey
    )

    begin
    {

        Write-Verbose 'Populating API headers'

        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = "$JumpCloudAPIKey"

        }

        $resultsArrayList = New-Object System.Collections.ArrayList


    }

    process
    {



        $MultiTenantURL = "$JCUrlBasePath/api/organizations/"

        $RawResults = Invoke-RestMethod -Method GET -Uri $MultiTenantURL -Headers $hdrs -UserAgent:(Get-JCUserAgent)

        foreach ($org in $RawResults.results)
        {

            $MSPOrg = [PSCustomObject]@{
                'OrgID'       = $org._id
                'displayName' = $org.displayName
            }

            $resultsArrayList.add($MSPOrg) | Out-Null

        }


    }

    end
    {
        Return $resultsArrayList
    }

}