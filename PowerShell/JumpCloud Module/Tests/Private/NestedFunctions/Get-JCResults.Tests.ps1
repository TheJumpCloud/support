Describe -Tag:('Parallel') "Get-JCResults Parallel" {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null }
    BeforeEach {
        # Set global variable to run in parallel before each It block
        $JCParallel = $true
    }
    It "Returns all users in parallel" {

        $URL = "{0}/api/search/systemusers" -f $JCUrlBasePath
        $Search = @{
            filter = @(
                @{}
            )
            fields = ""
            limit  = 1
            skip   = 0
        }
        $SearchJSON = $Search | ConvertTo-Json -Compress -Depth 4

        $ParallelUsers = Get-JCResults -Url $URL -method "POST" -body $SearchJSON -limit 1 -parallel $true

        # Ensure function runs in sequential
        $JCParallel = $false
        $SerialUsers = Get-JCUser

        $ParallelUsers.Count | Should -Be $SerialUsers.Count

        $SortedParallelUsers = $ParallelUsers.username | Sort-Object
        $SortedSerialUsers = $SerialUsers.username | Sort-Object

        $SortedParallelUsers | Should -Be $SortedSerialUsers

    }

    It "Returns all systems in parallel" {

        $URL = "$JCUrlBasePath/api/search/systems"
        $Search = @{
            filter = @(
                @{}
            )
            fields = ""
            limit  = 1
            skip   = 0
        }
        $SearchJSON = $Search | ConvertTo-Json -Compress -Depth 4

        $ParallelSystems = Get-JCResults -Url $URL -method "POST" -body $SearchJSON -limit 1 -parallel $true

        # Ensure function runs in sequential
        $JCParallel = $false
        $SerialSystems = Get-JCSystem

        $ParallelSystems.Count | Should -Be $SerialSystems.Count

        $SortedParallelSystems = $ParallelSystems.displayName | Sort-Object
        $SortedSerialSystems = $SerialSystems.displayName | Sort-Object

        $SortedParallelSystems | Should -Be $SortedSerialSystems

    }

    It "Returns all SystemGroupMembers in parallel" {
        $limitURL = "{0}/api/v2/Systemgroups/{1}/members" -f $JCUrlBasePath, $PesterParams_SystemGroup.Id
        $rawResults = Get-JCResults -Url $limitURL -method "GET" -limit 1 -parallel $true

        $ParallelSystemGroupMembers = [System.Collections.Generic.List[PSObject]]::new()
        foreach ($uid in $rawResults) {
            $System = Get-JCSystem -id:($uid.to.id)

            $FomattedResult = [pscustomobject]@{

                'GroupName' = $PesterParams_SystemGroup.name
                'System'    = $System.hostname
                'SystemID'  = $uid.to.id
            }

            $ParallelSystemGroupMembers.add($FomattedResult)
        }


        # Ensure function runs in sequential
        $JCParallel = $false
        $SerialSystemGroupMembers = Get-JCSystemGroupMember -ByID $PesterParams_SystemGroup.Id

        $ParallelSystemGroupMembers.Count | Should -Be $SerialSystemGroupMembers.Count

        $SortedParallelMembers = $ParallelSystemGroupMembers | Sort-Object -Property SystemID | ConvertTo-Json
        $SortedSerialMembers = $SerialSystemGroupMembers | Sort-Object -Property SystemID | ConvertTo-Json

        $SortedParallelMembers | Should -Be $SortedSerialMembers
    }

    It "Returns all UserGroupMembers in parallel" {
        $limitURL = "{0}/api/v2/Usergroups/{1}/members" -f $JCUrlBasePath, $PesterParams_UserGroup.Id
        $rawResults = Get-JCResults -Url $limitURL -method "GET" -limit 1 -parallel $true

        $ParallelUserGroupMembers = [System.Collections.Generic.List[PSObject]]::new()
        foreach ($uid in $rawResults) {
            $User = Get-JCUser -id:($uid.to.id)

            $FomattedResult = [pscustomobject]@{

                'GroupName' = $PesterParams_UserGroup.name
                'Username'  = $User.username
                'UserID'    = $uid.to.id
            }

            $ParallelUserGroupMembers.add($FomattedResult)
        }


        # Ensure function runs in sequential
        $JCParallel = $false
        $SerialUserGroupMembers = Get-JCUserGroupMember -ByID $PesterParams_UserGroup.Id

        $ParallelUserGroupMembers.Count | Should -Be $SerialUserGroupMembers.Count

        $SortedParallelMembers = $ParallelUserGroupMembers | Sort-Object -Property UserID | ConvertTo-Json
        $SortedSerialMembers = $SerialUserGroupMembers | Sort-Object -Property UserID | ConvertTo-Json

        $SortedParallelMembers | Should -Be $SortedSerialMembers
    }

    It "Returns all Groups in Parallel" {
        $limitURL = "$JCUrlBasePath/api/v2/groups"
        $ParallelGroups = Get-JCResults -Url $limitURL -method "GET" -limit 1 -parallel $true

        # Ensure function runs in Sequential
        $JCParallel = $false
        $SerialGroups = Get-JCGroup

        $SortedParallelGroups = $ParallelGroups | Sort-Object type, name | ConvertTo-Json
        $SortedSerialGroups = $SerialGroups | Sort-Object type, name | ConvertTo-Json

        $SortedParallelGroups | Should -Be $SortedSerialGroups

    }

    It "Returns all Commands in Parallel" {
        $URL = "{0}/api/search/commands" -f $JCUrlBasePath
        $Search = @{
            filter = @(
                @{}
            )
            fields = ""
            limit  = 1
            skip   = 0
        }
        $SearchJSON = $Search | ConvertTo-Json -Compress -Depth 4

        $ParallelCommands = Get-JCResults -Url $URL -method "POST" -body $SearchJSON -limit 1 -parallel $true

        # Ensure function runs in sequential
        $JCParallel = $false
        $SerialCommands = Get-JCCommand

        $ParallelCommands.Count | Should -Be $SerialCommands.Count

        $SortedParallelCommands = $ParallelCommands.name | Sort-Object
        $SortedSerialCommands = $SerialCommands.name | Sort-Object

        $SortedParallelCommands | Should -Be $SortedSerialCommands
    }

    It "Returns all CommandResults in Parallel" {
        $limitURL = "$JCUrlBasePath/api/commandresults"
        $ParallelCommandResults = Get-JCResults -Url $limitURL -method "GET" -limit $limit -parallel $true

        # Ensure function runs in sequential
        $JCParallel = $false
        $SerialCommandResults = Get-JCCommandResult

        $SortedParallelCommandResults = $ParallelCommandResults.name | Sort-Object
        $SortedSerialCommandResults = $SerialCommandResults.name | Sort-Object

        $SortedParallelCommandResults | Should -Be $SortedSerialCommandResults
    }
    AfterAll {
        $JCParallel = $true
    }
}