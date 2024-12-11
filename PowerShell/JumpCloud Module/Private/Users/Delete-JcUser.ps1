function Delete-JCUser {
    # UserId and cascade_manager are required
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'The JumpCloud User ID.')][ValidateNotNullOrEmpty()][System.String]$Id
        , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'The JumpCloud cascade manager ID.')][System.String]$managerId,
        # headers are required
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'The JumpCloud API headers.')][ValidateNotNullOrEmpty()][System.Collections.Hashtable]$Headers
    )

    process {
        try {
            if ($managerId) {
                $URI = "$JCUrlBasePath/api/systemusers/$($Id)?cascade_manager=$($managerId)"
                Write-Warning "Are you sure you wish to delete user: $Username ?" -WarningAction Inquire
                $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $Headers -UserAgent:(Get-JCUserAgent)
                Write-Debug $delete
                $Status = 'Deleted'
            } else {
                $URI = "$JCUrlBasePath/api/systemusers/$($Id)?cascade_manager=null"
                Write-Warning "Are you sure you wish to delete user: $Username ?" -WarningAction Inquire
                $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $Headers -UserAgent:(Get-JCUserAgent)
                Write-Debug $delete
                $Status = 'Deleted'
            }

        } catch {
            $Status = $_.ErrorDetails
        }
        $FormattedResults = [PSCustomObject]@{
            'User'    = $Username
            'Results' = $Status
        }
    }
    end {
        return $FormattedResults
    }
}