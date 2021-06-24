Function Write-Rainbow
{
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, Position = 0, HelpMessage = 'String to display.')][System.String]$String
        , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName, Position = 1, HelpMessage = 'List of foreground colors.')][System.String[]]$foregroundColor = ([enum]::GetValues([System.ConsoleColor]))
        , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName, Position = 2, HelpMessage = 'List of background colors.')][System.String[]]$backgroundColor = 'Black' #([enum]::GetValues([System.ConsoleColor]))
    )
    $count = 0
    while ($count -le $string.Length)
    {
        # [System.Console]::BackgroundColor = $backgroundColor | Get-Random
        # [System.Console]::ForegroundColor = $foregroundColor | Get-Random
        $HostForegroundColor = $foregroundColor | Get-Random
        $HostBackgroundColor = $backgroundColor | Get-Random
        if ($string[$count] -eq ' ')
        {
            Write-Host ($string[$count]) -NoNewline
        }
        elseif ($count -eq $string.Length)
        {
            Write-Host ($string[$count]) -backgroundColor:($HostBackgroundColor) -foregroundColor:($HostForegroundColor)
            Write-Host ('')
        }
        else
        {
            Write-Host ($string[$count]) -backgroundColor:($HostBackgroundColor) -foregroundColor:($HostForegroundColor) -NoNewline
        }
        $count ++
    }
}