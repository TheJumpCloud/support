Describe 'Get-JCEvent' -Tag:('JCEvent') {
    BeforeAll {
        #Requires -Modules JumpCloud
        <# ToDo
        Service - Not sure how to validate yet (Test that results service value matches parameter value)
    #>
        # Define parameters for functions
        $ParamHash = @{
            "StartTime"     = (Get-Date).ToUniversalTime();
            "EndTime"       = 'PlaceHolderDateTime';
            "Service"       = "all";
            "Sort"          = "DESC"
            "Limit"         = 2;
            "SearchTermAnd" = @{
                "event_type" = "user_delete"
            }
        }
        If ((Get-Command Get-JCEvent).Parameters.ContainsKey('Paginate'))
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
            $UserName = 'JCSystemUserTest-{0}' -f $i
            Write-Host ("Creating add/delete records for: $UserName")
            If (Get-JCUser -username:($UserName))
            {
                Remove-JCUser -username:($UserName) -Force
            }
            New-JCUser -username:($UserName) -firstname:($UserName) -lastname:($UserName) -email:($UserName + '@DeleteMe.com')
            Remove-JCUser -Username:($UserName) -Force
        }
        # Allow server time to process
        Start-Sleep -Seconds:(10)
        # Set EndTime
        $ParamHash.EndTime = (Get-Date).ToUniversalTime();
        # Convert times to UTC
        $StartTime = [DateTime]$ParamHash.StartTime
        $EndTime = [DateTime]$ParamHash.EndTime
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
            $MostRecentRecord = ([System.DateTime]($eventTest | Select-Object -First 1).timestamp).ToUniversalTime()
            $OldestRecord = ([System.DateTime]($eventTest | Select-Object -Last 1).timestamp).ToUniversalTime()
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
            $MostRecentRecord = ([System.DateTime]($eventTest | Select-Object -First 1).timestamp).ToUniversalTime()
            $OldestRecord = ([System.DateTime]($eventTest | Select-Object -Last 1).timestamp).ToUniversalTime()
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