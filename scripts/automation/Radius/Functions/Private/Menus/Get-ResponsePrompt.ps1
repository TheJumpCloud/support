function Get-ResponsePrompt {
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = "The message prompt to display to the console", Mandatory)]
        [System.String]
        $message
    )


    $promptForInvokeInput = $true
    while ($promptForInvokeInput) {
        $invokeCommands = Read-Host "$message`nPlease type: 'y'/'n' (or 'E' to return to menu)"
        switch ($invokeCommands) {
            'e' {
                Write-Host "Returning to Main Menu..."
                $promptForInvokeInput = $false
                return 'exit'
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