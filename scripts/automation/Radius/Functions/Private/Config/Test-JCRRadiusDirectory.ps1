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