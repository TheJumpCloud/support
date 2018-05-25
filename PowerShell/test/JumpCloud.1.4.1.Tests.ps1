Describe "Get-JCCommandResult" {

    It "Returns the total count of JumpCloud command results" {
        $TotalCount = Get-JCCommandResult -TotalCount
        $TotalCount | Should -BeGreaterThan 0
    }

    IT "Uses the -Skip parameter of JumpCloud command results" {

        $TotalCount = Get-JCCommandResult -TotalCount
        $Skip = 2 
        $SkipResults = Get-JCCommandResult -skip $Skip
        $Total = $SkipResults.count + $Skip 
        $Total | Should -Be $TotalCount
    }

    IT "Users the -Limit parameter of JumpCloud command results" {
        $TotalCount = Get-JCCommandResult -TotalCount
        $Limit = '4'
        $LimitTotal = Get-JCCommandResult -limit $Limit
        $LimitTotal.count | Should -be $TotalCount


    }
 
}