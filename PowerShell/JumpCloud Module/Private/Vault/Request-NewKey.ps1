function Request-NewKey() {
    Set-ToVault -Value (
        [System.Net.NetworkCredential]::new("", (Read-Host -Prompt "Type the api key" -AsSecureString)).Password
    ) -Key (
        Read-Host -Prompt "Type the name to be saved"
    ) -sufix $sufix_
    $plat = $env:CONSOLE_PLATFORM
    if($plat -eq "Windows") {
        $LinesToClear = $keys.Count + 4
    } elseIf($plat -eq "MacOS") {
        $LinesToClear = $keys.Count + 2
    } elseIf($plat -eq "Linux") {
        throw "Unsupported OS."
    } else {
        throw "Unsupported OS."
    }
    Clear-Console -LinesToClear $LinesToClear
}
