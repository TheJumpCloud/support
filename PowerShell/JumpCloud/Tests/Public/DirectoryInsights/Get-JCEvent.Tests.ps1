Describe 'Get-JCEvent' -Tag:('JCEvent') {
    BeforeAll {
        #Requires -Modules JumpCloud
        <# ToDo
        Service - Not sure how to validate yet (Test that results service value matches parameter value)
    #>
        # Define parameters for functions
        $ParamHash = @{
            "StartTime"     = (Get-Date).AddHours(-24).ToUniversalTime();
            "EndTime"       = (Get-Date).ToUniversalTime();
            "Service"       = "all";
            "Sort"          = "DESC"
            "SearchTermAnd" = @{
                "event_type" = "user_delete"
            }
        }
        # Create event records for tests
        Connect-JCOnline -force | Out-Null
        For ($i = 1; $i -le 4; $i++)
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
        $eventTest = Get-JCEvent -Service:($ParamHash.Service) -StartTime:($ParamHash.StartTime) -EndTime:($ParamHash.EndTime) -Sort:($ParamHash.Sort) -SearchTermAnd:($ParamHash.SearchTermAnd)
        If ([System.String]::IsNullOrEmpty($eventTest)) {
            $eventTest | Should -Not -BeNullOrEmpty
        }
        Else {
            # $eventTest = $eventTest
            $MostRecentRecord = ([System.DateTime]($eventTest | Select-Object -First 1).timestamp).ToUniversalTime()
            $OldestRecord = ([System.DateTime]($eventTest | Select-Object -Last 1).timestamp).ToUniversalTime()
            # Sort - Test that results come back in decending DateTime
            $MostRecentRecord | Should -BeGreaterThan $OldestRecord
            # EndTime - Test that results are not newer than EndTime parameter value
            $MostRecentRecord | Should -BeLessOrEqual $ParamHash.EndTime
            # StartTime - Test that results are not older than StartTime parameter value
            $OldestRecord | Should -BeGreaterOrEqual $ParamHash.StartTime
            # SearchTermAnd - Test that results matches parameter value
            ($eventTest.event_type | Select-Object -Unique) | Should -Be $ParamHash.SearchTermAnd.event_type
        }
    }
    It 'Get' {
        $eventTest = Get-JCEvent -Body:($ParamHash)
        If ([System.String]::IsNullOrEmpty($eventTest)) {
            $eventTest | Should -Not -BeNullOrEmpty
        }
        Else {
            # $eventTest = $eventTest
            $MostRecentRecord = ([System.DateTime]($eventTest | Select-Object -First 1).timestamp).ToUniversalTime()
            $OldestRecord = ([System.DateTime]($eventTest | Select-Object -Last 1).timestamp).ToUniversalTime()
            # Sort - Test that results come back in decending DateTime
            $MostRecentRecord | Should -BeGreaterThan $OldestRecord
            # EndTime - Test that results are not newer than EndTime parameter value
            $MostRecentRecord | Should -BeLessOrEqual $ParamHash.EndTime
            # StartTime - Test that results are not older than StartTime parameter value
            $OldestRecord | Should -BeGreaterOrEqual $ParamHash.StartTime
            # SearchTermAnd - Test that results matches parameter value
            ($eventTest.event_type | Select-Object -Unique) | Should -Be $ParamHash.SearchTermAnd.event_type
        }
    }
}
