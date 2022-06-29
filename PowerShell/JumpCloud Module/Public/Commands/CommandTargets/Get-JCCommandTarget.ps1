Function Get-JCCommandTarget {
    [CmdletBinding(DefaultParameterSetName = 'Systems')]
    param (

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Systems', Position = 0, HelpMessage = 'The id value of the JumpCloud command. Use the command ''Get-JCCommand | Select-Object _id, name'' to find the "_id" value for all the JumpCloud commands in your tenant.')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Groups', Position = 0, HelpMessage = 'The id value of the JumpCloud command. Use the command ''Get-JCCommand | Select-Object _id, name'' to find the "_id" value for all the JumpCloud commands in your tenant.')]
        [Alias('_id', 'id')]
        [String]$CommandID,

        [Parameter(ParameterSetName = 'Groups', HelpMessage = 'A switch parameter to display any System Groups associated with a command.')]
        [switch]$Groups

    )

    begin {

        Write-Verbose 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {
            Connect-JConline
        }

        $Parallel = $JCParallel

        if ($Parallel) {
            Write-Verbose 'Initilizing resultsArray'
            $resultsArrayList = [System.Collections.Concurrent.ConcurrentBag[object]]::new()
        } else {
            Write-Verbose 'Initilizing resultsArray'
            $resultsArrayList = New-Object -TypeName System.Collections.ArrayList
        }

        if ($PSCmdlet.ParameterSetName -eq 'Groups') {
            Write-Verbose 'Populating SystemGroupNameHash'
            $SystemGroupNameHash = Get-Hash_ID_SystemGroupName
        }

        if ($PSCmdlet.ParameterSetName -eq 'Systems') {
            Write-Verbose 'Populating SystemDisplayNameHash'
            $SystemDisplayNameHash = Get-Hash_SystemID_DisplayName

            Write-Verbose 'Populating SystemIDHash'
            $SystemHostNameHash = Get-Hash_SystemID_HostName
        }

        Write-Verbose 'Populating CommandNameHash'
        $CommandNameHash = Get-Hash_CommandID_Name

        Write-Verbose 'Populating CommandTriggerHash'
        $CommandTriggerHash = Get-Hash_CommandID_Trigger

        [int]$limit = '100'
        Write-Verbose "Setting limit to $limit"

        Write-Verbose 'Initilizing RawResults'
        $RawResults = @()

        Write-Verbose "parameter set: $($PSCmdlet.ParameterSetName)"
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            Systems {
                $SystemURL = "$JCUrlBasePath/api/v2/commands/$CommandID/systems"
                Write-Verbose $SystemURL
                if ($Parallel) {
                    # Parallel API call and resultsArrayList generation
                    $rawResults = Get-JCResults -Url $SystemURL -Method "GET" -limit $limit -parallel $true
                    $rawResults | ForEach-Object -Parallel {
                        # Get stored hash in each parallel thread
                        $CommandNameHash = $using:CommandNameHash
                        $CommandTriggerHash = $using:CommandTriggerHash
                        $SystemHostNameHash = $using:SystemHostNameHash
                        $SystemDisplayNameHash = $using:SystemDisplayNameHash

                        # resultsArrayList generation
                        $CommandName = $CommandNameHash.($using:CommandID)
                        $Trigger = $CommandTriggerHash.($using:CommandID)
                        $SystemID = $_.id
                        $Hostname = $SystemHostNameHash.($SystemID)
                        $Displyname = $SystemDisplayNameHash.($SystemID)

                        $CommandTargetSystem = [pscustomobject]@{
                            'CommandID'   = $CommandID
                            'CommandName' = $CommandName
                            'trigger'     = $Trigger
                            'SystemID'    = $SystemID
                            'DisplayName' = $Displyname
                            'HostName'    = $Hostname
                        }

                        $resultsArrayList.Add($CommandTargetSystem) | Out-Null
                    }
                } else {
                    # Sequential API call and resultsArrayList generation
                    $rawResults = Get-JCResults -Url $SystemURL -Method "GET" -limit $limit
                    foreach ($result in $RawResults) {
                        # resultsArrayList generation
                        $CommandName = $CommandNameHash.($CommandID)
                        $Trigger = $CommandTriggerHash.($CommandID)
                        $SystemID = $result.id
                        $Hostname = $SystemHostNameHash.($SystemID)
                        $Displyname = $SystemDisplayNameHash.($SystemID)

                        $CommandTargetSystem = [pscustomobject]@{
                            'CommandID'   = $CommandID
                            'CommandName' = $CommandName
                            'trigger'     = $Trigger
                            'SystemID'    = $SystemID
                            'DisplayName' = $Displyname
                            'HostName'    = $Hostname
                        }

                        $resultsArrayList.Add($CommandTargetSystem) | Out-Null
                    }
                }
            } # end Systems switch
            Groups {
                $SystemGroupsURL = "$JCUrlBasePath/api/v2/commands/$CommandID/systemgroups"
                Write-Verbose $SystemGroupsURL
                if ($Parallel) {
                    $rawResults = Get-JCResults -Url $SystemGroupsURL -Method "GET" -limit $limit -parallel $true
                    $rawResults | ForEach-Object -Parallel {
                        # Get stored hash in each parallel thread
                        $CommandNameHash = $using:CommandNameHash
                        $SystemGroupNameHash = $using:SystemGroupNameHash

                        # resultsArrayList generation
                        $CommandName = $CommandNameHash.($using:CommandID)
                        $GroupID = $_.id
                        $GroupName = $SystemGroupNameHash.($GroupID)

                        $Group = [pscustomobject]@{
                            'CommandID'   = $CommandID
                            'CommandName' = $CommandName
                            'GroupID'     = $GroupID
                            'GroupName'   = $GroupName
                        }

                        $resultsArrayList.Add($Group) | Out-Null

                    } # end parallel foreach
                } else {
                    # Sequential API call and resultsArrayList generation
                    $rawResults = Get-JCResults -Url $SystemGroupsURL -Method "GET" -limit $limit
                    foreach ($result in $RawResults) {
                        # resultsArrayList generation
                        $CommandName = $CommandNameHash.($CommandID)
                        $GroupID = $result.id
                        $GroupName = $SystemGroupNameHash.($GroupID)

                        $Group = [pscustomobject]@{

                            'CommandID'   = $CommandID
                            'CommandName' = $CommandName
                            'GroupID'     = $GroupID
                            'GroupName'   = $GroupName

                        }

                        $resultsArrayList.Add($Group) | Out-Null
                    } # end foreach
                } # end if/else parallel
            } # end Groups switch
        } # end switch
    } # end process

    end {
        switch ($PSCmdlet.ParameterSetName) {
            Systems {
                return $resultsArray | Sort-Object Displayname
            }
            Groups {
                return $resultsArray | Sort-Object GroupName
            }
        }
    }
}