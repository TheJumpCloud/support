# Interactive function to display choices and handle user input for selection
function Find-Interactive() {
    param (
        [string[]]$choices,
        [scriptblock]$Callback
    )
    $index = 0
    $running = $true
    $trigger = $false
    [Console]::CursorVisible = $false
    while ($running) {
        for ($i = 0; $i -lt $choices.Count; $i++) {
            if ($i -eq $index) {
                Write-Host " > $($choices[$i])" -ForegroundColor Cyan -BackgroundColor DarkGray
            } else {
                Write-Host "   $($choices[$i])"
            }
        }
        $key = [Console]::ReadKey($true)
        switch ($key.Key) {
            'UpArrow'               { $index = if ($index -gt 0) { $index - 1 } else { $choices.Count - 1 } }
            'DownArrow'             { $index = if ($index -lt $choices.Count - 1) { $index + 1 } else { 0 } }
            'Enter'                 { $running = $false ; $trigger = $false;}
            'Backspace'             { if($Callback) { $running = $false; $trigger = $true; } }
            'Escape'                { [Console]::CursorVisible = $true; return $null }
        }
        [Console]::SetCursorPosition(0, [Console]::CursorTop - ($choices.Count))
    }
    [Console]::CursorVisible = $true
    # Clear the choices from the console
    for ($i = 0; $i -lt $choices.Count; $i++) {
        Write-Host (" " * ([Console]::WindowWidth - 1))
    }
    [Console]::SetCursorPosition(0, [Console]::CursorTop - ($choices.Count))
    if($trigger -and $Callback) {
        $temp = Invoke-Command -ScriptBlock $Callback -ArgumentList $choices[$index]
        return $false
    }
    return $choices[$index]
}