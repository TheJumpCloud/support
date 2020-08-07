BeforeAll {
    Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null
    $ErrorActionPreference = 'Stop' # Continue (Default), Ignore, Inquire, SilentlyContinue, Stop, Suspend
}
Describe -Tag:('JCSystemInsights') "Get-JCSystemInsights Tests" {
    Function Get-JCSystemInsightsTestCases($System)
    {
        # Retrieve objects to test with
        $SystemInsightsPrefix = 'Get-JcSdkSystemInsight';
        $SystemInsightsTables = @();
        $Commands = Get-Command -Module:('JumpCloud.SDK.V2') -Name:("$($SystemInsightsPrefix)*") | select-object name;
        $Commands | ForEach-Object {
            $SystemInsightsTables += ($_.Name.Replace($SystemInsightsPrefix, ''))
        }
        $TableNames = $SystemInsightsTables | Where-Object { $_ -notin ('DiskInfo', 'WindowCrash', 'BitlockerInfo', 'Uptime', 'SipConfig', 'Alf', 'SharedResource', 'UserSshKey', 'UserGroup', 'SharingPreference', 'ScheduledTask', 'AlfException') } # HACK Temp workaround because these tables don't take strings as filters
        $SystemInsightsTestCases = @()
        $TableNames | ForEach-Object {
            $TableName = $_
            $SystemInsightsTestCases += @{
                testDescription = "Test table '$TableName' across all systems where error is NullOrEmpty."
                Command         = "Get-JCSystemInsights -Table:('$TableName');"
            }
            $SystemInsightsTestCases += @{
                testDescription = "Test table '$TableName' across specified systems ById where error is NullOrEmpty."
                Command         = "Get-JCSystemInsights -Table:('$TableName') -Id:('$(($System[0]._id))');"
            }
            # $SystemInsightsTestCases += @{
            #     testDescription = "Test table '$TableName' across specified systems ByValue Id where error is NullOrEmpty."
            #     Command         = "Get-JCSystemInsights -Table:('$TableName') -SearchBy:('ById') -SearchByValue:('$(($System._id) -join "','")');"
            # }
            # $SystemInsightsTestCases += @{
            #     testDescription = "Test table '$TableName' across specified systems ByName where error is NullOrEmpty."
            #     Command         = "Get-JCSystemInsights -Table:('$TableName') -Name:('$(($System.displayName) -join "','")');"
            # }
            # $SystemInsightsTestCases += @{
            #     testDescription = "Test table '$TableName' across specified systems ByValue Name where error is NullOrEmpty."
            #     Command         = "Get-JCSystemInsights -Table:('$TableName') -SearchBy:('ByName') -SearchByValue:('$(($System.displayName) -join "','")');"
            # }
        }
        Return $SystemInsightsTestCases
    }
    It '<testDescription>' -TestCases:(Get-JCSystemInsightsTestCases -System:($PesterParams_SystemLinux, $PesterParams_SystemMac, $PesterParams_SystemWindows)) {
        # Write-Host ("Command: $Command")
        $CommandResults = Invoke-Expression -Command:($Command) -ErrorVariable:('CommandResultsError')
        $CommandResultsError | Should -BeNullOrEmpty
    }
}