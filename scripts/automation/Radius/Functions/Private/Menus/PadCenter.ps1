function PadCenter {
    param (
        [string]$string,
        [char]$char
    )
    $maxlength = 120
    $length = $host.ui.rawui.windowsize.width
    if ($length -gt $maxlength) {
        $length = $maxlength
    }
    $spaces = $length - $string.Length
    $padLeft = $spaces / 2 + $string.Length
    return $string.PadLeft($padLeft, $char).PadRight($length, $char)
}