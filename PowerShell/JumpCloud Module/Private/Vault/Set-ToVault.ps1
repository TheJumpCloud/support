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
            security add-generic-password -a $env:USER -s ($key_+$sufix) -w $value -T "" 2>$null
            if ($LASTEXITCODE -ne 0) {
                throw "Failed to add key to Keychain."
            }
        } catch {
            Write-Host "Error adding key to Keychain: $_" -ForegroundColor Red
        }
    } elseif ($plat -eq "Windows") {
        try {
            cmdkey /generic:($key_+$sufix) /user:($env:USERNAME) /pass:$value 2>$null
            if ($LASTEXITCODE -ne 0) {
                throw "Failed to add key to Credential Manager."
            }
        } catch {
            throw "Error adding key to Credential Manager: $_"
        }
    } else {
        throw "Unsupported OS."
    }
}