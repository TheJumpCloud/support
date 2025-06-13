function Get-CaseInsensitiveFile {
    param (
        [Parameter(Mandatory)]
        [string]$Directory,
        [Parameter(Mandatory)]
        [string]$FileName
    )
    $file = Get-ChildItem -Path $Directory -File | Where-Object { $_.Name -ieq $FileName } | Select-Object -First 1
    if ($file) { return $file.FullName }
    else { return (Join-Path $Directory $FileName) } # If not found, return the intended path for creation
}