function Show-StatusMessage {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter()]
        [System.String]
        $message
    )
    Write-Host "`r"
    write-host "[status] - $message"
    start-sleep 3
}