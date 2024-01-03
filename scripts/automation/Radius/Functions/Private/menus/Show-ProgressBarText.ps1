Function Show-ProgressBarText {
    param(
        [int]$completedItems,
        [int]$totalItems,
        [string]$actionText
    )
    $pComplete = ($completedItems / $totalItems) * 100
    $barLength = [math]::Ceiling((($pComplete / 100)) * 30)

    $pbar = "[" + ('▯' * $barLength) + (' ' * (30 - $barLength)) + "]"
    $pmessage = "${actionText}: $completedItems out of $TotalItems ($pComplete%) $pbar"
    Write-Host $pmessage -NoNewline
}