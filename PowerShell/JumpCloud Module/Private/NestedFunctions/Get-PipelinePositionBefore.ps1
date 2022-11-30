Function Get-PipelinePositionBefore {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'Function name to test pipeline position is directly before function defined in the "after" param')]
        [System.String]
        $before,
        [Parameter(Mandatory = $true, HelpMessage = 'Function name to test pipeline position is directly after function defined in the "before" param')]
        [System.String]
        $after,
        [Parameter(Mandatory = $true, HelpMessage = 'Objects from Get-PipelineDetails')]
        [System.object]
        $functionArray
    )
    begin {
        $occursBefore = $false
    }
    process {
        # If function in pipeline (n) occurs before n+1, return $true
        for ($i = 0; $i -le $functionArray.count; $i++) {
            if (($functionArray[$i].Function -match $before) -and ($functionArray[$i + 1].Function -match $after)) {
                $occursBefore = $true
            }
        }
    }
    end {
        return $occursBefore
    }
}