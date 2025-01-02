<#
.Synopsis
Ordered list of report metadata
.Description
Ordered list of report metadata
.Example
PS C:\> Get-JCReport

Returns a list of all available reports
.Example
PS C:\> Get-JCReport -Sort 'CREATED_AT'

Returns a list of all available reports, sorted by the most recently created report

.Outputs
JumpCloud.SDK.DirectoryInsights.Models.IGet200ApplicationJsonItemsItem
.Link
https://github.com/TheJumpCloud/jcapi-powershell/tree/master/SDKs/PowerShell/JumpCloud.SDK.DirectoryInsights/docs/exports/Get-JcSdkReport.md
#>
Function Get-JCReport {
    [OutputType([JumpCloud.SDK.DirectoryInsights.Models.IGet200ApplicationJsonItemsItem])]
    [CmdletBinding(DefaultParameterSetName = 'List', PositionalBinding = $false)]
    Param(
        [Parameter()]
        [ArgumentCompleter([JumpCloud.SDK.DirectoryInsights.Support.Sort])]
        [JumpCloud.SDK.DirectoryInsights.Category('Query')]
        [JumpCloud.SDK.DirectoryInsights.Support.Sort]
        # Sort type and direction.
        # Default sort is descending, prefix with - to sort ascending.
        ${Sort},
        [Parameter(ValueFromPipelineByPropertyName, Mandatory = $true, ParameterSetName = 'Report', HelpMessage = 'ID of the Report request.')]
        [Alias("id")]
        [String]$ReportID,
        [Parameter(Mandatory = $true, ParameterSetName = 'Report', HelpMessage = 'Output type of the report content, either CSV or JSON')]
        [ValidateSet('json', 'csv')]
        [String]$Type
    )
    Begin {
        Connect-JCOnline -force | Out-Null
        $Results = @()
        $headers = @{
            "accept"    = "application/json";
            "x-api-key" = $Env:JCApiKey;
            "x-org-id"  = $Env:JCOrgId
        }
    }
    Process {
        switch ($PSCmdlet.ParameterSetName) {
            List {
                $Results = JumpCloud.SDK.DirectoryInsights\Get-JcSdkReport @PSBoundParameters
            }
            Report {
                # Boolean value to check if there was a generation failure
                $ReportGenerationFailure = $false

                # Do Until Loop until the status for the report is completed or break on failure
                do {
                    $Report = Get-JcSdkReport | Where-Object { $_.id -eq $ReportID }
                    if (!$Report) {
                        throw "No report was found with ReportID: $($ReportID). Please use Get-JCReport for a list of available reports"
                    }
                    switch ($Report.status) {
                        PENDING {
                            Write-Warning "[Status] Waiting 10s for Jumpcloud Report to complete"
                            Start-Sleep -Seconds 10
                        }
                        IN_PROGRESS {
                            Write-Warning "[Status] Waiting 10s for JumpCloud Report to complete"
                            Start-Sleep -Seconds 10
                        }
                        FAILED {
                            Write-Warning "Report failed to generate"
                            $ReportGenerationFailure = $true
                            break
                        }
                        DELETED {
                            Write-Warning "Report was deleted"
                            $ReportGenerationFailure = $true
                            break
                        }
                    }
                } until ($Report.status -eq "COMPLETED")
                $reportID = $Report.id
                switch ($Type) {
                    json {
                        $artifactID = ($Report.artifacts | Where-Object { $_.format -eq 'json' }).id
                    } csv {
                        $artifactID = ($Report.artifacts | Where-Object { $_.format -eq 'csv' }).id
                    }
                }

                # If the report failed to generate, return the report object containing the failure status
                if ($ReportGenerationFailure -eq $true) {
                    $Results = $Report
                } else {
                    $Results = Invoke-RestMethod -Uri "https://api.jumpcloud.com/insights/directory/v1/reports/$reportID/artifacts/$artifactID/content" -Method GET -Headers $headers
                }
            }
        }
    }
    End {
        Return $Results
    }
}
