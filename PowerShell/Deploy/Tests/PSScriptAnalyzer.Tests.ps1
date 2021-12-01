. ((Get-Item -Path:($PSScriptRoot)).Parent.FullName + '/' + 'Get-Config.ps1')
###########################################################################
Write-Host ('[status]Running PSScriptAnalyzer on: ' + $FolderPath_Module)
$ScriptAnalyzerResults = Invoke-ScriptAnalyzer -Path:($FolderPath_Module) -Recurse
If ($ScriptAnalyzerResults)
{
    $ScriptAnalyzerResults
    Write-Error ('Go fix the ScriptAnalyzer results!')
}
Else
{
    Write-Host ('[success]ScriptAnalyzer returned no results')
}