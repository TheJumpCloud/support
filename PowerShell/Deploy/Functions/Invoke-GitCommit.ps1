Function Invoke-GitCommit
{
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][string]$BranchName
    )
    # Logging
    $MyName = $MyInvocation.MyCommand.Name
    $ParentScriptName = (Get-PSCallStack | Where-Object { $_.Command -notin ($MyName, $MyName.Replace('.ps1', '')) }).Command -join ','
    $CommitMessage = 'Push to ' + $BranchName + '; Called by:' + $ParentScriptName + ';[skip ci]'
    $UserEmail = 'AzurePipelines@FakeEmail.com'
    $UserName = 'AzurePipelines'
    Invoke-Git -Arguments:('config user.email "' + $UserEmail + '";')
    Invoke-Git -Arguments:('config user.name "' + $UserName + '";')
    Invoke-Git -Arguments:('add -A;')
    Invoke-Git -Arguments:('status;')
    Invoke-Git -Arguments:('commit -m ' + '"' + $CommitMessage + '";')
    Invoke-Git -Arguments:('push origin HEAD:refs/heads/' + $BranchName + ';')
}