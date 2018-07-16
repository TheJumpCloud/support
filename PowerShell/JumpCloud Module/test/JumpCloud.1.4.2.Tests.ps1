Describe "Get-JCCommandResult" {

    It "Returns the max results" {
        $TotalCount = Get-JCCommandResult -TotalCount
        $MaxResults = $TotalCount - 1
        $Results = Get-JCCommandResult -MaxResults $MaxResults
        $UniqueResults = $Results | Select-Object -Property _id -Unique
        $UniqueResults.count | Should -Be $MaxResults
    }

    It "Returns the max results using skip" {
        $TotalCount = Get-JCCommandResult -TotalCount
        $MaxResults = $TotalCount - 2
        $Results = Get-JCCommandResult -MaxResults $MaxResults -Skip 1
        $UniqueResults = $Results | Select-Object -Property _id -Unique
        $UniqueResults.count | Should -Be $MaxResults
    }
 
}

