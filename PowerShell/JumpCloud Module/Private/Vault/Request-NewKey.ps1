function Request-NewKey() {
    param(
        [Parameter(Mandatory=$false)]
        [string]$sufix_
    )

    if (-not $PSBoundParameters.ContainsKey('sufix_')) {
        $sufix_ = if ($script:sufix) { $script:sufix } else { '.api.jc' }
    }
    $apiKey = [System.Net.NetworkCredential]::new("", (Read-Host -Prompt "Type the api key" -AsSecureString)).Password
    if ([string]::IsNullOrWhiteSpace($apiKey)) {
        throw "API key cannot be empty."
    }
    $temp_key = Read-Host -Prompt "Type the name to be saved"
    if ([string]::IsNullOrWhiteSpace($temp_key)) {
        throw "Key name cannot be empty."
    }
    
    if (-not (Confirm-Console -Message "Do you want to save the key to the vault?" -YesAction {
        Set-ToVault -Value $apiKey -Key $temp_key -sufix $sufix_
    })) {
        Clear-Console -LinesToClear 2
        return $apiKey
    } 
    Clear-Console -LinesToClear 2
}
