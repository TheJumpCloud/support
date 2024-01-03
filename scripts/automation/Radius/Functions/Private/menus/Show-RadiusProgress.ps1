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
        <# Action that will repeat until the condition is met #>
        $headerString += " | {$i,-$($($propertyNames[$i]).length)}"
    }
    if ($completedItems -eq 1) {
        write-host ($headerString -f $propertyNames)
        $propertyvalues = @($previousOperationResult.Values)
        $propertyvalues += "$($completedItems) / $($TotalItems)"

    } else {
        $propertyvalues = @($previousOperationResult.Values)
        $propertyvalues += "$($completedItems) / $($TotalItems)"

    }

    write-host ($headerString -f $propertyValues)

}
