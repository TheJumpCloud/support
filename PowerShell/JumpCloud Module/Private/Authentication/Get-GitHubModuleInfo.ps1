Function Get-GitHubModuleInfo
{
    Param(
        $GitHubModuleInfoURL = 'https://github.com/TheJumpCloud/support/blob/master/PowerShell/ModuleBanner.md'
    )
    # Define expected labels to find
    $Labels = @('Latest Version', 'Banner Current', 'Banner Old')
    # Define regex patterns
    [regex]$RegexPattern_Label = '(?is)(?<=<\/a>)(.*?)(?=<\/h4>)'
    [regex]$RegexPattern_Body = '(?is)(?<=<\/h4>)(.*?)($)'
    [regex]$RegexPattern_HtmlTags = '(<)(.*?)(>)'
    # Update security protocol
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls, [System.Net.SecurityProtocolType]::Tls12
    # Get latest module information
    $GitHubModuleInfo = Invoke-WebRequest -Uri:($GitHubModuleInfoURL) -UseBasicParsing
    $GitHubModuleInfoContent = $GitHubModuleInfo.Content
    $OutputObject = New-Object -TypeName:('PSObject ')
    # Get the body of the GitHub page
    $MarkDownBody = ($GitHubModuleInfoContent | Select-String -Pattern:('(?is)(?<=<article class="markdown-body entry-content p-3 p-md-6" itemprop="text">)(.*?)(?=<\/article>)')).Matches.Value
    ForEach ($Header In $MarkDownBody.Split('<h4>'))
    {
        # Get matching value
        $MatchedValue_Label = ($Header | Select-String -Pattern:($RegexPattern_Label)).Matches.Value
        $MatchedValue_Body = ($Header | Select-String -Pattern:($RegexPattern_Body)).Matches.Value
        $MatchedValue_HtmlTags = ($MatchedValue_Body | Select-String -AllMatches -Pattern:($RegexPattern_HtmlTags)).Matches.Value
        If (-not [System.String]::IsNullOrEmpty($MatchedValue_Body))
        {
            If ($MatchedValue_Label -in $Labels)
            {
                # Format the value
                ForEach ($MatchedValue_HtmlTag In $MatchedValue_HtmlTags)
                {
                    $MatchedValue_Body = ($MatchedValue_Body.Replace($MatchedValue_HtmlTag, '')).Trim()
                }
                Add-Member -InputObject:($OutputObject) -MemberType:('NoteProperty') -Name:($MatchedValue_Label.Replace(' ', '')) -Value:($MatchedValue_Body)
            }
            Else
            {
                Write-Error ('The label found is not in the list of expected labels: ' + $MatchedValue_Label + ' -notin ' + $Labels)
            }
        }
    }
    Return $OutputObject
}