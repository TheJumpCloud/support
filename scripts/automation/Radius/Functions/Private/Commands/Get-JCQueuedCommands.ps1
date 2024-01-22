function Get-JCQueuedCommands {
    param (
        [string]$workflow
    )
    begin {
        $headers = @{
            "x-api-key" = $Env:JCApiKey
            "x-org-id"  = $Env:JCOrgId

        }
        $limit = [int]100
        $skip = [int]0
        $resultsArray = @()
    }
    process {
        if ($workflow) {
            $response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/v2/queuedcommands?filter=workflow:eq:$workflow&skip=$skip&limit=$limit" -Method GET -Headers $headers
            $resultsArray += $response.results
        } else {
            while (($resultsArray.results).Count -ge $skip) {
                $response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/v2/queuedcommand/workflows?limit=$limit&skip=$skip" -Method GET -Headers $headers
                $skip += $limit
                $resultsArray += $response.results
            }
        }
    }
    end {
        return $resultsArray
    }
}