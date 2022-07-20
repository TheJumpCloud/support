Param(
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 2)][System.String[]]$ExcludeTagList
    , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 3)][System.String[]]$IncludeTagList
)

If (($IncludeTagList -eq '*') -OR (-not ($IncludeTagList))) {
    $PesterTests = Get-ChildItem -Path:("$PSScriptroot/../JumpCloud Module/Tests" + '/*.Tests.ps1') -Recurse
    $Tags = ForEach ($PesterTest In $PesterTests) {
        $PesterTestFullName = $PesterTest.FullName
        $FileContent = Get-Content -Path:($PesterTestFullName)
        $DescribeLines = $FileContent | Select-String -Pattern:([RegEx]'(Describe)')#.Matches.Value
        ForEach ($DescribeLine In $DescribeLines) {
            If ($DescribeLine.Line -match 'Tag') {
                $TagParameterValue = ($DescribeLine.Line | Select-String -Pattern:([RegEx]'(?<=-Tag)(.*?)(?=\s)')).Matches.Value
                @(":", "(", ")", "'") | ForEach-Object { If ($TagParameterValue -like ('*' + $_ + '*')) {
                        $TagParameterValue = $TagParameterValue.Replace($_, '')
                    } }
                $TagParameterValue
            } Else {
                Write-Error ('Tag missing in "' + $PesterTestFullName + '" on line number "' + $DescribeLine.LineNumber + '" value "' + ($DescribeLine.Line).Trim() + '"')
            }
        }
    }
    $Tags = $Tags | Select-Object -Unique
    $Tags = $Tags | ? { $_ -notin $ExcludeTagList }
} else {
    $Tags = $IncludeTagList
}

$numItems = $tags.Count
$numBuckets = $Env:CIRCLE_NODE_TOTAL # Get Parallelism from CircleCI Environment

# declare CI Index Array. Tests will reference this to run correct tests
$CIindex = @()

$itemsPerBucket = [math]::Floor(($numItems / $numBuckets))
$remainder = ($numItems % $numBuckets)
$extra = 0
for ($i = 0; $i -lt $numBuckets; $i++) {
    <# Action that will repeat until the condition is met #>
    if ($i -eq ($numBuckets - 1)) {
        $extra = $remainder
    }
    $indexList = ($itemsPerBucket + $extra)
    # Write-Host "Container $i contains $indexList items:"
    $CIIndexList = @()
    $CIIndexList += for ($k = 0; $k -lt $indexList; $k++) {
        <# Action that will repeat until the condition is met #>
        $bucketIndex = $i * $itemsPerBucket
        # write-host "`$tags[$($bucketIndex + $k)] ="$tags[($bucketIndex + $k)]
        $tags[$bucketIndex + $k]
    }
    # add to ciIndex Array
    $CIindex += , ($CIIndexList)
}
# Tests returned here should be split for parallel runs:
return $CIindex[$Env:CIRCLE_NODE_INDEX]