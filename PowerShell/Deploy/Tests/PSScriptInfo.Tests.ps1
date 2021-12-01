. ((Get-Item -Path:($PSScriptRoot)).Parent.FullName + '/' + 'Get-Config.ps1')
###########################################################################
$ScriptFileInfoResults = Get-ChildItem -Path:($FolderPath_Public) -Recurse -File | ForEach-Object { Test-ScriptFileInfo -Path:($_.FullName) -ErrorAction:('Ignore') }
If ($ScriptFileInfoResults)
{
    $ScriptFileInfoResults
    Write-Error ('Go fix the ScriptFileInfo results!')
}
Else
{
    Write-Host ('[success]ScriptFileInfo returned no results')
}