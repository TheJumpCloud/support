# Aux functions for interactive behavior and vault management
function Set-ToVault() {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Key,
        [Parameter(Mandatory=$false)]
        [string]$sufix,
        [Parameter(Mandatory=$true)]
        [string]$Value
    )
    if(!$sufix) {
        $sufix = ""
    }
    $key_ = $Key.ToLower().Replace(" ", "_").Trim()
    $plat = $env:CONSOLE_PLATFORM
    $value = $Value.Trim()
    if ($plat -eq "MacOS") {
        try {
            # Not necessary to use same approach as MacOs
            # MacOs is safe to use security command as above
            security add-generic-password -a $env:USER -s ($key_+$sufix) -w $value -T "" 2>$null
            if ($LASTEXITCODE -ne 0) {
                throw "Failed to add key to Keychain."
            }
        } catch {
            throw "Error adding key to Keychain: $_"
        }
    } elseif ($plat -eq "Windows") {
        try {
            Unlock-Platform
            [CredManager]::SetCreds(($key_ + $sufix), $env:USERNAME, $value)
        } catch {
            throw "Error adding key to Credential Manager: $_"
        }
    } else {
        throw "Unsupported OS."
    }
}