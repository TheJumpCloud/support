function Get-VaultKeys() {
    param(
        [Parameter(Mandatory=$true)]
        [string]$sufix
    )

    $plat = $env:CONSOLE_PLATFORM
    If($plat -eq "Windows") {
        $username = $env:USERNAME.Trim().ToLower().Replace(" ", "_")
        try {
            $keys = [CredManager]::GetTargetList().Where({ $_.EndsWith($sufix) })
        } catch {
            Write-Host "Error retrieving keys: $_" -ForegroundColor Red
            return $null
        }
    } ElseIf($plat -eq "MacOS") {
        $keys = security dump-keychain | ForEach-Object {
            if ($_ -match '0x00000007\s+<blob>="(.+?)"' -or $_ -match '"svce"<.+?>="(.+?'+$sufix+')"') {
                $found = $matches[1]
                if ($found.EndsWith($sufix)){return $found}
            }
        } | Select-Object -Unique
    } ElseIf($plat -eq "Linux") {
        throw "Unsupported OS."
    } Else {
        throw "Unsupported OS."
    }

    return $keys
}