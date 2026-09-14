function Request-Key {
    param (
        [Parameter(Mandatory=$false)]
        [string]$vaultKey
    )
    $foundKey = Get-KeyFromVault -Key $vaultKey

    if("" -eq $foundKey -or $null -eq $foundKey) {
        Write-Host "Aborted. Exiting." -ForegroundColor Yellow
        throw "No key selected"
    } else {
        return $foundKey
    }
}