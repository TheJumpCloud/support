Function Get-PipelinePositionBefore {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.String]
        $before,
        [Parameter()]
        [System.String]
        $after,
        [Parameter()]
        [System.object]
        $functionArray
    )
    begin {
        $occursBefore = $false

    }
    process {
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