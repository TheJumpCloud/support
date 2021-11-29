Function Global:Invoke-GitClone
{
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][string]$Repo
    )
    # Logging
    $MyName = $MyInvocation.MyCommand.Name
    $ParentScriptName = (Get-PSCallStack | Where-Object { $_.Command -notin ($MyName, $MyName.Replace('.ps1', '')) }).Command -join ','
    $UserEmail = 'AzurePipelines@FakeEmail.com'
    $UserName = 'AzurePipelines'
    Invoke-Git -Arguments:('config user.email "' + $UserEmail + '";')
    Invoke-Git -Arguments:('config user.name "' + $UserName + '";')
    Invoke-Git -Arguments:('clone ' + $Repo + ';')
    Invoke-Git -Arguments:('status;')
}