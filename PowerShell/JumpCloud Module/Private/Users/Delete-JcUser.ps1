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
                $Username = Get-JcSdkUser -Id $Id | Select-Object -ExpandProperty username
                $ManagerUsername = Get-JcSdkUser -Id $managerId | Select-Object -ExpandProperty username
                Write-Host "Deleting user: $($Username) and cascading managed users to manager: $($ManagerUsername)" -ForegroundColor Yellow
                $prompt = Read-Host "Are you sure you wish to delete the user: $($Username)? (Y/N)"
                while ($prompt -ne 'Y' -and $prompt -ne 'N') {
                    $prompt = Read-Host "Please enter Y or N"
                }
                if ($prompt -eq 'Y') {
                    $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $Headers -UserAgent:(Get-JCUserAgent)
                    Write-Debug $delete
                    $Status = 'Deleted'
                } elseif ($prompt -eq 'N') {
                    Write-Debug "User not deleted"
                    $Status = 'Not Deleted'
                }
            } else {
                $URI = "$JCUrlBasePath/api/systemusers/$($Id)?cascade_manager=null"
                $Username = Get-JcSdkUser -Id $Id | Select-Object -ExpandProperty username
                Write-Host "Deleting user: $Username" -ForegroundColor Yellow
                $prompt = Read-Host "Are you sure you wish to delete the user: $($Username)? (Y/N)"
                # Do a loop until the user enters Y or N
                while ($prompt -ne 'Y' -and $prompt -ne 'N') {
                    $prompt = Read-Host "Please enter Y or N"
                }
                if ($prompt -eq 'Y') {
                    $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $Headers -UserAgent:(Get-JCUserAgent)
                    Write-Debug $delete
                    $Status = 'Deleted'
                } elseif ($prompt -eq 'N') {
                    Write-Debug "User not deleted"
                    $Status = 'Not Deleted'
                }
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