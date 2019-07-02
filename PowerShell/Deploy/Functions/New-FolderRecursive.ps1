
#Function to create a folder and any child folders
Function New-FolderRecursive
{
    [cmdletbinding(SupportsShouldProcess = $True)]
    Param(
        [string]$Path
        , [switch]$Force
    )
    $StartLocation = Get-Location
    $CurrentLocation = $StartLocation
    $PathPart = @()
    # Determin OS specific variables
    $WindowsDeliminator = '\'
    $UnixDeliminator = '/'
    $PathDeliminator = Switch ([environment]::OSVersion.Platform) { 'Win32NT' { $WindowsDeliminator }'Unix' { $UnixDeliminator } }
    $RegEx_ExcludePathDeliminator = ('[^\' + $WindowsDeliminator + '|\' + $UnixDeliminator + ']')
    $RegEx_IncludePathDeliminator = ('[\' + $WindowsDeliminator + '|\' + $UnixDeliminator + ']')
    # Normalize path deliminator based upon OS
    $NormalizedPath = $Path -replace ($RegEx_IncludePathDeliminator, $PathDeliminator)
    # Determine if the last part of the path contains a file extension
    If ( (Split-Path -Path:($NormalizedPath) -Leaf) -match '\.[a-zA-Z0-9]+$')
    {
        $NormalizedPath = Split-Path -Path:($NormalizedPath) -Parent
    }
    # Remove Deliminator from strings to do a comparison
    $NormalizedPath_NoDeliminator = $NormalizedPath -replace ($RegEx_IncludePathDeliminator, '')
    $CurrentLocation_NoDeliminator = $CurrentLocation -replace ($RegEx_IncludePathDeliminator, '')
    # If the current path is not in the path passed in then reset the current location
    If ( $NormalizedPath_NoDeliminator -notmatch $CurrentLocation_NoDeliminator) { Set-Location; $CurrentLocation = Get-Location; }
    # Remove the current location from the path so it does not get recreated
    $NormalizedPath = $NormalizedPath.Replace($CurrentLocation, '');
    # Split path into each folder
    $SplitFullPath = $NormalizedPath -split $RegEx_IncludePathDeliminator
    ForEach ( $Directory In $SplitFullPath | Where-Object { $_ -and $_ -notin ($WindowsDeliminator, $UnixDeliminator) } )
    {
        $PathPart += $Directory
        $NewPath = $PathPart -join $PathDeliminator
        If ( !( Test-Path -Path:($NewPath) ))
        {
            If ($Force)
            {
                New-Item -ItemType:('directory') -Path:($NewPath) -Force
            }
            Else
            {
                New-Item -ItemType:('directory') -Path:($NewPath)
            }
        }
    }
    # Reset the location back to where the script started
    Set-Location -Path:($StartLocation) | Out-Null
}