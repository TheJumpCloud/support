function Invoke-CommandRun {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $commandID
    )
    begin {
        if ($commandID.length -ne 24) {
            throw "Supplied CommandID is not of the correct length"
        }
    }
    process {
        $headers = @{
            'x-api-key'    = $Env:JCApiKey
            'x-org-id'     = $Env:JCOrgId
            "content-type" = "application/json"
        }
        $body = @{
            _id = $commandID
        } | ConvertTo-Json
        $response = Invoke-RestMethod -Uri 'https://console.jumpcloud.com/api/runCommand' -Method POST -Headers $headers -ContentType 'application/json' -Body $body
    }
    end {
        if (!$response.queueIds) {
            Throw "Command with ID: $commandID could not be triggered"
        }

    }

}