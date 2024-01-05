function Get-ResponsePrompt {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.String]
        $message
    )


    $promptForInvokeInput = $true
    while ($promptForInvokeInput) {
        $invokeCommands = Read-Host "$message`nPlease type: 'y'/'n' (or 'E' to return to menu)"
        switch ($invokeCommands) {
            'e' {
                $promptForInvokeInput = $false
                break
            }
            'n' {
                return $false
            }
            'y' {
                return $true
            }
            default {
                write-host "Invalid input`nPlease type 'y'/ 'n' (or 'E' to return to menu)"
            }
        }
    }
}