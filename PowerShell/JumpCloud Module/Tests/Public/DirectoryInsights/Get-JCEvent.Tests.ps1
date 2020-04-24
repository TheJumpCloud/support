Describe 'Get-JCEvent' -Tag:('JCEvent') {
    #Requires -Modules JumpCloud
    <# ToDo
        Service - Not sure how to validate yet (Test that results service value matches parameter value)
    #>
    # Define parameters for functions
    $ParamHash = @{
        "StartTime"     = Get-Date -Date:(((Get-Date).AddMinutes(-10).ToUniversalTime())) -Format:('o');
        "EndTime"       = Get-Date -Date:(((Get-Date).ToUniversalTime())) -Format:('o');
        "Service"       = "all";
        "Sort"          = "DESC"
        "Limit"         = 2;
        "SearchTermAnd" = @{
            "event_type" = "group_create"
        }
    }
    $StartTime = Get-Date -Date:(([DateTime]$ParamHash.StartTime).ToUniversalTime())
    $EndTime = Get-Date -Date:(([DateTime]$ParamHash.EndTime).ToUniversalTime())
    $ContainsPaginate = (Get-Command Get-JCEvent).Parameters.ContainsKey('Paginate')
    If ($ContainsPaginate)
    {
        $ParamHash.Limit = ($ParamHash.Limit * 2)
    }
    Else
    {
        $ParamHash.Limit
    }
    # Create event records for tests
    Connect-JCOnline -force | Out-Null
    For ($i = 1; $i -le $ParamHash.Limit; $i++)
    {
        $GroupName = 'JCSystemGroupTest-{0}' -f $i
        Write-Host ("Creating add/delete records for: $GroupName")
        New-JCSystemGroup -GroupName:($GroupName) | Remove-JCSystemGroup -Force
    }
    It 'GetExpanded' {
        $eventTest = Get-JCEvent -Service:($ParamHash.Service) -StartTime:($ParamHash.StartTime) -EndTime:($ParamHash.EndTime) -Limit:($ParamHash.Limit) -Sort:($ParamHash.Sort) -SearchTermAnd:($ParamHash.SearchTermAnd)
        If ([System.String]::IsNullOrEmpty($eventTest))
        {
            $eventTest | Should -Not -BeNullOrEmpty
        }
        Else
        {
            $eventTest = ($eventTest)
            $MostRecentRecord = ($eventTest | Select-Object -First 1).timestamp
            $OldestRecord = ($eventTest | Select-Object -Last 1).timestamp
            # Limit - Test that results count matches parameter value
            $eventTest.Count | Should -Be $ParamHash.Limit
            # Sort - Test that results come back in decending DateTime
            $MostRecentRecord.Ticks | Should -BeGreaterThan $OldestRecord.Ticks
            # EndTime - Test that results are not newer than EndTime parameter value
            $MostRecentRecord.Ticks | Should -BeLessOrEqual $EndTime.Ticks
            # StartTime - Test that results are not older than StartTime parameter value
            $OldestRecord.Ticks | Should -BeGreaterOrEqual $StartTime.Ticks
            # SearchTermAnd - Test that results matches parameter value
            ($eventTest.event_type | Select-Object -Unique) | Should -Be $ParamHash.SearchTermAnd.event_type
        }
    }
    It 'Get' {
        $eventTest = Get-JCEvent -EventQueryBody:($ParamHash)
        If ([System.String]::IsNullOrEmpty($eventTest))
        {
            $eventTest | Should -Not -BeNullOrEmpty
        }
        Else
        {
            $eventTest = ($eventTest)
            $MostRecentRecord = ($eventTest | Select-Object -First 1).timestamp
            $OldestRecord = ($eventTest | Select-Object -Last 1).timestamp
            # Limit - Test that results count matches parameter value
            $eventTest.Count | Should -Be $ParamHash.Limit
            # Sort - Test that results come back in decending DateTime
            $MostRecentRecord.Ticks | Should -BeGreaterThan $OldestRecord.Ticks
            # EndTime - Test that results are not newer than EndTime parameter value
            $MostRecentRecord.Ticks | Should -BeLessOrEqual $EndTime.Ticks
            # StartTime - Test that results are not older than StartTime parameter value
            $OldestRecord.Ticks | Should -BeGreaterOrEqual $StartTime.Ticks
            # SearchTermAnd - Test that results matches parameter value
            ($eventTest.event_type | Select-Object -Unique) | Should -Be $ParamHash.SearchTermAnd.event_type
        }
    }
}
