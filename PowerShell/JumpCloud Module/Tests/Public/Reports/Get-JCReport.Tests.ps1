Describe -Tag:('JCReport') 'Get-JCReport Tests' {
    BeforeAll {
        # Generate report
        $usersToUserGroups = New-JCReport -ReportType "users-to-user-groups"
    }
    It ('Get all reports') {
        { $Reports = Get-JCReport } | Should -Not -Throw
    }
    It ('Get Browser Patch Policy Report with ArtifactID & ReportID - JSON') {
        do {
            $finishedReport = Get-JCReport | Where-Object { $_.id -eq $usersToUserGroups.id }
            switch ($finishedReport.status) {
                PENDING {
                    Write-Warning "[status] waiting 5s for jumpcloud report to complete"
                    Start-Sleep -Seconds 5
                }
                IN_PROGRESS {
                    Write-Warning "[status] waiting 5s for jumpcloud report to complete"
                    Start-Sleep -Seconds 5
                }
                FAILED {
                    throw "Report failed to generate"
                }
                DELETED {
                    throw "Report was deleted"
                }
            }
        } until ($finishedReport.status -eq "COMPLETED")
        $artifactID = ($finishedReport.artifacts | Where-Object { $_.format -eq 'json' }).id
        $reportID = $usersToUserGroups.id
        $reportContent = Get-JCReport -artifactID $artifactID -reportID $reportID

        $reportContent | Should -Not -BeNullOrEmpty
    }
}