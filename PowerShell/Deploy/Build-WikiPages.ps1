. "$PSScriptRoot/Get-Config.ps1" -GitSourceRepo:('https://github.com/TheJumpCloud/support')
###########################################################################
Invoke-GitClone -Repo:($GitSourceRepoWiki)
$SupportRepoDocs = "$FolderPath_Module/Docs"
$SupportWiki = "$ScriptRoot/support.wiki"
If (!(Test-Path -Path:($SupportWiki))) { New-Item -Path:($SupportWiki) -ItemType:('Directory') }
Set-Location -Path:($SupportWiki)
$Docs = Get-ChildItem -Path:($SupportRepoDocs + '/*.md') -Recurse
ForEach ($Doc In $Docs) {
    $DocName = $Doc.Name
    $DocFullName = $Doc.FullName
    $SupportWikiDocFullName = $SupportWiki + '/' + $DocName
    $DocContent = Get-Content -Path:($DocFullName)
    $NewDocContent = If (($DocContent | Select-Object -First 1) -eq '---') {
        $DocContent | Select-Object -Skip:(7)
    } Else {
        $DocContent
    }
    If (Test-Path -Path:($SupportWikiDocFullName)) {
        $SupportWikiDocContent = Get-Content -Path:($SupportWikiDocFullName)
        $Diffs = Compare-Object -ReferenceObject:($NewDocContent) -DifferenceObject:($SupportWikiDocContent)
        If (-not [string]::IsNullOrEmpty($Diffs)) {
            Write-Warning -Message:('Diffs found in: ' + $DocName)
        }
    } Else {
        Write-Warning -Message:('Creating new file: ' + $DocName)
    }
    Set-Content -Path:($SupportWikiDocFullName) -Value:($NewDocContent) -Force
}
# Check in changes to support wiki
Invoke-GitCommit -BranchName:($GitSourceRepoWiki)