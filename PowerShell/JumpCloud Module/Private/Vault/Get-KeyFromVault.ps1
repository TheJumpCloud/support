# Retrieve a key from the vault based on the provided key name
function Get-KeyFromVault() {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Key
    )
    $plat = $env:CONSOLE_PLATFORM
    Unlock-Platform
    if ($plat -eq "MacOS") {
        $serviceKey = security find-generic-password -s $Key -w
        if ($LASTEXITCODE -ne 0) {
            return $null
        }
    } elseif ($plat -eq "Windows") {
        $serviceKey = [CredManager]::GetCreds($Key)
    } else {
        throw "Unsupported OS."
    }

    Write-Host "Retrieved key from Credential Manager: $key" -ForegroundColor Green
    return $serviceKey
}