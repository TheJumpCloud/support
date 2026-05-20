# Clear a specified number of lines from the console
function Clear-Console {
    param(
        [Parameter(Mandatory=$true)]
        [int]$LinesToClear
    )
    $currentLine = $Host.UI.RawUI.CursorPosition.Y
    $bufferWidth = $Host.UI.RawUI.BufferSize.Width
    $startLine = $currentLine - $LinesToClear
    if ($startLine -lt 0) { $startLine = 0 }
    
    for ($i = $startLine; $i -le $currentLine; $i++) {
        [Console]::SetCursorPosition(0, $i)
        [Console]::Write(" " * $bufferWidth)
    }
    [Console]::SetCursorPosition(0, $startLine)
}