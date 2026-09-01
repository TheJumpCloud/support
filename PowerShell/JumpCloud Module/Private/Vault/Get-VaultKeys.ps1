function Get-VaultKeys() {
    param(
        [Parameter(Mandatory=$true)]
        [string]$sufix
    )

    $plat = $env:CONSOLE_PLATFORM
    If($plat -eq "Windows") {
        # $username = $env:USERNAME.Trim().ToLower().Replace(" ", "_")
        try {
            # @() ensures a single matching credential is returned as a one-element array,
            # not an unwrapped string (which breaks Find-Interactive choice indexing).
            $keys = @([CredManager]::GetTargetList().Where({ $_.EndsWith($sufix) }))
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
        } | Select-Object -Unique | ForEach-Object { ,$_ }
    } ElseIf($plat -eq "Linux") {
        throw "Unsupported OS."
    } Else {
        throw "Unsupported OS."
    }

    $keys = @($keys | Where-Object { $null -ne $_ })
    if ($keys.Count -eq 0) {
        return $null
    }
    return $keys
}