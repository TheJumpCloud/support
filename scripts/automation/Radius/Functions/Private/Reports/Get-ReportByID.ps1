Function Get-ReportByID {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.String]
        $reportID
    )
    begin {
        # write-host "attempting to get report by id: $reportId"
    }
    process {
        do {
            $reportList = Get-JCsdkReport -Sort 'CREATED_AT'
            $foundReport = $reportList | Where-Object { $_.Id -eq $reportID }
            if ($foundReport.Status -eq "PENDING") {
                Write-Warning "[status] waiting 10s for jumpcloud report to complete"
                start-sleep -Seconds 10
            }

        } until ($foundReport.Status -eq "COMPLETED")
    }
    end {
        return $foundReport
    }
}