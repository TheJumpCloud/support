# Helper function to extract a subject header value from a subject string
function Get-SubjectHeaderValue {
    param (
        [Parameter(Mandatory)]
        [string]$SubjectString,
        [Parameter(Mandatory)]
        [string]$Header
    )
    # Regex: match key, optional spaces, '=', optional spaces, then capture value up to next comma or end
    $pattern = "$Header\s*=\s*([^,]+)"
    if ($SubjectString -match $pattern) {
        return $Matches[1].Trim()
    }
    return $null
}