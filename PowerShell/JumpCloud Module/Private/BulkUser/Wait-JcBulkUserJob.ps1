function Wait-JcBulkUserJob {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)][ValidateNotNullOrEmpty()][string[]]$jobIds
    )
    begin {
        $finishedJobs = [System.Collections.Generic.List[PSObject]]::new()
        $unfinishedJobs = [System.Collections.Generic.List[PSObject]]::new()
    }
    process {
        # Initial JobStatus check
        $JobIds | ForEach-Object {
            $bulkJobResult = Get-JcSdkBulkUsersResult -JobId $_

            # If job is finished, add to finished list, otherwise add to unfinished list
            If ($bulkJobResult.Status -eq 'finished') {
                $finishedJobs.Add($bulkJobResult)
            } else {
                $unfinishedJobs.Add($bulkJobResult)
            }
        }

        # Continuously iterate through the unfinishedJob list to check status until unfinishedJob list is empty
        do {
            $unfinishedJobs | ForEach-Object {
                $bulkJobResult = Get-JcSdkBulkUsersResult -JobId $_.Id

                If ($bulkJobResult.Status -eq 'finished') {
                    # Add the finished job to the finished array
                    $finishedJobs.Add($bulkJobResult)
                    Write-Debug "$($_.Id) is finished"

                    # Remove the finished job from the unfinished array
                    $unfinishedJobs.Remove($bulkJobResult)
                    Write-Debug "Removing $($_.Id) from unfinished list"
                } else {
                    # If the job isn't finished, sleep 5 seconds.
                    Write-Debug "$($_.Id) is not finished... sleeping 5 seconds..."
                    Start-Sleep -Seconds 5
                }
            }
        } while ($unfinishedJobs.Count -gt 0)
    }
    end {
        return $finishedJobs
    }
}