. ($PSScriptRoot + '/' + 'Get-Config.ps1')
###########################################################################
$CurrentLocation = Get-Location
Set-Location -Path:($StagingDirectory)
Invoke-GitClone -Repo:($GitSourceRepoWiki)

### Add step check out support wiki
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

Set-Location -Path:($CurrentLocation)