# BeforeAll {
#     $FileBaseName = (Get-Item -Path:($MyInvocation.MyCommand.Path)).BaseName
# }

# Describe -Tag:('JCSystemInsights') "Get-JCSystemInsights Tests" {
#     BeforeAll { Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force | Out-Null }
#     BeforeAll {
#         # $DebugPreference = 'Continue' # SilentlyContinue (Default), Continue, Inquire, Stop
#         # $VerbosePreference = 'Continue' # SilentlyContinue (Default), Continue, Inquire, Stop
#         $ErrorActionPreference = 'Stop' # Continue (Default), Ignore, Inquire, SilentlyContinue, Stop, Suspend
#     }
#     AfterAll {
#         # $DebugPreference = 'SilentlyContinue' # SilentlyContinue (Default), Continue, Inquire, Stop
#         # $VerbosePreference = 'SilentlyContinue' # SilentlyContinue (Default), Continue, Inquire, Stop
#         $ErrorActionPreference = 'Continue' # Continue (Default), Ignore, Inquire, SilentlyContinue, Stop, Suspend
#     }
#     # Retrieve objects to test with
#     $Type = 'system'
#     $JCType = Get-JCType -Type:($Type)
#     $Tables = $JCType.SystemInsights.Table | Where-Object { $_ -notin ('disk_info', 'bitlocker_info', 'uptime', 'sip_config', 'alf', 'shared_resources', 'user_ssh_keys', 'user_groups', 'sharing_preferences', 'scheduled_tasks') } | Select-Object -first 1 # HACK Temp workaround because these tables don't take strings as filters
#     $JCObject = Get-JCObject -Type:($Type) -Fields:($JCType.ById, $JCType.ByName, 'systemInsights') | Where-Object { $_.systemInsights.state -eq 'enabled' -and $_.displayName -ne 'Dwights-MacBook-Pro.local' } #-Limit:(2) -Paginate:($false)
#     # Define misc. variables
#     $Mock = $false
#     $MockFilePath = $PSScriptRoot + '/MockCommands_' + $FileBaseName + '.ps1'
#     $TestMethods = ('ById', 'ByName')
#     # Remove mock file if exists
#     If ($Mock) { If (Test-Path -Path:($MockFilePath)) { Remove-Item -Path:($MockFilePath) -Force } }
#     # Run tests
#     If (-not ([System.String]::IsNullOrEmpty($JCObject)))
#     {
#         ForEach ($Table In $Tables)
#         {
#             Context ('Tests returning records of a specific table across all systems.') {
#                 $Command = "Get-JCSystemInsights -Table`:('$Table');"
#                 Context ("Running command: $Command") {
#                     If ($Mock)
#                     {
#                         $Command | Tee-Object -FilePath:($MockFilePath) -Append
#                     }
#                     Else
#                     {
#                         $CommandResults = Invoke-Expression -Command:($Command) -ErrorVariable:('CommandResultsError')
#                         # It("Where results should be not NullOrEmpty") {$CommandResults | Should -Not -BeNullOrEmpty}
#                         It("Where Error is NullOrEmpty") { $CommandResultsError | Should -BeNullOrEmpty }
#                     }
#                 }
#             }
#             Context ('Tests returning records of a specific table across specified systems.') {
#                 ForEach ($TestMethod In $TestMethods)
#                 {
#                     $TestMethodIdentifier = $TestMethod.Replace('By', '')
#                     $ById = $JCObject.($JCObject.ById | Select-Object -Unique)
#                     $ByName = $JCObject.($JCObject.ByName | Select-Object -Unique)
#                     $SearchByValue = Switch ($TestMethod)
#                     {
#                         'ById' { $ById }
#                         'ByName' { $ByName }
#                         Default { Write-Error ('Unknown $TestMethod: "' + $TestMethod + '"') }
#                     }
#                     $SingleJCItem = "'" + (($SearchByValue | Select-Object -First 1) -join "', '") + "'"
#                     $MultipleJCItem = "'" + (($SearchByValue | Select-Object -First 2) -join "', '") + "'"
#                     Context ("Testing by: $TestMethod'") {
#                         $CommandRecords = @()
#                         # Test using the -Id and -Name parameters with single item
#                         $CommandRecords += [PSCustomObject]@{ 'TestType' = 'Single'; 'Command' = "Get-JCSystemInsights -Table`:('$Table') -$TestMethodIdentifier`:($SingleJCItem);"; }
#                         # Test using the -SearchBy and -SearchByValue parameters with single item
#                         $CommandRecords += [PSCustomObject]@{ 'TestType' = 'Single'; 'Command' = "Get-JCSystemInsights -Table`:('$Table') -SearchBy`:('$TestMethod') -SearchByValue`:($SingleJCItem);"; }
#                         # Test using the -Id and -Name parameters with multiple items
#                         $CommandRecords += [PSCustomObject]@{ 'TestType' = 'Multiple'; 'Command' = "Get-JCSystemInsights -Table`:('$Table') -$TestMethodIdentifier`:($MultipleJCItem);"; }
#                         # Test using the -SearchBy and -SearchByValue parameters with multiple items
#                         $CommandRecords += [PSCustomObject]@{ 'TestType' = 'Multiple'; 'Command' = "Get-JCSystemInsights -Table`:('$Table') -SearchBy`:('$TestMethod') -SearchByValue`:($MultipleJCItem);"; }
#                         ForEach ($CommandRecord In $CommandRecords)
#                         {
#                             $TestType = $CommandRecord.TestType
#                             $Command = $CommandRecord.Command
#                             Context ("Running command: $Command") {
#                                 If ($Mock)
#                                 {
#                                     $Command | Tee-Object -FilePath:($MockFilePath) -Append
#                                 }
#                                 Else
#                                 {
#                                     $CommandResults = Invoke-Expression -Command:($Command) -ErrorVariable:('CommandResultsError')
#                                     It("Where Error is NullOrEmpty") { $CommandResultsError | Should -BeNullOrEmpty }
#                                     # It("Where results should be not NullOrEmpty") {$CommandResults | Should -Not -BeNullOrEmpty}
#                                     # Switch ($TestType)
#                                     # {
#                                     #     'Single'
#                                     #     {
#                                     #         It("Where unique object id count should Be 1") {($CommandResults.system_id | Select-Object -Unique | Measure-Object).Count | Should -Be 1}
#                                     #     }
#                                     #     'Multiple'
#                                     #     {
#                                     #         It("Where unique object id count should BeGreaterThan 1") {($CommandResults.system_id | Select-Object -Unique | Measure-Object).Count | Should -BeGreaterThan 1}
#                                     #     }
#                                     #     Default {Write-Error 'Unknown $TestType: "' + $TestType + '"'}
#                                     # }
#                                     # It("Where results '$($CommandResults.($CommandResults.ById | Select-Object -Unique) | Select-Object -Unique)' should BeIn '$ById'") {$CommandResults.($CommandResults.ById | Select-Object -Unique) | Select-Object -Unique | Should -BeIn $ById}
#                                 }
#                             }
#                         }
#                     }
#                 }
#             }
#         }
#     }
#     Else
#     {
#         Throw 'Command returned no JCObjects to test with.'
#     }
# }