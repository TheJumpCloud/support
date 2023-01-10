# Import Global Config:
. "$psscriptroot/config.ps1"
Connect-JCOnline $JCAPIKEY -Force

# Begin Functions

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
        if ($response.queueIds) {
            Write-Debug "$CommandID triggered sucessfully"
        } else {
            Throw "Command with ID: $commandID could not be triggered"
        }

    }

}

function Get-JCQueuedCommands {
    begin {
        $headers = @{
            "x-api-key" = $JCAPIKEY
            "x-org-id"  = $JCORGID

        }
        $limit = [int]100
        $skip = [int]0
        $resultsArray = @()
        $resultsArrayList = New-Object System.Collections.ArrayList
    }
    process {
        while (($resultsArray.results).Count -ge $skip) {
            $response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/v2/queuedcommand/workflows?limit=$limit&skip=$skip" -Method GET -Headers $headers
            $skip += $limit
            $resultsArray += $response
        }
        $resultsArrayList.Add($resultsArray)
    }
    end {
        return $resultsArrayList.Results
    }
}

# End Functions

# Tracking Variables for results
$SuccessfulCommandRuns = @()
$QueuedCommandRuns = @()
$FailedCommandRuns = @()

# Get all Commands with the RadiusCertInstall trigger
$RadiusCommands = Get-Content -Raw -Path "$PSScriptRoot/commands.json" | ConvertFrom-Json
$CommandCount = $RadiusCommands.Count

# Get all Command Results for the RadiusCommands
$CommandResults = Get-JCCommandResult -Detailed | Where-Object { $_.name -like "RadiusCert-Install*" }
$ResultCount = $CommandResults.Count

# Check results
$SuccessfulCommandRuns = $CommandResults | Select-Object -ExcludeProperty command | Where-Object { $_.exitCode -eq "0" }
$QueuedCommandRuns = Get-JCQueuedCommands
$FailedCommandRuns = $CommandResults | Select-Object -ExcludeProperty command | Where-Object { $_.exitCode -eq "1" -or $_.exitCode -eq "4" }

$RadiusCommands | ForEach-Object {
    if ($_.commandId -in $SuccessfulCommandRuns.workflowId) {
        $commandInfo = $SuccessfulCommandRuns | Where-Object workflowId -EQ $_.commandId
        $_.resultTimeStamp = $commandInfo.responseTime
        $_.result = $commandInfo.output
        $_.exitCode = $commandInfo.exitCode
    } elseif ($_.commandId -in $QueuedCommandRuns.command) {
        $_.commandQueued = $true
    } elseif ($_.commandId -in $FailedCommandRuns.workflowId) {
        $commandInfo = $FailedCommandRuns | Where-Object workflowId -EQ $_.commandId
        $_.resultTimeStamp = $commandInfo.responseTime
        $_.result = $commandInfo.output
        $_.exitCode = $commandInfo.exitCode
    }
}

$RadiusCommands | ConvertTo-Json | Out-File "$psscriptroot\commands.json"

Write-Host "[status] $($SuccessfulCommandRuns.Count) successful command executions and $($FailedCommandRuns.Count) failures"