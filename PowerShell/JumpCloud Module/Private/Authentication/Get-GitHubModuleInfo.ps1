Function Get-GitHubModuleInfo
{
    $GitHubModuleInfoURL = 'https://github.com/TheJumpCloud/support/blob/master/PowerShell/ModuleBanner.md'
    # Update security protocol
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls, [System.Net.SecurityProtocolType]::Tls12
    # Get latest module information
    $GitHubModuleInfo = Invoke-WebRequest -Uri:($GitHubModuleInfoURL) -UseBasicParsing -UserAgent:(Get-JCUserAgent) | Select-Object RawContent
    Return [PSCustomObject]@{
        'CurrentBanner' = ((((($GitHubModuleInfo -split "</a>Banner Current</h4>")[1]) -split "<pre><code>")[1]) -split "`n")[0]
        'OldBanner'     = ((((($GitHubModuleInfo -split "</a>Banner Old</h4>")[1]) -split "<pre><code>")[1]) -split "`n")[0]
        'LatestVersion' = ((((($GitHubModuleInfo -split "</a>Latest Version</h4>")[1]) -split "<pre><code>")[1]) -split "`n")[0]
    }
}