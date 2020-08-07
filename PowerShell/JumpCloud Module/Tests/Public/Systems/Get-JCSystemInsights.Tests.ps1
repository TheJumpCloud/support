BeforeAll {
    Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null
    $ErrorActionPreference = 'Stop' # Continue (Default), Ignore, Inquire, SilentlyContinue, Stop, Suspend
}
Describe -Tag:('JCSystemInsights') "Get-JCSystemInsights Tests" {
    Function Get-JCSystemInsightsTestCases($System)
    {
        # Retrieve objects to test with
        $SystemInsightsPrefix = 'Get-JcSdkSystemInsight';
        $SystemInsightsDataSet = [Ordered]@{}
        Get-Command -Module:('JumpCloud.SDK.V2') -Name:("$($SystemInsightsPrefix)*") | ForEach-Object {
            $Help = Get-Help -Name:($_.Name);
            $Table = $_.Name.Replace($SystemInsightsPrefix, '')
            $HelpDescription = $Help.Description.Text
            $FilterDescription = $Help.parameters.parameter.Where( { $_.Name -eq 'filter' }).Description.Text
            $FilterNames = ($HelpDescription | Select-String -Pattern:([Regex]'(?<=\ `)(.*?)(?=\`)') -AllMatches).Matches.Value
            $Operators = ($FilterDescription -Replace ('Supported operators are: ', '')).Trim()
            If ([System.String]::IsNullOrEmpty($HelpDescription) -or [System.String]::IsNullOrEmpty($FilterNames) -or [System.String]::IsNullOrEmpty($Operators))
            {
                Write-Error ('Get-JCSystemInsights parameter help info is missing.')
            }
            Else
            {
                $Filters = $FilterNames | ForEach-Object {
                    $FilterName = $_
                    $Operators | ForEach-Object {
                        $Operator = $_
                        ("'{0}:{1}:{2}'" -f $FilterName, $Operator, '[SearchValue <String>]');
                    }
                }
                $SystemInsightsDataSet.Add($Table, $Filters )
            }
        };
        $SystemInsightsTestCases = @()
        $SystemInsightsDataSet.GetEnumerator() | ForEach-Object {
            $TableName = $_.Key
            $SystemInsightsTestCases += @{
                testDescription = "Test table '$TableName' across all systems where error is NullOrEmpty."
                Command         = "Get-JCSystemInsights -Table:('$TableName');"
            }
            $SystemInsightsTestCases += @{
                testDescription = "Test table '$TableName' across specified systems through Id param where error is NullOrEmpty."
                Command         = "Get-JCSystemInsights -Table:('$TableName') -Id:('$(($System._id) -join "','")');"
            }
            # Use this if we decide to test the `-Filter` parameter eventually.
            # $Filter = $_.Value | Where-Object { $_ -like '%*system_id*%' } # Only test system_id filter since we dont know the values to search for in the other filters.
            # $Filter = $Filter.replace('[SearchValue <String>]', $System[0]._id)
            # $SystemInsightsTestCases += @{
            #     testDescription = "Test table '$TableName' across specified systems through filter param where error is NullOrEmpty."
            #     Command         = "Get-JCSystemInsights -Table:('$TableName') -Filter:('$($Filter)');"
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