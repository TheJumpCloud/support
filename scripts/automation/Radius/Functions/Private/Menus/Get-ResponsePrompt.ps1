function Get-ResponsePrompt {
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = "The message prompt to display to the console", Mandatory)]
        [System.String]
        $message,
        [Parameter(HelpMessage = "Change messaging if running in CLI")]
        [System.Boolean]
        $cli = $false
    )


    $promptForInvokeInput = $true
    while ($promptForInvokeInput) {
        if ($cli) {
            $invokeCommands = Read-Host "$message`nPlease type: 'y'/'n' (or 'E' to exit)"
        } else {
            $invokeCommands = Read-Host "$message`nPlease type: 'y'/'n' (or 'E' to return to Main Menu)"
        }
        switch ($invokeCommands) {
            'e' {
                if ($cli) {
                    Write-Host "Exiting..."
                } else {
                    Write-Host "Returning to Main Menu..."
                }
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
                write-host "Invalid input`nPlease type 'y'/ 'n' (or 'E' to exit)"
            }
        }
    }
}