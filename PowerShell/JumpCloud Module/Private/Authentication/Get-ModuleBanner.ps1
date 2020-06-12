Function Get-ModuleBanner
{
    Param(
        $ModuleBannerUrl = 'https://github.com/TheJumpCloud/support/blob/master/PowerShell/ModuleBanner.md'
    )
    # Update security protocol
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12, [System.Net.SecurityProtocolType]::Tls
    # Build output object
    $OutputObject = New-Object -TypeName:('PSCustomObject')
    # Define expected Headers to find
    $ModuleBanner_Headers = @('Latest Version', 'Banner Current', 'Banner Old')
    # Define regex patterns
    [regex]$Regex_HtmlTags = '(<)(.*?)(>)'
    [regex]$Regex_Article = '(?is)(?<=<article class="markdown-body entry-content" itemprop="text">)(.*?)(?=<\/article>)'
    [regex]$Regex_H4_Start = '<h4>'
    [regex]$Regex_H4_Content = '(?is)(?<=<\/a>)(.*?)(?=<\/h4>)'
    [regex]$Regex_H4_Body = '(?is)(?<=<\/h4>)(.*?)($)'
    # Get module banner from GitHub page
    $ModuleBannerPage = Invoke-WebRequest -Uri:($ModuleBannerUrl) -UseBasicParsing
    $ModuleBannerPageContent = $ModuleBannerPage.Content
    # Get the body of the GitHub page
    $ModuleBanner_MarkDownBody = ($ModuleBannerPageContent | Select-String -Pattern:($Regex_Article)).Matches.Value
    ForEach ($ModuleBanner_Section In $ModuleBanner_MarkDownBody -split ($Regex_H4_Start))
    {
        # Get matching value
        $ModuleBanner_Section_Header = ($ModuleBanner_Section | Select-String -Pattern:($Regex_H4_Content)).Matches.Value
        $ModuleBanner_Section_Body = ($ModuleBanner_Section | Select-String -Pattern:($Regex_H4_Body)).Matches.Value
        $ModuleBanner_Section_HtmlTags = ($ModuleBanner_Section_Body | Select-String -AllMatches -Pattern:($Regex_HtmlTags)).Matches.Value
        If (-not [System.String]::IsNullOrEmpty($ModuleBanner_Section_Header))
        {
            # Validate the section headers found are in the expected list
            If ($ModuleBanner_Section_Header -in $ModuleBanner_Headers)
            {
                # Remove html tags from the body content
                ForEach ($ModuleBanner_Section_HtmlTag In $ModuleBanner_Section_HtmlTags)
                {
                    $ModuleBanner_Section_Body = ($ModuleBanner_Section_Body.Replace($ModuleBanner_Section_HtmlTag, '')).Trim()
                }
                Add-Member -InputObject:($OutputObject) -MemberType:('NoteProperty') -Name:([System.String]$ModuleBanner_Section_Header) -Value:([System.String]$ModuleBanner_Section_Body)
            }
            Else
            {
                Write-Error ('The Header found is not in the list of expected headers: ' + $ModuleBanner_Section_Header + ' -notin ' + ($ModuleBanner_Headers -join (', ')))
            }
        }
    }
    Add-Member -InputObject:($OutputObject) -MemberType:('NoteProperty') -Name:('GitHubModuleBannerUrl') -Value:([System.String]$ModuleBannerUrl)
    Return $OutputObject
}