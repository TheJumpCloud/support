function Get-QueuedCommandByUser {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter()]
        [system.string]
        $username
    )

    begin {
        $headers = @{
            "x-api-key" = $Env:JCApiKey
            "x-org-id"  = $Env:JCOrgId

        }
        $limit = [int]100
        $skip = [int]0
        $resultsArray = @()
        $SearchFilter = @{
            searchTerm = "RadiusCert-Install:${username}:"
            fields     = @('name')
        }

    }

    process {
        $response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/v2/queuedcommand/workflows?&skip=$skip&limit=$limit&search[fields][0]=name&search[searchTerm]=RadiusCert-Install:${username}:" -Method GET -Headers $headers
    }

    end {
        return $response.results
    }
}
