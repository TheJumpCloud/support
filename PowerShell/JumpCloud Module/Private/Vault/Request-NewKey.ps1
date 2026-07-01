function Request-NewKey() {
    param(
        [Parameter(Mandatory=$false)]
        [string]$sufix_
    )

    if (-not $PSBoundParameters.ContainsKey('sufix_')) {
        $sufix_ = if ($script:sufix) { $script:sufix } else { '.api.jc' }
    }
    Set-ToVault -Value (
        [System.Net.NetworkCredential]::new("", (Read-Host -Prompt "Type the api key" -AsSecureString)).Password
    ) -Key (
        Read-Host -Prompt "Type the name to be saved"
    ) -sufix $sufix_
    Clear-Console -LinesToClear 2
}
