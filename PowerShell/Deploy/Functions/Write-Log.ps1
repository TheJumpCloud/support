#Function to log information/error in console and file
Function Write-Log
{
    Param(
        [Parameter(Mandatory = $true, Position = 0)][ValidateNotNullOrEmpty()]$Message,
        [Parameter(Mandatory = $false, Position = 1)][ValidateNotNullOrEmpty()] [string]$color = 'Gray',
        [Parameter(Mandatory = $false, Position = 2)][ValidateNotNullOrEmpty()] [bool]$showInConsole = $true,
        [Parameter(Mandatory = $false, Position = 3)][ValidateNotNullOrEmpty()] [bool]$exitInd = $false
    )
    $Error = ''
    If ($color.ToLower() -eq 'Red')
    {
        $Error = "[ERROR]"
    }
    If ($color.ToLower() -eq 'Yellow')
    {
        $Error = "[WARNING]"
    }
    If ($showInConsole -eq $true)
    {
        $CurrentVerbosePreference = $VerbosePreference
        $VerbosePreference = "Continue"
        $HostInfo = Get-Host
        If ($HostInfo.Name -notin ('Default Host', 'ServerRemoteHost'))
        {
            $VerboseForegroundColorOrg = $HostInfo.PrivateData.VerboseForegroundColor
            $HostInfo.PrivateData.VerboseForegroundColor = $color
        }
        Write-Verbose ("`r`n" + $Error + $Message)
        If ($HostInfo.Name -notin ('Default Host', 'ServerRemoteHost'))
        {
            $HostInfo.PrivateData.VerboseForegroundColor = $VerboseForegroundColorOrg
        }
        $VerbosePreference = $CurrentVerbosePreference
    }
    If ($exitInd)
    {
        $Error = "[EXITING SCRIPT]"
        If ($LogFullPath)
        {
            ($Error + $Message) | Out-File -FilePath:($LogFullPath) -Append -ErrorAction:($ErrorActionPreference) -WhatIf:($WhatIfPreference)
        }
        Write-Error ($Error + $Message)
        Break
    }
    Else
    {
        If ($LogFullPath)
        {
            ($Error + $Message) | Out-File -FilePath:($LogFullPath) -Append -ErrorAction:($ErrorActionPreference) -WhatIf:($WhatIfPreference)
        }
    }
}