Function Get-ModuleChangeLog
{
    Param(
        $ModuleChangeLogUrl = 'https://git.io/jc-pwsh-releasenotes'
        https://github.com/TheJumpCloud/support/blob/JumpCloudModule_1.14.0/PowerShell/ModuleChangelog.md
    )
    # Update security protocol
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls, [System.Net.SecurityProtocolType]::Tls12
    # Build output object
    $OutputObject = @()
    # Define expected Headers to find
    $ReleaseNotes_Headers = @('RELEASE DATE', 'RELEASE NOTES', 'FEATURES', 'IMPROVEMENTS', 'BUG FIXES')
    # Define regex patterns
    [regex]$Regex_HtmlTags = '(<)(.*?)(>)'
    [regex]$Regex_Article = '(?is)(?<=<article class="markdown-body entry-content p-3 p-md-6" itemprop="text">)(.*?)(?=<\/article>)'
    [regex]$Regex_H4_Start = '<h4>'
    [regex]$Regex_H4_Content = '(?is)(?<=<\/a>)(.*?)(?=<\/h4>)'
    [regex]$Regex_H4_Body = '(?is)(?<=<\/h4>)(.*?)($)'
    [regex]$Regex_H2_Start = '<h2>'
    [regex]$Regex_H2_Content = '(?is)(?<=<\/a>)(.*?)(?=<\/h2>)'
    # Get module change log from GitHub page
    $ReleaseNotesPage = Invoke-WebRequest -Uri:($ModuleChangeLogUrl) -UseBasicParsing
    $ReleaseNotesPageContent = $ReleaseNotesPage.Content
    # Get the body of the GitHub page
    $ReleaseNotes_MarkDownBody = ($ReleaseNotesPageContent | Select-String -Pattern:($Regex_Article)).Matches.Value
    ForEach ($ReleaseNote In $ReleaseNotes_MarkDownBody -split ($Regex_H2_Start))
    {
        $ReleaseNote_Object = New-Object -TypeName:('PSCustomObject')
        $ReleaseNote_VersionNumber = ($ReleaseNote | Select-String -Pattern:($Regex_H2_Content)).Matches.Value
        ForEach ($ReleaseNote_Section In $ReleaseNote -split ($Regex_H4_Start))
        {
            # Get matching value
            $ReleaseNote_Section_Header = ($ReleaseNote_Section | Select-String -Pattern:($Regex_H4_Content)).Matches.Value
            $ReleaseNote_Section_Body = ($ReleaseNote_Section | Select-String -Pattern:($Regex_H4_Body)).Matches.Value
            $ReleaseNote_Section_Body_HtmlTags = ($ReleaseNote_Section_Body | Select-String -AllMatches -Pattern:($Regex_HtmlTags)).Matches.Value
            If (-not [System.String]::IsNullOrEmpty($ReleaseNote_Section_Header))
            {
                # Validate the section headers found are in the expected list
                If ($ReleaseNote_Section_Header -in $ReleaseNotes_Headers)
                {
                    # Remove html tags from the body content
                    ForEach ($ReleaseNote_Section_Body_HtmlTag In $ReleaseNote_Section_Body_HtmlTags)
                    {
                        $ReleaseNote_Section_Body = ($ReleaseNote_Section_Body.Replace($ReleaseNote_Section_Body_HtmlTag, '')).Trim()
                    }
                    Add-Member -InputObject:($ReleaseNote_Object) -MemberType:('NoteProperty') -Name:([System.String]$ReleaseNote_Section_Header) -Value:([System.String]$ReleaseNote_Section_Body)
                }
                Else
                {
                    Write-Error ('The Header found is not in the list of expected headers: ' + $ReleaseNote_Section_Header + ' -notin ' + ($ReleaseNotes_Headers -join (', ')))
                }
            }
        }
        If (-not [System.String]::IsNullOrEmpty($ReleaseNote_Object))
        {
            # Add the version number
            Add-Member -InputObject:($ReleaseNote_Object) -MemberType:('NoteProperty') -Name:('VERSION') -Value:([System.String]$ReleaseNote_VersionNumber)
            Add-Member -InputObject:($OutputObject) -MemberType:('NoteProperty') -Name:('GitHubModuleChangeLogUrl') -Value:([System.String]$ModuleChangeLogUrl)
            $OutputObject += $ReleaseNote_Object
        }
    }
    Return $OutputObject
}