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
        foreach ($sys in $System) {
            if ($sys -eq $System[-1]) {
                $filterString += "system_id:eq:$($sys._id)"
            }
            else{
                $filterString += "system_id:eq:$($sys._id),"
            }
        }
        $TableNames | ForEach-Object {
            $TableName = $_
            $SystemInsightsTestCases += @{
                testDescription = "Test table '$TableName' across all systems where error is NullOrEmpty."
                Command         = "Get-JCSystemInsights -Table:('$TableName');"
            }
            $SystemInsightsTestCases += @{
                testDescription = "Test table '$TableName' across specified systems through Id param where error is NullOrEmpty."
                Command         = "Get-JCSystemInsights -Table:('$TableName') -Id:('$(($System._id) -join "','")');"
            }
            $SystemInsightsTestCases += @{
                testDescription = "Test table '$TableName' across specified systems through filter param where error is NullOrEmpty."
                Command         = "Get-JCSystemInsights -Table:('$TableName') -Filter:('$filterString');"
            }
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
        Write-Host ("Command: $Command")
        $CommandResults = Invoke-Expression -Command:($Command) -ErrorVariable:('CommandResultsError')
        $CommandResultsError | Should -BeNullOrEmpty
    }
}