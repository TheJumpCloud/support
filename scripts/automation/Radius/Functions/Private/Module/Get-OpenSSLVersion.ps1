function Get-OpenSSLVersion {
    [CmdletBinding()]
    param (
        [Parameter()]
        [system.string]
        $opensslBinary
    )
    begin {
        $conditionsNotMet = $false
        try {
            $version = Invoke-Expression "& '$opensslBinary' version"
        } catch {
            Write-Error "Something went wrong... Could not find openssl or the path is incorrect. Please update the `$JCR_OPENSSL variable in the config.ps1 file to the correct path"
            $conditionsNotMet = $true
        }

        # Required OpenSSL Version
        $OpenSSLVersion = [version]"3.0.0"

        # Determine Libre or Open SSL:
        if ($version -match "LibreSSL") {
            Write-Error "LibreSSL does not meet the requirements of this application, please install OpenSSL v3.0.0 or later"
            $conditionsNotMet = $true
        } else {
            [version]$Version = (Select-String -InputObject $version -Pattern "([0-9]+)\.([0-9]+)\.([0-9]+)").matches.value
        }

        # Determine if windows:
        if ([System.Environment]::OSVersion.Platform -match "Win") {
            # If env variable exists, skip check for subsequent runs of ./config.ps1
            if ($env:OPENSSL_MODULES) {
                $binItems = Get-ChildItem -Path $env:OPENSSL_MODULES
                if ("legacy.dll" -notin $binItems.Name) {
                    Write-Error "The required OpenSSL 'legacy.dll' file was not found in the bin path $PathDirectory. This is required to create certificates. `nIf this module file is located elsewhere, you may specify the path to that directory in this powershell session using this command: '`$env:OPENSSL_MODULES = C:/Path/To/Directory' "
                    $conditionsNotMet = $true
                }
            } else {
                # Try to point to the Legacy.dll file
                Write-Error "The required OpenSSL 'legacy.dll' file is required for this project. This module file is required to create certificates. `nIf this module file is located elsewhere, you may specify the path to that directory in this powershell session using this command: '`$env:OPENSSL_MODULES = C:/Path/To/openSSL_Directory/' Where the legacy.dll file is in openSSL_Directory "
                $conditionsNotMet = $true

            }

        }
    }
    process {
        if ($version -lt $OpenSSLVersion) {
            Write-Error "The installed version of OpenSSL: OpenSSL $Version, does not meet the requirements of this application, please install a later version of at least $Type $Version"
            $conditionsNotMet = $true
        }
    }
    end {
        # Return false if the version is less than the required version
        if ($conditionsNotMet) {
            return $false
        } else {
            return $true
        }
    }
}