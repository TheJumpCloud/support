Describe -Tag:('JCReport') 'Get-JCReport Tests' {
    BeforeAll {
        # Generate report
        $usersToUserGroups = New-JCReport -ReportType "users-to-user-groups"
    }
    It ('Get all reports') {
        { $Reports = Get-JCReport } | Should -Not -Throw
    }
    It ('Get Users to UserGroups Report with Type & ReportID - JSON') {
        $finishedReport = Get-JCReport | Where-Object { $_.id -eq $usersToUserGroups.id }
        $reportContent = Get-JCReport -reportID $finishedReport.id -type 'json'
        $reportContent | Should -Not -BeNullOrEmpty
    }
    It ('Get Users to UserGroups Report with Type & ReportID - CSV') {
        $finishedReport = Get-JCReport | Where-Object { $_.id -eq $usersToUserGroups.id }
        $reportContent = Get-JCReport -reportID $finishedReport.id -type 'csv'
        $reportContent | Should -Not -BeNullOrEmpty
    }
    It ('Gets report content using pipeline input recursively') {
        $reportContent = Get-JCReport | Where-Object { $_.id -eq $usersToUserGroups.id } | Get-JCReport -Type 'json'
        $reportContent | Should -Not -BeNullOrEmpty
    }
}