function Clear-JCQueuedCommand {
    param (
        [System.String]
        $workflowId
    )
    process {
        $headers = @{
            'x-api-key' = $Env:JCApiKey
            'x-org-id'  = $Env:JCOrgId
        }
        $response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/v2/commandqueue/$workflowId" -Method DELETE -Headers $headers -UserAgent $global:JCRSettings.userAgent
    }
    end {
        return $response
    }
}