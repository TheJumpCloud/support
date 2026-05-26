function Request-NewKey() {
    param(
        [Parameter(Mandatory=$false)]
        [string]$sufix_ = "api.jc"
    )
    Set-ToVault -Value (
        [System.Net.NetworkCredential]::new("", (Read-Host -Prompt "Type the api key" -AsSecureString)).Password
    ) -Key (
        Read-Host -Prompt "Type the name to be saved"
    ) -sufix $sufix_
    $LinesToClear = $keys.Count + 2
    Clear-Console -LinesToClear $LinesToClear
}
