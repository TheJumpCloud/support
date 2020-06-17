BeforeAll {
    Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null
    $ErrorActionPreference = 'Stop' # Continue (Default), Ignore, Inquire, SilentlyContinue, Stop, Suspend
    # Retrieve objects to test with
    $Type = 'system'
    $JCType = Get-JCType -Type:($Type)
    $TableNames = $JCType.SystemInsights.Table | Where-Object { $_ -notin ('disk_info', 'bitlocker_info', 'uptime', 'sip_config', 'alf', 'shared_resources', 'user_ssh_keys', 'user_groups', 'sharing_preferences', 'scheduled_tasks') } # HACK Temp workaround because these tables don't take strings as filters
    $TestCases = $TableNames | ForEach-Object {
        $TableName = $_
        @{ testDescription = 'Test a specific table across all systems where error is NullOrEmpty.'
            Command        = "Get-JCSystemInsights -Table:('$TableName');"
        }
        , @{ testDescription = 'Test a specific table across specified systems ById where error is NullOrEmpty.'
            Command          = "Get-JCSystemInsights -Table:('$TableName') -Id:('$($PesterParams_SystemLinux._id)');"
        }
        , @{ testDescription = 'Test a specific table across specified systems ByValue Id where error is NullOrEmpty.'
            Command          = "Get-JCSystemInsights -Table:('$TableName') -SearchBy:('ById') -SearchByValue:('$($PesterParams_SystemLinux._id)');"
        }
        , @{ testDescription = 'Test a specific table across specified systems ByName where error is NullOrEmpty.'
            Command          = "Get-JCSystemInsights -Table:('$TableName') -Name:('$($PesterParams_SystemLinux.displayName)');"
        }
        , @{ testDescription = 'Test a specific table across specified systems ByValue Name where error is NullOrEmpty.'
            Command          = "Get-JCSystemInsights -Table:('$TableName') -SearchBy:('ByName') -SearchByValue:('$($PesterParams_SystemLinux.displayName)');"
        }
    }
}
Describe -Tag:('JCSystemInsights') "Get-JCSystemInsights Tests" {
    It '<testDescription>' -TestCases:($TestCases) {
        param (
            [System.String] $Command
        )
        # Write-Host ($Command)
        $CommandResults = Invoke-Expression -Command:($Command) -ErrorVariable:('CommandResultsError')
        $CommandResultsError | Should -BeNullOrEmpty
    }
}
