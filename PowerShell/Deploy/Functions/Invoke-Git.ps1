Function Invoke-Git
{
    Param($Arguments)
    If ([environment]::OSVersion.Platform -eq 'Win32NT') { $env:GIT_REDIRECT_STDERR = '2>&1' }
    $LASTEXITCODE = 0
    $Error.Clear()
    $Command = 'git ' + $Arguments
    Write-Host ('[GitCommand]' + $Command)
    Invoke-Expression -Command:($Command)
    If ($LASTEXITCODE)
    {
        Throw ('Git error, $LASTEXITCODE: ' + $LASTEXITCODE)
    }
    If ($Error)
    {
        Throw ('Git error, $Error: ' + $Error)
    }
}