function Test-JCRRadiusDirectory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    # Resolve the full path
    $resolvedPath = Resolve-Path -Path $Path -ErrorAction SilentlyContinue

    if (-not $resolvedPath) {
        Write-Error "The path '$Path' does not exist."
        return $false
    }

    if (-not (Test-Path -Path $resolvedPath -PathType Container)) {
        Write-Error "The path '$resolvedPath' is not a directory."
        return $false
    }

    # validate that the $resolvedPath is not the same as the JCRScriptRoot
    # Write-Warning "Resolved path: $resolvedPath | JCRScriptRoot: $global:JCRScriptRoot"
    if ("$resolvedPath" -eq $($global:JCRScriptRoot)) {
        Write-Error "The path '$resolvedPath' cannot be the same as the JCRScriptRoot. This could lead to certificate data loss if the module is updated or reinstalled. Please set the 'RadiusDirectory' to different directory.`nSet-JCRConfig -RadiusDirectory '<Path/To/radiusDirectory>'"
        return $false
    }

    $certDir = Join-Path $resolvedPath "Cert"
    $userCertsDir = Join-Path $resolvedPath "UserCerts"

    $certExists = Test-Path -Path $certDir -PathType Container
    $userCertsExists = Test-Path -Path $userCertsDir -PathType Container

    if (-not $certExists) {
        Write-Host "The directory 'Cert' does not exist in '$resolvedPath'."
        # create the directory if it does not exist
        New-Item -Path $certDir -ItemType Directory | Out-Null
        Write-Host "Created directory 'Cert' in '$resolvedPath'."
    }
    if (-not $userCertsExists) {
        Write-Host "The directory 'UserCerts' does not exist in '$resolvedPath'."
        # create the directory if it does not exist
        New-Item -Path $userCertsDir -ItemType Directory | Out-Null
        Write-Host "Created directory 'UserCerts' in '$resolvedPath'."
    }

    return $true
}