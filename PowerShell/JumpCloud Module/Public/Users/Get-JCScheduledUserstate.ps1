Function Get-JCScheduledUserstate () {
    [CmdletBinding(DefaultParameterSetName = 'BulkLookup')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'BulkLookup', ValueFromPipelineByPropertyName = $True, HelpMessage = "The scheduled state you'd like to query (SUSPENDED or ACTIVATED)")]
        [ValidateSet('SUSPENDED', 'ACTIVATED')]
        [string]$State,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ByID', HelpMessage = 'The _id of the User which you want to lookup. UserID has an Alias of _id.')]
        [Alias('_id', 'id')]
        [String]$UserId
    )
    begin {
        Write-Verbose 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {
            Connect-JCOnline
        }

        Write-Verbose 'Initilizing resultsArray'
        $resultsArrayList = New-Object -TypeName System.Collections.ArrayList

        Write-Verbose "Parameter Set: $($PSCmdlet.ParameterSetName)"
    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            BulkLookup {
                if ($state -eq 'SUSPENDED') {
                    $scheduledUsers = Get-JcSdkBulkUserState | Where-Object State -EQ 'SUSPENDED'
                } else {
                    $scheduledUsers = Get-JcSdkBulkUserState | Where-Object State -EQ 'ACTIVATED'
                }

                # Create SearchBody to parse users
                $searchUserBody = @{
                    filter = @{
                        or = @(
                        )
                    }
                    fields = "firstname lastname email username _id"
                }

                # Create OR lookup for IDs
                $scheduledUsers | ForEach-Object {
                    $searchUserBody.filter.or += "_id:`$eq:$($_.SystemUserId)"
                }

                # Get users
                $searchUsers = Search-JcSdkUser -Body $searchUserBody
                $searchUsers | ForEach-Object {
                    # Get the scheduled date for the user
                    $user = $scheduledUsers | Where-Object SystemUserID -EQ $_.Id
                    # Convert the scheduled date to datetime (also seems to convert to local as well)
                    $localScheduledDate = [datetime]$user.ScheduledDate
                    # Create userResult
                    $userResult = [pscustomobject]@{
                        id            = $_.Id
                        Firstname     = $_.Firstname
                        Lastname      = $_.Lastname
                        Email         = $_.email
                        Username      = $_.username
                        ScheduledDate = $localScheduledDate
                    }
                    $resultsArrayList.Add($userResult) | Out-Null
                }
            }
            ByID {
                # Get User's scheduled state
                $scheduledUser = Get-JcSdkBulkUserState -Userid $userId
                # User attribute lookup
                $user = Get-JcSdkUser -Id $userId | Select-Object firstname, lastname, email, username, id
                # Convert date to local
                $localScheduledDate = [datetime]$scheduledUser.ScheduledDate
                # Create custom return object
                $userResult = [pscustomobject]@{
                    id            = $user.Id
                    Firstname     = $user.Firstname
                    Lastname      = $user.Lastname
                    Email         = $user.email
                    Username      = $user.username
                    ScheduledDate = $LocalScheduledDate
                }
                $resultsArrayList.Add($userResult) | Out-Null
            }
        }
    }
    end {
        return $resultsArrayList
    }
}