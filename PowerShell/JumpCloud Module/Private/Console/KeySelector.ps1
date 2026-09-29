function KeySelector {
    param(
        [Parameter(Mandatory=$false)]
        [string]$keyName
    )
    Unlock-Platform
    if(-not [System.String]::IsNullOrEmpty($keyName)) {
        return Request-Key -vaultKey $keyName
    }

    $sufix_ = $script:sufix
    $keys = Get-VaultKeys -sufix $sufix_
    if(($null -eq $keys) -or ($keys.Count -eq 0)) {
        Write-Host "No keys found in the vault. Please add a new key." -ForegroundColor Yellow
        $tempKey =Request-NewKey -sufix $sufix_
        if($tempKey) {
            Clear-Console -LinesToClear 1
            return $tempKey 
        }

        Clear-Console -LinesToClear 1
        $keys = Get-VaultKeys -sufix $sufix_
    }

    Write-Host "Select the JumpCloud Api Key. Press [Escape] to type a new key. Press [Backspace] to remove the selected key" -ForegroundColor Green
    # Stays in selection loop until user selects a key or abort.
    while (@($false, $null) -contains ($vaultKey = Find-Interactive -choices $keys -Callback {
        param($param)
        return Confirm-Console -Message "Selected key: $param. Are you sure want to remove this key from vault?" -YesAction { Remove-FromVault -Key $param }
    })) {
        $keys = Get-VaultKeys -sufix $sufix_
        if (($null -eq $vaultKey) -or ($null -eq $keys) -or ($keys.Count -eq 0)) {
            $linesToClear = 0
            if ($keys.Count -eq 0) {
                Write-Host "No keys found in vault. Please add a new key." -ForegroundColor Yellow
                $linesToClear += 1
            } else {
                $linesToClear = $keys.Count
            }
            $tempKey =Request-NewKey -sufix $sufix_
            if($tempKey) {
                Clear-Console -LinesToClear ($linesToClear + 1)
                return $tempKey 
            }

            # Lines are cleared after, because the user can see the names of already existing keys
            Clear-Console -LinesToClear $linesToClear
        }
        $keys = Get-VaultKeys -sufix $sufix_
    }

    # $vaultKey is being declared above as the output of Find-Interactive, so it will be available here for
    $foundKey = Request-Key -vaultKey $vaultKey

    Clear-Console -LinesToClear 1
    return $foundKey
}
