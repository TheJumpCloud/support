function Write-WrappedHost {
    param (
        [string]$Text,
        [ConsoleColor]$ForegroundColor,
        [switch]$Indent
    )
    $maxWidth = 120
    $width = [Math]::Min($host.UI.RawUI.WindowSize.Width, $maxWidth)
    $indentSize = if ($Indent) { 4 } else { 0 }
    $indentStr = ' ' * $indentSize
    $lines = ($Text -split "(`n)")
    foreach ($line in $lines) {
        $first = $true
        while ($line.Length -gt ($width - ($first -and $Indent ? $indentSize : 0))) {
            if ($first -and $Indent) {
                $chunk = $line.Substring(0, $width - $indentSize)
                $chunk = "$indentStr$chunk"
                $line = $line.Substring($width - $indentSize)
                $first = $false
            } else {
                $chunk = $line.Substring(0, $width)
                $line = $line.Substring($width)
            }
            if ($ForegroundColor) {
                Write-Host $chunk -ForegroundColor $ForegroundColor
            } else {
                Write-Host $chunk
            }
        }
        if ($ForegroundColor) {
            if ($first -and $Indent) {
                Write-Host ("$indentStr$line") -ForegroundColor $ForegroundColor
            } else {
                Write-Host $line -ForegroundColor $ForegroundColor
            }
        } else {
            if ($first -and $Indent) {
                Write-Host "$indentStr$line"
            } else {
                Write-Host $line
            }
        }
    }
}