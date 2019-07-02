. ($PSScriptRoot + '/' + 'Get-Config.ps1')
###########################################################################
Write-Host ('[status]Publishing to PowerShell Gallery:' + $FolderPath_Module)
Publish-Module -Path:($FolderPath_Module) -NuGetApiKey:($NUGETAPIKEY)