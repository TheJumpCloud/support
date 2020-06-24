BeforeAll {
    Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null
    $ErrorActionPreference = 'Stop' # Continue (Default), Ignore, Inquire, SilentlyContinue, Stop, Suspend

}
Describe -Tag:('JCSystemInsights') "Get-JCSystemInsights Tests" {
    Function Get-JCSystemInsightsTestCases($System)
    {
        # Retrieve objects to test with
        $TableNames = $PesterParams_SystemInsightsTables | Where-Object { $_ -notin ('disk_info', 'bitlocker_info', 'uptime', 'sip_config', 'alf', 'shared_resources', 'user_ssh_keys', 'user_groups', 'sharing_preferences', 'scheduled_tasks') } # HACK Temp workaround because these tables don't take strings as filters
        $SystemInsightsTestCases = @()
        $TableNames | ForEach-Object {
            $TableName = $_
            $SystemInsightsTestCases += @{
                testDescription = 'Test a specific table across all systems where error is NullOrEmpty.'
                Command         = "Get-JCSystemInsights -Table:('$TableName');"
            }
            $SystemInsightsTestCases += @{
                testDescription = 'Test a specific table across specified systems ById where error is NullOrEmpty.'
                Command         = "Get-JCSystemInsights -Table:('$TableName') -Id:('$(($System._id) -join "','")');"
            }
            $SystemInsightsTestCases += @{
                testDescription = 'Test a specific table across specified systems ByValue Id where error is NullOrEmpty.'
                Command         = "Get-JCSystemInsights -Table:('$TableName') -SearchBy:('ById') -SearchByValue:('$(($System._id) -join "','")');"
            }
            $SystemInsightsTestCases += @{
                testDescription = 'Test a specific table across specified systems ByName where error is NullOrEmpty.'
                Command         = "Get-JCSystemInsights -Table:('$TableName') -Name:('$(($System.displayName) -join "','")');"
            }
            $SystemInsightsTestCases += @{
                testDescription = 'Test a specific table across specified systems ByValue Name where error is NullOrEmpty.'
                Command         = "Get-JCSystemInsights -Table:('$TableName') -SearchBy:('ByName') -SearchByValue:('$(($System.displayName) -join "','")');"
            }
        }
        Return $SystemInsightsTestCases
    }
    It '<testDescription>' -TestCases:(Get-JCSystemInsightsTestCases -System:($PesterParams_SystemLinux, $PesterParams_SystemMac, $PesterParams_SystemWindows)) {
        # Write-Host ("Command: $Command")
        $CommandResults = Invoke-Expression -Command:($Command) -ErrorVariable:('CommandResultsError')
        $CommandResultsError | Should -BeNullOrEmpty
    }
}