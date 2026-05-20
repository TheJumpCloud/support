# Remove a key from the vault based on the provided key name
function Remove-FromVault() {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Key
    )

    $plat = $env:CONSOLE_PLATFORM
    if ($plat -eq "MacOS") {
        try {
            security delete-generic-password -s $Key 2>$null
            if ($LASTEXITCODE -ne 0) {
                throw "Failed to delete key from Keychain."
            }
        } catch {
            Write-Host "Error deleting key from Keychain: $_" -ForegroundColor Red
        }
    } elseif ($plat -eq "Windows") {
        try {
            cmdkey /delete:($Key) 2>$null
            if ($LASTEXITCODE -ne 0) {
                throw "Failed to delete key from Credential Manager."
            }
        } catch {
            throw "Error deleting key from Credential Manager: $_"
        }
    } else {
        throw "Unsupported OS."
    }
}