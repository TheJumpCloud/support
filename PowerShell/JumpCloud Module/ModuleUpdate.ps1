# Populate if you want to exclude files from help file creation
$ExcludeList = @('')
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
# # Clear out existing docs
# Remove-Item -Path:($FolderPath_Docs) -Recurse -Force
# Remove-Item -Path:($FolderPath_enUS) -Recurse -Force
# Create/update markdown help files using platyPS
Write-Host ('[status]Creating/Updating help files')
(Get-ChildItem -Path:($FolderPath_Public) -File -Recurse) | Where-Object { $_.Extension -eq '.ps1' -and $_.BaseName -notin $ExcludeList } | ForEach-Object {
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

# ##TODO
# ### Add step check out support wiki
# $PathToSupportWikiRepo = ''
# $SupportRepoDocs = $PSScriptRoot + '/Docs'
# $SupportWiki = $PathToSupportWikiRepo + '/support.wiki'
# $Docs = Get-ChildItem -Path:($SupportRepoDocs + '/*.md') -Recurse
# ForEach ($Doc In $Docs)
# {
#     $DocName = $Doc.Name
#     $DocFullName = $Doc.FullName
#     $SupportWikiDocFullName = $SupportWiki + '/' + $DocName
#     $DocContent = Get-Content -Path:($DocFullName)
#     If (Test-Path -Path:($SupportWikiDocFullName))
#     {
#         $SupportWikiDocContent = Get-Content -Path:($SupportWikiDocFullName)
#         $Diffs = Compare-Object -ReferenceObject:($DocContent) -DifferenceObject:($SupportWikiDocContent)
#         If ($Diffs)
#         {
#             Write-Warning -Message:('Diffs found in: ' + $DocName)
#             # are you sure you want to continue?
#         }
#     }
#     Else
#     {
#         Write-Warning -Message:('Creating new file: ' + $DocName)
#     }
#     $NewDocContent = If (($DocContent | Select-Object -First 1) -eq '---')
#     {
#         $DocContent | Select-Object -Skip:(7)
#     }
#     Else
#     {
#         $DocContent
#     }
#     Set-Content -Path:($SupportWikiDocFullName) -Value:($NewDocContent) -Force
# }
# ### Add step check in changes to support wiki