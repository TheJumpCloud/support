Function Get-GitHubModuleInfo
{
    Param(
        $GitHubModuleBannerUrl = 'https://github.com/TheJumpCloud/support/blob/master/PowerShell/ModuleBanner.md'
        # , $GitHubModuleReleaseNotesUrl = 'https://git.io/jc-pwsh-releasenotes'
        , $GitHubModuleReleaseNotesUrl = 'https://github.com/TheJumpCloud/support/blob/JumpCloudModule_1.13.4/PowerShell/ModuleChangelog.md'
    )
    # Update security protocol
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls, [System.Net.SecurityProtocolType]::Tls12
    # Build output object
    $OutputObject = New-Object -TypeName:('PSObject')
    [regex]$RegexPattern_Article = '(?is)(?<=<article class="markdown-body entry-content p-3 p-md-6" itemprop="text">)(.*?)(?=<\/article>)'

    # Get module banner from GitHub page
    # Define expected Headers to find
    $ModuleBanner_Headers = @('Latest Version', 'Banner Current', 'Banner Old')
    $ReleaseNotes_Headers = @('Release Date', 'Release Notes', 'Features', 'Improvements', 'Bug Fixes')
    # Define regex patterns
    [regex]$RegexPattern_Header = '(?is)(?<=<\/a>)(.*?)(?=<\/h4>)'
    [regex]$RegexPattern_Body = '(?is)(?<=<\/h4>)(.*?)($)'
    [regex]$RegexPattern_HtmlTags = '(<)(.*?)(>)'
    # Get latest module information
    $ModuleBanner = Invoke-WebRequest -Uri:($GitHubModuleBannerUrl) -UseBasicParsing
    $ModuleBannerContent = $ModuleBanner.Content
    # Get the body of the GitHub page
    $MarkDownBody_ModuleBanner = ($ModuleBannerContent | Select-String -Pattern:($RegexPattern_Article)).Matches.Value
    ForEach ($Section_ModuleBanner In $MarkDownBody_ModuleBanner -split ('<h4>'))
    {
        # Get matching value
        $MatchedValue_ModuleBanner_Header = ($Section_ModuleBanner | Select-String -Pattern:($RegexPattern_Header)).Matches.Value
        $MatchedValue_ModuleBanner_Body = ($Section_ModuleBanner | Select-String -Pattern:($RegexPattern_Body)).Matches.Value
        $MatchedValue_ModuleBanner_HtmlTags = ($MatchedValue_ModuleBanner_Body | Select-String -AllMatches -Pattern:($RegexPattern_HtmlTags)).Matches.Value
        If (-not [System.String]::IsNullOrEmpty($MatchedValue_ModuleBanner_Body))
        {
            If ($MatchedValue_ModuleBanner_Header -in $ModuleBanner_Headers)
            {
                # Format the value
                ForEach ($MatchedValue_ModuleBanner_HtmlTag In $MatchedValue_ModuleBanner_HtmlTags)
                {
                    $MatchedValue_ModuleBanner_Body = ($MatchedValue_ModuleBanner_Body.Replace($MatchedValue_ModuleBanner_HtmlTag, '')).Trim()
                }
                Add-Member -InputObject:($OutputObject) -MemberType:('NoteProperty') -Name:($MatchedValue_ModuleBanner_Header) -Value:([System.String]$MatchedValue_ModuleBanner_Body)
            }
            Else
            {
                Write-Error ('The Header found is not in the list of expected headers: ' + $MatchedValue_ModuleBanner_Header + ' -notin ' + ($ModuleBanner_Headers -join (', ')))
            }
        }
    }
    # Get release notes from GitHub page
    $ReleaseNotes = Invoke-WebRequest -Uri:($GitHubModuleReleaseNotesUrl) -UseBasicParsing
    $ReleaseNotesContent = $ReleaseNotes.Content
    $MarkDownBody_ReleaseNotes = ($ReleaseNotesContent | Select-String -Pattern:($RegexPattern_Article)).Matches.Value
    $VersionReleaseNotes = ($MarkDownBody_ReleaseNotes -split ('<h2>') | Select-String -Pattern:('</a>' + $OutputObject.'Latest Version' + '</h2>'))
    $ReleaseNotes_VersionNumber = $VersionReleaseNotes.Matches.Value
    $MarkDownBodyContent_ReleaseNotes = $VersionReleaseNotes.Line
    ForEach ($Section_ReleaseNotes In $MarkDownBodyContent_ReleaseNotes -split ('<h4>'))
    {
        # Get matching value
        $MatchedValue_ReleaseNotes_Header = ($Section_ReleaseNotes | Select-String -Pattern:($RegexPattern_Header)).Matches.Value
        $MatchedValue_ReleaseNotes_Body = ($Section_ReleaseNotes | Select-String -Pattern:($RegexPattern_Body)).Matches.Value
        $MatchedValue_ReleaseNotes_Body_HtmlTags = ($MatchedValue_ReleaseNotes_Body | Select-String -AllMatches -Pattern:($RegexPattern_HtmlTags)).Matches.Value
        $MatchedValue_ReleaseNotes_Version = $ReleaseNotes_VersionNumber
        $MatchedValue_ReleaseNotes_Version_HtmlTags = ($ReleaseNotes_VersionNumber | Select-String -AllMatches -Pattern:($RegexPattern_HtmlTags)).Matches.Value
        If (-not [System.String]::IsNullOrEmpty($MatchedValue_ReleaseNotes_Header))
        {
            If ($MatchedValue_ReleaseNotes_Header -in $ReleaseNotes_Headers)
            {
                # Parse the version number
                ForEach ($MatchedValue_ReleaseNotes_Version_HtmlTag In $MatchedValue_ReleaseNotes_Version_HtmlTags)
                {
                    $MatchedValue_ReleaseNotes_Version = ($MatchedValue_ReleaseNotes_Version.Replace($MatchedValue_ReleaseNotes_Version_HtmlTag, '')).Trim()
                }
                # Parse the release notes
                ForEach ($MatchedValue_ReleaseNotes_Body_HtmlTag In $MatchedValue_ReleaseNotes_Body_HtmlTags)
                {
                    $MatchedValue_ReleaseNotes_Body = ($MatchedValue_ReleaseNotes_Body.Replace($MatchedValue_ReleaseNotes_Body_HtmlTag, '')).Trim()
                }
                # Validate that your pulling the correct version release notes
                If ($MatchedValue_ReleaseNotes_Version -eq $OutputObject.'Latest Version')
                {
                    Add-Member -InputObject:($OutputObject) -MemberType:('NoteProperty') -Name:($MatchedValue_ReleaseNotes_Header) -Value:([System.String]$MatchedValue_ReleaseNotes_Body)
                }
                Else
                {
                    Write-Error ('Unable to find latest version within release notes.')
                }
            }
            Else
            {
                Write-Error ('The Header found is not in the list of expected headers: ' + $MatchedValue_ReleaseNotes_Header + ' -notin ' + ($ReleaseNotes_Headers -join (', ')))
            }
        }
    }
    Add-Member -InputObject:($OutputObject) -MemberType:('NoteProperty') -Name:('ModuleBannerUrl') -Value:($GitHubModuleBannerUrl)
    Add-Member -InputObject:($OutputObject) -MemberType:('NoteProperty') -Name:('ReleaseNotesUrl') -Value:($GitHubModuleReleaseNotesUrl)
    Return $OutputObject
}