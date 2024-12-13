Function Get-LatestUserToDeviceReport {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.Int32]
        $minutes
    )
    begin {
        # get UTC time now:
        $utcTimeNow = Get-Date ([datetime]::UtcNow) -UFormat "%m/%d/%Y %r"

        $headers = @{
            "accept"    = "application/json";
            "x-api-key" = $Env:JCApiKey;
            "x-org-id"  = $Env:JCOrgId
        }

    }
    process {
        $reportList = Get-JCsdkReport -Sort 'CREATED_AT'
        $userAndDeviceReports = $reportList | Where-Object { $_.Type -eq "ods-users-to-devices" }
        if ($userAndDeviceReports) {
            # get the first report
            $firstUAndDReport = $userAndDeviceReports | Select-Object -First 1
            $timespan = New-TimeSpan -end $utcTimeNow -start $firstUAndDReport.Created_At
            # if time between now and the last generated report is >=24, create a new report
            if ($timespan.Minutes -ge $minutes) {
                write-host "last report generated $($timespan.Minutes) minutes ago; generating new user to device report"
                $requestedReport = New-JcSdkReport -ReportType 'users-to-devices'
                $latestReport = Get-ReportByID -reportID $requestedReport.Id
            } else {
                write-host "last report generated $($timespan.Minutes) minutes ago"
                # return the last report
                $latestReport = Get-ReportByID -reportID $firstUAndDReport.Id
            }

        } else {
            # if there are no reports create a new one:
            write-host "generating new user to device report"
            $requestedReport = New-JcSdkReport -ReportType 'users-to-devices'
            $latestReport = Get-ReportByID -reportID $requestedReport.Id
        }

        # get the json artifact:
        # download json
        $artifactID = ($latestReport.artifacts | Where-Object { $_.format -eq 'json' }).id
        $reportID = $latestReport.id
        $reportContent = Invoke-RestMethod -Uri "https://api.jumpcloud.com/insights/directory/v1/reports/$reportID/artifacts/$artifactID/content" -Method GET -Headers $headers
    }
    end {
        # return the latest user report
        return $reportContent
    }
}