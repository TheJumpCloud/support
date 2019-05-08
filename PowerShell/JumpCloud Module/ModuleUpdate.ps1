# Issues with Add-JCRadiusReplyAttribute and Set-JCRadiusReplyAttribute
$ExcludeList = @('Add-JCRadiusReplyAttribute', 'Set-JCRadiusReplyAttribute')

# Define path variables
$ModulePath = $PSScriptRoot
$FilePath_Psd1 = $ModulePath + '/JumpCloud.psd1'
$FolderPath_Public = $ModulePath + '/Public'
$FolderPath_Docs = $ModulePath + '/Docs'
$FolderPath_enUS = $ModulePath + '/en-Us'
$GitHubWikiUrl = 'https://github.com/TheJumpCloud/support/wiki/'

# Import required modules
Write-Host ('[status]Importing current module: ' + $ModuleName)
Import-Module ($FilePath_Psd1) -Force
Write-Host ('[status]Installing module: PlatyPS')
Install-Module -Name:('PlatyPS') -Force -Scope:('CurrentUser')

# Create/update markdown help files using platyPS
Write-Host ('[status]Creating/Updating help files')
(Get-ChildItem -Path:($FolderPath_Public) -File -Recurse) | Where-Object {$_.Extension -eq '.ps1' -and $_.BaseName -notin $ExcludeList} | ForEach-Object {
    $FunctionName = $_.BaseName
    $FilePath_Md = $FolderPath_Docs + '/' + $FunctionName + '.md'
    If (Test-Path -Path:($FilePath_Md))
    {
        # Write-Host ('Updating: ' + $FunctionName + '.md')
        Update-MarkdownHelp -Path:($FilePath_Md) -Force -ExcludeDontShow -UpdateInputOutput
    }
    Else
    {
        # Write-Host ('Creating: ' + $FunctionName + '.md')
        New-MarkdownHelp  -Command:($FunctionName) -OutputFolder:($FolderPath_Docs) -Force  -ExcludeDontShow -OnlineVersionUrl:($GitHubWikiUrl + $FunctionName)
    }
}

# Create new ExternalHelp file.
Write-Host ('[status]Creating new external help file')
New-ExternalHelp -Path:($FolderPath_Docs) -OutputPath:($FolderPath_enUS) -Force

# Create online versions of the help files in the support.wiki
# Update docs with links to the online docs for 'Get-Help -online' commands
