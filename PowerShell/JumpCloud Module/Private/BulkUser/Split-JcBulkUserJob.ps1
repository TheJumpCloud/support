function Split-JcBulkUserJob {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)][ValidateNotNullOrEmpty()][PSObject[]]$userArray
    )
    begin {
        # Amount to split into separate arrays (800 user objects)
        $count = 800

        # New list to hold new split arrays
        $aggregateList = @()
    }
    process {
        # Find how many split blocks
        $splitBlocks = [Math]::Floor($userArray.Count / $count)

        # Determine how many items are leftover
        $leftOver = $userArray.Count % $count

        # Iterate through splitBlocks and add newly formed arrays to the aggregateList
        for ($i = 0; $i -lt $splitBlocks; $i++) {
            $end = $count * ($i + 1) - 1

            $aggregateList += @(, $userArray[$start..$end])
            $start = $end + 1
        }

        # Add any remaining leftover items to a final array
        if ($leftOver -gt 0) {
            $aggregateList += @(, $userArray[$start..($end + $leftOver)])
        }
    }
    end {
        # Return the aggregateList of arrays
        return $aggregateList
    }
}