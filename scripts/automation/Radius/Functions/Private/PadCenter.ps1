function PadCenter {
    param (
        [string]$string,
        [char]$char
    )
    $length = $host.ui.rawui.windowsize.width
    $spaces = $length - $string.Length
    $padLeft = $spaces / 2 + $string.Length
    return $string.PadLeft($padLeft, $char).PadRight($length, $char)
}