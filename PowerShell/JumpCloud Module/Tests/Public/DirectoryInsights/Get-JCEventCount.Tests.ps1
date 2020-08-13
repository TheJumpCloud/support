Describe 'Get-JCEventCount' -Tag:('JCEvent') {
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
        For ($i = 1; $i -le 4; $i++) {
            $UserName = 'JCSystemUserTest-{0}' -f $i
            Write-Host ("Creating add/delete records for: $UserName")
            If (Get-JCUser -username:($UserName)) {
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
        $eventTest = Get-JCEventCount -Service:($ParamHash.Service) -StartTime:($ParamHash.StartTime) -EndTime:($ParamHash.EndTime) -Sort:($ParamHash.Sort) -SearchTermAnd:($ParamHash.SearchTermAnd)
        $eventTest | Should -Not -BeNullOrEmpty
        $eventTest | Should -BeOfType System.Int64
    }
    It 'Get' {
        $eventTest = Get-JCEventCount -Body:($ParamHash)
        $eventTest | Should -Not -BeNullOrEmpty
        $eventTest | Should -BeOfType System.Int64
    }
}
