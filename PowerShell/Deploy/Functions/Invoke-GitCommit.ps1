Function Global:Invoke-GitCommit{
    param (
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][string]$BranchName
    )
    If ($BranchName -like 'refs/*/merge')
    {
        Write-Warning  ('Skipping commit because branch matched "merge": ' + $BranchName)
    }
    Else
    {
        #Logging
        $CommitMessage = 'Push to ' + $BranchName + ';[skip ci]'
        $UserEmail = 'CircleCI@FakeEmail.com'
        $UserName = 'CircleCI'
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
        Invoke-Git -Arguments:('config user.email "' + $UserEmail + '";')
        Invoke-Git -Arguments:('config user.name "' + $UserName + '";')
        Invoke-Git -Arguments:('add -A;')
        Invoke-Git -Arguments:('status;')
        Invoke-Git -Arguments:('remote;')
        Invoke-Git -Arguments:('commit -m ' + '"' + $CommitMessage + '";')
        Invoke-Git -Arguments:('push origin HEAD:refs/heads/' + $BranchName + ' --dry-run' + ';')
    }
}