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

    }
    process {
        $occursBefore = $false
        for ($i = 0; $i -le $functionArray.count; $i++) {
            $functionArray[$i].Function
            if (($functionArray[$i].Function -match $before) -and ($functionArray[$i + 1].Function -match $after)) {
                $setAfterGet = $true
            }
        }

    }
    end {
        return $occursBefore
    }
}