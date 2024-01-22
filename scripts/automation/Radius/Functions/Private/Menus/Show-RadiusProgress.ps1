Function Show-RadiusProgress {
    param(
        [int]$completedItems,
        [int]$totalItems,
        [string]$actionText,
        [System.Object]$previousOperationResult
    )

    $propertyNames = @($previousOperationResult.keys)
    $propertyNames += "Items Processed"
    $headerString = "{0,-$($($propertyNames[0]).length)}"

    for ($i = 1; $i -lt $propertyNames.Count; $i++) {
        $headerString += " | {$i,-$($($propertyNames[$i]).length)}"
    }
    if ($completedItems -eq 1) {
        Write-Host $(PadCenter -string " results " -char '-')
        write-host ($headerString -f $propertyNames)
        $propertyvalues = @($previousOperationResult.Values)
        $propertyvalues += "$($completedItems) / $($TotalItems)"

    } else {
        $propertyvalues = @($previousOperationResult.Values)
        $propertyvalues += "$($completedItems) / $($TotalItems)"

    }

    write-host ($headerString -f $propertyValues)
    if ($completedItems -eq $totalItems) {
        Write-Host $(PadCenter -string "" -char '-')
    }

}
